import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';
import '../../../appointment/domain/entities/appointment_entity.dart';
import '../../../appointment/domain/repositories/appointment_repository.dart';
import '../../../services/domain/repositories/service_repository.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import '../entities/available_time_slot_entity.dart';

/// UseCase para obter horários disponíveis de um profissional
/// 
/// Calcula os slots de tempo disponíveis considerando:
/// - Horários de trabalho do profissional
/// - Agendamentos existentes
/// - Duração do serviço selecionado
/// - Intervalos entre slots
class GetAvailableTimeSlotsUseCase {
  final UserProfileRepository _userProfileRepository;
  final AppointmentRepository _appointmentRepository;
  final ServiceRepository _serviceRepository;

  GetAvailableTimeSlotsUseCase({
    required UserProfileRepository userProfileRepository,
    required AppointmentRepository appointmentRepository,
    required ServiceRepository serviceRepository,
  }) : _userProfileRepository = userProfileRepository,
       _appointmentRepository = appointmentRepository,
       _serviceRepository = serviceRepository;

  /// Executa o cálculo de horários disponíveis
  /// 
  /// [professionalId] - ID do profissional
  /// [date] - Data para calcular disponibilidade
  /// [serviceId] - ID do serviço (opcional, se não informado usa duração padrão)
  /// [intervalMinutes] - Intervalo entre slots em minutos (padrão: 30)
  /// [minLeadTimeHours] - Tempo mínimo de antecedência em horas (padrão: 2)
  /// [maxAdvanceDays] - Máximo de dias de antecedência (padrão: 30)
  Future<Either<Failure, List<AvailableTimeSlotEntity>>> call({
    required String professionalId,
    required DateTime date,
    String? serviceId,
    int intervalMinutes = 30,
    int minLeadTimeHours = 2,
    int maxAdvanceDays = 30,
  }) async {
    try {
      // Validar parâmetros
      final validationResult = _validateParameters(
        date: date,
        minLeadTimeHours: minLeadTimeHours,
        maxAdvanceDays: maxAdvanceDays,
      );
      
      if (validationResult != null) {
        return Left(validationResult);
      }

      // 1. Obter perfil do profissional
      final professionalResult = await _userProfileRepository.getUserProfileByUserId(professionalId);
      final professional = professionalResult.fold(
        (failure) => null,
        (profile) => profile,
      );

      if (professional == null) {
        return Left(ServerFailure(message: 'Profissional não encontrado'));
      }

      if (!professional.isProfessional) {
        return Left(ServerFailure(message: 'Usuário não é um profissional'));
      }

      // 2. Obter duração do serviço
      int serviceDuration = 60; // Duração padrão em minutos
      if (serviceId != null) {
        final serviceResult = await _serviceRepository.getService(serviceId);
        serviceResult.fold(
          (failure) => null,
          (service) => serviceDuration = service.duration,
        );
      }

      // 3. Obter horários de trabalho do profissional
      final workingHours = _parseWorkingHours(professional.workingHours, date);
      if (workingHours.isEmpty) {
        return Right([]); // Profissional não trabalha neste dia
      }

      // 4. Obter agendamentos existentes para a data
      final appointmentsResult = await _appointmentRepository.getAppointmentsByDateRange(
        date,
        DateTime(date.year, date.month, date.day, 23, 59, 59),
        professionalId: professionalId,
      );

      final existingAppointments = appointmentsResult.fold(
        (failure) => <AppointmentEntity>[],
        (appointments) => appointments,
      );

      // 5. Calcular slots disponíveis
      final availableSlots = _calculateAvailableSlots(
        workingHours: workingHours,
        existingAppointments: existingAppointments,
        serviceDuration: serviceDuration,
        intervalMinutes: intervalMinutes,
        professionalId: professionalId,
        date: date,
        minLeadTimeHours: minLeadTimeHours,
      );

      return Right(availableSlots);
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao calcular horários disponíveis: $e'));
    }
  }

  /// Valida os parâmetros de entrada
  Failure? _validateParameters({
    required DateTime date,
    required int minLeadTimeHours,
    required int maxAdvanceDays,
  }) {
    final now = DateTime.now();
    final minDate = now.add(Duration(hours: minLeadTimeHours));
    final maxDate = now.add(Duration(days: maxAdvanceDays));

    if (date.isBefore(minDate)) {
      return ServerFailure(
        message: 'Não é possível agendar com menos de $minLeadTimeHours horas de antecedência',
      );
    }

    if (date.isAfter(maxDate)) {
      return ServerFailure(
        message: 'Não é possível agendar com mais de $maxAdvanceDays dias de antecedência',
      );
    }

    return null;
  }

  /// Converte horários de trabalho do banco para lista de intervalos
  List<TimeRange> _parseWorkingHours(Map<String, dynamic>? workingHours, DateTime date) {
    if (workingHours == null) return [];

    final dayOfWeek = _getDayOfWeekKey(date.weekday);
    final dayData = workingHours[dayOfWeek] as Map<String, dynamic>?;
    
    if (dayData == null || dayData['enabled'] != true) {
      return [];
    }

    final startTime = dayData['start'] as String?;
    final endTime = dayData['end'] as String?;

    if (startTime == null || endTime == null) {
      return [];
    }

    return [TimeRange(start: startTime, end: endTime)];
  }

  /// Converte número do dia da semana para chave do banco
  String _getDayOfWeekKey(int weekday) {
    const dayKeys = {
      1: 'monday',
      2: 'tuesday', 
      3: 'wednesday',
      4: 'thursday',
      5: 'friday',
      6: 'saturday',
      7: 'sunday',
    };
    return dayKeys[weekday] ?? 'monday';
  }

  /// Calcula os slots disponíveis baseado nos horários de trabalho e agendamentos
  List<AvailableTimeSlotEntity> _calculateAvailableSlots({
    required List<TimeRange> workingHours,
    required List<AppointmentEntity> existingAppointments,
    required int serviceDuration,
    required int intervalMinutes,
    required String professionalId,
    required DateTime date,
    required int minLeadTimeHours,
  }) {
    final availableSlots = <AvailableTimeSlotEntity>[];
    final now = DateTime.now();
    final minTime = now.add(Duration(hours: minLeadTimeHours));

    for (final workingRange in workingHours) {
      final startTime = _parseTimeString(workingRange.start, date);
      final endTime = _parseTimeString(workingRange.end, date);

      // Ajustar horário de início se necessário
      final actualStartTime = startTime.isBefore(minTime) ? minTime : startTime;

      // Gerar slots potenciais
      var currentTime = actualStartTime;
      while (currentTime.add(Duration(minutes: serviceDuration)).isBefore(endTime) ||
             currentTime.add(Duration(minutes: serviceDuration)).isAtSameMomentAs(endTime)) {
        
        final slotEndTime = currentTime.add(Duration(minutes: serviceDuration));
        
        // Verificar se o slot não conflita com agendamentos existentes
        if (!_hasTimeConflict(currentTime, slotEndTime, existingAppointments)) {
          final slot = AvailableTimeSlotEntity(
            id: '${professionalId}_${currentTime.millisecondsSinceEpoch}',
            startTime: currentTime,
            endTime: slotEndTime,
            durationMinutes: serviceDuration,
            professionalId: professionalId,
          );
          availableSlots.add(slot);
        }

        // Avançar para o próximo slot
        currentTime = currentTime.add(Duration(minutes: intervalMinutes));
      }
    }

    return availableSlots;
  }

  /// Converte string de tempo (HH:mm) para DateTime
  DateTime _parseTimeString(String timeString, DateTime date) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  /// Verifica se um slot de tempo conflita com agendamentos existentes
  bool _hasTimeConflict(DateTime startTime, DateTime endTime, List<AppointmentEntity> appointments) {
    for (final appointment in appointments) {
      // Considerar apenas agendamentos confirmados ou pendentes
      if (appointment.status != AppointmentStatus.confirmed && 
          appointment.status != AppointmentStatus.pending) {
        continue;
      }

      final appointmentEndTime = appointment.appointmentDateTime.add(
        Duration(minutes: appointment.estimatedDuration),
      );

      // Verificar sobreposição
      if (startTime.isBefore(appointmentEndTime) && endTime.isAfter(appointment.appointmentDateTime)) {
        return true;
      }
    }
    return false;
  }
}

/// Classe auxiliar para representar um intervalo de tempo
class TimeRange {
  final String start;
  final String end;

  const TimeRange({
    required this.start,
    required this.end,
  });

  @override
  String toString() => 'TimeRange(start: $start, end: $end)';
}

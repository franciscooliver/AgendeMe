import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';
import '../entities/appointment_entity.dart';

/// Repositório abstrato para operações de agendamentos
/// 
/// Define os contratos para CRUD operations com agendamentos no Firestore
/// Implementação concreta fica na camada data
abstract class AppointmentRepository {
  
  /// Busca um agendamento pelo ID
  /// 
  /// [id] - ID único do agendamento
  /// Retorna [Right] com AppointmentEntity se encontrado
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, AppointmentEntity>> getAppointment(String id);

  /// Cria um novo agendamento
  /// 
  /// [appointment] - Entidade do agendamento a ser criado
  /// Retorna [Right] com AppointmentEntity criado
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, AppointmentEntity>> createAppointment(
    AppointmentEntity appointment,
  );

  /// Atualiza um agendamento existente
  /// 
  /// [appointment] - Entidade do agendamento com dados atualizados
  /// Retorna [Right] com AppointmentEntity atualizado
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, AppointmentEntity>> updateAppointment(
    AppointmentEntity appointment,
  );

  /// Remove um agendamento (soft delete - marca como cancelado)
  /// 
  /// [id] - ID único do agendamento a ser cancelado
  /// [reason] - Motivo do cancelamento (opcional)
  /// Retorna [Right] com void se cancelado com sucesso
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, void>> deleteAppointment(
    String id, {
    String? reason,
  });

  /// Remove um agendamento permanentemente do banco
  /// 
  /// [id] - ID único do agendamento a ser removido permanentemente
  /// Retorna [Right] com void se removido com sucesso
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, void>> permanentDeleteAppointment(String id);

  /// Busca todos os agendamentos de um profissional
  /// 
  /// [professionalId] - ID do profissional
  /// [includeFinished] - Se deve incluir agendamentos finalizados
  /// [limit] - Número máximo de agendamentos a retornar
  /// [offset] - Número de agendamentos a pular (para paginação)
  /// Retorna [Right] com lista de AppointmentEntity
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<AppointmentEntity>>> getAppointmentsByProfessional(
    String professionalId, {
    bool includeFinished = false,
    int limit = 20,
    int offset = 0,
  });

  /// Busca todos os agendamentos de um cliente
  /// 
  /// [clientId] - ID do cliente
  /// [includeFinished] - Se deve incluir agendamentos finalizados
  /// [limit] - Número máximo de agendamentos a retornar
  /// [offset] - Número de agendamentos a pular (para paginação)
  /// Retorna [Right] com lista de AppointmentEntity
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<AppointmentEntity>>> getAppointmentsByClient(
    String clientId, {
    bool includeFinished = false,
    int limit = 20,
    int offset = 0,
  });

  /// Busca agendamentos por faixa de datas
  /// 
  /// [startDate] - Data inicial da busca
  /// [endDate] - Data final da busca
  /// [professionalId] - ID do profissional (opcional - filtra por profissional)
  /// [clientId] - ID do cliente (opcional - filtra por cliente)
  /// [includeFinished] - Se deve incluir agendamentos finalizados
  /// Retorna [Right] com lista de AppointmentEntity
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<AppointmentEntity>>> getAppointmentsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? professionalId,
    String? clientId,
    bool includeFinished = false,
  });

  /// Busca agendamentos por status
  /// 
  /// [status] - Status dos agendamentos a buscar
  /// [professionalId] - ID do profissional (opcional - filtra por profissional)
  /// [clientId] - ID do cliente (opcional - filtra por cliente)
  /// [limit] - Número máximo de agendamentos a retornar
  /// Retorna [Right] com lista de AppointmentEntity
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<AppointmentEntity>>> getAppointmentsByStatus(
    AppointmentStatus status, {
    String? professionalId,
    String? clientId,
    int limit = 20,
  });

  /// Busca próximos agendamentos de um usuário (cliente ou profissional)
  /// 
  /// [userId] - ID do usuário
  /// [isProfessional] - Se o usuário é profissional (true) ou cliente (false)
  /// [limit] - Número máximo de agendamentos a retornar
  /// Retorna [Right] com lista de AppointmentEntity ordenados por data
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<AppointmentEntity>>> getUpcomingAppointments(
    String userId, {
    required bool isProfessional,
    int limit = 10,
  });

  /// Busca agendamentos de hoje para um profissional
  /// 
  /// [professionalId] - ID do profissional
  /// Retorna [Right] com lista de AppointmentEntity do dia atual
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<AppointmentEntity>>> getTodayAppointments(
    String professionalId,
  );

  /// Busca agendamentos de uma semana específica
  /// 
  /// [startOfWeek] - Primeiro dia da semana (DateTime)
  /// [professionalId] - ID do profissional (opcional)
  /// [clientId] - ID do cliente (opcional)
  /// Retorna [Right] com lista de AppointmentEntity da semana
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<AppointmentEntity>>> getWeekAppointments(
    DateTime startOfWeek, {
    String? professionalId,
    String? clientId,
  });

  /// Busca agendamentos de um mês específico
  /// 
  /// [year] - Ano
  /// [month] - Mês (1-12)
  /// [professionalId] - ID do profissional (opcional)
  /// [clientId] - ID do cliente (opcional)
  /// Retorna [Right] com lista de AppointmentEntity do mês
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<AppointmentEntity>>> getMonthAppointments(
    int year,
    int month, {
    String? professionalId,
    String? clientId,
  });

  /// Verifica conflitos de horário para um profissional
  /// 
  /// [professionalId] - ID do profissional
  /// [appointmentDateTime] - Data e hora do agendamento
  /// [duration] - Duração em minutos do serviço
  /// [excludeAppointmentId] - ID do agendamento a excluir da verificação (para edição)
  /// Retorna [Right] com true se há conflito, false caso contrário
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, bool>> hasTimeConflict(
    String professionalId,
    DateTime appointmentDateTime,
    int duration, {
    String? excludeAppointmentId,
  });

  /// Busca horários disponíveis para um profissional em um dia
  /// 
  /// [professionalId] - ID do profissional
  /// [date] - Data para verificar disponibilidade
  /// [serviceDuration] - Duração do serviço em minutos
  /// [workingHoursStart] - Horário de início do trabalho (ex: "09:00")
  /// [workingHoursEnd] - Horário de fim do trabalho (ex: "18:00")
  /// [intervalMinutes] - Intervalo entre horários em minutos (padrão: 30)
  /// Retorna [Right] com lista de horários disponíveis (DateTime)
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<DateTime>>> getAvailableTimeSlots(
    String professionalId,
    DateTime date,
    int serviceDuration, {
    required String workingHoursStart,
    required String workingHoursEnd,
    int intervalMinutes = 30,
  });

  /// Confirma um agendamento pendente
  /// 
  /// [appointmentId] - ID do agendamento a ser confirmado
  /// Retorna [Right] com AppointmentEntity confirmado
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, AppointmentEntity>> confirmAppointment(
    String appointmentId,
  );

  /// Cancela um agendamento
  /// 
  /// [appointmentId] - ID do agendamento a ser cancelado
  /// [reason] - Motivo do cancelamento
  /// [cancelledBy] - Quem cancelou ('client' ou 'professional')
  /// Retorna [Right] com AppointmentEntity cancelado
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, AppointmentEntity>> cancelAppointment(
    String appointmentId,
    String reason, {
    required String cancelledBy,
  });

  /// Marca um agendamento como concluído
  /// 
  /// [appointmentId] - ID do agendamento a ser marcado como concluído
  /// [professionalNotes] - Observações do profissional (opcional)
  /// Retorna [Right] com AppointmentEntity concluído
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, AppointmentEntity>> completeAppointment(
    String appointmentId, {
    String? professionalNotes,
  });

  /// Marca um agendamento como "não compareceu"
  /// 
  /// [appointmentId] - ID do agendamento
  /// Retorna [Right] com AppointmentEntity marcado como no-show
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, AppointmentEntity>> markAsNoShow(String appointmentId);

  /// Reagenda um agendamento existente
  /// 
  /// [appointmentId] - ID do agendamento a ser reagendado
  /// [newDateTime] - Nova data e hora
  /// [reason] - Motivo do reagendamento (opcional)
  /// Retorna [Right] com AppointmentEntity reagendado
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, AppointmentEntity>> rescheduleAppointment(
    String appointmentId,
    DateTime newDateTime, {
    String? reason,
  });

  /// Obtém estatísticas de agendamentos de um profissional
  /// 
  /// [professionalId] - ID do profissional
  /// [startDate] - Data inicial para as estatísticas (opcional)
  /// [endDate] - Data final para as estatísticas (opcional)
  /// Retorna [Right] com Map contendo estatísticas
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, AppointmentStatistics>> getAppointmentStatistics(
    String professionalId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Verifica se um agendamento existe
  /// 
  /// [id] - ID do agendamento
  /// Retorna [Right] com true se existe, false caso contrário
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, bool>> appointmentExists(String id);
}

/// Classe para estatísticas dos agendamentos
class AppointmentStatistics {
  final int totalAppointments;
  final int pendingAppointments;
  final int confirmedAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final int noShowAppointments;
  final double totalRevenue;
  final double averageRevenue;
  final Map<String, int> appointmentsByStatus;
  final Map<String, int> appointmentsByDay;
  final Map<String, double> revenueByMonth;
  final DateTime? lastAppointmentDate;
  final DateTime? nextAppointmentDate;

  const AppointmentStatistics({
    required this.totalAppointments,
    required this.pendingAppointments,
    required this.confirmedAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.noShowAppointments,
    required this.totalRevenue,
    required this.averageRevenue,
    required this.appointmentsByStatus,
    required this.appointmentsByDay,
    required this.revenueByMonth,
    this.lastAppointmentDate,
    this.nextAppointmentDate,
  });

  AppointmentStatistics copyWith({
    int? totalAppointments,
    int? pendingAppointments,
    int? confirmedAppointments,
    int? completedAppointments,
    int? cancelledAppointments,
    int? noShowAppointments,
    double? totalRevenue,
    double? averageRevenue,
    Map<String, int>? appointmentsByStatus,
    Map<String, int>? appointmentsByDay,
    Map<String, double>? revenueByMonth,
    DateTime? lastAppointmentDate,
    DateTime? nextAppointmentDate,
  }) {
    return AppointmentStatistics(
      totalAppointments: totalAppointments ?? this.totalAppointments,
      pendingAppointments: pendingAppointments ?? this.pendingAppointments,
      confirmedAppointments: confirmedAppointments ?? this.confirmedAppointments,
      completedAppointments: completedAppointments ?? this.completedAppointments,
      cancelledAppointments: cancelledAppointments ?? this.cancelledAppointments,
      noShowAppointments: noShowAppointments ?? this.noShowAppointments,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      averageRevenue: averageRevenue ?? this.averageRevenue,
      appointmentsByStatus: appointmentsByStatus ?? this.appointmentsByStatus,
      appointmentsByDay: appointmentsByDay ?? this.appointmentsByDay,
      revenueByMonth: revenueByMonth ?? this.revenueByMonth,
      lastAppointmentDate: lastAppointmentDate ?? this.lastAppointmentDate,
      nextAppointmentDate: nextAppointmentDate ?? this.nextAppointmentDate,
    );
  }
}

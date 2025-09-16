import '../../../../core/core.dart';

/// Entidade que representa um slot de tempo disponível para agendamento
/// 
/// Contém informações sobre um horário específico onde um profissional
/// está disponível para realizar um serviço
class AvailableTimeSlotEntity extends BaseEntity {
  /// Data e hora de início do slot
  final DateTime startTime;
  
  /// Data e hora de fim do slot
  final DateTime endTime;
  
  /// Duração do slot em minutos
  final int durationMinutes;
  
  /// ID do profissional
  final String professionalId;
  
  /// ID do serviço (opcional, se o slot foi calculado para um serviço específico)
  final String? serviceId;
  
  /// Flag indicando se o slot está disponível
  final bool isAvailable;
  
  /// Motivo da indisponibilidade (se aplicável)
  final String? unavailabilityReason;

  const AvailableTimeSlotEntity({
    required super.id,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.professionalId,
    this.serviceId,
    this.isAvailable = true,
    this.unavailabilityReason,
  });

  @override
  List<Object?> get props => [
        id,
        startTime,
        endTime,
        durationMinutes,
        professionalId,
        serviceId,
        isAvailable,
        unavailabilityReason,
      ];

  @override
  AvailableTimeSlotEntity copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    String? professionalId,
    String? serviceId,
    bool? isAvailable,
    String? unavailabilityReason,
  }) {
    return AvailableTimeSlotEntity(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      professionalId: professionalId ?? this.professionalId,
      serviceId: serviceId ?? this.serviceId,
      isAvailable: isAvailable ?? this.isAvailable,
      unavailabilityReason: unavailabilityReason ?? this.unavailabilityReason,
    );
  }

  /// Retorna o horário formatado como string (ex: "14:30")
  String get formattedTime {
    final hour = startTime.hour.toString().padLeft(2, '0');
    final minute = startTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Retorna a duração formatada como string (ex: "1h 30min")
  String get formattedDuration {
    if (durationMinutes < 60) {
      return '${durationMinutes}min';
    } else {
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      if (minutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${minutes}min';
      }
    }
  }

  /// Verifica se o slot está no passado
  bool get isPast => startTime.isBefore(DateTime.now());

  /// Verifica se o slot é hoje
  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
           startTime.month == now.month &&
           startTime.day == now.day;
  }

  /// Verifica se o slot é amanhã
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return startTime.year == tomorrow.year &&
           startTime.month == tomorrow.month &&
           startTime.day == tomorrow.day;
  }

  @override
  String toString() {
    return 'AvailableTimeSlotEntity(id: $id, startTime: $formattedTime, duration: $formattedDuration, available: $isAvailable)';
  }
}

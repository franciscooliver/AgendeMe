import '../../../../core/core.dart';

/// Entidade que representa um agendamento entre um profissional e um cliente
/// 
/// Contém todas as informações necessárias sobre o agendamento,
/// incluindo data/hora, serviço, participantes e status
class AppointmentEntity extends BaseEntity {
  /// ID do profissional responsável pelo atendimento
  final String professionalId;
  
  /// ID do cliente que fez o agendamento
  final String clientId;
  
  /// ID do serviço a ser realizado
  final String serviceId;
  
  /// Data e hora do agendamento
  final DateTime appointmentDateTime;
  
  /// Status atual do agendamento
  final AppointmentStatus status;
  
  /// Observações ou notas sobre o agendamento
  final String? notes;
  
  /// Observações específicas do profissional (privadas)
  final String? professionalNotes;
  
  /// Observações específicas do cliente
  final String? clientNotes;
  
  /// Preço final do serviço no momento do agendamento
  final double price;
  
  /// Duração estimada do serviço em minutos
  final int estimatedDuration;
  
  /// Data de criação do agendamento
  final DateTime createdAt;
  
  /// Data da última atualização
  final DateTime updatedAt;
  
  /// ID do agendamento que foi reagendado (se aplicável)
  final String? rescheduledFromId;
  
  /// Motivo do cancelamento (se aplicável)
  final String? cancellationReason;
  
  /// Data do cancelamento (se aplicável)
  final DateTime? cancelledAt;

  const AppointmentEntity({
    required super.id,
    required this.professionalId,
    required this.clientId,
    required this.serviceId,
    required this.appointmentDateTime,
    required this.price,
    required this.estimatedDuration,
    required this.createdAt,
    required this.updatedAt,
    this.status = AppointmentStatus.pending,
    this.notes,
    this.professionalNotes,
    this.clientNotes,
    this.rescheduledFromId,
    this.cancellationReason,
    this.cancelledAt,
  });

  @override
  List<Object?> get props => [
        id,
        professionalId,
        clientId,
        serviceId,
        appointmentDateTime,
        status,
        notes,
        professionalNotes,
        clientNotes,
        price,
        estimatedDuration,
        createdAt,
        updatedAt,
        rescheduledFromId,
        cancellationReason,
        cancelledAt,
      ];

  @override
  AppointmentEntity copyWith({
    String? id,
    String? professionalId,
    String? clientId,
    String? serviceId,
    DateTime? appointmentDateTime,
    AppointmentStatus? status,
    String? notes,
    String? professionalNotes,
    String? clientNotes,
    double? price,
    int? estimatedDuration,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? rescheduledFromId,
    String? cancellationReason,
    DateTime? cancelledAt,
  }) {
    return AppointmentEntity(
      id: id ?? this.id,
      professionalId: professionalId ?? this.professionalId,
      clientId: clientId ?? this.clientId,
      serviceId: serviceId ?? this.serviceId,
      appointmentDateTime: appointmentDateTime ?? this.appointmentDateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      professionalNotes: professionalNotes ?? this.professionalNotes,
      clientNotes: clientNotes ?? this.clientNotes,
      price: price ?? this.price,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rescheduledFromId: rescheduledFromId ?? this.rescheduledFromId,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  /// Retorna a data do agendamento formatada (dd/MM/yyyy)
  String get formattedDate {
    return '${appointmentDateTime.day.toString().padLeft(2, '0')}/'
           '${appointmentDateTime.month.toString().padLeft(2, '0')}/'
           '${appointmentDateTime.year}';
  }

  /// Retorna o horário do agendamento formatado (HH:mm)
  String get formattedTime {
    return '${appointmentDateTime.hour.toString().padLeft(2, '0')}:'
           '${appointmentDateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Retorna o preço formatado como string em reais
  String get formattedPrice => 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  /// Retorna a duração estimada formatada como string legível
  String get formattedDuration {
    if (estimatedDuration < 60) {
      return '${estimatedDuration}min';
    } else {
      final hours = estimatedDuration ~/ 60;
      final minutes = estimatedDuration % 60;
      if (minutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${minutes}min';
      }
    }
  }

  /// Verifica se o agendamento é hoje
  bool get isToday {
    final now = DateTime.now();
    return appointmentDateTime.year == now.year &&
           appointmentDateTime.month == now.month &&
           appointmentDateTime.day == now.day;
  }

  /// Verifica se o agendamento é no futuro
  bool get isFuture => appointmentDateTime.isAfter(DateTime.now());

  /// Verifica se o agendamento já passou
  bool get isPast => appointmentDateTime.isBefore(DateTime.now());

  /// Verifica se o agendamento pode ser cancelado
  bool get canBeCancelled {
    return status != AppointmentStatus.cancelled &&
           status != AppointmentStatus.completed &&
           isFuture;
  }

  /// Verifica se o agendamento pode ser reagendado
  bool get canBeRescheduled {
    return status == AppointmentStatus.pending ||
           status == AppointmentStatus.confirmed;
  }

  /// Verifica se o agendamento pode ser confirmado
  bool get canBeConfirmed {
    return status == AppointmentStatus.pending && isFuture;
  }

  /// Verifica se o agendamento pode ser marcado como completo
  bool get canBeCompleted {
    return status == AppointmentStatus.confirmed && !isFuture;
  }

  /// Retorna a descrição do status em português
  String get statusDescription => status.description;

  /// Retorna o ícone representativo do status
  String get statusIcon => status.icon;

  /// Retorna a cor representativa do status
  String get statusColor => status.color;

  /// Verifica se o agendamento tem informações básicas completas
  bool get hasBasicInfo => 
    professionalId.isNotEmpty && 
    clientId.isNotEmpty && 
    serviceId.isNotEmpty && 
    price >= 0 &&
    estimatedDuration > 0;

  /// Verifica se o agendamento está completo
  bool get isComplete => hasBasicInfo;

  @override
  String toString() {
    return 'AppointmentEntity(id: $id, date: $formattedDate, time: $formattedTime, status: ${status.description})';
  }
}

/// Enum que define os possíveis status de um agendamento
enum AppointmentStatus {
  /// Agendamento criado, aguardando confirmação
  pending('pending', 'Pendente', '⏳', '#FFA500'),
  
  /// Agendamento confirmado pelo profissional
  confirmed('confirmed', 'Confirmado', '✅', '#4CAF50'),
  
  /// Agendamento cancelado
  cancelled('cancelled', 'Cancelado', '❌', '#F44336'),
  
  /// Agendamento concluído/realizado
  completed('completed', 'Concluído', '🎉', '#2196F3'),
  
  /// Cliente não compareceu
  noShow('no_show', 'Não Compareceu', '👻', '#9E9E9E'),
  
  /// Agendamento em andamento
  inProgress('in_progress', 'Em Andamento', '🔄', '#FF9800');

  const AppointmentStatus(this.value, this.description, this.icon, this.color);

  /// Valor string do status (para persistência)
  final String value;
  
  /// Descrição do status para exibição
  final String description;
  
  /// Ícone representativo do status
  final String icon;
  
  /// Cor representativa do status (hex)
  final String color;

  /// Converte string para AppointmentStatus
  static AppointmentStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'completed':
        return AppointmentStatus.completed;
      case 'no_show':
        return AppointmentStatus.noShow;
      case 'in_progress':
        return AppointmentStatus.inProgress;
      default:
        return AppointmentStatus.pending;
    }
  }

  /// Lista de status que indicam que o agendamento está ativo
  static const List<AppointmentStatus> activeStatuses = [
    AppointmentStatus.pending,
    AppointmentStatus.confirmed,
    AppointmentStatus.inProgress,
  ];

  /// Lista de status que indicam que o agendamento foi finalizado
  static const List<AppointmentStatus> finishedStatuses = [
    AppointmentStatus.completed,
    AppointmentStatus.cancelled,
    AppointmentStatus.noShow,
  ];

  /// Verifica se o status indica um agendamento ativo
  bool get isActive => activeStatuses.contains(this);

  /// Verifica se o status indica um agendamento finalizado
  bool get isFinished => finishedStatuses.contains(this);

  @override
  String toString() => value;
}

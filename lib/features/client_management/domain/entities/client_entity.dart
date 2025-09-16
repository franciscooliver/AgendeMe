import '../../../../core/core.dart';

/// Entidade que representa um cliente na perspectiva do profissional
/// 
/// Contém informações essenciais do cliente que o profissional precisa ver
/// para gerenciamento de agendamentos e relacionamento profissional-cliente
class ClientEntity extends BaseEntity {
  /// ID do usuário cliente no Firebase Auth
  final String userId;
  
  /// Nome completo do cliente
  final String name;
  
  /// Email do cliente para contato
  final String email;
  
  /// Número de telefone do cliente
  final String? phone;
  
  /// URL da foto de perfil do cliente
  final String? profileImageUrl;
  
  /// Data da primeira interação com o profissional
  final DateTime firstAppointmentDate;
  
  /// Data da última interação/agendamento
  final DateTime lastInteractionDate;
  
  /// Total de agendamentos realizados com este profissional
  final int totalAppointments;
  
  /// Status do relacionamento com o cliente
  final ClientStatus status;
  
  /// Observações específicas do profissional sobre o cliente
  final String? notes;
  
  /// Lista de serviços já utilizados pelo cliente
  final List<String> servicesUsed;
  
  /// Valor total gasto pelo cliente (em reais)
  final double totalSpent;
  
  /// Flag indicando se o cliente está ativo
  final bool isActive;

  const ClientEntity({
    required super.id,
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    required this.firstAppointmentDate,
    required this.lastInteractionDate,
    this.totalAppointments = 0,
    this.status = ClientStatus.active,
    this.notes,
    this.servicesUsed = const [],
    this.totalSpent = 0.0,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        email,
        phone,
        profileImageUrl,
        firstAppointmentDate,
        lastInteractionDate,
        totalAppointments,
        status,
        notes,
        servicesUsed,
        totalSpent,
        isActive,
      ];

  @override
  ClientEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    DateTime? firstAppointmentDate,
    DateTime? lastInteractionDate,
    int? totalAppointments,
    ClientStatus? status,
    String? notes,
    List<String>? servicesUsed,
    double? totalSpent,
    bool? isActive,
  }) {
    return ClientEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      firstAppointmentDate: firstAppointmentDate ?? this.firstAppointmentDate,
      lastInteractionDate: lastInteractionDate ?? this.lastInteractionDate,
      totalAppointments: totalAppointments ?? this.totalAppointments,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      servicesUsed: servicesUsed ?? this.servicesUsed,
      totalSpent: totalSpent ?? this.totalSpent,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Verifica se é um cliente recente (primeira interação nos últimos 30 dias)
  bool get isNewClient {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return firstAppointmentDate.isAfter(thirtyDaysAgo);
  }

  /// Verifica se é um cliente frequente (mais de 5 agendamentos)
  bool get isFrequentClient => totalAppointments > 5;

  /// Verifica se é um cliente VIP (mais de 10 agendamentos ou valor alto)
  bool get isVipClient => totalAppointments > 10 || totalSpent > 1000.0;

  /// Verifica se o cliente está inativo há muito tempo (sem interação há 60+ dias)
  bool get isInactive {
    final sixtyDaysAgo = DateTime.now().subtract(const Duration(days: 60));
    return lastInteractionDate.isBefore(sixtyDaysAgo);
  }

  /// Retorna valor médio gasto por agendamento
  double get averageSpentPerAppointment {
    if (totalAppointments == 0) return 0.0;
    return totalSpent / totalAppointments;
  }

  /// Retorna descrição do status do cliente
  String get statusDescription => status.description;

  /// Retorna ícone representativo do status do cliente
  String get statusIcon => status.icon;

  @override
  String toString() {
    return 'ClientEntity(id: $id, name: $name, email: $email, totalAppointments: $totalAppointments)';
  }
}

/// Enum que define os possíveis status de um cliente
enum ClientStatus {
  /// Cliente ativo e regular
  active('active', 'Ativo', '✅'),
  
  /// Cliente inativo (sem agendamentos recentes)
  inactive('inactive', 'Inativo', '😴'),
  
  /// Cliente com alguma restrição ou problema
  blocked('blocked', 'Bloqueado', '🚫'),
  
  /// Cliente VIP com tratamento especial
  vip('vip', 'VIP', '⭐'),
  
  /// Cliente novo (primeira interação recente)
  newClient('new', 'Novo', '🎉');

  const ClientStatus(this.value, this.description, this.icon);

  /// Valor string do status (para persistência)
  final String value;
  
  /// Descrição do status para exibição
  final String description;
  
  /// Ícone representativo do status
  final String icon;

  /// Converte string para ClientStatus
  static ClientStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return ClientStatus.active;
      case 'inactive':
        return ClientStatus.inactive;
      case 'blocked':
        return ClientStatus.blocked;
      case 'vip':
        return ClientStatus.vip;
      case 'new':
        return ClientStatus.newClient;
      default:
        return ClientStatus.active;
    }
  }

  @override
  String toString() => value;
}

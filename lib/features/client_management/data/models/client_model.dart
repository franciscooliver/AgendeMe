import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/client_entity.dart';

/// Model que representa um cliente com funcionalidades de serialização
/// 
/// Estende ClientEntity e adiciona métodos para conversão JSON/Firestore
class ClientModel extends ClientEntity {
  const ClientModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.email,
    super.phone,
    super.profileImageUrl,
    required super.firstAppointmentDate,
    required super.lastInteractionDate,
    super.totalAppointments = 0,
    super.status = ClientStatus.active,
    super.notes,
    super.servicesUsed = const [],
    super.totalSpent = 0.0,
    super.isActive = true,
  });

  /// Cria ClientModel a partir de ClientEntity
  factory ClientModel.fromEntity(ClientEntity entity) {
    return ClientModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      profileImageUrl: entity.profileImageUrl,
      firstAppointmentDate: entity.firstAppointmentDate,
      lastInteractionDate: entity.lastInteractionDate,
      totalAppointments: entity.totalAppointments,
      status: entity.status,
      notes: entity.notes,
      servicesUsed: entity.servicesUsed,
      totalSpent: entity.totalSpent,
      isActive: entity.isActive,
    );
  }

  /// Cria ClientModel a partir de DocumentSnapshot do Firestore
  factory ClientModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ClientModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      profileImageUrl: data['profile_image_url'],
      firstAppointmentDate: (data['first_appointment_date'] as Timestamp).toDate(),
      lastInteractionDate: (data['last_interaction_date'] as Timestamp).toDate(),
      totalAppointments: data['total_appointments'] ?? 0,
      status: ClientStatus.fromString(data['status'] ?? 'active'),
      notes: data['notes'],
      servicesUsed: List<String>.from(data['services_used'] ?? []),
      totalSpent: (data['total_spent'] ?? 0.0).toDouble(),
      isActive: data['is_active'] ?? true,
    );
  }

  /// Cria ClientModel a partir de Map (JSON)
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImageUrl: json['profile_image_url'],
      firstAppointmentDate: DateTime.parse(json['first_appointment_date']),
      lastInteractionDate: DateTime.parse(json['last_interaction_date']),
      totalAppointments: json['total_appointments'] ?? 0,
      status: ClientStatus.fromString(json['status'] ?? 'active'),
      notes: json['notes'],
      servicesUsed: List<String>.from(json['services_used'] ?? []),
      totalSpent: (json['total_spent'] ?? 0.0).toDouble(),
      isActive: json['is_active'] ?? true,
    );
  }

  /// Converte para Map para envio ao Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'first_appointment_date': Timestamp.fromDate(firstAppointmentDate),
      'last_interaction_date': Timestamp.fromDate(lastInteractionDate),
      'total_appointments': totalAppointments,
      'status': status.value,
      'notes': notes,
      'services_used': servicesUsed,
      'total_spent': totalSpent,
      'is_active': isActive,
      'created_at': Timestamp.fromDate(firstAppointmentDate),
      'updated_at': Timestamp.fromDate(lastInteractionDate),
    };
  }

  /// Converte para Map sem timestamps do Firestore (para JSON puro)
  Map<String, dynamic> toJsonWithoutTimestamp() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'first_appointment_date': firstAppointmentDate.toIso8601String(),
      'last_interaction_date': lastInteractionDate.toIso8601String(),
      'total_appointments': totalAppointments,
      'status': status.value,
      'notes': notes,
      'services_used': servicesUsed,
      'total_spent': totalSpent,
      'is_active': isActive,
    };
  }

  /// Cria uma cópia do ClientModel com campos atualizados
  @override
  ClientModel copyWith({
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
    return ClientModel(
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
}

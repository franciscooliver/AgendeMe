import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/appointment_entity.dart';

/// Model que representa um agendamento com funcionalidades de serialização
/// 
/// Estende AppointmentEntity e adiciona métodos para conversão JSON/Firestore
class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.professionalId,
    required super.clientId,
    required super.serviceId,
    required super.appointmentDateTime,
    required super.price,
    required super.estimatedDuration,
    required super.createdAt,
    required super.updatedAt,
    super.status = AppointmentStatus.pending,
    super.notes,
    super.professionalNotes,
    super.clientNotes,
    super.rescheduledFromId,
    super.cancellationReason,
    super.cancelledAt,
  });

  /// Cria AppointmentModel a partir de AppointmentEntity
  factory AppointmentModel.fromEntity(AppointmentEntity entity) {
    return AppointmentModel(
      id: entity.id,
      professionalId: entity.professionalId,
      clientId: entity.clientId,
      serviceId: entity.serviceId,
      appointmentDateTime: entity.appointmentDateTime,
      status: entity.status,
      notes: entity.notes,
      professionalNotes: entity.professionalNotes,
      clientNotes: entity.clientNotes,
      price: entity.price,
      estimatedDuration: entity.estimatedDuration,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      rescheduledFromId: entity.rescheduledFromId,
      cancellationReason: entity.cancellationReason,
      cancelledAt: entity.cancelledAt,
    );
  }

  /// Converte para Map para envio ao Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professional_id': professionalId,
      'client_id': clientId,
      'service_id': serviceId,
      'appointment_date_time': Timestamp.fromDate(appointmentDateTime),
      'status': status.value,
      'notes': notes,
      'professional_notes': professionalNotes,
      'client_notes': clientNotes,
      'price': price,
      'estimated_duration': estimatedDuration,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'rescheduled_from_id': rescheduledFromId,
      'cancellation_reason': cancellationReason,
      'cancelled_at': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
    };
  }

  /// Cria AppointmentModel a partir de dados do Firestore
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      professionalId: json['professional_id'] as String,
      clientId: json['client_id'] as String,
      serviceId: json['service_id'] as String,
      appointmentDateTime: (json['appointment_date_time'] as Timestamp).toDate(),
      status: AppointmentStatus.fromString(json['status'] as String),
      notes: json['notes'] as String?,
      professionalNotes: json['professional_notes'] as String?,
      clientNotes: json['client_notes'] as String?,
      price: (json['price'] as num).toDouble(),
      estimatedDuration: json['estimated_duration'] as int,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
      rescheduledFromId: json['rescheduled_from_id'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      cancelledAt: json['cancelled_at'] != null
          ? (json['cancelled_at'] as Timestamp).toDate()
          : null,
    );
  }

  /// Cria AppointmentModel a partir de DocumentSnapshot do Firestore
  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  /// Cria AppointmentModel a partir de DocumentSnapshot com ID customizado
  factory AppointmentModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  /// Converte para DocumentSnapshot format (sem o ID)
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // O ID é gerenciado pelo DocumentSnapshot
    return json;
  }

  @override
  AppointmentModel copyWith({
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
    return AppointmentModel(
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
}

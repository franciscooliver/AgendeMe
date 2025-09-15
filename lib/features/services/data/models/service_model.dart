import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/service_entity.dart';

/// Model que representa um serviço com funcionalidades de serialização
/// 
/// Estende ServiceEntity e adiciona métodos para conversão JSON/Firestore
class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    required super.professionalId,
    required super.name,
    required super.description,
    required super.category,
    required super.duration,
    required super.price,
    required super.createdAt,
    required super.updatedAt,
    super.isActive = true,
    super.notes,
    super.imageUrl,
  });

  /// Cria ServiceModel a partir de ServiceEntity
  factory ServiceModel.fromEntity(ServiceEntity entity) {
    return ServiceModel(
      id: entity.id,
      professionalId: entity.professionalId,
      name: entity.name,
      description: entity.description,
      category: entity.category,
      duration: entity.duration,
      price: entity.price,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      notes: entity.notes,
      imageUrl: entity.imageUrl,
    );
  }

  /// Converte para Map para envio ao Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professional_id': professionalId,
      'name': name,
      'description': description,
      'category': category,
      'duration': duration,
      'price': price,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'is_active': isActive,
      'notes': notes,
      'image_url': imageUrl,
    };
  }

  /// Cria ServiceModel a partir de dados do Firestore
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      professionalId: json['professional_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      duration: json['duration'] as int,
      price: (json['price'] as num).toDouble(),
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
      isActive: json['is_active'] as bool? ?? true,
      notes: json['notes'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  /// Cria ServiceModel a partir de DocumentSnapshot do Firestore
  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel.fromJson({
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
  ServiceModel copyWith({
    String? id,
    String? professionalId,
    String? name,
    String? description,
    String? category,
    int? duration,
    double? price,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    String? imageUrl,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      professionalId: professionalId ?? this.professionalId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

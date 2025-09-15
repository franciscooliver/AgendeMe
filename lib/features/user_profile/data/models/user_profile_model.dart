import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/user_type.dart';

/// Model que representa o perfil de usuário com funcionalidades de serialização
/// 
/// Estende UserProfileEntity e adiciona métodos para conversão JSON/Firestore
class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.email,
    required super.userType,
    super.bio,
    super.phone,
    super.address,
    super.city,
    super.state,
    super.profileImageUrl,
    required super.createdAt,
    required super.updatedAt,
    super.isActive = true,
    super.services,
    super.workingHours,
    super.pricing,
    super.favoriteProfessionals,
    super.notificationPreferences,
  });

  /// Cria UserProfileModel a partir de UserProfileEntity
  factory UserProfileModel.fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      userType: entity.userType,
      bio: entity.bio,
      phone: entity.phone,
      address: entity.address,
      city: entity.city,
      state: entity.state,
      profileImageUrl: entity.profileImageUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      services: entity.services,
      workingHours: entity.workingHours,
      pricing: entity.pricing,
      favoriteProfessionals: entity.favoriteProfessionals,
      notificationPreferences: entity.notificationPreferences,
    );
  }

  /// Converte para Map para envio ao Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'user_type': userType.value,
      'bio': bio,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'profile_image_url': profileImageUrl,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'is_active': isActive,
      'services': services,
      'working_hours': workingHours,
      'pricing': pricing,
      'favorite_professionals': favoriteProfessionals,
      'notification_preferences': notificationPreferences,
    };
  }

  /// Cria UserProfileModel a partir de dados do Firestore
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      userType: UserType.fromString(json['user_type'] as String),
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
      isActive: json['is_active'] as bool? ?? true,
      services: json['services'] != null 
          ? List<String>.from(json['services'] as List)
          : null,
      workingHours: json['working_hours'] as Map<String, dynamic>?,
      pricing: json['pricing'] as Map<String, dynamic>?,
      favoriteProfessionals: json['favorite_professionals'] != null
          ? List<String>.from(json['favorite_professionals'] as List)
          : null,
      notificationPreferences: json['notification_preferences'] as Map<String, dynamic>?,
    );
  }

  /// Cria UserProfileModel a partir de DocumentSnapshot do Firestore
  factory UserProfileModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Garantir que o ID do documento seja usado como ID do modelo
    data['id'] = doc.id;
    
    return UserProfileModel.fromJson(data);
  }

  /// Converte para UserProfileEntity
  UserProfileEntity toEntity() {
    return UserProfileEntity(
      id: id,
      userId: userId,
      name: name,
      email: email,
      userType: userType,
      bio: bio,
      phone: phone,
      address: address,
      city: city,
      state: state,
      profileImageUrl: profileImageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      services: services,
      workingHours: workingHours,
      pricing: pricing,
      favoriteProfessionals: favoriteProfessionals,
      notificationPreferences: notificationPreferences,
    );
  }

  /// Método copyWith específico para UserProfileModel
  @override
  UserProfileModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    UserType? userType,
    String? bio,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<String>? services,
    Map<String, dynamic>? workingHours,
    Map<String, dynamic>? pricing,
    List<String>? favoriteProfessionals,
    Map<String, dynamic>? notificationPreferences,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      services: services ?? this.services,
      workingHours: workingHours ?? this.workingHours,
      pricing: pricing ?? this.pricing,
      favoriteProfessionals: favoriteProfessionals ?? this.favoriteProfessionals,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
    );
  }
}

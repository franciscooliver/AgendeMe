import '../../../../core/core.dart';
import 'user_type.dart';

/// Entidade que representa o perfil completo do usuário
/// 
/// Contém informações além da autenticação, incluindo dados pessoais,
/// profissionais e preferências específicas do tipo de usuário
class UserProfileEntity extends BaseEntity {
  /// ID do usuário no Firebase Auth (referência para UserEntity)
  final String userId;
  
  /// Nome completo do usuário
  final String name;
  
  /// Email do usuário (copiado do Firebase Auth para facilitar consultas)
  final String email;
  
  /// Tipo do usuário (Cliente ou Profissional)
  final UserType userType;
  
  /// Biografia ou descrição do usuário
  final String? bio;
  
  /// Número de telefone para contato
  final String? phone;
  
  /// Endereço do usuário
  final String? address;
  
  /// Cidade onde o usuário está localizado
  final String? city;
  
  /// Estado/região do usuário
  final String? state;
  
  /// URL da foto de perfil
  final String? profileImageUrl;
  
  /// Data de criação do perfil
  final DateTime createdAt;
  
  /// Data da última atualização
  final DateTime updatedAt;
  
  /// Flag indicando se o perfil está ativo
  final bool isActive;
  
  /// Campos específicos para profissionais
  /// Lista de serviços oferecidos (apenas para profissionais)
  final List<String>? services;
  
  /// Horário de funcionamento (apenas para profissionais)
  final Map<String, dynamic>? workingHours;
  
  /// Preços dos serviços (apenas para profissionais)
  final Map<String, dynamic>? pricing;
  
  /// Campos específicos para clientes
  /// Lista de profissionais favoritos (apenas para clientes)
  final List<String>? favoriteProfessionals;
  
  /// Preferências de notificação (apenas para clientes)
  final Map<String, dynamic>? notificationPreferences;

  const UserProfileEntity({
    required super.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.userType,
    this.bio,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    // Campos para profissionais
    this.services,
    this.workingHours,
    this.pricing,
    // Campos para clientes
    this.favoriteProfessionals,
    this.notificationPreferences,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        email,
        userType,
        bio,
        phone,
        address,
        city,
        state,
        profileImageUrl,
        createdAt,
        updatedAt,
        isActive,
        services,
        workingHours,
        pricing,
        favoriteProfessionals,
        notificationPreferences,
      ];

  @override
  UserProfileEntity copyWith({
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
    return UserProfileEntity(
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

  /// Verifica se o usuário é um cliente
  bool get isClient => userType.isClient;

  /// Verifica se o usuário é um profissional
  bool get isProfessional => userType.isProfessional;

  /// Retorna o nome de exibição do tipo de usuário
  String get userTypeDisplayName => userType.displayName;

  /// Verifica se o perfil tem informações básicas completas
  bool get hasBasicInfo => name.isNotEmpty && email.isNotEmpty;

  /// Verifica se o perfil tem informações de contato
  bool get hasContactInfo => phone != null && phone!.isNotEmpty;

  /// Verifica se o perfil tem localização
  bool get hasLocation => address != null && city != null && state != null;

  /// Verifica se o perfil está completo (informações básicas + contato + localização)
  bool get isComplete => hasBasicInfo && hasContactInfo && hasLocation;

  @override
  String toString() {
    return 'UserProfileEntity(id: $id, name: $name, userType: $userType, email: $email)';
  }
}

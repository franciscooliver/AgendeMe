import '../../../../core/core.dart';

/// Entidade que representa um serviço oferecido por um profissional
/// 
/// Contém todas as informações necessárias sobre o serviço,
/// incluindo nome, descrição, duração, preço e categoria
class ServiceEntity extends BaseEntity {
  /// ID do profissional que oferece este serviço
  final String professionalId;
  
  /// Nome do serviço
  final String name;
  
  /// Descrição detalhada do serviço
  final String description;
  
  /// Categoria do serviço (ex: "Cabelo", "Estética", "Massagem")
  final String category;
  
  /// Duração do serviço em minutos
  final int duration;
  
  /// Preço do serviço em reais (valor decimal)
  final double price;
  
  /// Flag indicando se o serviço está ativo/disponível
  final bool isActive;
  
  /// Data de criação do serviço
  final DateTime createdAt;
  
  /// Data da última atualização
  final DateTime updatedAt;
  
  /// Observações adicionais sobre o serviço (opcional)
  final String? notes;
  
  /// URL de imagem ilustrativa do serviço (opcional)
  final String? imageUrl;

  const ServiceEntity({
    required super.id,
    required this.professionalId,
    required this.name,
    required this.description,
    required this.category,
    required this.duration,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.notes,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        professionalId,
        name,
        description,
        category,
        duration,
        price,
        isActive,
        createdAt,
        updatedAt,
        notes,
        imageUrl,
      ];

  @override
  ServiceEntity copyWith({
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
    return ServiceEntity(
      id: id ?? this.id,
      professionalId: professionalId ?? this.professionalId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Retorna o preço formatado como string em reais
  String get formattedPrice => 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  /// Retorna a duração formatada como string legível
  String get formattedDuration {
    if (duration < 60) {
      return '${duration}min';
    } else {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      if (minutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${minutes}min';
      }
    }
  }

  /// Verifica se o serviço tem informações básicas completas
  bool get hasBasicInfo => 
    name.isNotEmpty && 
    description.isNotEmpty && 
    category.isNotEmpty && 
    duration > 0 && 
    price >= 0;

  /// Verifica se o serviço está completo (todas as informações preenchidas)
  bool get isComplete => hasBasicInfo && professionalId.isNotEmpty;

  @override
  String toString() {
    return 'ServiceEntity(id: $id, name: $name, category: $category, price: $formattedPrice, duration: $formattedDuration)';
  }
}

/// Categorias predefinidas de serviços
class ServiceCategories {
  static const String hair = 'Cabelo';
  static const String nails = 'Unhas';
  static const String aesthetics = 'Estética';
  static const String massage = 'Massagem';
  static const String makeup = 'Maquiagem';
  static const String eyebrows = 'Sobrancelhas';
  static const String skincare = 'Cuidados com a Pele';
  static const String depilation = 'Depilação';
  static const String therapy = 'Terapias';
  static const String other = 'Outros';

  /// Lista de todas as categorias disponíveis
  static const List<String> all = [
    hair,
    nails,
    aesthetics,
    massage,
    makeup,
    eyebrows,
    skincare,
    depilation,
    therapy,
    other,
  ];

  /// Verifica se uma categoria é válida
  static bool isValid(String category) => all.contains(category);
}

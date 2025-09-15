import '../../domain/entities/template_example_entity.dart';

/// Model que estende a entidade do domínio
/// 
/// Responsável por serialização/deserialização de dados
/// seguindo as convenções do projeto
class TemplateExampleModel extends TemplateExampleEntity {
  const TemplateExampleModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    super.updatedAt,
    super.isActive,
  });

  /// Cria um model a partir de um Map (JSON)
  factory TemplateExampleModel.fromJson(Map<String, dynamic> json) {
    return TemplateExampleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Converte o model para Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Cria um model a partir de uma entidade
  factory TemplateExampleModel.fromEntity(TemplateExampleEntity entity) {
    return TemplateExampleModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
    );
  }

  @override
  TemplateExampleModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return TemplateExampleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

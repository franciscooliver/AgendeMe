import '../../../../core/core.dart';

/// Entidade de exemplo que demonstra a estrutura padrão
/// 
/// Esta entidade serve como template para implementação de outras entidades
/// seguindo as convenções definidas no projeto
class TemplateExampleEntity extends BaseEntity {
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const TemplateExampleEntity({
    required super.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        createdAt,
        updatedAt,
        isActive,
      ];

  @override
  TemplateExampleEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return TemplateExampleEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'TemplateExampleEntity(id: $id, title: $title, isActive: $isActive)';
  }
}

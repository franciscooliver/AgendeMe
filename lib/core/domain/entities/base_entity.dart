import 'package:equatable/equatable.dart';

/// Classe base abstrata para todas as entidades do domínio
/// 
/// Todas as entidades devem herdar desta classe para garantir:
/// - Comparação de igualdade consistente via Equatable
/// - Estrutura padronizada com ID obrigatório
/// - Método copyWith para imutabilidade
abstract class BaseEntity extends Equatable {
  /// Identificador único da entidade
  final String id;

  const BaseEntity({required this.id});

  @override
  List<Object?> get props => [id];

  /// Método abstrato para criar uma cópia da entidade com propriedades alteradas
  /// 
  /// Deve ser implementado em cada entidade específica
  BaseEntity copyWith();

  @override
  String toString() => '$runtimeType(id: $id)';
}

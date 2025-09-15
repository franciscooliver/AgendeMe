import 'package:dartz/dartz.dart';
import '../../../../core/core.dart';
import '../entities/template_example_entity.dart';

/// Interface do repositório para Template Example
/// 
/// Define todos os métodos necessários para operações de dados
/// seguindo os padrões estabelecidos no projeto
abstract class TemplateExampleRepository extends SearchableRepository<TemplateExampleEntity> {
  /// Busca entidades por status ativo/inativo
  Future<Either<Failure, List<TemplateExampleEntity>>> getByStatus(bool isActive);

  /// Busca entidades criadas em um período específico
  Future<Either<Failure, List<TemplateExampleEntity>>> getByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Alterna o status ativo/inativo de uma entidade
  Future<Either<Failure, TemplateExampleEntity>> toggleStatus(String id);

  /// Busca entidades por título (case insensitive)
  Future<Either<Failure, List<TemplateExampleEntity>>> searchByTitle(String title);
}

import 'package:dartz/dartz.dart';
import '../../../../core/core.dart';
import '../entities/template_example_entity.dart';
import '../repositories/template_example_repository.dart';

/// Parâmetros para criar um Template Example
class CreateTemplateExampleParams {
  final String title;
  final String description;

  const CreateTemplateExampleParams({
    required this.title,
    required this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateTemplateExampleParams &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          description == other.description;

  @override
  int get hashCode => title.hashCode ^ description.hashCode;
}

/// Caso de uso para criar um novo Template Example
class CreateTemplateExample
    extends UseCase<TemplateExampleEntity, CreateTemplateExampleParams> {
  final TemplateExampleRepository repository;

  CreateTemplateExample(this.repository);

  @override
  Future<Either<Failure, TemplateExampleEntity>> call(
    CreateTemplateExampleParams params,
  ) async {
    // Validações
    if (params.title.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Título é obrigatório'),
      );
    }

    if (params.title.trim().length < 3) {
      return const Left(
        ValidationFailure(message: 'Título deve ter pelo menos 3 caracteres'),
      );
    }

    if (params.description.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Descrição é obrigatória'),
      );
    }

    try {
      // Criar entidade
      final entity = TemplateExampleEntity(
        id: AppUtils.generateUniqueId(),
        title: params.title.trim(),
        description: params.description.trim(),
        createdAt: DateTime.now(),
      );

      // Salvar no repositório
      return await repository.create(entity);
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro inesperado ao criar Template Example',
          details: e.toString(),
        ),
      );
    }
  }
}

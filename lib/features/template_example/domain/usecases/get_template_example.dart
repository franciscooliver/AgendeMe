import 'package:dartz/dartz.dart';
import '../../../../core/core.dart';
import '../entities/template_example_entity.dart';
import '../repositories/template_example_repository.dart';

/// Caso de uso para buscar um Template Example por ID
/// 
/// Demonstra a estrutura padrão de use cases no projeto
class GetTemplateExample extends UseCase<TemplateExampleEntity, String> {
  final TemplateExampleRepository repository;

  GetTemplateExample(this.repository);

  @override
  Future<Either<Failure, TemplateExampleEntity>> call(String id) async {
    if (id.isEmpty) {
      return const Left(
        ValidationFailure(message: 'ID não pode estar vazio'),
      );
    }

    try {
      return await repository.getById(id);
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro inesperado ao buscar Template Example',
          details: e.toString(),
        ),
      );
    }
  }
}

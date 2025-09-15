import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/core.dart';
import '../entities/service_entity.dart';
import '../repositories/service_repository.dart';

/// Use case para editar/atualizar um serviço existente
class EditService extends UseCase<ServiceEntity, EditServiceParams> {
  final ServiceRepository repository;

  EditService(this.repository);

  @override
  Future<Either<Failure, ServiceEntity>> call(EditServiceParams params) async {
    // Validações de negócio antes da atualização
    if (params.service.id.isEmpty) {
      return Left(ValidationFailure(message: 'ID do serviço é obrigatório'));
    }

    if (params.service.name.isEmpty) {
      return Left(ValidationFailure(message: 'Nome do serviço é obrigatório'));
    }

    if (params.service.description.isEmpty) {
      return Left(ValidationFailure(message: 'Descrição do serviço é obrigatória'));
    }

    if (params.service.professionalId.isEmpty) {
      return Left(ValidationFailure(message: 'ID do profissional é obrigatório'));
    }

    if (params.service.category.isEmpty) {
      return Left(ValidationFailure(message: 'Categoria do serviço é obrigatória'));
    }

    if (!ServiceCategories.isValid(params.service.category)) {
      return Left(ValidationFailure(message: 'Categoria do serviço inválida'));
    }

    if (params.service.duration <= 0) {
      return Left(ValidationFailure(message: 'Duração deve ser maior que zero'));
    }

    if (params.service.price < 0) {
      return Left(ValidationFailure(message: 'Preço não pode ser negativo'));
    }

    // Verificar se o serviço existe
    final existsResult = await repository.serviceExists(params.service.id);
    
    return existsResult.fold(
      (failure) => Left(failure),
      (exists) {
        if (!exists) {
          return Left(ValidationFailure(message: 'Serviço não encontrado'));
        }
        
        // Atualizar o serviço com timestamp atualizado
        final serviceToUpdate = params.service.copyWith(
          updatedAt: DateTime.now(),
        );
        
        return repository.updateService(serviceToUpdate);
      },
    );
  }
}

/// Parâmetros para o EditService use case
class EditServiceParams extends Equatable {
  final ServiceEntity service;

  const EditServiceParams({required this.service});

  @override
  List<Object> get props => [service];
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/core.dart';
import '../repositories/service_repository.dart';

/// Use case para excluir um serviço (soft delete)
class DeleteService extends UseCase<void, DeleteServiceParams> {
  final ServiceRepository repository;

  DeleteService(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteServiceParams params) async {
    // Validações de negócio antes da exclusão
    if (params.serviceId.isEmpty) {
      return Left(ValidationFailure(message: 'ID do serviço é obrigatório'));
    }

    // Verificar se o serviço existe
    final existsResult = await repository.serviceExists(params.serviceId);
    
    return existsResult.fold(
      (failure) => Left(failure),
      (exists) {
        if (!exists) {
          return Left(ValidationFailure(message: 'Serviço não encontrado'));
        }
        
        // Deletar o serviço (soft delete - marca como inativo)
        return repository.deleteService(params.serviceId);
      },
    );
  }
}

/// Parâmetros para o DeleteService use case
class DeleteServiceParams extends Equatable {
  final String serviceId;

  const DeleteServiceParams({required this.serviceId});

  @override
  List<Object> get props => [serviceId];
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/core.dart';
import '../entities/service_entity.dart';
import '../repositories/service_repository.dart';

/// Use case para criar um novo serviço
class AddService extends UseCase<ServiceEntity, AddServiceParams> {
  final ServiceRepository repository;

  AddService(this.repository);

  @override
  Future<Either<Failure, ServiceEntity>> call(AddServiceParams params) async {
    // Validações de negócio antes da criação
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

    // Criar o serviço com timestamps atualizados
    final serviceToCreate = params.service.copyWith(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true, // Novos serviços começam ativos
    );

    return repository.createService(serviceToCreate);
  }
}

/// Parâmetros para o AddService use case
class AddServiceParams extends Equatable {
  final ServiceEntity service;

  const AddServiceParams({required this.service});

  @override
  List<Object> get props => [service];
}

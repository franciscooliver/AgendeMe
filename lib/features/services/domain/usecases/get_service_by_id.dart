import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/core.dart';
import '../entities/service_entity.dart';
import '../repositories/service_repository.dart';

/// Use case para buscar um serviço específico pelo ID
class GetServiceById extends UseCase<ServiceEntity, GetServiceByIdParams> {
  final ServiceRepository repository;

  GetServiceById(this.repository);

  @override
  Future<Either<Failure, ServiceEntity>> call(GetServiceByIdParams params) async {
    // Validações de negócio
    if (params.serviceId.isEmpty) {
      return Left(ValidationFailure(message: 'ID do serviço é obrigatório'));
    }

    // Buscar o serviço pelo ID
    return repository.getService(params.serviceId);
  }
}

/// Parâmetros para o GetServiceById use case
class GetServiceByIdParams extends Equatable {
  final String serviceId;

  const GetServiceByIdParams({required this.serviceId});

  @override
  List<Object> get props => [serviceId];
}

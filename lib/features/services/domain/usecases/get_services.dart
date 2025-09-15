import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/core.dart';
import '../entities/service_entity.dart';
import '../repositories/service_repository.dart';

/// Use case para buscar serviços de um profissional
class GetServices extends UseCase<List<ServiceEntity>, GetServicesParams> {
  final ServiceRepository repository;

  GetServices(this.repository);

  @override
  Future<Either<Failure, List<ServiceEntity>>> call(GetServicesParams params) async {
    // Validações de negócio
    if (params.professionalId.isEmpty) {
      return Left(ValidationFailure(message: 'ID do profissional é obrigatório'));
    }

    // Buscar serviços do profissional
    return repository.getServicesByProfessional(
      params.professionalId,
      includeInactive: params.includeInactive,
    );
  }
}

/// Parâmetros para o GetServices use case
class GetServicesParams extends Equatable {
  final String professionalId;
  final bool includeInactive;

  const GetServicesParams({
    required this.professionalId,
    this.includeInactive = false,
  });

  @override
  List<Object> get props => [professionalId, includeInactive];
}

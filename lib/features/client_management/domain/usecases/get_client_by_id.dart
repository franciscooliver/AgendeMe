import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/core.dart';
import '../entities/client_entity.dart';
import '../repositories/client_repository.dart';

/// Use case para buscar um cliente específico por ID
class GetClientById extends UseCase<ClientEntity, GetClientByIdParams> {
  final ClientRepository repository;

  GetClientById(this.repository);

  @override
  Future<Either<Failure, ClientEntity>> call(GetClientByIdParams params) async {
    return await repository.getClientById(params.clientId);
  }
}

/// Parâmetros para o GetClientById use case
class GetClientByIdParams extends Equatable {
  final String clientId;

  const GetClientByIdParams({required this.clientId});

  @override
  List<Object> get props => [clientId];
}

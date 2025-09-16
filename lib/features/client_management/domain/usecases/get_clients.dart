import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/core.dart';
import '../entities/client_entity.dart';
import '../repositories/client_repository.dart';

/// Use case para buscar clientes de um profissional
class GetClients extends UseCase<List<ClientEntity>, GetClientsParams> {
  final ClientRepository repository;

  GetClients(this.repository);

  @override
  Future<Either<Failure, List<ClientEntity>>> call(GetClientsParams params) async {
    return await repository.getClientsByProfessional(
      params.professionalId,
      includeInactive: params.includeInactive,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

/// Parâmetros para o GetClients use case
class GetClientsParams extends Equatable {
  final String professionalId;
  final bool includeInactive;
  final int limit;
  final int offset;

  const GetClientsParams({
    required this.professionalId,
    this.includeInactive = false,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [professionalId, includeInactive, limit, offset];
}

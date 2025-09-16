import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/core.dart';
import '../entities/client_entity.dart';
import '../repositories/client_repository.dart';

/// Use case para buscar clientes por termo de pesquisa
class SearchClients extends UseCase<List<ClientEntity>, SearchClientsParams> {
  final ClientRepository repository;

  SearchClients(this.repository);

  @override
  Future<Either<Failure, List<ClientEntity>>> call(SearchClientsParams params) async {
    return await repository.searchClients(
      params.professionalId,
      params.searchTerm,
      limit: params.limit,
    );
  }
}

/// Parâmetros para o SearchClients use case
class SearchClientsParams extends Equatable {
  final String professionalId;
  final String searchTerm;
  final int limit;

  const SearchClientsParams({
    required this.professionalId,
    required this.searchTerm,
    this.limit = 10,
  });

  @override
  List<Object> get props => [professionalId, searchTerm, limit];
}

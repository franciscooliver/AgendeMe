import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_remote_datasource.dart';
import '../models/client_model.dart';

/// Implementação do repositório de clientes
/// 
/// Responsável por coordenar as operações de dados entre
/// as fontes remotas e locais, aplicando regras de negócio
class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ClientRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ClientEntity>>> getClientsByProfessional(
    String professionalId, {
    bool includeInactive = false,
    int limit = 20,
    int offset = 0,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final clients = await remoteDataSource.getClientsByProfessional(
          professionalId,
          includeInactive: includeInactive,
          limit: limit,
          offset: offset,
        );
        return Right(clients);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao buscar clientes: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, ClientEntity>> getClientById(String clientId) async {
    if (await networkInfo.isConnected) {
      try {
        final client = await remoteDataSource.getClientById(clientId);
        return Right(client);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao buscar cliente: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<ClientEntity>>> searchClients(
    String professionalId,
    String searchTerm, {
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final clients = await remoteDataSource.searchClients(
          professionalId,
          searchTerm,
          limit: limit,
        );
        return Right(clients);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao buscar clientes: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, ClientEntity>> addClient(ClientEntity client) async {
    if (await networkInfo.isConnected) {
      try {
        // Assumindo que o client.id contém o professionalId temporariamente
        // Em implementação real, isso viria de um contexto ou parâmetro separado
        final professionalId = client.id.split('_').first; // Exemplo de extração
        
        final clientModel = ClientModel.fromEntity(client);
        final savedClient = await remoteDataSource.addClient(
          clientModel,
          professionalId,
        );
        return Right(savedClient);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao adicionar cliente: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, ClientEntity>> updateClient(ClientEntity client) async {
    if (await networkInfo.isConnected) {
      try {
        final clientModel = ClientModel.fromEntity(client);
        final updatedClient = await remoteDataSource.updateClient(clientModel);
        return Right(updatedClient);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao atualizar cliente: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, ClientEntity>> updateClientStatistics(
    String clientId,
    double servicePrice,
    String serviceName,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedClient = await remoteDataSource.updateClientStatistics(
          clientId,
          servicePrice,
          serviceName,
        );
        return Right(updatedClient);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao atualizar estatísticas: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> removeClientAssociation(
    String professionalId,
    String clientId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.removeClientAssociation(professionalId, clientId);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao remover cliente: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<ClientEntity>>> getClientsByStatus(
    String professionalId,
    ClientStatus status, {
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final clients = await remoteDataSource.getClientsByStatus(
          professionalId,
          status,
          limit: limit,
        );
        return Right(clients);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao buscar clientes por status: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<ClientEntity>>> getVipClients(
    String professionalId, {
    int limit = 10,
  }) async {
    return await getClientsByStatus(
      professionalId,
      ClientStatus.vip,
      limit: limit,
    );
  }

  @override
  Future<Either<Failure, List<ClientEntity>>> getInactiveClients(
    String professionalId, {
    int daysSinceLastInteraction = 60,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final clients = await remoteDataSource.getClientsByProfessional(
          professionalId,
          includeInactive: true,
          limit: limit * 2, // Buscar mais para filtrar
        );

        final cutoffDate = DateTime.now().subtract(Duration(days: daysSinceLastInteraction));
        final inactiveClients = clients
            .where((client) => client.lastInteractionDate.isBefore(cutoffDate))
            .take(limit)
            .toList();

        return Right(inactiveClients);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao buscar clientes inativos: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasClientAssociation(
    String professionalId,
    String clientUserId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final hasAssociation = await remoteDataSource.hasClientAssociation(
          professionalId,
          clientUserId,
        );
        return Right(hasAssociation);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao verificar associação: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, ClientStatistics>> getClientStatistics(
    String professionalId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final statistics = await remoteDataSource.getClientStatistics(professionalId);
        return Right(statistics);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao obter estatísticas: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }
}

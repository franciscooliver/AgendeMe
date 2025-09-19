import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/service_remote_datasource.dart';
import '../models/service_model.dart';

/// Implementação concreta do ServiceRepository
/// 
/// Coordena entre data sources e trata erros convertendo-os em Failures
class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ServiceRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ServiceEntity>> getService(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final serviceModel = await remoteDataSource.getService(id);
        return Right(serviceModel);
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServicesByProfessional(
    String professionalId, {
    bool includeInactive = false,
  }) async {
    print('🔍 DEBUG: ServiceRepository.getServicesByProfessional iniciado para professionalId: $professionalId');
    
    print('🔍 DEBUG: Verificando conectividade...');
    final isConnected = await networkInfo.isConnected;
    print('🔍 DEBUG: Conectividade: $isConnected');
    
    if (isConnected) {
      try {
        print('🔍 DEBUG: Chamando remoteDataSource.getServicesByProfessional...');
        final serviceModels = await remoteDataSource.getServicesByProfessional(
          professionalId,
          includeInactive: includeInactive,
        );
        print('🔍 DEBUG: remoteDataSource retornou ${serviceModels.length} serviços');
        return Right(serviceModels.cast<ServiceEntity>());
      } catch (e) {
        print('🔍 DEBUG: Erro no remoteDataSource: $e');
        return Left(_handleException(e));
      }
    } else {
      print('🔍 DEBUG: Sem conexão com a internet');
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, ServiceEntity>> createService(ServiceEntity service) async {
    if (await networkInfo.isConnected) {
      try {
        final serviceModel = ServiceModel.fromEntity(service);
        final createdModel = await remoteDataSource.createService(serviceModel);
        return Right(createdModel);
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, ServiceEntity>> updateService(ServiceEntity service) async {
    if (await networkInfo.isConnected) {
      try {
        final serviceModel = ServiceModel.fromEntity(service);
        final updatedModel = await remoteDataSource.updateService(serviceModel);
        return Right(updatedModel);
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteService(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteService(id);
        return const Right(null);
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> permanentDeleteService(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.permanentDeleteService(id);
        return const Right(null);
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getAllServices({
    int limit = 20,
    int offset = 0,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final serviceModels = await remoteDataSource.getAllServices(
          limit: limit,
          offset: offset,
        );
        return Right(serviceModels.cast<ServiceEntity>());
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServicesByCategory(
    String category, {
    int limit = 20,
    int offset = 0,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final serviceModels = await remoteDataSource.getServicesByCategory(
          category,
          limit: limit,
          offset: offset,
        );
        return Right(serviceModels.cast<ServiceEntity>());
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServicesByPriceRange({
    double? minPrice,
    double? maxPrice,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final serviceModels = await remoteDataSource.getServicesByPriceRange(
          minPrice: minPrice,
          maxPrice: maxPrice,
          limit: limit,
        );
        return Right(serviceModels.cast<ServiceEntity>());
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServicesByDuration({
    int? minDuration,
    int? maxDuration,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final serviceModels = await remoteDataSource.getServicesByDuration(
          minDuration: minDuration,
          maxDuration: maxDuration,
          limit: limit,
        );
        return Right(serviceModels.cast<ServiceEntity>());
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> searchServicesByName(
    String searchTerm, {
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final serviceModels = await remoteDataSource.searchServicesByName(
          searchTerm,
          limit: limit,
        );
        return Right(serviceModels.cast<ServiceEntity>());
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleServiceStatus(String id, bool isActive) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.toggleServiceStatus(id, isActive);
        return const Right(null);
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, bool>> serviceExists(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final exists = await remoteDataSource.serviceExists(id);
        return Right(exists);
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getServiceStatistics(
    String professionalId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final statistics = await remoteDataSource.getServiceStatistics(professionalId);
        return Right(statistics);
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  /// Trata exceções e converte em Failures apropriados
  Failure _handleException(dynamic exception) {
    final message = exception.toString().toLowerCase();

    if (message.contains('permission') || message.contains('unauthorized')) {
      return PermissionFailure(
        message: 'Permissão negada para acessar os dados',
        details: exception,
      );
    }

    if (message.contains('not found') || message.contains('não encontrado')) {
      return ValidationFailure(
        message: 'Recurso não encontrado',
        details: exception,
      );
    }

    if (message.contains('network') || message.contains('connection')) {
      return NetworkFailure(
        message: 'Erro de conexão de rede',
        details: exception,
      );
    }

    if (message.contains('firebase') || message.contains('firestore')) {
      return FirebaseFailure(
        message: 'Erro no Firebase/Firestore',
        details: exception,
      );
    }

    // Erro genérico para outros casos
    return ServerFailure(
      message: 'Erro interno do servidor',
      details: exception,
    );
  }
}

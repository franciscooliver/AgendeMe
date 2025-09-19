import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';
import '../../../../core/data/helpers/cache_first_helper.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

/// Implementação concreta do UserProfileRepository
/// 
/// Coordena entre data sources e trata erros convertendo-os em Failures
/// Implementa padrão cache-first para melhor performance
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final CacheFirstHelper _cacheHelper;

  UserProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required ILocalCacheService cacheService,
  }) : _cacheHelper = CacheFirstHelper(cacheService: cacheService);

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile(String id) async {
    if (await networkInfo.isConnected) {
      try {
        // Usar cache-first pattern
        final result = await _cacheHelper.forceRefresh<UserProfileEntity>(
          cacheKey: 'user_profile_$id',
          fetchFunction: _fetchUserProfileFromRemote(id),
          fromJson: (json) => UserProfileModel.fromJson(json).toEntity(),
          toJson: (entity) => UserProfileModel.fromEntity(entity).toJson(),
        );
        return result;
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      // Sem conexão - tentar buscar do cache
      final cachedData = _cacheHelper.cacheService.getData<Map<String, dynamic>>('user_profile_$id');
      if (cachedData != null) {
        try {
          final entity = UserProfileModel.fromJson(cachedData).toEntity();
          return Right(entity);
        } catch (e) {
          return Left(NetworkFailure(message: 'Sem conexão e cache inválido'));
        }
      }
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  /// Método auxiliar para buscar dados do remote datasource
  Future<Either<Failure, UserProfileEntity>> _fetchUserProfileFromRemote(String id) async {
    try {
      final userProfileModel = await remoteDataSource.getUserProfile(id);
      return Right(userProfileModel.toEntity());
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfileByUserId(String userId) async {
    print('🔍 Repository: getUserProfileByUserId iniciado para $userId');
    if (await networkInfo.isConnected) {
      try {
        print('🔍 Repository: Chamando remoteDataSource.getUserProfileByUserId');
        final userProfileModel = await remoteDataSource.getUserProfileByUserId(userId);
        print('🔍 Repository: Resultado do datasource: $userProfileModel');
        
        if (userProfileModel == null) {
          print('🔍 Repository: Profile não encontrado, retornando NotFoundFailure');
          return Left(NotFoundFailure(
            message: 'Perfil de usuário não encontrado',
            code: 'profile_not_found',
            details: {'userId': userId},
          ));
        }
        
        print('🔍 Repository: Profile encontrado, convertendo para entity');
        return Right(userProfileModel.toEntity());
      } catch (e) {
        print('🔍 Repository: Exception capturada: $e');
        return Left(_handleException(e));
      }
    } else {
      print('🔍 Repository: Sem conexão com internet');
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> createUserProfile(
    UserProfileEntity userProfile,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final userProfileModel = UserProfileModel.fromEntity(userProfile);
        final createdModel = await remoteDataSource.createUserProfile(userProfileModel);
        return Right(createdModel.toEntity());
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> updateUserProfile(
    UserProfileEntity userProfile,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final userProfileModel = UserProfileModel.fromEntity(userProfile);
        final updatedModel = await remoteDataSource.updateUserProfile(userProfileModel);
        return Right(updatedModel.toEntity());
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserProfile(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteUserProfile(id);
        return const Right(null);
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<UserProfileEntity>>> getAllUserProfiles({
    int limit = 20,
    int offset = 0,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userProfileModels = await remoteDataSource.getAllUserProfiles(
          limit: limit,
          offset: offset,
        );
        final userProfileEntities = userProfileModels
            .map((model) => model.toEntity())
            .toList();
        return Right(userProfileEntities);
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<UserProfileEntity>>> getUserProfilesByType(
    String userType, {
    int limit = 20,
    int offset = 0,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userProfileModels = await remoteDataSource.getUserProfilesByType(
          userType,
          limit: limit,
          offset: offset,
        );
        final userProfileEntities = userProfileModels
            .map((model) => model.toEntity())
            .toList();
        return Right(userProfileEntities);
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<UserProfileEntity>>> getProfessionalsByCity(
    String city, {
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userProfileModels = await remoteDataSource.getProfessionalsByCity(
          city,
          limit: limit,
        );
        final userProfileEntities = userProfileModels
            .map((model) => model.toEntity())
            .toList();
        return Right(userProfileEntities);
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<UserProfileEntity>>> getProfessionalsByService(
    String service, {
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userProfileModels = await remoteDataSource.getProfessionalsByService(
          service,
          limit: limit,
        );
        final userProfileEntities = userProfileModels
            .map((model) => model.toEntity())
            .toList();
        return Right(userProfileEntities);
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, bool>> userProfileExists(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final exists = await remoteDataSource.userProfileExists(userId);
        return Right(exists);
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  /// Trata exceções convertendo-as em Failures apropriados
  Failure _handleException(dynamic exception) {
    final String message = exception.toString();

    // Categorizar diferentes tipos de erro
    if (message.contains('não encontrado') || message.contains('not found')) {
      return ServerFailure(
        message: 'Recurso não encontrado',
        details: exception,
      );
    }

    if (message.contains('permission') || message.contains('unauthorized')) {
      return PermissionFailure(
        message: 'Sem permissão para realizar esta operação',
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

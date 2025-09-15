import 'package:dartz/dartz.dart';
import '../../../../core/core.dart';
import '../../domain/entities/template_example_entity.dart';
import '../../domain/repositories/template_example_repository.dart';
import '../datasources/template_example_local_datasource.dart';
import '../datasources/template_example_remote_datasource.dart';
import '../models/template_example_model.dart';

/// Implementação concreta do repositório Template Example
/// 
/// Demonstra como implementar a lógica de repository seguindo
/// as convenções e padrões do projeto
class TemplateExampleRepositoryImpl implements TemplateExampleRepository {
  final TemplateExampleRemoteDataSource remoteDataSource;
  final TemplateExampleLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TemplateExampleRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, TemplateExampleEntity>> getById(String id) async {
    try {
      // Sempre tenta buscar do cache primeiro
      try {
        final cachedModel = await localDataSource.getTemplateExample(id);
        return Right(cachedModel);
      } catch (e) {
        // Se não encontrar no cache, tenta buscar remotamente
      }

      // Verifica conectividade
      if (await networkInfo.isConnected) {
        final remoteModel = await remoteDataSource.getTemplateExample(id);
        
        // Salva no cache para próximas consultas
        await localDataSource.cacheTemplateExample(remoteModel);
        
        return Right(remoteModel);
      } else {
        return const Left(
          NetworkFailure(message: 'Sem conexão com a internet'),
        );
      }
    } on ServerFailure catch (failure) {
      return Left(failure);
    } on CacheFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro inesperado ao buscar Template Example',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<TemplateExampleEntity>>> getAll({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteModels = await remoteDataSource.getAllTemplateExamples(
          page: page,
          limit: limit,
          filters: filters,
        );
        
        // Atualiza cache com dados remotos
        await localDataSource.cacheTemplateExamples(remoteModels);
        
        return Right(remoteModels);
      } else {
        // Sem internet, busca do cache
        try {
          final cachedModels = await localDataSource.getAllTemplateExamples();
          return Right(cachedModels);
        } catch (e) {
          return const Left(
            CacheFailure(message: 'Dados não disponíveis offline'),
          );
        }
      }
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro inesperado ao buscar Template Examples',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, TemplateExampleEntity>> create(TemplateExampleEntity entity) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(
          NetworkFailure(message: 'Conexão necessária para criar item'),
        );
      }

      final model = TemplateExampleModel.fromEntity(entity);
      final createdModel = await remoteDataSource.createTemplateExample(model);
      
      // Atualiza cache
      await localDataSource.cacheTemplateExample(createdModel);
      
      return Right(createdModel);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro inesperado ao criar Template Example',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, TemplateExampleEntity>> update(TemplateExampleEntity entity) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(
          NetworkFailure(message: 'Conexão necessária para atualizar item'),
        );
      }

      final model = TemplateExampleModel.fromEntity(entity);
      final updatedModel = await remoteDataSource.updateTemplateExample(model);
      
      // Atualiza cache
      await localDataSource.cacheTemplateExample(updatedModel);
      
      return Right(updatedModel);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro inesperado ao atualizar Template Example',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(
          NetworkFailure(message: 'Conexão necessária para deletar item'),
        );
      }

      await remoteDataSource.deleteTemplateExample(id);
      
      // Remove do cache
      await localDataSource.removeTemplateExample(id);
      
      return const Right(null);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro inesperado ao deletar Template Example',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> exists(String id) async {
    try {
      // Verifica primeiro no cache
      if (await localDataSource.hasTemplateExample(id)) {
        return const Right(true);
      }

      // Se não está no cache e há internet, verifica remotamente
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.getTemplateExample(id);
          return const Right(true);
        } catch (e) {
          return const Right(false);
        }
      }

      return const Right(false);
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro ao verificar existência do Template Example',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<TemplateExampleEntity>>> search(
    String query, {
    Map<String, dynamic>? filters,
    int? page,
    int? limit,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(
          NetworkFailure(message: 'Conexão necessária para busca'),
        );
      }

      final results = await remoteDataSource.searchTemplateExamples(
        query,
        filters: filters,
        page: page,
        limit: limit,
      );
      
      return Right(results);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro inesperado na busca',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<TemplateExampleEntity>>> getByStatus(bool isActive) async {
    try {
      if (await networkInfo.isConnected) {
        final results = await remoteDataSource.getTemplateExamplesByStatus(isActive);
        return Right(results);
      } else {
        // Filtro offline no cache
        try {
          final cachedModels = await localDataSource.getAllTemplateExamples();
          final filtered = cachedModels.where((model) => model.isActive == isActive).toList();
          return Right(filtered);
        } catch (e) {
          return const Left(
            CacheFailure(message: 'Dados não disponíveis offline'),
          );
        }
      }
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro ao buscar por status',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<TemplateExampleEntity>>> getByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Busca geral e filtra por data
      final allResult = await getAll();
      
      return allResult.fold(
        (failure) => Left(failure),
        (items) {
          final filtered = items.where((item) {
            return item.createdAt.isAfter(startDate) &&
                   item.createdAt.isBefore(endDate);
          }).toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro ao buscar por período',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, TemplateExampleEntity>> toggleStatus(String id) async {
    try {
      // Busca o item atual
      final currentResult = await getById(id);
      
      return currentResult.fold(
        (failure) => Left(failure),
        (current) async {
          // Alterna o status
          final updated = current.copyWith(
            isActive: !current.isActive,
            updatedAt: DateTime.now(),
          );
          
          // Salva a alteração
          return await update(updated);
        },
      );
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro ao alternar status',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<TemplateExampleEntity>>> searchByTitle(String title) async {
    try {
      return await search(title, filters: {'field': 'title'});
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro ao buscar por título',
          details: e.toString(),
        ),
      );
    }
  }
}

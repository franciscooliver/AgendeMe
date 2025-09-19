import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../domain/entities/base_entity.dart';
import '../../domain/services/i_local_cache_service.dart';
import '../../error/failures.dart';

/// Helper class que implementa o padrão cache-first para repositories
/// 
/// Este helper pode ser usado por repositories para implementar o padrão
/// cache-first de forma consistente e reutilizável.
class CacheFirstHelper {
  final ILocalCacheService _cacheService;

  CacheFirstHelper({required ILocalCacheService cacheService})
      : _cacheService = cacheService;

  /// Busca dados usando estratégia cache-first
  /// 
  /// 1. Verifica cache local primeiro
  /// 2. Retorna dados do cache imediatamente se disponíveis
  /// 3. Busca dados frescos do servidor em paralelo
  /// 4. Atualiza cache e emite dados frescos
  Stream<Either<Failure, T>> getDataWithCache<T extends BaseEntity>({
    required String cacheKey,
    required Future<Either<Failure, T>> fetchFunction,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
    Duration? cacheExpiration,
  }) async* {
    // 1. Verificar cache primeiro
    if (_cacheService.hasValidCache(cacheKey, expiration: cacheExpiration)) {
      final cachedData = _cacheService.getData<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        try {
          final entity = fromJson(cachedData);
          yield Right(entity);
        } catch (e) {
          // Se falhar ao deserializar cache, continuar com fetch
          print('⚠️ Erro ao deserializar cache: $e');
        }
      }
    }

    // 2. Buscar dados frescos do servidor
    try {
      final result = await fetchFunction;
      
      if (result.isRight()) {
        final entity = result.getOrElse(() => throw Exception('Erro inesperado'));
        
        // 3. Atualizar cache com dados frescos
        try {
          final jsonData = toJson(entity);
          await _cacheService.saveDataWithTimestamp(cacheKey, jsonData);
        } catch (e) {
          print('⚠️ Erro ao salvar no cache: $e');
        }
        
        // 4. Emitir dados frescos
        yield Right(entity);
      } else {
        // Se houver falha, não emitir nada (mantém dados do cache se disponíveis)
        final failure = result.fold((f) => f, (_) => throw Exception('Erro inesperado'));
        print('❌ Erro ao buscar dados frescos: ${failure.message}');
      }
    } catch (e) {
      // Em caso de erro inesperado, emitir erro
      yield Left(ServerFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  /// Busca lista de dados usando estratégia cache-first
  Stream<Either<Failure, List<T>>> getDataListWithCache<T extends BaseEntity>({
    required String cacheKey,
    required Future<Either<Failure, List<T>>> fetchFunction,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
    Duration? cacheExpiration,
  }) async* {
    // 1. Verificar cache primeiro
    if (_cacheService.hasValidCache(cacheKey, expiration: cacheExpiration)) {
      final cachedData = _cacheService.getData<List<dynamic>>(cacheKey);
      if (cachedData != null) {
        try {
          final entities = cachedData
              .map((item) => fromJson(item as Map<String, dynamic>))
              .toList();
          yield Right(entities);
        } catch (e) {
          print('⚠️ Erro ao deserializar cache de lista: $e');
        }
      }
    }

    // 2. Buscar dados frescos do servidor
    try {
      final result = await fetchFunction;
      
      if (result.isRight()) {
        final entities = result.getOrElse(() => throw Exception('Erro inesperado'));
        
        // 3. Atualizar cache com dados frescos
        try {
          final jsonData = entities.map((entity) => toJson(entity)).toList();
          await _cacheService.saveDataWithTimestamp(cacheKey, jsonData);
        } catch (e) {
          print('⚠️ Erro ao salvar lista no cache: $e');
        }
        
        // 4. Emitir dados frescos
        yield Right(entities);
      } else {
        final failure = result.fold((f) => f, (_) => throw Exception('Erro inesperado'));
        print('❌ Erro ao buscar lista fresca: ${failure.message}');
      }
    } catch (e) {
      yield Left(ServerFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  /// Força refresh dos dados (ignora cache)
  Future<Either<Failure, T>> forceRefresh<T extends BaseEntity>({
    required String cacheKey,
    required Future<Either<Failure, T>> fetchFunction,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    try {
      final result = await fetchFunction;
      
      return result.fold(
        (failure) => Left(failure),
        (entity) async {
          // Atualizar cache com dados frescos
          try {
            final jsonData = toJson(entity);
            await _cacheService.saveDataWithTimestamp(cacheKey, jsonData);
            return Right(entity);
          } catch (e) {
            print('⚠️ Erro ao salvar no cache: $e');
            return Right(entity);
          }
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  /// Força refresh de lista de dados (ignora cache)
  Future<Either<Failure, List<T>>> forceRefreshList<T extends BaseEntity>({
    required String cacheKey,
    required Future<Either<Failure, List<T>>> fetchFunction,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    try {
      final result = await fetchFunction;
      
      return result.fold(
        (failure) => Left(failure),
        (entities) async {
          try {
            final jsonData = entities.map((entity) => toJson(entity)).toList();
            await _cacheService.saveDataWithTimestamp(cacheKey, jsonData);
            return Right(entities);
          } catch (e) {
            print('⚠️ Erro ao salvar lista no cache: $e');
            return Right(entities);
          }
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  /// Invalida cache para uma chave específica
  Future<Either<Failure, void>> invalidateCache(String cacheKey) async {
    try {
      await _cacheService.invalidateCache(cacheKey);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao invalidar cache: ${e.toString()}'));
    }
  }

  /// Invalida todo o cache
  Future<Either<Failure, void>> clearAllCache() async {
    try {
      await _cacheService.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao limpar cache: ${e.toString()}'));
    }
  }

  /// Acesso ao cache service para operações específicas
  ILocalCacheService get cacheService => _cacheService;
}

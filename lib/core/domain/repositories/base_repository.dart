import 'package:dartz/dartz.dart';
import '../../error/failures.dart';

/// Interface base abstrata para todos os repositórios do domínio
/// 
/// Define contratos padrão para operações CRUD que podem ser
/// implementados por repositórios específicos de cada feature
abstract class BaseRepository<T> {
  /// Busca uma entidade pelo ID
  Future<Either<Failure, T>> getById(String id);

  /// Busca todas as entidades (com paginação opcional)
  Future<Either<Failure, List<T>>> getAll({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
  });

  /// Cria uma nova entidade
  Future<Either<Failure, T>> create(T entity);

  /// Atualiza uma entidade existente
  Future<Either<Failure, T>> update(T entity);

  /// Remove uma entidade pelo ID
  Future<Either<Failure, void>> delete(String id);

  /// Verifica se uma entidade existe
  Future<Either<Failure, bool>> exists(String id);
}

/// Interface para repositórios que suportam busca
abstract class SearchableRepository<T> extends BaseRepository<T> {
  /// Busca entidades por texto
  Future<Either<Failure, List<T>>> search(
    String query, {
    Map<String, dynamic>? filters,
    int? page,
    int? limit,
  });
}

/// Interface para repositórios que suportam cache
abstract class CacheableRepository<T> extends BaseRepository<T> {
  /// Limpa o cache
  Future<Either<Failure, void>> clearCache();

  /// Atualiza o cache
  Future<Either<Failure, void>> refreshCache();
}

/// Interface para repositórios que suportam sincronização
abstract class SyncableRepository<T> extends BaseRepository<T> {
  /// Sincroniza dados locais com remotos
  Future<Either<Failure, void>> sync();

  /// Verifica se há dados para sincronizar
  Future<Either<Failure, bool>> hasPendingSync();
}

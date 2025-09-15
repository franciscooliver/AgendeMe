import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';
import '../entities/service_entity.dart';

/// Repositório abstrato para operações de serviços
/// 
/// Define os contratos para CRUD operations com serviços no Firestore
/// Implementação concreta fica na camada data
abstract class ServiceRepository {
  /// Busca um serviço pelo ID
  /// 
  /// [id] - ID único do serviço
  /// Retorna [Right] com ServiceEntity se encontrado
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, ServiceEntity>> getService(String id);

  /// Busca todos os serviços de um profissional
  /// 
  /// [professionalId] - ID do profissional
  /// [includeInactive] - Se deve incluir serviços inativos
  /// Retorna [Right] com lista de ServiceEntity
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<ServiceEntity>>> getServicesByProfessional(
    String professionalId, {
    bool includeInactive = false,
  });

  /// Cria um novo serviço
  /// 
  /// [service] - Entidade do serviço a ser criado
  /// Retorna [Right] com ServiceEntity criado
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, ServiceEntity>> createService(ServiceEntity service);

  /// Atualiza um serviço existente
  /// 
  /// [service] - Entidade do serviço com dados atualizados
  /// Retorna [Right] com ServiceEntity atualizado
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, ServiceEntity>> updateService(ServiceEntity service);

  /// Remove um serviço (soft delete - marca como inativo)
  /// 
  /// [id] - ID único do serviço a ser removido
  /// Retorna [Right] com void se removido com sucesso
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, void>> deleteService(String id);

  /// Remove um serviço permanentemente do banco
  /// 
  /// [id] - ID único do serviço a ser removido permanentemente
  /// Retorna [Right] com void se removido com sucesso
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, void>> permanentDeleteService(String id);

  /// Lista todos os serviços ativos (com paginação)
  /// 
  /// [limit] - Número máximo de serviços a retornar
  /// [offset] - Número de serviços a pular (para paginação)
  /// Retorna [Right] com lista de ServiceEntity
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<ServiceEntity>>> getAllServices({
    int limit = 20,
    int offset = 0,
  });

  /// Busca serviços por categoria
  /// 
  /// [category] - Categoria dos serviços
  /// [limit] - Número máximo de serviços a retornar
  /// [offset] - Número de serviços a pular (para paginação)
  /// Retorna [Right] com lista de ServiceEntity
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<ServiceEntity>>> getServicesByCategory(
    String category, {
    int limit = 20,
    int offset = 0,
  });

  /// Busca serviços por faixa de preço
  /// 
  /// [minPrice] - Preço mínimo (opcional)
  /// [maxPrice] - Preço máximo (opcional)
  /// [limit] - Número máximo de serviços a retornar
  /// Retorna [Right] com lista de ServiceEntity
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<ServiceEntity>>> getServicesByPriceRange({
    double? minPrice,
    double? maxPrice,
    int limit = 20,
  });

  /// Busca serviços por duração
  /// 
  /// [minDuration] - Duração mínima em minutos (opcional)
  /// [maxDuration] - Duração máxima em minutos (opcional)
  /// [limit] - Número máximo de serviços a retornar
  /// Retorna [Right] com lista de ServiceEntity
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<ServiceEntity>>> getServicesByDuration({
    int? minDuration,
    int? maxDuration,
    int limit = 20,
  });

  /// Busca serviços por nome (pesquisa textual)
  /// 
  /// [searchTerm] - Termo de busca
  /// [limit] - Número máximo de serviços a retornar
  /// Retorna [Right] com lista de ServiceEntity
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<ServiceEntity>>> searchServicesByName(
    String searchTerm, {
    int limit = 20,
  });

  /// Ativa/desativa um serviço
  /// 
  /// [id] - ID do serviço
  /// [isActive] - Status ativo/inativo
  /// Retorna [Right] com void se atualizado com sucesso
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, void>> toggleServiceStatus(String id, bool isActive);

  /// Verifica se um serviço existe
  /// 
  /// [id] - ID do serviço
  /// Retorna [Right] com true se existe, false caso contrário
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, bool>> serviceExists(String id);

  /// Obtém estatísticas de serviços de um profissional
  /// 
  /// [professionalId] - ID do profissional
  /// Retorna [Right] com Map contendo estatísticas
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, Map<String, dynamic>>> getServiceStatistics(
    String professionalId,
  );
}

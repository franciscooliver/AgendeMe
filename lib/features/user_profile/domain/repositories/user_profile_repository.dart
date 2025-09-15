import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';
import '../entities/user_profile_entity.dart';

/// Repositório abstrato para operações de perfil de usuário
/// 
/// Define os contratos para CRUD operations com profiles no Firestore
/// Implementação concreta fica na camada data
abstract class UserProfileRepository {
  /// Busca um perfil de usuário pelo ID
  /// 
  /// [id] - ID único do perfil de usuário
  /// Retorna [Right] com UserProfileEntity se encontrado
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, UserProfileEntity>> getUserProfile(String id);

  /// Busca um perfil de usuário pelo userId (ID do Firebase Auth)
  /// 
  /// [userId] - ID do usuário no Firebase Auth
  /// Retorna [Right] com UserProfileEntity se encontrado
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, UserProfileEntity>> getUserProfileByUserId(String userId);

  /// Cria um novo perfil de usuário
  /// 
  /// [userProfile] - Entidade do perfil a ser criada
  /// Retorna [Right] com UserProfileEntity criado
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, UserProfileEntity>> createUserProfile(
    UserProfileEntity userProfile
  );

  /// Atualiza um perfil de usuário existente
  /// 
  /// [userProfile] - Entidade do perfil com dados atualizados
  /// Retorna [Right] com UserProfileEntity atualizado
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, UserProfileEntity>> updateUserProfile(
    UserProfileEntity userProfile
  );

  /// Remove um perfil de usuário
  /// 
  /// [id] - ID único do perfil a ser removido
  /// Retorna [Right] com void se removido com sucesso
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, void>> deleteUserProfile(String id);

  /// Lista todos os perfis de usuário (com paginação)
  /// 
  /// [limit] - Número máximo de perfis a retornar
  /// [offset] - Número de perfis a pular (para paginação)
  /// Retorna [Right] com lista de UserProfileEntity
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<UserProfileEntity>>> getAllUserProfiles({
    int limit = 20,
    int offset = 0,
  });

  /// Busca perfis por tipo de usuário
  /// 
  /// [userType] - Tipo de usuário para filtrar (client/professional)
  /// [limit] - Número máximo de perfis a retornar
  /// [offset] - Número de perfis a pular (para paginação)
  /// Retorna [Right] com lista de UserProfileEntity
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<UserProfileEntity>>> getUserProfilesByType(
    String userType, {
    int limit = 20,
    int offset = 0,
  });

  /// Busca perfis profissionais por cidade
  /// 
  /// [city] - Cidade para filtrar profissionais
  /// [limit] - Número máximo de perfis a retornar
  /// Retorna [Right] com lista de UserProfileEntity de profissionais
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<UserProfileEntity>>> getProfessionalsByCity(
    String city, {
    int limit = 20,
  });

  /// Busca perfis profissionais por serviço oferecido
  /// 
  /// [service] - Serviço para filtrar profissionais
  /// [limit] - Número máximo de perfis a retornar
  /// Retorna [Right] com lista de UserProfileEntity de profissionais
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, List<UserProfileEntity>>> getProfessionalsByService(
    String service, {
    int limit = 20,
  });

  /// Verifica se um perfil existe para determinado userId
  /// 
  /// [userId] - ID do usuário no Firebase Auth
  /// Retorna [Right] com true se existe, false caso contrário
  /// Retorna [Left] com Failure em caso de erro
  Future<Either<Failure, bool>> userProfileExists(String userId);
}

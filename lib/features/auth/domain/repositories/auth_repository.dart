import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Criar uma nova conta de usuário com email e senha
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    String? name,
  });

  /// Fazer login com email e senha
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  /// Fazer logout do usuário atual
  Future<Either<Failure, Unit>> signOut();

  /// Verificar se há um usuário logado
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Stream do estado de autenticação
  Stream<UserEntity?> get authStateChanges;
}

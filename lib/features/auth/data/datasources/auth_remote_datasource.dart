import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Criar conta com email e senha
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? name,
  });

  /// Login com email e senha
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  /// Logout
  Future<void> signOut();

  /// Obter usuário atual
  Future<UserModel?> getCurrentUser();

  /// Stream do estado de autenticação
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Falha ao criar conta');
      }

      // Atualizar o displayName se fornecido
      if (name != null && name.trim().isNotEmpty) {
        await credential.user!.updateDisplayName(name.trim());
        // Recarregar o usuário para obter os dados atualizados
        await credential.user!.reload();
      }

      return UserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Erro inesperado: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Falha ao fazer login');
      }

      return UserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Erro inesperado: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      print('🔍 DEBUG: AuthRemoteDataSource - Iniciando Firebase signOut...');
      await firebaseAuth.signOut();
      print('🔍 DEBUG: AuthRemoteDataSource - Firebase signOut concluído com sucesso');
    } catch (e) {
      print('🔍 DEBUG: AuthRemoteDataSource - Erro no Firebase signOut: $e');
      throw Exception('Erro ao fazer logout: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) return null;
      
      return UserModel.fromFirebaseUser(currentUser);
    } catch (e) {
      throw Exception('Erro ao obter usuário atual: ${e.toString()}');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().map((user) {
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    });
  }

  /// Mapear exceções do Firebase para mensagens amigáveis
  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('A senha é muito fraca');
      case 'email-already-in-use':
        return Exception('Este email já está em uso');
      case 'invalid-email':
        return Exception('Email inválido');
      case 'operation-not-allowed':
        return Exception('Operação não permitida');
      case 'user-disabled':
        return Exception('Esta conta foi desabilitada');
      case 'user-not-found':
        return Exception('Usuário não encontrado');
      case 'wrong-password':
        return Exception('Senha incorreta');
      case 'invalid-credential':
        return Exception('Credenciais inválidas');
      case 'too-many-requests':
        return Exception('Muitas tentativas. Tente novamente mais tarde');
      case 'network-request-failed':
        return Exception('Erro de conexão');
      default:
        return Exception('Erro de autenticação: ${e.message}');
    }
  }
}

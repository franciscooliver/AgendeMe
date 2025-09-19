import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/core.dart';
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
  final ILocalCacheService localCacheService;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.localCacheService,
  });

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

      final userModel = UserModel.fromFirebaseUser(credential.user!);
      
      // Salvar dados de autenticação no cache local
      await _saveAuthDataToCache(userModel);
      
      return userModel;
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

      final userModel = UserModel.fromFirebaseUser(credential.user!);
      
      // Salvar dados de autenticação no cache local
      await _saveAuthDataToCache(userModel);
      
      return userModel;
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
      
      // Limpar dados de autenticação do cache local
      print('🔍 DEBUG: AuthRemoteDataSource - Limpando cache local...');
      await localCacheService.clearAuthData();
      print('🔍 DEBUG: AuthRemoteDataSource - Cache local limpo com sucesso');
    } catch (e) {
      print('🔍 DEBUG: AuthRemoteDataSource - Erro no Firebase signOut: $e');
      throw Exception('Erro ao fazer logout: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      print('🔍 DEBUG: getCurrentUser() - Firebase currentUser: ${currentUser?.email}');
      
      // SEMPRE verificar cache primeiro para debug
      final cachedAuthData = localCacheService.getAuthData();
      print('🔍 DEBUG: getCurrentUser() - Cache data: $cachedAuthData');
      
      if (currentUser == null) {
        // Se não há usuário no Firebase, verificar cache local
        if (cachedAuthData != null) {
          print('🔍 DEBUG: Firebase não tem usuário, mas cache local tem dados de auth');
          
          // Tentar reautenticar usando dados do cache
          final userModel = UserModel(
            id: cachedAuthData['uid'] as String,
            email: cachedAuthData['email'] as String,
            emailVerified: true, // Assumir que estava verificado antes
          );
          
          print('🔍 DEBUG: Retornando UserModel baseado no cache: ${userModel.email}');
          return userModel;
        }
        
        print('🔍 DEBUG: Nenhum usuário no Firebase nem no cache');
        return null;
      }
      
      print('🔍 DEBUG: Usuário encontrado no Firebase: ${currentUser.email}');
      final userModel = UserModel.fromFirebaseUser(currentUser);
      
      // Atualizar cache local com dados atuais
      await _saveAuthDataToCache(userModel);
      
      return userModel;
    } catch (e) {
      print('🔍 DEBUG: Erro ao obter usuário atual: $e');
      throw Exception('Erro ao obter usuário atual: ${e.toString()}');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().map((user) {
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    });
  }

  /// Salvar dados de autenticação no cache local
  Future<void> _saveAuthDataToCache(UserModel userModel) async {
    try {
      print('🔍 DEBUG: AuthRemoteDataSource._saveAuthDataToCache() - Salvando dados para: ${userModel.email}');
      // Para determinar se é profissional, precisamos verificar o perfil do usuário
      // Por enquanto, vamos assumir que não é profissional (será atualizado quando o perfil for carregado)
      await localCacheService.saveAuthData(
        uid: userModel.id,
        email: userModel.email,
        isProfessional: false, // Será atualizado quando o perfil for carregado
      );
      print('🔍 DEBUG: AuthRemoteDataSource._saveAuthDataToCache() - Dados salvos com sucesso');
    } catch (e) {
      // Log do erro mas não falha a operação principal
      print('🔍 DEBUG: Erro ao salvar dados no cache: $e');
    }
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

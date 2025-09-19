import 'package:get/get.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/data/services/local_cache_service_impl.dart';
import '../../../../core/domain/services/i_local_cache_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/models/user_model.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';

class AuthController extends GetxController {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthController({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
  });

  // Estados observáveis
  final _currentUser = Rxn<UserEntity>();
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  // Getters
  UserEntity? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get isAuthenticated => _currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    print('🔍 DEBUG: AuthController.onInit() iniciado');
    print('🔍 DEBUG: AuthController.onInit() - Verificando dependências...');
    
    // Usar Future.microtask para garantir que a inicialização aconteça após o build
    Future.microtask(() async {
      try {
        // Testar GetStorage
        print('🔍 DEBUG: AuthController.onInit() - Obtendo cache service...');
        final cacheService = Modular.get<ILocalCacheService>();
        print('🔍 DEBUG: AuthController.onInit() - Cache service obtido: ${cacheService.runtimeType}');
        
        if (cacheService is LocalCacheServiceImpl) {
          print('🔍 DEBUG: AuthController.onInit() - Testando GetStorage...');
          cacheService.testGetStorage();
        } else {
          print('🔍 DEBUG: AuthController.onInit() - Cache service não é LocalCacheServiceImpl!');
        }
        
        // VERIFICAR CACHE PRIMEIRO antes de chamar checkCurrentUser
        print('🔍 DEBUG: AuthController.onInit() - Verificando cache primeiro...');
        final cacheData = cacheService.getAuthData();
        if (cacheData != null) {
          print('🔍 DEBUG: AuthController.onInit() - Cache encontrado, configurando usuário imediatamente');
          final userModel = UserModel(
            id: cacheData['uid'] as String,
            email: cacheData['email'] as String,
            emailVerified: true,
          );
          _currentUser.value = userModel;
          print('🔍 DEBUG: AuthController.onInit() - Usuário configurado via cache: ${userModel.email}');
          print('🔍 DEBUG: AuthController.onInit() - isAuthenticated: $isAuthenticated');
        } else {
          print('🔍 DEBUG: AuthController.onInit() - Nenhum cache encontrado');
        }
        
        print('🔍 DEBUG: AuthController.onInit() - Chamando checkCurrentUser...');
        await checkCurrentUser();
      } catch (e) {
        print('🔍 DEBUG: AuthController.onInit() - ERRO: $e');
      }
    });
  }

  /// Verificar se há usuário logado
  Future<void> checkCurrentUser() async {
    print('🔍 DEBUG: AuthController.checkCurrentUser() iniciado');
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await getCurrentUserUseCase(NoParams());

    result.fold(
      (failure) {
        print('🔍 DEBUG: AuthController - Falha ao obter usuário: ${failure.message}');
        _errorMessage.value = failure.message;
        _currentUser.value = null;
      },
      (user) {
        print('🔍 DEBUG: AuthController - Usuário encontrado: ${user?.email}');
        _currentUser.value = user;
      },
    );

    print('🔍 DEBUG: AuthController - isAuthenticated: $isAuthenticated');
    print('🔍 DEBUG: AuthController - currentUser: ${_currentUser.value?.email}');
    _isLoading.value = false;
  }

  /// Fazer login
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await signInUseCase(SignInParams(
      email: email,
      password: password,
    ));

    _isLoading.value = false;

    return result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        return false;
      },
      (user) {
        _currentUser.value = user;
        _errorMessage.value = '';
        return true;
      },
    );
  }

  /// Criar conta
  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await signUpUseCase(SignUpParams(
      email: email,
      password: password,
      name: name,
    ));

    _isLoading.value = false;

    return result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        return false;
      },
      (user) {
        _currentUser.value = user;
        _errorMessage.value = '';
        return true;
      },
    );
  }

  /// Fazer logout
  Future<bool> signOut() async {
    print('🔍 DEBUG: Iniciando processo de logout...');
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      print('🔍 DEBUG: Chamando signOutUseCase...');
      final result = await signOutUseCase(NoParams());
      print('🔍 DEBUG: signOutUseCase retornou resultado');

      return result.fold(
        (failure) {
          print('🔍 DEBUG: Falha no logout: ${failure.message}');
          _errorMessage.value = failure.message;
          _isLoading.value = false;
          
          return false;
        },
        (_) {
          print('🔍 DEBUG: Logout bem-sucedido, limpando estado...');
          _currentUser.value = null;
          _errorMessage.value = '';
          _isLoading.value = false;
          
          print('🔍 DEBUG: Navegando para / (rota raiz)...');
          // Navegar para a rota raiz, deixando o AuthWrapperPage gerenciar a navegação
          Modular.to.pushReplacementNamed('/');
          
          return true;
        },
      );
    } catch (e) {
      print('🔍 DEBUG: Erro inesperado no logout: $e');
      _isLoading.value = false;
      
      return false;
    }
  }

  /// Limpar mensagem de erro
  void clearError() {
    _errorMessage.value = '';
  }
}

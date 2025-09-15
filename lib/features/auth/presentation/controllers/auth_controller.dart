import 'package:get/get.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
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
    checkCurrentUser();
  }

  /// Verificar se há usuário logado
  Future<void> checkCurrentUser() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await getCurrentUserUseCase(NoParams());

    result.fold(
      (failure) => _errorMessage.value = failure.message,
      (user) => _currentUser.value = user,
    );

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
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await signUpUseCase(SignUpParams(
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

  /// Fazer logout
  Future<bool> signOut() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await signOutUseCase(NoParams());

    _isLoading.value = false;

    return result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        return false;
      },
      (_) {
        _currentUser.value = null;
        _errorMessage.value = '';
        return true;
      },
    );
  }

  /// Limpar mensagem de erro
  void clearError() {
    _errorMessage.value = '';
  }
}

import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/user_type.dart';
import 'user_profile_controller.dart';

/// Controller para gerenciar a seleção de tipo de usuário
/// 
/// Responsável por:
/// - Gerenciar a seleção do tipo de usuário (Cliente/Profissional)
/// - Criar perfil inicial no Firestore após seleção
/// - Coordenar navegação para dashboard apropriado
/// - Tratar erros e estados de loading
class UserTypeSelectionController extends GetxController {
  late final UserProfileController _userProfileController;
  late final AuthController _authController;

  UserTypeSelectionController({
    UserProfileController? userProfileController,
    AuthController? authController,
  }) {
    try {
      _userProfileController = userProfileController ?? Modular.get<UserProfileController>();
      _authController = authController ?? Modular.get<AuthController>();
      print('✅ UserTypeSelectionController inicializado com sucesso');
    } catch (e) {
      print('❌ Erro ao inicializar UserTypeSelectionController: $e');
      rethrow;
    }
  }

  // Estado reativo
  final Rxn<UserType> _selectedUserType = Rxn<UserType>();
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // Getters
  UserType? get selectedUserType => _selectedUserType.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get hasSelection => _selectedUserType.value != null;

  /// Seleciona o tipo de usuário
  void selectUserType(UserType userType) {
    _selectedUserType.value = userType;
    _errorMessage.value = '';
  }

  /// Cria o perfil inicial com o tipo selecionado
  Future<void> createProfile() async {
    print('🚀 CreateProfile iniciado');
    
    if (_selectedUserType.value == null) {
      print('❌ Erro: Nenhum tipo selecionado');
      _errorMessage.value = 'Por favor, selecione um tipo de usuário';
      return;
    }

    print('✅ Tipo selecionado: ${_selectedUserType.value}');

    final currentUser = _authController.currentUser;
    if (currentUser == null) {
      print('❌ Erro: Usuário não encontrado');
      _errorMessage.value = 'Usuário não encontrado. Faça login novamente.';
      return;
    }

    print('✅ Usuário atual: ${currentUser.email}');

    try {
      print('🔄 Iniciando loading...');
      _isLoading.value = true;
      _errorMessage.value = '';

      print('📝 Criando perfil básico...');
      // Criar perfil básico
      final success = await _userProfileController.createProfile(
        userId: currentUser.id,
        name: currentUser.displayName ?? currentUser.email.split('@')[0],
        email: currentUser.email,
        userType: _selectedUserType.value!,
      );

      print('✅ Resultado da criação: $success');

      if (success) {
        print('✅ Perfil criado com sucesso! A UI irá observar e navegar automaticamente.');
        // A navegação será feita pela UI ao observar o estado de sucesso
        // Não fazemos navegação aqui para evitar conflitos
      } else {
        print('❌ Falha na criação do perfil');
        // Estado de erro é gerenciado pelo UserProfileController
        // A UI irá observar e mostrar feedback adequado
      }
    } catch (e) {
      print('💥 Erro na criação do perfil: $e');
      _errorMessage.value = 'Erro inesperado: $e';
      // Estado de erro é gerenciado aqui e pelo UserProfileController
      // A UI irá observar e mostrar feedback adequado
    } finally {
      print('⏹️ Finalizando loading...');
      _isLoading.value = false;
    }
  }

  /// Navega para o dashboard apropriado baseado no tipo de usuário
  Future<void> _navigateToAppropiateDashboard() async {
    if (_selectedUserType.value == null) return;

    try {
      switch (_selectedUserType.value!) {
        case UserType.client:
          // TODO: Navegar para dashboard do cliente quando implementado
          print('✅ Navegando para dashboard do cliente');
          // Por enquanto, ir para home
          Modular.to.pushReplacementNamed('/');
          break;
          
        case UserType.professional:
          // Navegar para calendário profissional
          print('✅ Navegando para calendário profissional');
          Modular.to.pushReplacementNamed('/professional/calendar');
          break;
      }
    } catch (e) {
      // Log do erro para debug (pode ser removido em produção)
      // Fallback para home em caso de erro na navegação
      Modular.to.pushReplacementNamed('/');
    }
  }

  /// Faz logout do usuário
  Future<void> logout() async {
    try {
      _isLoading.value = true;
      
      final success = await _authController.signOut();
      
      if (success) {
        // Limpar estado
        _selectedUserType.value = null;
        _errorMessage.value = '';
        
        // Navegar para login
        Modular.to.pushReplacementNamed('/auth/login');
      } else {
        print('❌ Erro ao fazer logout');
        _errorMessage.value = 'Não foi possível fazer logout. Tente novamente.';
      }
    } catch (e) {
      print('💥 Erro inesperado ao fazer logout: $e');
      _errorMessage.value = 'Erro inesperado ao fazer logout.';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage.value = '';
  }

  /// Limpa o estado do controller
  void clearState() {
    _selectedUserType.value = null;
    _errorMessage.value = '';
    _isLoading.value = false;
  }

  /// Valida se pode continuar com a criação do perfil
  bool get canProceed {
    return _selectedUserType.value != null && 
           !_isLoading.value && 
           _authController.isAuthenticated;
  }

  /// Retorna uma descrição amigável do tipo selecionado
  String get selectedUserTypeDescription {
    switch (_selectedUserType.value) {
      case UserType.client:
        return 'Como cliente, você poderá agendar serviços com profissionais.';
      case UserType.professional:
        return 'Como profissional, você poderá gerenciar sua agenda e oferecer serviços.';
      case null:
        return 'Selecione um tipo de usuário para continuar.';
    }
  }

  @override
  void onClose() {
    // Limpar estado ao fechar o controller
    clearState();
    super.onClose();
  }
}

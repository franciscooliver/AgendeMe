import 'package:get/get.dart';

import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/user_type.dart';
import '../../domain/usecases/create_user_profile.dart';
import '../../domain/usecases/get_user_profile_by_user_id.dart';
import '../../domain/usecases/update_user_profile.dart';

/// Controller para gerenciar o estado do perfil de usuário
/// 
/// Responsável por:
/// - Gerenciar estado reativo do perfil do usuário
/// - Coordenar use cases de CRUD do perfil
/// - Validar dados do formulário
/// - Feedback visual para o usuário
class UserProfileController extends GetxController {
  final GetUserProfileByUserId getUserProfileByUserId;
  final CreateUserProfile createUserProfile;
  final UpdateUserProfile updateUserProfile;

  UserProfileController({
    required this.getUserProfileByUserId,
    required this.createUserProfile,
    required this.updateUserProfile,
  });

  // Estado reativo
  final Rx<UserProfileEntity?> _userProfile = Rx<UserProfileEntity?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _hasProfile = false.obs;
  final RxBool _lastOperationSuccess = false.obs;
  final RxString _lastSuccessMessage = ''.obs;

  // Getters
  UserProfileEntity? get userProfile => _userProfile.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get hasProfile => _hasProfile.value;
  bool get lastOperationSuccess => _lastOperationSuccess.value;
  String get lastSuccessMessage => _lastSuccessMessage.value;

  /// Carrega o perfil do usuário pelo userId do Firebase Auth
  Future<void> loadUserProfile(String userId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await getUserProfileByUserId(
        GetUserProfileByUserIdParams(userId: userId),
      );

      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          _hasProfile.value = false;
          _userProfile.value = null;
        },
        (profile) {
          _userProfile.value = profile;
          _hasProfile.value = true;
        },
      );
    } catch (e) {
      _errorMessage.value = 'Erro inesperado ao carregar perfil: $e';
      _hasProfile.value = false;
      _userProfile.value = null;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Cria um novo perfil de usuário
  Future<bool> createProfile({
    required String userId,
    required String name,
    required String email,
    required UserType userType,
    String? bio,
    String? phone,
    String? address,
    String? city,
    String? state,
    List<String>? services,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final newProfile = UserProfileEntity(
        id: '', // Será gerado pelo Firestore
        userId: userId,
        name: name,
        email: email,
        userType: userType,
        bio: bio,
        phone: phone,
        address: address,
        city: city,
        state: state,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        services: services,
      );

      final result = await createUserProfile(
        CreateUserProfileParams(userProfile: newProfile),
      );

      return result.fold(
        (failure) {
          print('❌ Falha na criação do perfil: ${failure.message}');
          _errorMessage.value = failure.message;
          _hasProfile.value = false;
          _userProfile.value = null;
          _lastOperationSuccess.value = false;
          _lastSuccessMessage.value = '';
          return false;
        },
        (createdProfile) {
          print('✅ Perfil criado com sucesso: ${createdProfile.id}');
          _userProfile.value = createdProfile;
          _hasProfile.value = true;
          _errorMessage.value = '';
          _lastOperationSuccess.value = true;
          _lastSuccessMessage.value = 'Perfil criado com sucesso!';
          return true;
        },
      );
    } catch (e) {
      print('💥 Erro inesperado na criação do perfil: $e');
      _errorMessage.value = 'Erro inesperado ao criar perfil: $e';
      _hasProfile.value = false;
      _userProfile.value = null;
      _lastOperationSuccess.value = false;
      _lastSuccessMessage.value = '';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Atualiza o perfil de usuário existente
  Future<bool> updateProfile({
    required String name,
    required String email,
    String? bio,
    String? phone,
    String? address,
    String? city,
    String? state,
    List<String>? services,
    Map<String, dynamic>? workingHours,
    Map<String, dynamic>? pricing,
  }) async {
    if (_userProfile.value == null) {
      _errorMessage.value = 'Nenhum perfil carregado para atualizar';
      return false;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final updatedProfile = _userProfile.value!.copyWith(
        name: name,
        email: email,
        bio: bio,
        phone: phone,
        address: address,
        city: city,
        state: state,
        services: services,
        workingHours: workingHours,
        pricing: pricing,
        updatedAt: DateTime.now(),
      );

      final result = await updateUserProfile(
        UpdateUserProfileParams(userProfile: updatedProfile),
      );

      bool success = false;
      String message = '';
      
      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          message = failure.message;
          success = false;
        },
        (updatedProfileResult) {
          _userProfile.value = updatedProfileResult;
          message = 'Perfil atualizado com sucesso!';
          success = true;
        },
      );

      // Mostrar feedback após o fold para evitar problemas com GetX
      try {
        if (success) {
          Get.snackbar(
            'Sucesso',
            message,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            'Erro',
            message,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        print('⚠️ Erro ao mostrar snackbar: $e');
      }

      return success;
    } catch (e) {
      _errorMessage.value = 'Erro inesperado ao atualizar perfil: $e';
      try {
        Get.snackbar(
          'Erro',
          'Erro inesperado ao atualizar perfil',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (snackbarError) {
        print('⚠️ Erro ao mostrar snackbar de erro: $snackbarError');
      }
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage.value = '';
  }

  /// Limpa mensagens de sucesso
  void clearSuccess() {
    _lastOperationSuccess.value = false;
    _lastSuccessMessage.value = '';
  }

  /// Limpa todos os feedback (erro e sucesso)
  void clearFeedback() {
    clearError();
    clearSuccess();
  }

  /// Limpa estado do controller
  void clearState() {
    _userProfile.value = null;
    _hasProfile.value = false;
    _errorMessage.value = '';
    _isLoading.value = false;
    _lastOperationSuccess.value = false;
    _lastSuccessMessage.value = '';
  }

  /// Verifica se o usuário tem informações básicas completas
  bool get hasBasicInfo => _userProfile.value?.hasBasicInfo ?? false;

  /// Verifica se o usuário tem informações de contato
  bool get hasContactInfo => _userProfile.value?.hasContactInfo ?? false;

  /// Verifica se o usuário tem localização
  bool get hasLocation => _userProfile.value?.hasLocation ?? false;

  /// Verifica se o perfil está completo
  bool get isProfileComplete => _userProfile.value?.isComplete ?? false;

  /// Verifica se o usuário é um profissional
  bool get isProfessional => _userProfile.value?.isProfessional ?? false;

  /// Verifica se o usuário é um cliente
  bool get isClient => _userProfile.value?.isClient ?? false;
}

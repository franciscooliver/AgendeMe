import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/core.dart';
import '../../../../core/data/helpers/cache_first_helper.dart';
import '../../../../core/domain/services/i_local_cache_service.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/user_type.dart';
import '../../domain/usecases/create_user_profile.dart';
import '../../domain/usecases/get_user_profile_by_user_id.dart';
import '../../domain/usecases/update_user_profile.dart';
import '../../domain/usecases/upload_profile_picture_usecase.dart';
import '../../data/models/user_profile_model.dart';

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
  final UploadProfilePictureUseCase uploadProfilePictureUseCase;
  late final CacheFirstHelper _cacheHelper;

  UserProfileController({
    required this.getUserProfileByUserId,
    required this.createUserProfile,
    required this.updateUserProfile,
    required this.uploadProfilePictureUseCase,
  }) {
    // Inicializar cache helper
    final cacheService = Modular.get<ILocalCacheService>();
    _cacheHelper = CacheFirstHelper(cacheService: cacheService);
  }

  // Estado reativo
  final Rx<UserProfileEntity?> _userProfile = Rx<UserProfileEntity?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _hasProfile = false.obs;
  final RxBool _lastOperationSuccess = false.obs;
  final RxString _lastSuccessMessage = ''.obs;
  
  // Estados específicos para upload de foto de perfil
  final RxBool _isUploadingProfilePicture = false.obs;
  final RxString _profilePictureError = ''.obs;

  // Getters
  UserProfileEntity? get userProfile => _userProfile.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get hasProfile => _hasProfile.value;
  bool get lastOperationSuccess => _lastOperationSuccess.value;
  String get lastSuccessMessage => _lastSuccessMessage.value;
  
  // Getters para upload de foto de perfil
  bool get isUploadingProfilePicture => _isUploadingProfilePicture.value;
  String get profilePictureError => _profilePictureError.value;

  /// Carrega o perfil do usuário pelo userId do Firebase Auth usando cache-first
  Future<void> loadUserProfile(String userId) async {
    try {
      print('🔍 UserProfileController: Iniciando loadUserProfile com cache-first para $userId');
      _isLoading.value = true;
      _errorMessage.value = '';

      // Verificar cache primeiro
      final cacheKey = 'user_profile_$userId';
      final cachedData = _cacheHelper.cacheService.getData<Map<String, dynamic>>(cacheKey);
      
      if (cachedData != null) {
        print('🔍 UserProfileController: Cache encontrado, carregando dados do cache');
        try {
          final cachedProfile = UserProfileModel.fromJson(cachedData).toEntity();
          _userProfile.value = cachedProfile;
          _hasProfile.value = true;
          print('🔍 UserProfileController: Dados do cache carregados: ${cachedProfile.name}');
        } catch (e) {
          print('🔍 UserProfileController: Erro ao processar cache: $e');
        }
      }

      // Buscar dados frescos em paralelo
      print('🔍 UserProfileController: Buscando dados frescos do servidor');
      final result = await getUserProfileByUserId(
        GetUserProfileByUserIdParams(userId: userId),
      );

      print('🔍 UserProfileController: Resultado obtido do usecase');
      
      result.fold(
        (failure) {
          print('🔍 UserProfileController: Failure recebido: ${failure.runtimeType} - ${failure.message}');
          if (failure is NotFoundFailure) {
            // Usuário genuinamente não tem perfil - não é erro
            print('🔍 UserProfileController: NotFoundFailure - usuário não tem perfil');
            _hasProfile.value = false;
            _userProfile.value = null;
            _errorMessage.value = ''; // Limpar erro pois não é um erro real
            // Limpar cache se não há perfil
            _cacheHelper.cacheService.removeData(cacheKey);
          } else {
            // Erro real durante a busca do perfil
            print('🔍 UserProfileController: Erro real: ${failure.message}');
            _errorMessage.value = failure.message;
            // Não alterar hasProfile se temos cache válido
            if (cachedData == null) {
              _hasProfile.value = false;
              _userProfile.value = null;
            }
          }
        },
        (profile) {
          print('🔍 UserProfileController: Perfil encontrado: ${profile.name} - ${profile.userType}');
          _userProfile.value = profile;
          _hasProfile.value = true;
          
          // Salvar no cache
          try {
            final profileModel = UserProfileModel.fromEntity(profile);
            _cacheHelper.cacheService.saveData(cacheKey, profileModel.toJson());
            print('🔍 UserProfileController: Perfil salvo no cache');
          } catch (e) {
            print('🔍 UserProfileController: Erro ao salvar no cache: $e');
          }
        },
      );
      
      print('🔍 UserProfileController: Estado final - hasProfile: ${_hasProfile.value}, errorMessage: ${_errorMessage.value}');
    } catch (e) {
      print('🔍 UserProfileController: Exception capturada: $e');
      _errorMessage.value = 'Erro inesperado ao carregar perfil: $e';
      // Não alterar hasProfile se temos cache válido
      final cacheKey = 'user_profile_$userId';
      final cachedData = _cacheHelper.cacheService.getData<Map<String, dynamic>>(cacheKey);
      if (cachedData == null) {
        _hasProfile.value = false;
        _userProfile.value = null;
      }
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
          
          // Invalidar cache do perfil após atualização bem-sucedida
          _invalidateProfileCache(updatedProfileResult.userId);
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

  /// Atualiza o perfil local (usado por outros controllers)
  void updateLocalProfile(UserProfileEntity updatedProfile) {
    _userProfile.value = updatedProfile;
    _hasProfile.value = true;
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

  /// Limpa erro específico de foto de perfil
  void clearProfilePictureError() {
    _profilePictureError.value = '';
  }

  /// Faz upload de foto de perfil a partir da galeria
  Future<bool> uploadProfilePictureFromGallery() async {
    return await _uploadProfilePicture(
      UploadProfilePictureParams.fromGallery(),
    );
  }

  /// Faz upload de foto de perfil a partir da câmera
  Future<bool> uploadProfilePictureFromCamera() async {
    return await _uploadProfilePicture(
      UploadProfilePictureParams.fromCamera(),
    );
  }

  /// Método privado que executa o upload da foto de perfil
  Future<bool> _uploadProfilePicture(UploadProfilePictureParams params) async {
    try {
      _isUploadingProfilePicture.value = true;
      _profilePictureError.value = '';

      final result = await uploadProfilePictureUseCase(params);

      return result.fold(
        (failure) {
          _profilePictureError.value = failure.message;
          _showErrorFeedback('Erro no upload', failure.message);
          return false;
        },
        (downloadUrl) {
          // Atualizar perfil local com nova URL
          if (_userProfile.value != null) {
            _userProfile.value = _userProfile.value!.copyWith(
              profileImageUrl: downloadUrl,
              updatedAt: DateTime.now(),
            );
            
            // Invalidar cache do perfil após atualização da foto
            _invalidateProfileCache(_userProfile.value!.userId);
          }
          
          _showSuccessFeedback('Sucesso', 'Foto de perfil atualizada!');
          return true;
        },
      );

    } catch (e) {
      _profilePictureError.value = 'Erro inesperado: $e';
      _showErrorFeedback('Erro inesperado', 'Falha no upload da foto: $e');
      return false;
    } finally {
      _isUploadingProfilePicture.value = false;
    }
  }

  /// Obtém a URL da foto de perfil atual
  String? get currentProfilePictureUrl => _userProfile.value?.profileImageUrl;

  /// Verifica se o usuário tem foto de perfil
  bool get hasProfilePicture => currentProfilePictureUrl != null && 
                               currentProfilePictureUrl!.isNotEmpty;

  /// Verifica se existe um perfil para o userId (para debug)
  Future<bool> userProfileExists(String userId) async {
    try {
      // Usar o repository diretamente para verificar existência
      final result = await getUserProfileByUserId(
        GetUserProfileByUserIdParams(userId: userId),
      );
      
      return result.fold(
        (failure) => false, // Se deu failure, consideramos que não existe
        (profile) => true,  // Se encontrou profile, existe
      );
    } catch (e) {
      print('🔍 UserProfileController: Erro em userProfileExists: $e');
      return false;
    }
  }

  /// Mostra feedback de sucesso (evita problemas com GetX)
  void _showSuccessFeedback(String title, String message) {
    try {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } catch (e) {
      print('⚠️ Erro ao mostrar snackbar de sucesso: $e');
      // Fallback: usar print se snackbar falhar
      print('✅ $title: $message');
    }
  }

  /// Mostra feedback de erro (evita problemas com GetX)
  void _showErrorFeedback(String title, String message) {
    try {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } catch (e) {
      print('⚠️ Erro ao mostrar snackbar de erro: $e');
      // Fallback: usar print se snackbar falhar
      print('❌ $title: $message');
    }
  }

  /// Invalida cache do perfil após modificações
  void _invalidateProfileCache(String userId) {
    try {
      final cacheKey = 'user_profile_$userId';
      _cacheHelper.invalidateSpecificCache(cacheKey).then((result) {
        result.fold(
          (failure) => print('⚠️ Erro ao invalidar cache do perfil: ${failure.message}'),
          (_) => print('✅ Cache do perfil invalidado com sucesso'),
        );
      });
    } catch (e) {
      print('⚠️ Erro ao invalidar cache do perfil: $e');
    }
  }
}

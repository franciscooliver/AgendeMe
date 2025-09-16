import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import '../../../user_profile/presentation/controllers/user_profile_controller.dart';

/// Controller para gerenciar a configuração do perfil profissional
/// 
/// Responsável por:
/// - Gerenciar estado dos horários de trabalho
/// - Coordenar atualização do perfil profissional
/// - Validar dados de configuração
/// - Feedback visual para o usuário
class ProfessionalConfigController extends GetxController {
  late final UserProfileRepository _userProfileRepository;
  late final UserProfileController _userProfileController;

  // Controllers de texto
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();

  // Estado reativo
  final Rx<UserProfileEntity?> _userProfile = Rx<UserProfileEntity?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isSaving = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _hasUnsavedChanges = false.obs;

  // Horários de trabalho (dias da semana)
  final RxMap<String, Map<String, dynamic>> _workingDays = <String, Map<String, dynamic>>{
    'Segunda-feira': {'enabled': true, 'start': '08:00', 'end': '18:00'},
    'Terça-feira': {'enabled': true, 'start': '08:00', 'end': '18:00'},
    'Quarta-feira': {'enabled': true, 'start': '08:00', 'end': '18:00'},
    'Quinta-feira': {'enabled': true, 'start': '08:00', 'end': '18:00'},
    'Sexta-feira': {'enabled': true, 'start': '08:00', 'end': '18:00'},
    'Sábado': {'enabled': false, 'start': '08:00', 'end': '12:00'},
    'Domingo': {'enabled': false, 'start': '08:00', 'end': '12:00'},
  }.obs;

  @override
  void onInit() {
    super.onInit();
    _userProfileRepository = Modular.get<UserProfileRepository>();
    _userProfileController = Modular.get<UserProfileController>();
    
    // Listeners para detectar mudanças
    addressController.addListener(_onFormChanged);
    cityController.addListener(_onFormChanged);
    stateController.addListener(_onFormChanged);
  }

  // Getters
  UserProfileEntity? get userProfile => _userProfile.value;
  bool get isLoading => _isLoading.value;
  bool get isSaving => _isSaving.value;
  String get errorMessage => _errorMessage.value;
  bool get hasUnsavedChanges => _hasUnsavedChanges.value;
  Map<String, Map<String, dynamic>> get workingDays => _workingDays;

  /// Carrega o perfil do usuário atual
  Future<void> loadUserProfile() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _errorMessage.value = 'Usuário não autenticado';
        return;
      }

      // Buscar perfil do usuário
      final result = await _userProfileRepository.getUserProfileByUserId(currentUser.uid);
      
      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
        },
        (profile) {
          _userProfile.value = profile;
          _populateFormFields(profile);
        },
      );
    } catch (e) {
      _errorMessage.value = 'Erro ao carregar perfil: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Popula os campos do formulário com dados do perfil
  void _populateFormFields(UserProfileEntity profile) {
    // Campos de localização
    addressController.text = profile.address ?? '';
    cityController.text = profile.city ?? '';
    stateController.text = profile.state ?? '';

    // Horários de trabalho
    if (profile.workingHours != null) {
      _parseWorkingHours(profile.workingHours!);
    }

    // Marcar como sem alterações após popular
    _hasUnsavedChanges.value = false;
  }

  /// Converte horários do banco de dados para o formato do controller
  void _parseWorkingHours(Map<String, dynamic> workingHours) {
    for (final day in _workingDays.keys) {
      final dayKey = _getDayKey(day);
      if (workingHours.containsKey(dayKey)) {
        final dayData = workingHours[dayKey] as Map<String, dynamic>;
        _workingDays[day] = {
          'enabled': dayData['enabled'] ?? false,
          'start': dayData['start'] ?? '08:00',
          'end': dayData['end'] ?? '18:00',
        };
      }
    }
    _workingDays.refresh();
  }

  /// Converte nome do dia para chave do banco de dados
  String _getDayKey(String dayName) {
    final dayKeys = {
      'Segunda-feira': 'monday',
      'Terça-feira': 'tuesday',
      'Quarta-feira': 'wednesday',
      'Quinta-feira': 'thursday',
      'Sexta-feira': 'friday',
      'Sábado': 'saturday',
      'Domingo': 'sunday',
    };
    return dayKeys[dayName] ?? dayName.toLowerCase();
  }

  /// Atualiza status de trabalho de um dia
  void updateWorkingDay(String day, bool enabled) {
    _workingDays[day]!['enabled'] = enabled;
    _workingDays.refresh();
    _hasUnsavedChanges.value = true;
  }

  /// Atualiza horário de trabalho de um dia
  void updateWorkingTime(String day, TimeOfDay time, bool isStartTime) {
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    _workingDays[day]![isStartTime ? 'start' : 'end'] = timeString;
    _workingDays.refresh();
    _hasUnsavedChanges.value = true;
  }

  /// Obtém horário para um dia específico
  TimeOfDay getTimeForDay(String day, bool isStartTime) {
    final timeString = _workingDays[day]![isStartTime ? 'start' : 'end'] as String;
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Callback para mudanças nos campos de endereço
  void onAddressChanged(String value) {
    _hasUnsavedChanges.value = true;
  }

  /// Callback para mudanças no campo cidade
  void onCityChanged(String value) {
    _hasUnsavedChanges.value = true;
  }

  /// Callback para mudanças no campo estado
  void onStateChanged(String value) {
    _hasUnsavedChanges.value = true;
  }

  /// Listener genérico para mudanças no formulário
  void _onFormChanged() {
    _hasUnsavedChanges.value = true;
  }

  /// Salva toda a configuração do perfil profissional
  Future<bool> saveConfiguration() async {
    try {
      _isSaving.value = true;
      _errorMessage.value = '';

      final currentProfile = _userProfile.value;
      if (currentProfile == null) {
        _errorMessage.value = 'Perfil não carregado';
        return false;
      }

      // Preparar dados de horários de trabalho para o banco
      final workingHoursData = <String, dynamic>{};
      for (final entry in _workingDays.entries) {
        final dayKey = _getDayKey(entry.key);
        workingHoursData[dayKey] = entry.value;
      }

      // Criar perfil atualizado
      final updatedProfile = currentProfile.copyWith(
        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
        city: cityController.text.trim().isEmpty ? null : cityController.text.trim(),
        state: stateController.text.trim().isEmpty ? null : stateController.text.trim(),
        workingHours: workingHoursData,
        updatedAt: DateTime.now(),
      );

      // Salvar no repositório
      final result = await _userProfileRepository.updateUserProfile(updatedProfile);

      return result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          return false;
        },
        (savedProfile) {
          _userProfile.value = savedProfile;
          _hasUnsavedChanges.value = false;
          
          // Atualizar também o controller global do perfil
          _userProfileController.updateLocalProfile(savedProfile);
          
          return true;
        },
      );
    } catch (e) {
      _errorMessage.value = 'Erro ao salvar configuração: $e';
      return false;
    } finally {
      _isSaving.value = false;
    }
  }

  /// Validação básica dos campos obrigatórios
  bool validateForm() {
    if (cityController.text.trim().isEmpty) {
      _errorMessage.value = 'Cidade é obrigatória';
      return false;
    }

    if (stateController.text.trim().isEmpty) {
      _errorMessage.value = 'Estado é obrigatório';
      return false;
    }

    // Verificar se pelo menos um dia está habilitado
    final hasEnabledDay = _workingDays.values.any((day) => day['enabled'] == true);
    if (!hasEnabledDay) {
      _errorMessage.value = 'Configure pelo menos um dia de trabalho';
      return false;
    }

    return true;
  }

  /// Reseta formulário para os valores originais
  void resetForm() {
    final profile = _userProfile.value;
    if (profile != null) {
      _populateFormFields(profile);
    }
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage.value = '';
  }

  @override
  void onClose() {
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    super.onClose();
  }
}

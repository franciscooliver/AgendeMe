import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../../../services/domain/repositories/service_repository.dart';
import '../../domain/entities/available_time_slot_entity.dart';
import '../../domain/usecases/get_available_time_slots_usecase.dart';

/// Controller para gerenciar a visualização de horários disponíveis
/// 
/// Responsável por:
/// - Gerenciar estado da interface de horários disponíveis
/// - Coordenar busca de dados do profissional e serviços
/// - Calcular e exibir slots de tempo disponíveis
/// - Gerenciar seleção de data e serviço
class ProfessionalAvailabilityController extends GetxController {
  late final GetAvailableTimeSlotsUseCase _getAvailableTimeSlotsUseCase;
  late final UserProfileRepository _userProfileRepository;
  late final ServiceRepository _serviceRepository;

  // Parâmetros
  final String professionalId;

  // Estado reativo
  final Rx<UserProfileEntity?> _professional = Rx<UserProfileEntity?>(null);
  final RxList<ServiceEntity> _services = <ServiceEntity>[].obs;
  final RxList<AvailableTimeSlotEntity> _availableSlots = <AvailableTimeSlotEntity>[].obs;
  final Rx<DateTime> _selectedDate = DateTime.now().obs;
  final Rx<ServiceEntity?> _selectedService = Rx<ServiceEntity?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingSlots = false.obs;
  final RxString _errorMessage = ''.obs;

  ProfessionalAvailabilityController(this.professionalId) {
    print('🔍 DEBUG: ProfessionalAvailabilityController criado com ID: $professionalId');
    _getAvailableTimeSlotsUseCase = Modular.get<GetAvailableTimeSlotsUseCase>();
    _userProfileRepository = Modular.get<UserProfileRepository>();
    _serviceRepository = Modular.get<ServiceRepository>();
  }

  @override
  void onInit() {
    super.onInit();
    print('🔍 DEBUG: onInit chamado para professionalId: $professionalId');
    print('🔍 DEBUG: onInit - Iniciando carregamento de dados...');
    _loadProfessionalData();
  }

  // Getters
  UserProfileEntity? get professional => _professional.value;
  List<ServiceEntity> get services => _services;
  List<AvailableTimeSlotEntity> get availableSlots => _availableSlots;
  DateTime get selectedDate => _selectedDate.value;
  ServiceEntity? get selectedService => _selectedService.value;
  bool get isLoading => _isLoading.value;
  bool get isLoadingSlots => _isLoadingSlots.value;
  String get errorMessage => _errorMessage.value;

  /// Carrega dados do profissional e seus serviços
  Future<void> _loadProfessionalData() async {
    try {
      print('🔍 DEBUG: Carregando dados do profissional: $professionalId');
      print('🔍 DEBUG: Tipo do professionalId: ${professionalId.runtimeType}');
      print('🔍 DEBUG: Tamanho do professionalId: ${professionalId.length}');
      print('🔍 DEBUG: Professional: ${professional.toString()}');
      _isLoading.value = true;
      _errorMessage.value = '';

      // Abordagem simplificada: buscar todos os profissionais e filtrar
      print('🔍 DEBUG: Buscando todos os profissionais...');
      final allProfessionalsResult = await _userProfileRepository.getUserProfilesByType('professional', limit: 100);
      
      allProfessionalsResult.fold(
        (failure) {
          print('🔍 DEBUG: Erro ao buscar profissionais: ${failure.message}');
          _errorMessage.value = 'Erro ao carregar profissionais: ${failure.message}';
        },
        (professionals) {
          print('🔍 DEBUG: Profissionais encontrados: ${professionals.length}');
          
          // Log de todos os profissionais para debug
          for (final prof in professionals) {
            print('🔍 DEBUG: - ${prof.name}: userId=${prof.userId}, id=${prof.id}');
          }
          
          // Buscar o profissional pelo userId
          final matchingProfessional = professionals.where((p) => p.userId == professionalId).firstOrNull;
          
          if (matchingProfessional != null) {
            print('🔍 DEBUG: Profissional encontrado: ${matchingProfessional.name}');
            print('🔍 DEBUG: Profile ID: ${matchingProfessional.id}');
            print('🔍 DEBUG: Profile userId: ${matchingProfessional.userId}');
            _professional.value = matchingProfessional;
          } else {
            print('🔍 DEBUG: Profissional não encontrado com userId: $professionalId');
            _errorMessage.value = 'Profissional não encontrado';
          }
        },
      );

      // Carregar serviços do profissional
      print('🔍 DEBUG: Carregando serviços para professionalId: $professionalId');
      final servicesResult = await _serviceRepository.getServicesByProfessional(professionalId);
      
      servicesResult.fold(
        (failure) {
          print('🔍 DEBUG: Erro ao carregar serviços: ${failure.message}');
          _errorMessage.value = failure.message;
        },
        (services) {
          print('🔍 DEBUG: Serviços carregados: ${services.length}');
          _services.value = services.where((service) => service.isActive).toList();
          print('🔍 DEBUG: Filtro isActive aplicado. Serviços ativos: ${_services.length}');
          print('🔍 DEBUG: Serviços ativos: ${_services.length}');
          // Selecionar primeiro serviço por padrão se disponível
          if (_services.isNotEmpty) {
            _selectedService.value = _services.first;
            print('🔍 DEBUG: Primeiro serviço selecionado: ${_services.first.name}');
          }
        },
      );

      // Carregar horários disponíveis para a data atual
      if (_selectedService.value != null) {
        await _loadAvailableSlots();
      }
    } catch (e) {
      _errorMessage.value = 'Erro ao carregar dados: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Carrega horários disponíveis para a data selecionada
  Future<void> _loadAvailableSlots() async {
    if (_selectedService.value == null) return;

    try {
      _isLoadingSlots.value = true;
      _errorMessage.value = '';

      final result = await _getAvailableTimeSlotsUseCase(
        professionalId: professionalId,
        date: _selectedDate.value,
        serviceId: _selectedService.value!.id,
      );

      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          _availableSlots.clear();
        },
        (slots) {
          _availableSlots.value = slots;
        },
      );
    } catch (e) {
      _errorMessage.value = 'Erro ao carregar horários: $e';
      _availableSlots.clear();
    } finally {
      _isLoadingSlots.value = false;
    }
  }

  /// Atualiza a data selecionada
  Future<void> updateSelectedDate(DateTime newDate) async {
    if (_selectedDate.value == newDate) return;
    
    _selectedDate.value = newDate;
    await _loadAvailableSlots();
  }

  /// Atualiza o serviço selecionado
  Future<void> updateSelectedService(ServiceEntity? service) async {
    if (_selectedService.value == service) return;
    
    _selectedService.value = service;
    await _loadAvailableSlots();
  }

  /// Seleciona um slot de tempo disponível
  void selectTimeSlot(AvailableTimeSlotEntity slot) {
    if (_professional.value == null || _selectedService.value == null) {
      Get.snackbar(
        'Erro',
        'Dados incompletos. Tente novamente.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Navegar para tela de confirmação de agendamento
    Modular.to.pushNamed(
      '/appointment/confirmation',
      arguments: {
        'professional': _professional.value!,
        'service': _selectedService.value!,
        'slot': slot,
      },
    );
  }

  /// Agrupa slots por período do dia
  Map<String, List<AvailableTimeSlotEntity>> get groupedSlots {
    final grouped = <String, List<AvailableTimeSlotEntity>>{
      'Manhã': <AvailableTimeSlotEntity>[],
      'Tarde': <AvailableTimeSlotEntity>[],
      'Noite': <AvailableTimeSlotEntity>[],
    };

    for (final slot in _availableSlots) {
      final hour = slot.startTime.hour;
      if (hour < 12) {
        grouped['Manhã']!.add(slot);
      } else if (hour < 18) {
        grouped['Tarde']!.add(slot);
      } else {
        grouped['Noite']!.add(slot);
      }
    }

    // Remover períodos vazios
    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  /// Verifica se há slots disponíveis para a data selecionada
  bool get hasAvailableSlots => _availableSlots.isNotEmpty;

  /// Retorna mensagem quando não há slots disponíveis
  String get noSlotsMessage {
    if (_selectedService.value == null) {
      return 'Selecione um serviço para ver os horários disponíveis';
    }
    return 'Não há horários disponíveis para esta data';
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage.value = '';
  }

  /// Recarrega os dados
  @override
  Future<void> refresh() async {
    await _loadProfessionalData();
  }
}

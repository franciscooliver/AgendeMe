import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../client_management/domain/entities/client_entity.dart';
import '../../../client_management/domain/usecases/get_clients.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../../../services/domain/usecases/get_services.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../../../user_profile/domain/usecases/get_user_profile_by_user_id.dart';
import '../../domain/usecases/create_appointment_usecase.dart' as appointment_usecase;
import '../../domain/repositories/appointment_repository.dart';

/// Controller para gerenciar o formulário de agendamentos
/// 
/// Responsável por coordenar a criação e edição de agendamentos
/// para profissionais, incluindo seleção de clientes, serviços,
/// data/hora e validações
class AppointmentFormController extends GetxController {
  final GetClients _getClientsUseCase;
  final GetServices _getServicesUseCase;
  final GetUserProfileByUserId _getUserProfileUseCase;
  final appointment_usecase.CreateAppointmentUseCase _createAppointmentUseCase;
  final AppointmentRepository _appointmentRepository;

  // Dados do formulário
  final Rx<ClientEntity?> _selectedClient = Rx<ClientEntity?>(null);
  final Rx<ServiceEntity?> _selectedService = Rx<ServiceEntity?>(null);
  final Rx<DateTime?> _selectedDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> _selectedTime = Rx<TimeOfDay?>(null);
  final RxString _notes = ''.obs;

  // Listas de dados
  final RxList<ClientEntity> _clients = <ClientEntity>[].obs;
  final RxList<ServiceEntity> _services = <ServiceEntity>[].obs;
  final Rx<UserProfileEntity?> _professional = Rx<UserProfileEntity?>(null);

  // Estados de controle
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingClients = false.obs;
  final RxBool _isLoadingServices = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _successMessage = ''.obs;

  // Validação de disponibilidade
  // final RxList<AppointmentEntity> _existingAppointments = <AppointmentEntity>[].obs;
  final RxBool _isCheckingAvailability = false.obs;
  final RxString _availabilityMessage = ''.obs;

  AppointmentFormController({
    required GetClients getClientsUseCase,
    required GetServices getServicesUseCase,
    required GetUserProfileByUserId getUserProfileUseCase,
    required appointment_usecase.CreateAppointmentUseCase createAppointmentUseCase,
    required AppointmentRepository appointmentRepository,
  }) : _getClientsUseCase = getClientsUseCase,
       _getServicesUseCase = getServicesUseCase,
       _getUserProfileUseCase = getUserProfileUseCase,
       _createAppointmentUseCase = createAppointmentUseCase,
       _appointmentRepository = appointmentRepository;

  // Getters
  ClientEntity? get selectedClient => _selectedClient.value;
  ServiceEntity? get selectedService => _selectedService.value;
  DateTime? get selectedDate => _selectedDate.value;
  TimeOfDay? get selectedTime => _selectedTime.value;
  String get notes => _notes.value;
  List<ClientEntity> get clients => _clients;
  List<ServiceEntity> get services => _services;
  UserProfileEntity? get professional => _professional.value;
  bool get isLoading => _isLoading.value;
  bool get isLoadingClients => _isLoadingClients.value;
  bool get isLoadingServices => _isLoadingServices.value;
  String get errorMessage => _errorMessage.value;
  String get successMessage => _successMessage.value;
  bool get isCheckingAvailability => _isCheckingAvailability.value;
  String get availabilityMessage => _availabilityMessage.value;

  /// Verifica se todos os campos obrigatórios estão preenchidos
  bool get isFormValid => 
    _selectedClient.value != null &&
    _selectedService.value != null &&
    _selectedDate.value != null &&
    _selectedTime.value != null;

  /// Inicializa o controller
  Future<void> initialize() async {
    try {
      _isLoading.value = true;
      _clearErrorMessages();

      // Obter dados do profissional atual
      final authController = Modular.get<AuthController>();
      if (authController.currentUser != null) {
        await _loadProfessional(authController.currentUser!.id);
      }

      // Carregar dados iniciais
      if (_professional.value != null) {
        await Future.wait([
          _loadClients(),
          _loadServices(),
        ]);
      }
    } catch (e) {
      _errorMessage.value = 'Erro ao inicializar: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Carrega dados do profissional
  Future<void> _loadProfessional(String userId) async {
    try {
      final result = await _getUserProfileUseCase(GetUserProfileByUserIdParams(userId: userId));
      result.fold(
        (failure) => _errorMessage.value = failure.message,
        (profile) => _professional.value = profile,
      );
    } catch (e) {
      _errorMessage.value = 'Erro ao carregar profissional: $e';
    }
  }

  /// Carrega lista de clientes
  Future<void> _loadClients() async {
    if (_professional.value == null) return;

    try {
      _isLoadingClients.value = true;
      final result = await _getClientsUseCase(GetClientsParams(
        professionalId: _professional.value!.id,
      ));

      result.fold(
        (failure) => _errorMessage.value = failure.message,
        (clients) => _clients.value = clients,
      );
    } catch (e) {
      _errorMessage.value = 'Erro ao carregar clientes: $e';
    } finally {
      _isLoadingClients.value = false;
    }
  }

  /// Carrega lista de serviços
  Future<void> _loadServices() async {
    if (_professional.value == null) return;

    try {
      _isLoadingServices.value = true;
      final result = await _getServicesUseCase(GetServicesParams(
        professionalId: _professional.value!.id,
      ));

      result.fold(
        (failure) => _errorMessage.value = failure.message,
        (services) => _services.value = services,
      );
    } catch (e) {
      _errorMessage.value = 'Erro ao carregar serviços: $e';
    } finally {
      _isLoadingServices.value = false;
    }
  }

  /// Atualiza cliente selecionado
  void selectClient(ClientEntity? client) {
    _selectedClient.value = client;
    _clearErrorMessages();
    _clearAvailabilityMessage();
  }

  /// Atualiza serviço selecionado
  void selectService(ServiceEntity? service) {
    _selectedService.value = service;
    _clearErrorMessages();
    _clearAvailabilityMessage();
  }

  /// Atualiza data selecionada
  void selectDate(DateTime? date) {
    _selectedDate.value = date;
    _clearErrorMessages();
    _clearAvailabilityMessage();
    
    // Limpar horário se a data mudou
    if (_selectedTime.value != null) {
      _selectedTime.value = null;
    }
  }

  /// Atualiza horário selecionado
  void selectTime(TimeOfDay? time) {
    _selectedTime.value = time;
    _clearErrorMessages();
    
    // Verificar disponibilidade quando horário for selecionado
    if (time != null && _selectedDate.value != null && _selectedService.value != null) {
      _checkAvailability();
    }
  }

  /// Atualiza observações
  void updateNotes(String notes) {
    _notes.value = notes;
  }

  /// Verifica disponibilidade do horário selecionado
  Future<void> _checkAvailability() async {
    if (_selectedDate.value == null || 
        _selectedTime.value == null || 
        _selectedService.value == null ||
        _professional.value == null) {
      return;
    }

    try {
      _isCheckingAvailability.value = true;
      _availabilityMessage.value = 'Verificando disponibilidade...';

      // Criar DateTime combinando data e hora
      final appointmentDateTime = DateTime(
        _selectedDate.value!.year,
        _selectedDate.value!.month,
        _selectedDate.value!.day,
        _selectedTime.value!.hour,
        _selectedTime.value!.minute,
      );

      // Verificar se o horário está no passado
      if (appointmentDateTime.isBefore(DateTime.now())) {
        _availabilityMessage.value = 'Horário não pode ser no passado';
        return;
      }

      // Verificar se está dentro do horário de trabalho
      if (!_isWithinWorkingHours(appointmentDateTime)) {
        _availabilityMessage.value = 'Horário fora do expediente de trabalho';
        return;
      }

      // Verificar conflitos com agendamentos existentes
      await _checkTimeConflicts(appointmentDateTime);
    } catch (e) {
      _availabilityMessage.value = 'Erro ao verificar disponibilidade: $e';
    } finally {
      _isCheckingAvailability.value = false;
    }
  }

  /// Verifica conflitos de horário com agendamentos existentes
  Future<void> _checkTimeConflicts(DateTime appointmentDateTime) async {
    try {
      // Calcular início e fim do dia para buscar agendamentos
      final startOfDay = DateTime(
        appointmentDateTime.year,
        appointmentDateTime.month,
        appointmentDateTime.day,
        0,
        0,
        0,
      );
      final endOfDay = DateTime(
        appointmentDateTime.year,
        appointmentDateTime.month,
        appointmentDateTime.day,
        23,
        59,
        59,
      );

      // Buscar agendamentos do profissional para o dia selecionado
      final result = await _appointmentRepository.getAppointmentsByDateRange(
        startOfDay,
        endOfDay,
        professionalId: _professional.value!.id,
        includeFinished: false,
      );

      result.fold(
        (failure) {
          _availabilityMessage.value = 'Erro ao verificar agendamentos: ${failure.message}';
        },
        (existingAppointments) {
          // Verificar se há conflito com algum agendamento existente
          final hasConflict = _hasTimeConflict(appointmentDateTime, existingAppointments);
          
          if (hasConflict) {
            _availabilityMessage.value = 'Horário já ocupado por outro agendamento';
          } else {
            _availabilityMessage.value = 'Horário disponível';
          }
        },
      );
    } catch (e) {
      _availabilityMessage.value = 'Erro ao verificar conflitos: $e';
    }
  }

  /// Verifica se há conflito de horário com agendamentos existentes
  bool _hasTimeConflict(DateTime appointmentDateTime, List<dynamic> existingAppointments) {
    final serviceDuration = _selectedService.value!.duration;
    final appointmentEndTime = appointmentDateTime.add(Duration(minutes: serviceDuration));

    for (final appointment in existingAppointments) {
      final existingStart = appointment.appointmentDateTime;
      final existingEnd = existingStart.add(Duration(minutes: appointment.estimatedDuration));

      // Verificar se há sobreposição de horários
      if (appointmentDateTime.isBefore(existingEnd) && appointmentEndTime.isAfter(existingStart)) {
        return true;
      }
    }

    return false;
  }

  /// Verifica se o horário está dentro do expediente de trabalho
  bool _isWithinWorkingHours(DateTime appointmentDateTime) {
    if (_professional.value?.workingHours == null) {
      return true; // Se não há horário definido, permitir
    }

    // TODO: Implementar lógica de horário de trabalho
    // Por enquanto, permitir horários entre 8h e 18h
    final hour = appointmentDateTime.hour;
    return hour >= 8 && hour <= 18;
  }

  /// Cria o agendamento
  Future<void> createAppointment() async {
    if (!isFormValid) {
      _errorMessage.value = 'Preencha todos os campos obrigatórios';
      return;
    }

    // Mostrar diálogo de confirmação
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    try {
      _isLoading.value = true;
      _clearErrorMessages();

      // Criar DateTime combinando data e hora
      final appointmentDateTime = DateTime(
        _selectedDate.value!.year,
        _selectedDate.value!.month,
        _selectedDate.value!.day,
        _selectedTime.value!.hour,
        _selectedTime.value!.minute,
      );

      final params = appointment_usecase.CreateAppointmentParams(
        professionalId: _professional.value!.id,
        clientId: _selectedClient.value!.id,
        serviceId: _selectedService.value!.id,
        appointmentDateTime: appointmentDateTime,
        price: _selectedService.value!.price,
        duration: _selectedService.value!.duration,
        notes: _notes.value.isEmpty ? null : _notes.value,
      );

      final result = await _createAppointmentUseCase(params);

      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
        },
        (appointment) {
          _successMessage.value = 'Agendamento criado com sucesso!';
          _clearForm();
          // Navegar de volta ou mostrar sucesso
          Get.back();
        },
      );
    } catch (e) {
      _errorMessage.value = 'Erro inesperado ao criar agendamento: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Limpa o formulário
  void _clearForm() {
    _selectedClient.value = null;
    _selectedService.value = null;
    _selectedDate.value = null;
    _selectedTime.value = null;
    _notes.value = '';
    _clearAvailabilityMessage();
  }

  /// Limpa mensagens de erro e sucesso
  void _clearErrorMessages() {
    _errorMessage.value = '';
    _successMessage.value = '';
  }

  /// Limpa mensagem de disponibilidade
  void _clearAvailabilityMessage() {
    _availabilityMessage.value = '';
  }

  /// Cancela o formulário
  void cancel() {
    _clearForm();
    _clearErrorMessages();
    Get.back();
  }

  /// Mostra diálogo de confirmação antes de criar o agendamento
  Future<bool> _showConfirmationDialog() async {
    final summary = appointmentSummary;
    if (summary.isEmpty) return false;

    return await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmar Agendamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${summary['client']}'),
            const SizedBox(height: 8),
            Text('Serviço: ${summary['service']}'),
            const SizedBox(height: 8),
            Text('Data: ${summary['date']}'),
            const SizedBox(height: 8),
            Text('Horário: ${summary['time']}'),
            const SizedBox(height: 8),
            Text('Preço: R\$ ${summary['price'].toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Duração: ${summary['duration']} minutos'),
            if (summary['notes'] != null && summary['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Observações: ${summary['notes']}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Retorna um resumo dos dados do agendamento
  Map<String, dynamic> get appointmentSummary {
    if (!isFormValid) return {};

    final appointmentDateTime = DateTime(
      _selectedDate.value!.year,
      _selectedDate.value!.month,
      _selectedDate.value!.day,
      _selectedTime.value!.hour,
      _selectedTime.value!.minute,
    );

    return {
      'client': _selectedClient.value?.name ?? '',
      'service': _selectedService.value?.name ?? '',
      'date': _selectedDate.value!.day.toString().padLeft(2, '0') + 
              '/' + _selectedDate.value!.month.toString().padLeft(2, '0') + 
              '/' + _selectedDate.value!.year.toString(),
      'time': '${_selectedTime.value!.hour.toString().padLeft(2, '0')}:${_selectedTime.value!.minute.toString().padLeft(2, '0')}',
      'price': _selectedService.value?.price ?? 0.0,
      'duration': _selectedService.value?.duration ?? 0,
      'notes': _notes.value,
      'appointmentDateTime': appointmentDateTime,
    };
  }

  @override
  void onClose() {
    _clearForm();
    super.onClose();
  }
}

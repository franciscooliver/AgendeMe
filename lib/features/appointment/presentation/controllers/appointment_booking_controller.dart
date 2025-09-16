import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../../../professional_availability/domain/entities/available_time_slot_entity.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/usecases/create_appointment_usecase.dart';

/// Controller para gerenciar o fluxo de agendamento
/// 
/// Responsável por coordenar a seleção de horários, dados do agendamento
/// e criação do appointment no sistema
class AppointmentBookingController extends GetxController {
  final CreateAppointmentUseCase _createAppointmentUseCase;

  // Dados do agendamento
  final Rx<UserProfileEntity?> _professional = Rx<UserProfileEntity?>(null);
  final Rx<ServiceEntity?> _selectedService = Rx<ServiceEntity?>(null);
  final Rx<AvailableTimeSlotEntity?> _selectedSlot = Rx<AvailableTimeSlotEntity?>(null);
  final RxString _notes = ''.obs;
  final RxString _clientNotes = ''.obs;

  // Estados de controle
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _successMessage = ''.obs;

  AppointmentBookingController({
    required CreateAppointmentUseCase createAppointmentUseCase,
  }) : _createAppointmentUseCase = createAppointmentUseCase;

  // Getters
  UserProfileEntity? get professional => _professional.value;
  ServiceEntity? get selectedService => _selectedService.value;
  AvailableTimeSlotEntity? get selectedSlot => _selectedSlot.value;
  String get notes => _notes.value;
  String get clientNotes => _clientNotes.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  String get successMessage => _successMessage.value;

  /// Verifica se todos os dados necessários estão preenchidos
  bool get isBookingDataComplete => 
    _professional.value != null &&
    _selectedService.value != null &&
    _selectedSlot.value != null;

  /// Inicializa o controller com dados do profissional
  void initializeWithProfessional(UserProfileEntity professional) {
    _professional.value = professional;
    _clearErrorMessages();
  }

  /// Define o serviço selecionado
  void setSelectedService(ServiceEntity service) {
    _selectedService.value = service;
    _clearErrorMessages();
  }

  /// Define o horário selecionado
  void setSelectedSlot(AvailableTimeSlotEntity slot) {
    _selectedSlot.value = slot;
    _clearErrorMessages();
  }

  /// Atualiza as observações gerais
  void updateNotes(String notes) {
    _notes.value = notes;
  }

  /// Atualiza as observações do cliente
  void updateClientNotes(String clientNotes) {
    _clientNotes.value = clientNotes;
  }

  /// Cria o agendamento
  Future<void> createAppointment() async {
    if (!isBookingDataComplete) {
      _errorMessage.value = 'Dados incompletos para criar o agendamento';
      return;
    }

    try {
      _isLoading.value = true;
      _clearErrorMessages();

      final params = CreateAppointmentParams(
        professionalId: _professional.value!.id,
        clientId: Modular.get<AuthController>().currentUser!.id,
        serviceId: _selectedService.value!.id,
        appointmentDateTime: _selectedSlot.value!.startTime,
        price: _selectedService.value!.price,
        duration: _selectedService.value!.duration,
        notes: _notes.value.isEmpty ? null : _notes.value,
        clientNotes: _clientNotes.value.isEmpty ? null : _clientNotes.value,
      );

      final result = await _createAppointmentUseCase(params);

      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
        },
        (appointment) {
          _successMessage.value = 'Agendamento criado com sucesso!';
          _clearBookingData();
          // Navegar para tela de sucesso ou voltar
          _navigateToSuccess(appointment);
        },
      );
    } catch (e) {
      _errorMessage.value = 'Erro inesperado ao criar agendamento: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Cancela o agendamento atual
  void cancelBooking() {
    _clearBookingData();
    _clearErrorMessages();
    Get.back();
  }

  /// Limpa os dados do agendamento
  void _clearBookingData() {
    _professional.value = null;
    _selectedService.value = null;
    _selectedSlot.value = null;
    _notes.value = '';
    _clientNotes.value = '';
  }

  /// Limpa mensagens de erro e sucesso
  void _clearErrorMessages() {
    _errorMessage.value = '';
    _successMessage.value = '';
  }

  /// Navega para tela de sucesso
  void _navigateToSuccess(AppointmentEntity appointment) {
    // TODO: Implementar navegação para tela de sucesso
    // Por enquanto, mostra snackbar e volta
    Get.snackbar(
      'Sucesso!',
      'Agendamento criado com sucesso',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
    
    // Volta para a tela anterior
    Get.back();
  }

  /// Retorna um resumo dos dados do agendamento
  Map<String, dynamic> get bookingSummary {
    if (!isBookingDataComplete) return {};

    return {
      'professional': _professional.value?.name ?? '',
      'service': _selectedService.value?.name ?? '',
      'date': _selectedSlot.value != null 
        ? '${_selectedSlot.value!.startTime.day.toString().padLeft(2, '0')}/${_selectedSlot.value!.startTime.month.toString().padLeft(2, '0')}/${_selectedSlot.value!.startTime.year.toString()}'
        : '',
      'time': _selectedSlot.value?.formattedTime ?? '',
      'price': _selectedService.value?.price ?? 0.0,
      'duration': _selectedService.value?.duration ?? 0,
      'notes': _notes.value,
      'clientNotes': _clientNotes.value,
    };
  }

  @override
  void onClose() {
    _clearBookingData();
    super.onClose();
  }
}

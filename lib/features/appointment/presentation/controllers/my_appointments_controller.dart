import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../appointment/domain/entities/appointment_entity.dart';
import '../../../appointment/domain/repositories/appointment_repository.dart';

/// Controller para gerenciar a tela de agendamentos do cliente
/// 
/// Responsável por buscar, exibir e cancelar agendamentos do cliente logado
class MyAppointmentsController extends GetxController {
  final AppointmentRepository _appointmentRepository;
  final AuthController _authController;

  MyAppointmentsController({
    required AppointmentRepository appointmentRepository,
    required AuthController authController,
  }) : _appointmentRepository = appointmentRepository,
       _authController = authController;

  // Estados observáveis
  final RxList<AppointmentEntity> appointments = <AppointmentEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAppointments();
  }

  /// Busca os agendamentos do cliente logado
  Future<void> fetchAppointments() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final currentUser = _authController.currentUser;
      if (currentUser == null) {
        errorMessage.value = 'Usuário não autenticado';
        return;
      }

      final result = await _appointmentRepository.getAppointmentsByClient(
        currentUser.id,
        includeFinished: true, // Incluir agendamentos finalizados
        limit: 50, // Limite razoável para não sobrecarregar
      );

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          appointments.clear();
        },
        (appointmentList) {
          appointments.assignAll(appointmentList);
          errorMessage.value = '';
        },
      );
    } catch (e) {
      errorMessage.value = 'Erro inesperado: $e';
      appointments.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Cancela um agendamento específico
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      isLoading.value = true;

      // Primeiro, buscar o agendamento atual
      final getResult = await _appointmentRepository.getAppointment(appointmentId);
      
      if (getResult.isLeft()) {
        Get.snackbar(
          'Erro',
          'Não foi possível encontrar o agendamento',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      final appointment = getResult.getOrElse(() => throw Exception('Agendamento não encontrado'));
      
      // Criar uma cópia do agendamento com status cancelado
      final updatedAppointment = appointment.copyWith(
        status: AppointmentStatus.cancelled,
        updatedAt: DateTime.now(),
        cancelledAt: DateTime.now(),
        cancellationReason: 'Cancelado pelo cliente',
      );
      
      final result = await _appointmentRepository.updateAppointment(updatedAppointment);

      result.fold(
        (failure) {
          Get.snackbar(
            'Erro',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
        (updatedAppointment) {
          Get.snackbar(
            'Sucesso',
            'Agendamento cancelado com sucesso',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          // Recarregar a lista de agendamentos
          fetchAppointments();
        },
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro inesperado: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Atualiza a lista de agendamentos (para pull-to-refresh)
  Future<void> refreshAppointments() async {
    await fetchAppointments();
  }

  /// Verifica se o usuário pode cancelar um agendamento
  bool canCancelAppointment(AppointmentEntity appointment) {
    return appointment.status == AppointmentStatus.pending ||
           appointment.status == AppointmentStatus.confirmed;
  }

  /// Obtém a cor do status do agendamento
  Color getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.inProgress:
        return Colors.blue;
      case AppointmentStatus.completed:
        return Colors.grey;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.grey;
    }
  }

  /// Obtém o texto do status do agendamento
  String getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pendente';
      case AppointmentStatus.confirmed:
        return 'Confirmado';
      case AppointmentStatus.inProgress:
        return 'Em Andamento';
      case AppointmentStatus.completed:
        return 'Concluído';
      case AppointmentStatus.cancelled:
        return 'Cancelado';
      case AppointmentStatus.noShow:
        return 'Não Compareceu';
    }
  }

  /// Formata a data e hora do agendamento
  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateStr;
    if (appointmentDate == today) {
      dateStr = 'Hoje';
    } else if (appointmentDate == today.add(const Duration(days: 1))) {
      dateStr = 'Amanhã';
    } else {
      dateStr = '${dateTime.day.toString().padLeft(2, '0')}/'
               '${dateTime.month.toString().padLeft(2, '0')}/'
               '${dateTime.year}';
    }
    
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:'
                   '${dateTime.minute.toString().padLeft(2, '0')}';
    
    return '$dateStr às $timeStr';
  }
}

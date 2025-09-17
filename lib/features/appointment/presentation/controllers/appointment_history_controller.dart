import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';

/// Controller para gerenciar a tela de histórico de agendamentos do cliente
/// 
/// Responsável por buscar e exibir agendamentos históricos (finalizados, cancelados, etc.)
class AppointmentHistoryController extends GetxController {
  final AppointmentRepository _appointmentRepository;
  final AuthController _authController;

  AppointmentHistoryController({
    required AppointmentRepository appointmentRepository,
    required AuthController authController,
  }) : _appointmentRepository = appointmentRepository,
       _authController = authController;

  // Estados observáveis
  final RxList<AppointmentEntity> historicalAppointments = <AppointmentEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedPeriod = 'all'.obs;

  // Opções de filtro por período
  final List<Map<String, dynamic>> periodOptions = [
    {'key': 'all', 'label': 'Todos'},
    {'key': '30days', 'label': 'Últimos 30 dias'},
    {'key': '90days', 'label': 'Últimos 90 dias'},
    {'key': '6months', 'label': 'Últimos 6 meses'},
    {'key': '1year', 'label': 'Último ano'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchHistoricalAppointments();
  }

  /// Busca os agendamentos históricos do cliente logado
  Future<void> fetchHistoricalAppointments() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final currentUser = _authController.currentUser;
      if (currentUser == null) {
        errorMessage.value = 'Usuário não autenticado';
        return;
      }

      // Calcular período baseado na seleção
      DateTime? startDate;
      final now = DateTime.now();
      
      switch (selectedPeriod.value) {
        case '30days':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case '90days':
          startDate = now.subtract(const Duration(days: 90));
          break;
        case '6months':
          startDate = DateTime(now.year, now.month - 6, now.day);
          break;
        case '1year':
          startDate = DateTime(now.year - 1, now.month, now.day);
          break;
        default:
          startDate = null; // Todos os agendamentos
      }

      print('🔍 DEBUG: Buscando histórico de agendamentos');
      print('🔍 DEBUG: Cliente ID: ${currentUser.id}');
      print('🔍 DEBUG: Período selecionado: ${selectedPeriod.value}');
      print('🔍 DEBUG: Data inicial: $startDate');

      final result = await _appointmentRepository.getHistoricalAppointmentsByClient(
        currentUser.id,
        startDate: startDate,
        endDate: null, // Sem data final para buscar todos os históricos
        limit: 100, // Limite maior para histórico
      );

      result.fold(
        (failure) {
          print('❌ DEBUG: Erro ao buscar histórico: ${failure.message}');
          errorMessage.value = failure.message;
          historicalAppointments.clear();
        },
        (appointmentList) {
          print('✅ DEBUG: Agendamentos históricos encontrados: ${appointmentList.length}');
          
          // Os agendamentos já vêm filtrados e ordenados do Firestore
          historicalAppointments.assignAll(appointmentList);
          errorMessage.value = '';
        },
      );
    } catch (e) {
      print('❌ DEBUG: Erro inesperado: $e');
      errorMessage.value = 'Erro inesperado: $e';
      historicalAppointments.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Atualiza o período de filtro e recarrega os dados
  void updatePeriodFilter(String period) {
    selectedPeriod.value = period;
    fetchHistoricalAppointments();
  }

  /// Formata a data para exibição
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Ontem';
    } else if (difference < 7) {
      return 'Há $difference dias';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return 'Há $weeks semana${weeks > 1 ? 's' : ''}';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return 'Há $months mês${months > 1 ? 'es' : ''}';
    } else {
      final years = (difference / 365).floor();
      return 'Há $years ano${years > 1 ? 's' : ''}';
    }
  }

  /// Formata o status para exibição
  String formatStatus(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.completed:
        return 'Concluído';
      case AppointmentStatus.cancelled:
        return 'Cancelado';
      case AppointmentStatus.noShow:
        return 'Faltou';
      default:
        return 'Desconhecido';
    }
  }

  /// Retorna a cor do status
  Color getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.orange;
      case AppointmentStatus.noShow:
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }
}

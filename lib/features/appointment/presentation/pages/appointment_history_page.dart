import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../../domain/entities/appointment_entity.dart';
import '../controllers/appointment_history_controller.dart';

/// Página para exibir o histórico de agendamentos do cliente
/// 
/// Permite visualizar agendamentos históricos (finalizados, cancelados, etc.)
/// com opções de filtro por período
class AppointmentHistoryPage extends StatelessWidget {
  const AppointmentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Modular.get<AppointmentHistoryController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Agendamentos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Modular.to.pop(),
        ),
      ),
      body: Column(
        children: [
          // Filtro de período
          _buildPeriodFilter(controller),
          
          // Lista de agendamentos
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return _buildErrorState(controller);
              }

              if (controller.historicalAppointments.isEmpty) {
                return _buildEmptyState();
              }

              return _buildAppointmentsList(controller);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter(AppointmentHistoryController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar por período:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => DropdownButtonFormField<String>(
            value: controller.selectedPeriod.value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: controller.periodOptions.map((option) {
              return DropdownMenuItem<String>(
                value: option['key'],
                child: Text(option['label']),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.updatePeriodFilter(value);
              }
            },
          )),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppointmentHistoryController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar histórico',
              style: Get.textTheme.headlineSmall?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.fetchHistoricalAppointments(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum agendamento histórico',
              style: Get.textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Você ainda não possui agendamentos finalizados ou cancelados.',
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(AppointmentHistoryController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.historicalAppointments.length,
      itemBuilder: (context, index) {
        final appointment = controller.historicalAppointments[index];
        return _buildAppointmentCard(controller, appointment);
      },
    );
  }

  Widget _buildAppointmentCard(
    AppointmentHistoryController controller,
    AppointmentEntity appointment,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com status e data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: controller.getStatusColor(appointment.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: controller.getStatusColor(appointment.status).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    controller.formatStatus(appointment.status),
                    style: TextStyle(
                      color: controller.getStatusColor(appointment.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  controller.formatDate(appointment.appointmentDateTime),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Detalhes do agendamento
            _buildAppointmentDetail(
              icon: Icons.calendar_today,
              label: 'Data e Hora',
              value: _formatDateTime(appointment.appointmentDateTime),
            ),
            
            _buildAppointmentDetail(
              icon: Icons.build,
              label: 'Serviço',
              value: 'ID: ${appointment.serviceId}',
            ),
            
            _buildAppointmentDetail(
              icon: Icons.person,
              label: 'Profissional',
              value: 'ID: ${appointment.professionalId}',
            ),
            
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildAppointmentDetail(
                icon: Icons.note,
                label: 'Observações',
                value: appointment.notes!,
              ),
            ],
            
            if (appointment.cancellationReason != null && appointment.cancellationReason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildAppointmentDetail(
                icon: Icons.cancel,
                label: 'Motivo do cancelamento',
                value: appointment.cancellationReason!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final date = '${dateTime.day.toString().padLeft(2, '0')}/'
                '${dateTime.month.toString().padLeft(2, '0')}/'
                '${dateTime.year}';
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:'
                '${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date às $time';
  }
}

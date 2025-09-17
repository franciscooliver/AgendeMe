import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../../domain/entities/appointment_entity.dart';
import '../controllers/my_appointments_controller.dart';

/// Página para exibir os agendamentos do cliente logado
/// 
/// Permite visualizar todos os agendamentos do cliente, incluindo
/// status, detalhes e opção de cancelamento
class MyAppointmentsPage extends StatelessWidget {
  const MyAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Modular.get<MyAppointmentsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Agendamentos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Modular.to.pop(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar agendamentos',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => controller.fetchAppointments(),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        if (controller.appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum agendamento encontrado',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Você ainda não possui agendamentos.\nQue tal buscar um profissional?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Modular.to.pop();
                    Modular.to.pushNamed('/professional-search/search');
                  },
                  child: const Text('Buscar Profissionais'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchAppointments(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.appointments.length,
            itemBuilder: (context, index) {
              final appointment = controller.appointments[index];
              return _buildAppointmentCard(context, appointment, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    AppointmentEntity appointment,
    MyAppointmentsController controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com status e data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusChip(appointment.status.value),
                Text(
                  _formatDateTime(appointment.appointmentDateTime),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Detalhes do agendamento
            _buildDetailRow(
              Icons.person,
              'Profissional',
              'ID: ${appointment.professionalId}',
            ),
            
            const SizedBox(height: 8),
            
            _buildDetailRow(
              Icons.work,
              'Serviço',
              'ID: ${appointment.serviceId}',
            ),
            
            const SizedBox(height: 8),
            
            _buildDetailRow(
              Icons.access_time,
              'Duração',
              '${appointment.estimatedDuration} minutos',
            ),
            
            if (appointment.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.note,
                'Observações',
                appointment.notes!,
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Botões de ação
            if (_canCancelAppointment(appointment.status.value)) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showCancelDialog(
                        context,
                        appointment,
                        controller,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        label = 'Pendente';
        break;
      case 'confirmed':
        color = Colors.green;
        label = 'Confirmado';
        break;
      case 'in_progress':
        color = Colors.blue;
        label = 'Em Andamento';
        break;
      case 'completed':
        color = Colors.grey;
        label = 'Concluído';
        break;
      case 'canceled':
        color = Colors.red;
        label = 'Cancelado';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
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
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
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

  bool _canCancelAppointment(String status) {
    return status.toLowerCase() == 'pending' || 
           status.toLowerCase() == 'confirmed';
  }

  void _showCancelDialog(
    BuildContext context,
    AppointmentEntity appointment,
    MyAppointmentsController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Agendamento'),
        content: const Text(
          'Tem certeza que deseja cancelar este agendamento? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await controller.cancelAppointment(appointment.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sim, Cancelar'),
          ),
        ],
      ),
    );
  }
}

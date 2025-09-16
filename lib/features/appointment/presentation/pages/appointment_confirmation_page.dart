import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../../../professional_availability/domain/entities/available_time_slot_entity.dart';
import '../controllers/appointment_booking_controller.dart';

/// Página de confirmação de agendamento
/// 
/// Interface para o cliente confirmar os detalhes do agendamento
/// antes de criar o appointment no sistema
class AppointmentConfirmationPage extends StatefulWidget {
  final UserProfileEntity professional;
  final ServiceEntity service;
  final AvailableTimeSlotEntity slot;

  const AppointmentConfirmationPage({
    super.key,
    required this.professional,
    required this.service,
    required this.slot,
  });

  @override
  State<AppointmentConfirmationPage> createState() => _AppointmentConfirmationPageState();
}

class _AppointmentConfirmationPageState extends State<AppointmentConfirmationPage> {
  late final AppointmentBookingController _controller;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _clientNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AppointmentBookingController(
      createAppointmentUseCase: Modular.get(),
    );
    _controller.initializeWithProfessional(widget.professional);
    _controller.setSelectedService(widget.service);
    _controller.setSelectedSlot(widget.slot);
  }

  @override
  void dispose() {
    _controller.dispose();
    _notesController.dispose();
    _clientNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Agendamento'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (_controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return _buildContent();
      }),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildProfessionalInfo(),
          const SizedBox(height: 24),
          _buildServiceInfo(),
          const SizedBox(height: 24),
          _buildDateTimeInfo(),
          const SizedBox(height: 24),
          _buildNotesSection(),
          const SizedBox(height: 32),
          _buildActionButtons(),
          const SizedBox(height: 16),
          if (_controller.errorMessage.isNotEmpty)
            _buildErrorMessage(),
          if (_controller.successMessage.isNotEmpty)
            _buildSuccessMessage(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: Theme.of(context).primaryColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirme seu Agendamento',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Revise os detalhes antes de confirmar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfo() {
    return _buildInfoCard(
      title: 'Profissional',
      icon: Icons.person,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.professional.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.professional.bio != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.professional.bio!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceInfo() {
    return _buildInfoCard(
      title: 'Serviço',
      icon: Icons.room_service,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.service.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.service.duration} minutos',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                'R\$ ${widget.service.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeInfo() {
    return _buildInfoCard(
      title: 'Data e Horário',
      icon: Icons.schedule,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                widget.slot.startTime.day.toString().padLeft(2, '0') + '/' +
                widget.slot.startTime.month.toString().padLeft(2, '0') + '/' +
                widget.slot.startTime.year.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                widget.slot.formattedTime,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return _buildInfoCard(
      title: 'Observações (Opcional)',
      icon: Icons.note,
      child: Column(
        children: [
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              hintText: 'Observações gerais sobre o agendamento...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
            maxLines: 3,
            onChanged: (value) => _controller.updateNotes(value),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _clientNotesController,
            decoration: const InputDecoration(
              hintText: 'Observações pessoais (apenas você verá)...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
            maxLines: 2,
            onChanged: (value) => _controller.updateClientNotes(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _controller.isLoading ? null : _controller.cancelBooking,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey[400]!),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _controller.isLoading || !_controller.isBookingDataComplete
                ? null
                : _controller.createAppointment,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: _controller.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Confirmar Agendamento',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _controller.errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _controller.successMessage,
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

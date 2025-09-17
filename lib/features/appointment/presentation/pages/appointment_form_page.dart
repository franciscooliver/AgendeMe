import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../../../client_management/domain/entities/client_entity.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../controllers/appointment_form_controller.dart';

/// Página para criação/edição de agendamentos por profissionais
/// 
/// Interface para profissionais criarem e editarem agendamentos
/// incluindo seleção de cliente, serviço, data/hora e observações
class AppointmentFormPage extends StatefulWidget {
  const AppointmentFormPage({super.key});

  @override
  State<AppointmentFormPage> createState() => _AppointmentFormPageState();
}

class _AppointmentFormPageState extends State<AppointmentFormPage> {
  late final AppointmentFormController _controller;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<AppointmentFormController>();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Agendamento'),
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
          _buildClientSelection(),
          const SizedBox(height: 24),
          _buildServiceSelection(),
          const SizedBox(height: 24),
          _buildDateTimeSelection(),
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
            Icons.event_available,
            color: Theme.of(context).primaryColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Criar Novo Agendamento',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Preencha os dados para criar um novo agendamento',
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

  Widget _buildClientSelection() {
    return _buildInfoCard(
      title: 'Cliente *',
      icon: Icons.person,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_controller.isLoadingClients)
            const Center(child: CircularProgressIndicator())
          else if (_controller.clients.isEmpty)
            const Text(
              'Nenhum cliente encontrado',
              style: TextStyle(color: Colors.grey),
            )
          else
            DropdownButtonFormField<ClientEntity>(
              value: _controller.selectedClient,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Selecione um cliente',
              ),
              items: _controller.clients.map((client) {
                return DropdownMenuItem<ClientEntity>(
                  value: client,
                  child: Text(client.name),
                );
              }).toList(),
              onChanged: _controller.selectClient,
              validator: (value) {
                if (value == null) {
                  return 'Selecione um cliente';
                }
                return null;
              },
            ),
        ],
      ),
    );
  }

  Widget _buildServiceSelection() {
    return _buildInfoCard(
      title: 'Serviço *',
      icon: Icons.room_service,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_controller.isLoadingServices)
            const Center(child: CircularProgressIndicator())
          else if (_controller.services.isEmpty)
            const Text(
              'Nenhum serviço encontrado',
              style: TextStyle(color: Colors.grey),
            )
          else
            DropdownButtonFormField<ServiceEntity>(
              value: _controller.selectedService,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Selecione um serviço',
              ),
              items: _controller.services.map((service) {
                return DropdownMenuItem<ServiceEntity>(
                  value: service,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(service.name),
                      Text(
                        'R\$ ${service.price.toStringAsFixed(2)} - ${service.duration}min',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _controller.selectService,
              validator: (value) {
                if (value == null) {
                  return 'Selecione um serviço';
                }
                return null;
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelection() {
    return _buildInfoCard(
      title: 'Data e Horário *',
      icon: Icons.schedule,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seleção de data
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                          _controller.selectedDate != null
                              ? '${_controller.selectedDate!.day.toString().padLeft(2, '0')}/${_controller.selectedDate!.month.toString().padLeft(2, '0')}/${_controller.selectedDate!.year.toString()}'
                              : 'Selecionar data',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Seleção de horário
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _controller.selectedDate != null ? _selectTime : null,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: _controller.selectedDate != null 
                          ? null 
                          : Colors.grey[100],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 8),
                        Text(
                          _controller.selectedTime != null
                              ? '${_controller.selectedTime!.hour.toString().padLeft(2, '0')}:${_controller.selectedTime!.minute.toString().padLeft(2, '0')}'
                              : 'Selecionar horário',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Mensagem de disponibilidade
          if (_controller.availabilityMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _controller.availabilityMessage.contains('disponível')
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _controller.availabilityMessage.contains('disponível')
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.red.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _controller.availabilityMessage.contains('disponível')
                        ? Icons.check_circle
                        : Icons.error,
                    color: _controller.availabilityMessage.contains('disponível')
                        ? Colors.green
                        : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _controller.availabilityMessage,
                      style: TextStyle(
                        color: _controller.availabilityMessage.contains('disponível')
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return _buildInfoCard(
      title: 'Observações (Opcional)',
      icon: Icons.note,
      child: TextField(
        controller: _notesController,
        decoration: const InputDecoration(
          hintText: 'Observações sobre o agendamento...',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(12),
        ),
        maxLines: 3,
        onChanged: _controller.updateNotes,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _controller.isLoading ? null : _controller.cancel,
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
            onPressed: _controller.isLoading || !_controller.isFormValid
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
                    'Criar Agendamento',
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

  /// Seleciona a data do agendamento
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _controller.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null && picked != _controller.selectedDate) {
      _controller.selectDate(picked);
    }
  }

  /// Seleciona o horário do agendamento
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _controller.selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null && picked != _controller.selectedTime) {
      _controller.selectTime(picked);
    }
  }
}

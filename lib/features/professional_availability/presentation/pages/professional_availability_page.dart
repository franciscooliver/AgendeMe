import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../controllers/professional_availability_controller.dart';
import '../widgets/available_slots_widget.dart';
import '../widgets/service_selector_widget.dart';
import '../widgets/professional_info_widget.dart';

/// Página para visualizar horários disponíveis de um profissional
/// 
/// Interface para clientes visualizarem e selecionarem horários
/// disponíveis para agendamento com um profissional específico
class ProfessionalAvailabilityPage extends StatefulWidget {
  final String professionalId;

  const ProfessionalAvailabilityPage({
    super.key,
    required this.professionalId,
  });

  @override
  State<ProfessionalAvailabilityPage> createState() => _ProfessionalAvailabilityPageState();
}

class _ProfessionalAvailabilityPageState extends State<ProfessionalAvailabilityPage> {
  late final ProfessionalAvailabilityController _controller;

  @override
  void initState() {
    super.initState();
    print('🔍 DEBUG: ProfessionalAvailabilityPage initState - professionalId: ${widget.professionalId}');
    _controller = Get.put(ProfessionalAvailabilityController(widget.professionalId));
    print('🔍 DEBUG: Controller criado e registrado: $_controller');
    print('🔍 DEBUG: Controller hash: ${_controller.hashCode}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horários Disponíveis'),
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

        if (_controller.errorMessage.isNotEmpty) {
          return _buildErrorState();
        }

        if (_controller.professional == null) {
          return _buildNotFoundState();
        }

        return _buildContent();
      }),
    );
  }

  /// Conteúdo principal da página
  Widget _buildContent() {
    return Column(
      children: [
        // Informações do profissional
        ProfessionalInfoWidget(
          professional: _controller.professional!,
        ),

        // Seletor de serviço
        ServiceSelectorWidget(
          services: _controller.services,
          selectedService: _controller.selectedService,
          onServiceSelected: _controller.updateSelectedService,
        ),

        // Calendário
        _buildCalendar(),

        // Horários disponíveis
        Expanded(
          child: AvailableSlotsWidget(
            controller: _controller,
          ),
        ),
      ],
    );
  }

  /// Widget do calendário
  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar<DateTime>(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 30)),
        focusedDay: _controller.selectedDate,
        selectedDayPredicate: (day) => isSameDay(_controller.selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          _controller.updateSelectedDate(selectedDay);
        },
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(
            color: Colors.red[300],
          ),
          defaultTextStyle: const TextStyle(
            color: Colors.black87,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  /// Estado de erro
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              'Erro ao carregar dados',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _controller.errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _controller.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado quando profissional não é encontrado
  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Profissional não encontrado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'O profissional solicitado não foi encontrado ou não está mais disponível.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Modular.to.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}

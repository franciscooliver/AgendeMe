import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../controllers/professional_calendar_controller.dart';

class ProfessionalCalendarScreen extends StatelessWidget {
  const ProfessionalCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Modular.get<ProfessionalCalendarController>();

    void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
      if (!isSameDay(controller.selectedDay, selectedDay)) {
        controller.updateSelectedDay(selectedDay);
        controller.updateFocusedDay(focusedDay);
      }
    }

    return _buildScreen(context, controller, onDaySelected);
  }

  Widget _buildScreen(
    BuildContext context,
    ProfessionalCalendarController controller,
    void Function(DateTime, DateTime) onDaySelected,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Agenda'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() => Column(
        children: [
          // Indicador de carregamento
          if (controller.isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.deepPurple,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
            ),

          // Calendário
          Card(
            margin: const EdgeInsets.all(12.0),
            child: TableCalendar<dynamic>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: controller.focusedDay,
              calendarFormat: controller.calendarFormat,
              eventLoader: controller.getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) {
                return isSameDay(controller.selectedDay, day);
              },
              onDaySelected: onDaySelected,
              onFormatChanged: (format) {
                if (controller.calendarFormat != format) {
                  controller.updateCalendarFormat(format);
                }
              },
              onPageChanged: (focusedDay) {
                controller.updateFocusedDay(focusedDay);
              },
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(color: Colors.red),
                selectedDecoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                formatButtonTextStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          
          // Lista de agendamentos do dia selecionado
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatSelectedDate(controller.selectedDay),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (controller.selectedDay != null)
                                Text(
                                  _formatDayOfWeek(controller.selectedDay!),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (controller.errorMessage.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.deepPurple),
                            onPressed: controller.refreshAppointments,
                            tooltip: 'Recarregar',
                          ),
                      ],
                    ),
                  ),
                  
                  // Mensagem de erro
                  if (controller.errorMessage.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade600),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              controller.errorMessage,
                              style: TextStyle(color: Colors.red.shade600),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: controller.clearError,
                            iconSize: 18,
                          ),
                        ],
                      ),
                    ),
                  
                  Expanded(
                    child: _buildAppointmentsList(controller),
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar navegação para tela de criação de agendamento
          final selectedDate = controller.selectedDay != null 
              ? '${controller.selectedDay!.day}/${controller.selectedDay!.month}/${controller.selectedDay!.year}'
              : 'hoje';
          
          Get.snackbar(
            'Novo Agendamento',
            'Funcionalidade de criar agendamento para $selectedDate em desenvolvimento',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.deepPurple.withOpacity(0.9),
            colorText: Colors.white,
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Novo Agendamento',
      ),
    );
  }

  /// Constrói a lista de compromissos para o dia selecionado
  Widget _buildAppointmentsList(ProfessionalCalendarController controller) {
    final selectedDayEvents = controller.selectedDay != null
        ? controller.getEventsForDay(controller.selectedDay!)
        : <dynamic>[];
    
    if (selectedDayEvents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum agendamento para este dia',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Toque no botão + para adicionar um novo agendamento',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: selectedDayEvents.length,
      itemBuilder: (context, index) {
        final event = selectedDayEvents[index];
        return _buildAppointmentCard(event);
      },
    );
  }

  /// Constrói um card individual de compromisso
  Widget _buildAppointmentCard(dynamic appointment) {
    // Definir ícone baseado no tipo de serviço
    IconData serviceIcon = Icons.content_cut; // padrão para corte
    if (appointment.service?.toLowerCase().contains('barba') == true) {
      serviceIcon = Icons.face;
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 4.0,
      ),
      elevation: 2,
      child: ListTile(
        onTap: () {
          // TODO: Navegar para detalhes do agendamento
          Get.snackbar(
            'Em breve',
            'Funcionalidade de detalhes do agendamento em desenvolvimento',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        },
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Icon(
            serviceIcon,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          appointment.title ?? 'Cliente',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.service ?? 'Serviço',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${appointment.time ?? "00:00"} (${appointment.duration ?? 60} min)',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
  }

  /// Formata a data selecionada para exibição
  String _formatSelectedDate(DateTime? selectedDay) {
    if (selectedDay == null) return 'Selecione um dia';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    
    if (selected.isAtSameMomentAs(today)) {
      return 'Agendamentos para hoje';
    } else if (selected.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Agendamentos para amanhã';
    } else if (selected.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      return 'Agendamentos para ontem';
    } else {
      return 'Agendamentos para ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}';
    }
  }

  /// Formata o dia da semana da data selecionada
  String _formatDayOfWeek(DateTime selectedDay) {
    const weekdays = [
      '', // Índice 0 não é usado
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo',
    ];
    
    return weekdays[selectedDay.weekday];
  }
}

import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

/// Controller para gerenciar o estado do calendário profissional
/// 
/// Responsável por:
/// - Controlar a data focada e selecionada no calendário
/// - Gerenciar o formato do calendário (mês/semana)
/// - Buscar e organizar compromissos para exibição
/// - Mapear eventos para o formato adequado do table_calendar
class ProfessionalCalendarController extends GetxController {
  // Estado reativo do calendário
  final Rx<DateTime> _focusedDay = DateTime.now().obs;
  final Rx<DateTime?> _selectedDay = Rx<DateTime?>(DateTime.now());
  final Rx<CalendarFormat> _calendarFormat = CalendarFormat.month.obs;
  
  // Estado dos compromissos
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxMap<DateTime, List<dynamic>> _events = <DateTime, List<dynamic>>{}.obs;

  // Getters para acessar o estado
  DateTime get focusedDay => _focusedDay.value;
  DateTime? get selectedDay => _selectedDay.value;
  CalendarFormat get calendarFormat => _calendarFormat.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  Map<DateTime, List<dynamic>> get events => _events;

  @override
  void onInit() {
    super.onInit();
    
    // Inicializar carregamento dos compromissos para o mês atual
    _loadAppointmentsForMonth(focusedDay);
  }

  /// Atualiza a data focada do calendário
  void updateFocusedDay(DateTime newFocusedDay) {
    if (_focusedDay.value.month != newFocusedDay.month ||
        _focusedDay.value.year != newFocusedDay.year) {
      // Se mudou de mês/ano, recarregar compromissos
      _loadAppointmentsForMonth(newFocusedDay);
    }
    _focusedDay.value = newFocusedDay;
  }

  /// Atualiza a data selecionada
  void updateSelectedDay(DateTime? newSelectedDay) {
    _selectedDay.value = newSelectedDay;
  }

  /// Atualiza o formato do calendário
  void updateCalendarFormat(CalendarFormat newFormat) {
    _calendarFormat.value = newFormat;
  }

  /// Retorna os eventos para um dia específico
  List<dynamic> getEventsForDay(DateTime day) {
    // Normalizar a data para comparação (apenas dia/mês/ano)
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  /// Carrega compromissos para o mês especificado
  Future<void> _loadAppointmentsForMonth(DateTime targetMonth) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // TODO: Substituir por chamada real ao UseCase quando a feature appointment for implementada
      await _loadMockAppointments(targetMonth);

    } catch (e) {
      _errorMessage.value = 'Erro ao carregar compromissos: $e';
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os compromissos',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Mock temporário para simular compromissos
  /// TODO: Remover quando a feature appointment for implementada
  Future<void> _loadMockAppointments(DateTime targetMonth) async {
    // Simular delay da API
    await Future.delayed(const Duration(milliseconds: 500));

    // Limpar eventos existentes
    _events.clear();

    // Gerar alguns compromissos mock para demonstração
    final mockAppointments = _generateMockAppointments(targetMonth);
    
    // Organizar compromissos por data
    for (final appointment in mockAppointments) {
      final date = DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
      );
      
      if (_events.containsKey(date)) {
        _events[date]!.add(appointment);
      } else {
        _events[date] = [appointment];
      }
    }
  }

  /// Gera compromissos mock para demonstração
  /// TODO: Remover quando a feature appointment for implementada
  List<_MockAppointment> _generateMockAppointments(DateTime targetMonth) {
    final appointments = <_MockAppointment>[];
    final endDate = DateTime(targetMonth.year, targetMonth.month + 1, 0);

    // Adicionar alguns compromissos aleatórios
    final appointmentDays = [5, 12, 18, 22, 28];
    
    for (final day in appointmentDays) {
      if (day <= endDate.day) {
        final appointmentDate = DateTime(targetMonth.year, targetMonth.month, day);
        
        // Adicionar 1-3 compromissos por dia
        final numberOfAppointments = (day % 3) + 1;
        
        for (int i = 0; i < numberOfAppointments; i++) {
          appointments.add(_MockAppointment(
            id: '${day}_$i',
            title: 'Cliente ${day == 5 ? 'Maria Silva' : day == 12 ? 'João Santos' : day == 18 ? 'Ana Costa' : day == 22 ? 'Pedro Lima' : 'Carlos Souza'}',
            service: day % 2 == 0 ? 'Corte de Cabelo' : 'Barba',
            date: appointmentDate,
            time: '${8 + (i * 2)}:00',
            duration: 60,
          ));
        }
      }
    }

    return appointments;
  }

  /// Força recarregamento dos compromissos
  Future<void> refreshAppointments() async {
    await _loadAppointmentsForMonth(focusedDay);
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage.value = '';
  }
}

/// Classe temporária para simular um compromisso
/// TODO: Remover quando AppointmentEntity for implementada
class _MockAppointment {
  final String id;
  final String title;
  final String service;
  final DateTime date;
  final String time;
  final int duration; // em minutos

  _MockAppointment({
    required this.id,
    required this.title,
    required this.service,
    required this.date,
    required this.time,
    required this.duration,
  });

  @override
  String toString() => '$title - $service ($time)';
}

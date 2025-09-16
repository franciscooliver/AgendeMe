import 'package:flutter_modular/flutter_modular.dart';

import 'domain/usecases/get_available_time_slots_usecase.dart';
import 'presentation/controllers/professional_availability_controller.dart';
import 'presentation/pages/professional_availability_page.dart';

/// Módulo para funcionalidades de visualização de horários disponíveis
/// 
/// Responsável por permitir que clientes visualizem os horários disponíveis
/// de um profissional para agendamento
class ProfessionalAvailabilityModule extends Module {
  @override
  void binds(i) {
    // Use Cases
    i.addLazySingleton<GetAvailableTimeSlotsUseCase>(
      () => GetAvailableTimeSlotsUseCase(
        userProfileRepository: i(),
        appointmentRepository: i(),
        serviceRepository: i(),
      ),
    );

    // Controllers
    i.addLazySingleton<ProfessionalAvailabilityController>(
      () => ProfessionalAvailabilityController(i()),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/availability/:professionalId',
      child: (context) => ProfessionalAvailabilityPage(
        professionalId: r.args.params['professionalId']!,
      ),
    );
  }
}

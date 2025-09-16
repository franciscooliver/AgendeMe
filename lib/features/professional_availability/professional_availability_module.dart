import 'package:flutter_modular/flutter_modular.dart';

import '../user_profile/domain/repositories/user_profile_repository.dart';
import '../appointment/domain/repositories/appointment_repository.dart';
import '../services/domain/repositories/service_repository.dart';
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
        userProfileRepository: Modular.get<UserProfileRepository>(),
        appointmentRepository: Modular.get<AppointmentRepository>(),
        serviceRepository: Modular.get<ServiceRepository>(),
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

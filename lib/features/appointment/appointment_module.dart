import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../core/core.dart';
import 'data/datasources/appointment_remote_datasource.dart';
import 'data/repositories/appointment_repository_impl.dart';
import 'domain/repositories/appointment_repository.dart';
import 'domain/usecases/create_appointment_usecase.dart';
import 'presentation/controllers/appointment_booking_controller.dart';
import 'presentation/pages/appointment_confirmation_page.dart';

/// Módulo da feature Appointment
/// 
/// Responsável por registrar todas as dependências da feature:
/// - Data Sources
/// - Repositories  
/// - Use Cases (futuros)
/// - Controllers (futuros)
/// - Páginas e rotas (futuras)
class AppointmentModule extends Module {
  @override
  void binds(Injector i) {
    // External dependencies
    i.addLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
    
    // NetworkInfo from parent module (AppModule)
    // Using Modular.get to access parent scope

    // Data Sources
    i.addLazySingleton<AppointmentRemoteDataSource>(
      () => AppointmentRemoteDataSourceImpl(
        firestore: i.get<FirebaseFirestore>(),
      ),
    );

    // Repositories
    i.addLazySingleton<AppointmentRepository>(
      () => AppointmentRepositoryImpl(
        remoteDataSource: i.get<AppointmentRemoteDataSource>(),
        networkInfo: Modular.get<NetworkInfo>(), // Access from parent scope (AppModule)
      ),
    );

    // Use Cases
    i.addLazySingleton<CreateAppointmentUseCase>(
      () => CreateAppointmentUseCase(repository: i.get<AppointmentRepository>()),
    );

    // i.addLazySingleton<GetAppointmentsUseCase>(
    //   () => GetAppointmentsUseCase(i.get<AppointmentRepository>()),
    // );

    // Controllers
    i.addLazySingleton<AppointmentBookingController>(
      () => AppointmentBookingController(
        createAppointmentUseCase: i.get<CreateAppointmentUseCase>(),
      ),
    );
  }

  @override
  void routes(RouteManager r) {
    // Rota para confirmação de agendamento
    r.child(
      '/confirmation',
      child: (context) => AppointmentConfirmationPage(
        professional: r.args.data['professional'],
        service: r.args.data['service'],
        slot: r.args.data['slot'],
      ),
    );
  }
}

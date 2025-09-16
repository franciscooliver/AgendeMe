import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../core/core.dart';
import 'data/datasources/appointment_remote_datasource.dart';
import 'data/repositories/appointment_repository_impl.dart';
import 'domain/repositories/appointment_repository.dart';

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

    // Use Cases - A serem implementados nas próximas tarefas
    // i.addLazySingleton<CreateAppointmentUseCase>(
    //   () => CreateAppointmentUseCase(i.get<AppointmentRepository>()),
    // );

    // i.addLazySingleton<GetAppointmentsUseCase>(
    //   () => GetAppointmentsUseCase(i.get<AppointmentRepository>()),
    // );

    // Controllers - A serem implementados nas próximas tarefas  
    // i.addLazySingleton<AppointmentController>(
    //   () => AppointmentController(
    //     createAppointmentUseCase: i.get<CreateAppointmentUseCase>(),
    //     getAppointmentsUseCase: i.get<GetAppointmentsUseCase>(),
    //     appointmentRepository: i.get<AppointmentRepository>(),
    //   ),
    // );
  }

  @override
  void routes(RouteManager r) {
    // Rotas a serem implementadas nas próximas tarefas
    
    // Rota para listagem de agendamentos
    // r.child(
    //   '/appointments',
    //   child: (context) => const AppointmentListPage(),
    // );

    // Rota para criação de agendamento
    // r.child(
    //   '/appointments/create',
    //   child: (context) => const CreateAppointmentPage(),
    // );

    // Rota para detalhes do agendamento
    // r.child(
    //   '/appointments/:appointmentId',
    //   child: (context) => AppointmentDetailPage(
    //     appointmentId: r.args.params['appointmentId']!,
    //   ),
    // );

    // Rota padrão temporária (a ser removida quando houver páginas)
    // r.child(
    //   '/',
    //   child: (context) => const Scaffold(
    //     body: Center(
    //       child: Text('Appointment Module - Coming Soon'),
    //     ),
    //   ),
    // );
  }
}

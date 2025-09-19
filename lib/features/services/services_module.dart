import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../core/core.dart';
import 'data/datasources/service_remote_datasource.dart';
import 'data/repositories/service_repository_impl.dart';
import 'domain/repositories/service_repository.dart';
import 'domain/usecases/add_service.dart';
import 'domain/usecases/delete_service.dart';
import 'domain/usecases/edit_service.dart';
import 'domain/usecases/get_service_by_id.dart';
import 'domain/usecases/get_services.dart';
import 'presentation/controllers/service_controller.dart';
import 'presentation/pages/service_list_page.dart';
import 'presentation/pages/service_form_page.dart';

/// Módulo da feature Services
/// 
/// Responsável por registrar todas as dependências da feature:
/// - Data Sources
/// - Repositories  
/// - Use Cases
/// - Controllers
/// - Páginas e rotas
class ServicesModule extends Module {
  @override
  void binds(Injector i) {
    // External dependencies
    i.addLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
    i.addLazySingleton<Connectivity>(() => Connectivity());
    i.addLazySingleton<InternetConnectionChecker>(() => InternetConnectionChecker.instance);
    
    // Core bindings
    i.addLazySingleton<NetworkInfo>(() => NetworkInfoImpl(i()));

    // Data Sources
    i.addLazySingleton<ServiceRemoteDataSource>(
      () => ServiceRemoteDataSourceImpl(
        firestore: i.get<FirebaseFirestore>(),
      ),
    );

    // Repositories
    i.addLazySingleton<ServiceRepository>(
      () => ServiceRepositoryImpl(
        remoteDataSource: i.get<ServiceRemoteDataSource>(),
        networkInfo: i.get<NetworkInfo>(), // Use local injection instead of Modular.get
      ),
    );

    // Use Cases
    i.addLazySingleton<GetServices>(
      () => GetServices(i.get<ServiceRepository>()),
    );

    i.addLazySingleton<GetServiceById>(
      () => GetServiceById(i.get<ServiceRepository>()),
    );

    i.addLazySingleton<AddService>(
      () => AddService(i.get<ServiceRepository>()),
    );

    i.addLazySingleton<EditService>(
      () => EditService(i.get<ServiceRepository>()),
    );

    i.addLazySingleton<DeleteService>(
      () => DeleteService(i.get<ServiceRepository>()),
    );

    // Controllers
    i.addLazySingleton<ServiceController>(
      () => ServiceController(
        getServices: i.get<GetServices>(),
        getServiceById: i.get<GetServiceById>(),
        addService: i.get<AddService>(),
        editService: i.get<EditService>(),
        deleteService: i.get<DeleteService>(),
      ),
    );
  }

  @override
  void routes(RouteManager r) {
    // Rota para listagem de serviços
    r.child(
      '/',
      child: (context) => const ServiceListPage(),
    );

    // Rota para adicionar novo serviço
    r.child(
      '/add',
      child: (context) => const ServiceFormPage(),
    );

    // Rota para editar serviço existente
    r.child(
      '/:serviceId/edit',
      child: (context) => ServiceFormPage(
        serviceId: r.args.params['serviceId'],
      ),
    );

    // TODO: Adicionar outras rotas quando necessário
    // r.child(
    //   '/services/:serviceId',
    //   child: (context) => ServiceDetailPage(
    //     serviceId: r.args.params['serviceId']!,
    //   ),
    // );
  }
}

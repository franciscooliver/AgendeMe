import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../core/core.dart';
import 'data/datasources/client_remote_datasource.dart';
import 'data/repositories/client_repository_impl.dart';
import 'domain/repositories/client_repository.dart';
import 'domain/usecases/get_clients.dart';
import 'domain/usecases/get_client_by_id.dart';
import 'domain/usecases/search_clients.dart';
import 'domain/usecases/add_client.dart';
import 'domain/usecases/update_client_statistics.dart';
import 'domain/usecases/auto_register_client.dart';
import 'domain/services/client_auto_registration_service.dart';
import 'presentation/controllers/client_controller.dart';
import 'presentation/pages/client_list_page.dart';

/// Módulo da feature Client Management
/// 
/// Responsável por registrar todas as dependências da feature:
/// - Data Sources
/// - Repositories  
/// - Use Cases
/// - Controllers
/// - Páginas e rotas
class ClientManagementModule extends Module {
  @override
  void binds(Injector i) {
    // External dependencies
    i.addLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
    
    // NetworkInfo from parent module (AppModule)
    // Using Modular.get to access parent scope

    // Data Sources
    i.addLazySingleton<ClientRemoteDataSource>(
      () => ClientRemoteDataSourceImpl(
        firestore: i.get<FirebaseFirestore>(),
      ),
    );

    // Repositories
    i.addLazySingleton<ClientRepository>(
      () => ClientRepositoryImpl(
        remoteDataSource: i.get<ClientRemoteDataSource>(),
        networkInfo: Modular.get<NetworkInfo>(), // Access from parent scope (AppModule)
      ),
    );

    // Use Cases
    i.addLazySingleton<GetClients>(
      () => GetClients(i.get<ClientRepository>()),
    );

    i.addLazySingleton<GetClientById>(
      () => GetClientById(i.get<ClientRepository>()),
    );

    i.addLazySingleton<SearchClients>(
      () => SearchClients(i.get<ClientRepository>()),
    );

    i.addLazySingleton<AddClient>(
      () => AddClient(i.get<ClientRepository>()),
    );

    i.addLazySingleton<UpdateClientStatistics>(
      () => UpdateClientStatistics(i.get<ClientRepository>()),
    );

    i.addLazySingleton<AutoRegisterClient>(
      () => AutoRegisterClient(i.get<ClientRepository>()),
    );

    // Services
    i.addLazySingleton<ClientAutoRegistrationService>(
      () => ClientAutoRegistrationServiceImpl(
        autoRegisterClient: i.get<AutoRegisterClient>(),
        updateClientStatistics: i.get<UpdateClientStatistics>(),
      ),
    );

    // Controllers
    i.addLazySingleton<ClientController>(
      () => ClientController(
        getClients: i.get<GetClients>(),
        getClientById: i.get<GetClientById>(),
        searchClients: i.get<SearchClients>(),
        addClient: i.get<AddClient>(),
        updateClientStatistics: i.get<UpdateClientStatistics>(),
        clientRepository: i.get<ClientRepository>(),
      ),
    );
  }

  @override
  void routes(RouteManager r) {
    // Rota para listagem de clientes
    r.child(
      '/clients',
      child: (context) => const ClientListPage(),
    );

    // Rota padrão que redireciona para a listagem
    r.child(
      '/',
      child: (context) => const ClientListPage(),
    );

    // TODO: Adicionar outras rotas quando necessário
    // r.child(
    //   '/clients/:clientId',
    //   child: (context) => ClientDetailPage(
    //     clientId: r.args.params['clientId']!,
    //   ),
    // );
  }
}

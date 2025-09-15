import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../../core/core.dart';
import '../data/datasources/template_example_local_datasource.dart';
import '../data/datasources/template_example_remote_datasource.dart';
import '../data/repositories/template_example_repository_impl.dart';
import '../domain/repositories/template_example_repository.dart';
import '../domain/usecases/create_template_example.dart';
import '../domain/usecases/get_all_template_examples.dart';
import '../domain/usecases/get_template_example.dart';
import 'controllers/template_example_controller.dart';
import 'pages/template_example_page.dart';

/// Módulo da feature Template Example
/// 
/// Demonstra como configurar dependency injection e routing
/// seguindo as convenções do projeto com Flutter Modular
class TemplateExampleModule extends Module {
  @override
  void binds(Injector i) {
    // ===== CORE DEPENDENCIES =====
    
    // NetworkInfo - singleton global (reutiliza da app se já existir)
    i.addLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(InternetConnectionChecker.instance),
    );

    // ===== DATA LAYER =====
    
    // DataSources
    i.addLazySingleton<TemplateExampleRemoteDataSource>(
      () => TemplateExampleRemoteDataSourceImpl(),
    );
    
    i.addLazySingleton<TemplateExampleLocalDataSource>(
      () => TemplateExampleLocalDataSourceImpl(),
    );

    // Repository Implementation
    i.addLazySingleton<TemplateExampleRepository>(
      () => TemplateExampleRepositoryImpl(
        remoteDataSource: i<TemplateExampleRemoteDataSource>(),
        localDataSource: i<TemplateExampleLocalDataSource>(),
        networkInfo: i<NetworkInfo>(),
      ),
    );

    // ===== DOMAIN LAYER =====
    
    // Use Cases
    i.addLazySingleton<GetTemplateExample>(
      () => GetTemplateExample(i<TemplateExampleRepository>()),
    );
    
    i.addLazySingleton<GetAllTemplateExamples>(
      () => GetAllTemplateExamples(i<TemplateExampleRepository>()),
    );
    
    i.addLazySingleton<CreateTemplateExample>(
      () => CreateTemplateExample(i<TemplateExampleRepository>()),
    );

    // ===== PRESENTATION LAYER =====
    
    // Controllers
    i.addLazySingleton<TemplateExampleController>(
      () => TemplateExampleController(
        getTemplateExample: i<GetTemplateExample>(),
        getAllTemplateExamples: i<GetAllTemplateExamples>(),
        createTemplateExample: i<CreateTemplateExample>(),
      ),
    );
  }

  @override
  void routes(RouteManager r) {
    // Rota principal da feature
    r.child(
      '/',
      child: (context) => const TemplateExamplePage(),
    );
    
    // Rota para criação (exemplo - seria implementada em uma página específica)
    r.child(
      '/create',
      child: (context) => const Scaffold(
        body: Center(
          child: Text('Página de Criação\n(A ser implementada)'),
        ),
      ),
    );
    
    // Rota para detalhes com parâmetro
    r.child(
      '/details/:id',
      child: (context) {
        final id = r.args.params['id'] ?? '';
        return Scaffold(
          appBar: AppBar(
            title: Text('Detalhes do Template $id'),
          ),
          body: const Center(
            child: Text('Página de Detalhes\n(A ser implementada)'),
          ),
        );
      },
    );
    
    // Rota para edição com parâmetro
    r.child(
      '/edit/:id',
      child: (context) {
        final id = r.args.params['id'] ?? '';
        return Scaffold(
          appBar: AppBar(
            title: Text('Editar Template $id'),
          ),
          body: const Center(
            child: Text('Página de Edição\n(A ser implementada)'),
          ),
        );
      },
    );
  }
}

/// Módulo simplificado para demonstração de diferentes padrões de binding
class TemplateExampleModuleAlternative extends Module {
  @override
  void binds(Injector i) {
    // ===== PADRÃO LAZY SINGLETON =====
    // Use lazy singleton para objetos que devem ser únicos
    // mas só criados quando necessário (padrão recomendado)
    
    i.addLazySingleton<CreateTemplateExample>(
      () => CreateTemplateExample(i<TemplateExampleRepository>()),
    );

    // ===== PADRÃO LAZY SINGLETON PARA REPOSITORY =====
    // Repository como lazy singleton
    
    i.addLazySingleton<TemplateExampleRepository>(
      () => TemplateExampleRepositoryImpl(
        remoteDataSource: i<TemplateExampleRemoteDataSource>(),
        localDataSource: i<TemplateExampleLocalDataSource>(),
        networkInfo: i<NetworkInfo>(),
      ),
    );

    // ===== PADRÃO LAZY SINGLETON =====
    // Use lazy singleton para objetos que devem ser únicos
    // mas só criados quando necessário (padrão recomendado)
    
    i.addLazySingleton<TemplateExampleController>(
      () => TemplateExampleController(
        getTemplateExample: i<GetTemplateExample>(),
        getAllTemplateExamples: i<GetAllTemplateExamples>(),
        createTemplateExample: i<CreateTemplateExample>(),
      ),
    );

    // ===== PADRÃO INSTANCE =====
    // Use instance para objetos já criados ou configurações específicas
    
    i.addInstance<NetworkInfo>(
      NetworkInfoImpl(InternetConnectionChecker.instance),
    );
  }

  @override
  void routes(RouteManager r) {
    // Exemplo de rotas com guards e middlewares
    r.child(
      '/',
      child: (context) => const TemplateExamplePage(),
      guards: [
        // Aqui você poderia adicionar guards de autenticação
        // AuthGuard(),
      ],
    );
    
    // Exemplo de rota com transição customizada
    r.child(
      '/animated',
      child: (context) => const TemplateExamplePage(),
      transition: TransitionType.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
    
    // Exemplo de rota que redireciona
    r.redirect('/', to: '/template-example/');
  }
}

/// Exemplo de como organizar bindings por responsabilidade
class TemplateExampleModuleAdvanced extends Module {
  @override
  void binds(Injector i) {
    _bindDataSources(i);
    _bindRepositories(i);
    _bindUseCases(i);
    _bindControllers(i);
    _bindServices(i);
  }

  void _bindDataSources(Injector i) {
    i.addLazySingleton<TemplateExampleRemoteDataSource>(
      () => TemplateExampleRemoteDataSourceImpl(),
    );
    
    i.addLazySingleton<TemplateExampleLocalDataSource>(
      () => TemplateExampleLocalDataSourceImpl(),
    );
  }

  void _bindRepositories(Injector i) {
    i.addLazySingleton<TemplateExampleRepository>(
      () => TemplateExampleRepositoryImpl(
        remoteDataSource: i(),
        localDataSource: i(),
        networkInfo: i(),
      ),
    );
  }

  void _bindUseCases(Injector i) {
    i.addLazySingleton(() => GetTemplateExample(i()));
    i.addLazySingleton(() => GetAllTemplateExamples(i()));
    i.addLazySingleton(() => CreateTemplateExample(i()));
  }

  void _bindControllers(Injector i) {
    i.addLazySingleton(() => TemplateExampleController(
      getTemplateExample: i(),
      getAllTemplateExamples: i(),
      createTemplateExample: i(),
    ));
  }

  void _bindServices(Injector i) {
    // Aqui você poderia adicionar serviços específicos da feature
    // como validadores, formatadores, etc.
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const TemplateExamplePage());
    r.child('/create', child: (context) => const _CreatePage());
    r.child('/details/:id', child: (context) => _DetailsPage(id: r.args.params['id']!));
  }
}

// Páginas de exemplo para demonstrar a estrutura
class _CreatePage extends StatelessWidget {
  const _CreatePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Página de Criação'),
      ),
    );
  }
}

class _DetailsPage extends StatelessWidget {
  final String id;
  
  const _DetailsPage({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Detalhes do item: $id'),
      ),
    );
  }
}

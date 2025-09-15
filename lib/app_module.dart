import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'core/core.dart';
import 'features/auth/auth_module.dart';
import 'features/auth/presentation/pages/auth_wrapper_page.dart';

class AppModule extends Module {
  @override
  void binds(Injector i) {
    // External dependencies
    i.addLazySingleton<Connectivity>(() => Connectivity());
    
    // Core bindings
    i.addLazySingleton<NetworkInfo>(() => NetworkInfoImpl(i()));
  }

  @override
  void routes(RouteManager r) {
    // Rotas de autenticação
    r.module('/auth', module: AuthModule());
    
    // Rota inicial - wrapper que verifica autenticação
    r.child('/', child: (context) => const AuthWrapperPage());
  }
}

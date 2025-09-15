import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'core/core.dart';
import 'features/auth/auth_module.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/professional/professional_module.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/pages/auth_wrapper_page.dart';

class AppModule extends Module {
  @override
  void binds(Injector i) {
    // External dependencies
    i.addLazySingleton<Connectivity>(() => Connectivity());
    i.addLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    i.addLazySingleton<InternetConnectionChecker>(() => InternetConnectionChecker.instance);
    
    // Core bindings
    i.addLazySingleton<NetworkInfo>(() => NetworkInfoImpl(i()));
    
    // Auth bindings (global scope for AuthWrapperPage)
    i.addLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(firebaseAuth: i()),
    );
    i.addLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: i(),
        networkInfo: i(),
      ),
    );
    
    // Use Cases
    i.addLazySingleton(() => SignInUseCase(i()));
    i.addLazySingleton(() => SignUpUseCase(i()));
    i.addLazySingleton(() => SignOutUseCase(i()));
    i.addLazySingleton(() => GetCurrentUserUseCase(i()));
    
    // Controller (global scope)
    i.addLazySingleton(() => AuthController(
          signInUseCase: i(),
          signUpUseCase: i(),
          signOutUseCase: i(),
          getCurrentUserUseCase: i(),
        ));
  }

  @override
  void routes(RouteManager r) {
    // Rotas de autenticação
    r.module('/auth', module: AuthModule());
    
    // Rotas do profissional
    r.module('/professional', module: ProfessionalModule());
    
    // Rota inicial - wrapper que verifica autenticação
    r.child('/', child: (context) => const AuthWrapperPage());
  }
}

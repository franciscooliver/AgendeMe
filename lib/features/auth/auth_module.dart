import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../core/network/network_info.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/get_current_user_usecase.dart';
import 'domain/usecases/sign_in_usecase.dart';
import 'domain/usecases/sign_out_usecase.dart';
import 'domain/usecases/sign_up_usecase.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';

class AuthModule extends Module {
  @override
  void binds(Injector i) {
    // External dependencies
    i.addLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

    // DataSources
    i.addLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(firebaseAuth: i()),
    );

    // Repository
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

    // Controller
    i.addLazySingleton(() => AuthController(
          signInUseCase: i(),
          signUpUseCase: i(),
          signOutUseCase: i(),
          getCurrentUserUseCase: i(),
        ));
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/login',
      child: (context) => const LoginPage(),
    );
    r.child(
      '/register',
      child: (context) => const RegisterPage(),
    );
  }
}

import 'package:flutter_modular/flutter_modular.dart';

import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';

class AuthModule extends Module {
  @override
  void binds(Injector i) {
    // Auth dependencies are now handled in AppModule for global access
    // This module only handles auth-specific routes
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

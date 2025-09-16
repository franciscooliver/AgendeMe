import 'package:flutter_modular/flutter_modular.dart';

import 'presentation/controllers/professional_calendar_controller.dart';
import 'presentation/pages/professional_calendar_screen.dart';
import 'presentation/pages/professional_config_screen.dart';
import 'presentation/pages/professional_dashboard_screen.dart';

class ProfessionalModule extends Module {
  @override
  void binds(Injector i) {
    // Controllers
    i.addLazySingleton<ProfessionalCalendarController>(
      () => ProfessionalCalendarController(),
    );
    
    // Note: ProfessionalConfigController é criado via Get.put()
    // nas telas que o utilizam para evitar conflitos de escopo
    
    // TODO: Adicionar bindings para repositórios, use cases
    // quando forem implementados nas próximas subtarefas
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/dashboard',
      child: (context) => const ProfessionalDashboardScreen(),
    );

    r.child(
      '/calendar',
      child: (context) => const ProfessionalCalendarScreen(),
    );
    
    r.child(
      '/config',
      child: (context) => const ProfessionalConfigScreen(),
    );
    
    // Rota padrão que redireciona para o dashboard
    r.child(
      '/',
      child: (context) => const ProfessionalDashboardScreen(),
    );
  }
}

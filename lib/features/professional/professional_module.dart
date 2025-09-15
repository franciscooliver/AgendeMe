import 'package:flutter_modular/flutter_modular.dart';

import 'presentation/controllers/professional_calendar_controller.dart';
import 'presentation/pages/professional_calendar_screen.dart';

class ProfessionalModule extends Module {
  @override
  void binds(Injector i) {
    // Controllers
    i.addLazySingleton<ProfessionalCalendarController>(
      () => ProfessionalCalendarController(),
    );
    
    // TODO: Adicionar bindings para repositórios, use cases
    // quando forem implementados nas próximas subtarefas
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/calendar',
      child: (context) => const ProfessionalCalendarScreen(),
    );
    
    // Rota padrão que redireciona para o calendário
    r.child(
      '/',
      child: (context) => const ProfessionalCalendarScreen(),
    );
  }
}

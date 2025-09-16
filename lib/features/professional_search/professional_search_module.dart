import 'package:flutter_modular/flutter_modular.dart';

import 'domain/usecases/search_professionals_usecase.dart';
import 'presentation/controllers/professional_search_controller.dart';
import 'presentation/pages/professional_search_page.dart';

/// Módulo para funcionalidades de busca de profissionais
/// 
/// Responsável por gerenciar a busca de profissionais por nome, serviço ou localização
class ProfessionalSearchModule extends Module {
  @override
  void binds(i) {
    // Use Cases
    i.addLazySingleton<SearchProfessionalsUseCase>(
      () => SearchProfessionalsUseCase(),
    );

    // Controllers
    i.addLazySingleton<ProfessionalSearchController>(
      () => ProfessionalSearchController(i()),
    );
  }

  @override
  void routes(r) {
    r.child(
      '/search',
      child: (context) => const ProfessionalSearchPage(),
    );
  }
}

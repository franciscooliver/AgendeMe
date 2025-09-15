import 'package:flutter_modular/flutter_modular.dart';

import 'domain/repositories/user_profile_repository.dart';
import 'domain/usecases/delete_user_profile.dart';
import 'domain/usecases/get_user_profile.dart';
import 'presentation/pages/user_type_selection_screen.dart';
import 'presentation/pages/user_profile_view_page.dart';
import 'presentation/pages/user_profile_edit_page.dart';

/// Módulo da feature User Profile
/// 
/// Responsável apenas pelas rotas da feature, já que todas as dependências
/// estão registradas no AppModule para permitir acesso global pelo AuthWrapperPage.
class UserProfileModule extends Module {
  @override
  void binds(Injector i) {
    print('-- UserProfileModule INITIALIZED');
    
    // Note: All bindings are now in AppModule for global access
    // This module only handles additional use cases if needed
    
    // GetUserProfile use case for specific profile viewing by document ID
    i.addLazySingleton<GetUserProfile>(
      () => GetUserProfile(Modular.get<UserProfileRepository>()),
    );

    // DeleteUserProfile use case for profile deletion
    i.addLazySingleton<DeleteUserProfile>(
      () => DeleteUserProfile(Modular.get<UserProfileRepository>()),
    );
  }

  @override
  void routes(RouteManager r) {
    // Rota para seleção de tipo de usuário
    r.child(
      '/user-type-selection',
      child: (context) => const UserTypeSelectionScreen(),
    );

    // Rota para visualização do perfil
    r.child(
      '/profile',
      child: (context) => UserProfileViewPage(
        userId: r.args.queryParams['userId'],
      ),
    );
    
    // Rota para edição/criação do perfil
    r.child(
      '/profile/edit',
      child: (context) => UserProfileEditPage(
        userId: r.args.queryParams['userId'],
      ),
    );
  }
}

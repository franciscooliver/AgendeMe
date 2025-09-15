import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../core/core.dart';
import 'data/datasources/user_profile_remote_datasource.dart';
import 'data/repositories/user_profile_repository_impl.dart';
import 'domain/repositories/user_profile_repository.dart';
import 'domain/usecases/create_user_profile.dart';
import 'domain/usecases/delete_user_profile.dart';
import 'domain/usecases/get_user_profile.dart';
import 'domain/usecases/get_user_profile_by_user_id.dart';
import 'domain/usecases/update_user_profile.dart';
import 'presentation/controllers/user_profile_controller.dart';
import 'presentation/pages/user_type_selection_screen.dart';

/// Módulo da feature User Profile
/// 
/// Responsável por registrar todas as dependências da feature:
/// - Data Sources
/// - Repositories  
/// - Use Cases
/// - Controllers
/// - Páginas e rotas
class UserProfileModule extends Module {
  @override
  void binds(Injector i) {
    // External dependencies
    i.addLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

    // Data Sources
    i.addLazySingleton<UserProfileRemoteDataSource>(
      () => UserProfileRemoteDataSourceImpl(
        firestore: i.get<FirebaseFirestore>(),
      ),
    );

    // Repositories
    i.addLazySingleton<UserProfileRepository>(
      () => UserProfileRepositoryImpl(
        remoteDataSource: i.get<UserProfileRemoteDataSource>(),
        networkInfo: i.get<NetworkInfo>(),
      ),
    );

    // Use Cases
    i.addLazySingleton<GetUserProfile>(
      () => GetUserProfile(i.get<UserProfileRepository>()),
    );

    i.addLazySingleton<GetUserProfileByUserId>(
      () => GetUserProfileByUserId(i.get<UserProfileRepository>()),
    );

    i.addLazySingleton<CreateUserProfile>(
      () => CreateUserProfile(i.get<UserProfileRepository>()),
    );

    i.addLazySingleton<UpdateUserProfile>(
      () => UpdateUserProfile(i.get<UserProfileRepository>()),
    );

    i.addLazySingleton<DeleteUserProfile>(
      () => DeleteUserProfile(i.get<UserProfileRepository>()),
    );

    // Controllers
    i.addLazySingleton<UserProfileController>(
      () => UserProfileController(
        getUserProfileByUserId: i.get<GetUserProfileByUserId>(),
        createUserProfile: i.get<CreateUserProfile>(),
        updateUserProfile: i.get<UpdateUserProfile>(),
      ),
    );
  }

  @override
  void routes(RouteManager r) {
    // Rota para seleção de tipo de usuário
    r.child(
      '/user-type-selection',
      child: (context) => const UserTypeSelectionScreen(),
    );

    // TODO: Adicionar outras rotas quando implementadas
    // r.child(
    //   '/profile',
    //   child: (context) => const UserProfilePage(),
    // );
    // 
    // r.child(
    //   '/profile/edit',
    //   child: (context) => const EditUserProfilePage(),
    // );
  }
}

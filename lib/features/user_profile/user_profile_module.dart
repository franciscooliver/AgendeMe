import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../core/core.dart';
import 'data/datasources/user_profile_remote_datasource.dart';
import 'data/repositories/user_profile_repository_impl.dart';
import 'data/services/firebase_storage_service.dart';
import 'data/services/image_picker_service.dart';
import 'data/services/image_compressor_service.dart';
import 'domain/repositories/user_profile_repository.dart';
import 'domain/usecases/create_user_profile.dart';
import 'domain/usecases/delete_user_profile.dart';
import 'domain/usecases/get_user_profile.dart';
import 'domain/usecases/get_user_profile_by_user_id.dart';
import 'domain/usecases/update_user_profile.dart';
import 'domain/usecases/pick_and_compress_image_usecase.dart';
import 'domain/usecases/upload_profile_picture_usecase.dart';
import 'presentation/controllers/user_profile_controller.dart';
import 'presentation/controllers/user_type_selection_controller.dart';
import 'presentation/pages/user_type_selection_screen.dart';
import 'presentation/pages/user_profile_view_page.dart';
import 'presentation/pages/user_profile_edit_page.dart';

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
    i.addLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
    
    // NetworkInfo from parent module (AppModule)
    // Using Modular.get to access parent scope

    // Services
    i.addLazySingleton<IStorageService>(
      () => FirebaseStorageService(firebaseStorage: i.get<FirebaseStorage>()),
    );
    
    i.addLazySingleton<ImagePickerService>(
      () => ImagePickerService(),
    );
    
    i.addLazySingleton<ImageCompressorService>(
      () => ImageCompressorService(),
    );

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
        networkInfo: Modular.get<NetworkInfo>(), // Access from parent scope (AppModule)
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

    i.addLazySingleton<PickAndCompressImageUseCase>(
      () => PickAndCompressImageUseCase(
        imagePickerService: i.get<ImagePickerService>(),
        imageCompressorService: i.get<ImageCompressorService>(),
      ),
    );

    i.addLazySingleton<UploadProfilePictureUseCase>(
      () => UploadProfilePictureUseCase(
        pickAndCompressImageUseCase: i.get<PickAndCompressImageUseCase>(),
        storageService: i.get<IStorageService>(),
        userProfileRepository: i.get<UserProfileRepository>(),
      ),
    );

    // Controllers
    i.addLazySingleton<UserProfileController>(
      () => UserProfileController(
        getUserProfileByUserId: i.get<GetUserProfileByUserId>(),
        createUserProfile: i.get<CreateUserProfile>(),
        updateUserProfile: i.get<UpdateUserProfile>(),
        uploadProfilePictureUseCase: i.get<UploadProfilePictureUseCase>(),
      ),
    );

    // UserTypeSelectionController (needs both auth and user profile)
    i.addLazySingleton<UserTypeSelectionController>(
      () => UserTypeSelectionController(),
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

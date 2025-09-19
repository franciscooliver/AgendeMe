import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'core/core.dart';
import 'core/data/services/local_cache_service_impl.dart';
import 'features/appointment/appointment_module.dart';
import 'features/auth/auth_module.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/client_management/client_management_module.dart';
import 'features/professional/professional_module.dart';
import 'features/professional_availability/professional_availability_module.dart';
import 'features/professional_search/professional_search_module.dart';
import 'features/services/services_module.dart';
import 'features/user_profile/user_profile_module.dart';
import 'features/home/presentation/pages/client_dashboard_screen.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/pages/auth_wrapper_page.dart';
// User Profile dependencies needed globally
import 'features/user_profile/data/datasources/user_profile_remote_datasource.dart';
import 'features/user_profile/data/repositories/user_profile_repository_impl.dart';
import 'features/user_profile/data/services/firebase_storage_service.dart';
import 'features/user_profile/data/services/image_picker_service.dart';
import 'features/user_profile/data/services/image_compressor_service.dart';
import 'features/user_profile/domain/repositories/user_profile_repository.dart';
import 'features/user_profile/domain/usecases/create_user_profile.dart';
import 'features/user_profile/domain/usecases/get_user_profile_by_user_id.dart';
import 'features/user_profile/domain/usecases/update_user_profile.dart';
import 'features/user_profile/domain/usecases/upload_profile_picture_usecase.dart';
import 'features/user_profile/domain/usecases/pick_and_compress_image_usecase.dart';
import 'features/user_profile/presentation/controllers/user_profile_controller.dart';
import 'features/user_profile/presentation/controllers/user_type_selection_controller.dart';
// Services dependencies for global scope
import 'features/services/data/datasources/service_remote_datasource.dart';
import 'features/services/data/repositories/service_repository_impl.dart';
import 'features/services/domain/repositories/service_repository.dart';
// Appointment dependencies for global scope
import 'features/appointment/data/datasources/appointment_remote_datasource.dart';
import 'features/appointment/data/repositories/appointment_repository_impl.dart';
import 'features/appointment/domain/repositories/appointment_repository.dart';

class AppModule extends Module {
  @override
  void binds(Injector i) {
    print('🔍 DEBUG: AppModule.binds() iniciado');
    
    // External dependencies
    i.addLazySingleton<Connectivity>(() => Connectivity());
    i.addLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    i.addLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
    i.addLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
    i.addLazySingleton<InternetConnectionChecker>(() => InternetConnectionChecker.instance);
    
    // Core bindings
    i.addLazySingleton<NetworkInfo>(() => NetworkInfoImpl(i()));
    print('🔍 DEBUG: AppModule.binds() - Registrando ILocalCacheService...');
    i.addLazySingleton<ILocalCacheService>(() => LocalCacheServiceImpl());
    print('🔍 DEBUG: AppModule.binds() - ILocalCacheService registrado');
    
    // Auth bindings (global scope for AuthWrapperPage)
    i.addLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: i(),
        localCacheService: i(),
      ),
    );
    i.addLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: i(),
        networkInfo: i(),
      ),
    );
    
    // Auth Use Cases
    i.addLazySingleton(() => SignInUseCase(i()));
    i.addLazySingleton(() => SignUpUseCase(i()));
    i.addLazySingleton(() => SignOutUseCase(i()));
    i.addLazySingleton(() => GetCurrentUserUseCase(i()));
    
    // Auth Controller (global scope)
    i.addLazySingleton(() {
      // FORÇAR instanciação do ILocalCacheService ANTES do AuthController
      print('🔍 DEBUG: AppModule.binds() - Forçando instanciação do ILocalCacheService');
      final cacheService = i<ILocalCacheService>();
      print('🔍 DEBUG: AppModule.binds() - ILocalCacheService instanciado: ${cacheService.runtimeType}');
      
      final controller = AuthController(
        signInUseCase: i(),
        signUpUseCase: i(),
        signOutUseCase: i(),
        getCurrentUserUseCase: i(),
      );
      
      // FORÇAR inicialização do AuthController imediatamente
      print('🔍 DEBUG: AppModule.binds() - Forçando inicialização do AuthController');
      controller.onInit();
      
      return controller;
    });

    // === USER PROFILE DEPENDENCIES (Global scope for AuthWrapperPage) ===
    
    // User Profile Services
    i.addLazySingleton<IStorageService>(
      () => FirebaseStorageService(firebaseStorage: i<FirebaseStorage>()),
    );
    
    i.addLazySingleton<ImagePickerService>(
      () => ImagePickerService(),
    );
    
    i.addLazySingleton<ImageCompressorService>(
      () => ImageCompressorService(),
    );

    // User Profile Data Sources
    i.addLazySingleton<UserProfileRemoteDataSource>(
      () => UserProfileRemoteDataSourceImpl(
        firestore: i<FirebaseFirestore>(),
      ),
    );

    // User Profile Repository
    i.addLazySingleton<UserProfileRepository>(
      () => UserProfileRepositoryImpl(
        remoteDataSource: i<UserProfileRemoteDataSource>(),
        networkInfo: i<NetworkInfo>(),
        cacheService: i<ILocalCacheService>(),
      ),
    );

    // === SERVICES DEPENDENCIES (Global scope for ProfessionalAvailabilityModule) ===
    
    // Service Data Sources
    i.addLazySingleton<ServiceRemoteDataSource>(
      () => ServiceRemoteDataSourceImpl(
        firestore: i<FirebaseFirestore>(),
      ),
    );

    // Service Repository
    i.addLazySingleton<ServiceRepository>(
      () => ServiceRepositoryImpl(
        remoteDataSource: i<ServiceRemoteDataSource>(),
        networkInfo: i<NetworkInfo>(),
      ),
    );

    // === APPOINTMENT DEPENDENCIES (Global scope for ProfessionalAvailabilityModule) ===
    
    // Appointment Data Sources
    i.addLazySingleton<AppointmentRemoteDataSource>(
      () => AppointmentRemoteDataSourceImpl(
        firestore: i<FirebaseFirestore>(),
      ),
    );

    // Appointment Repository
    i.addLazySingleton<AppointmentRepository>(
      () => AppointmentRepositoryImpl(
        remoteDataSource: i<AppointmentRemoteDataSource>(),
        networkInfo: i<NetworkInfo>(),
      ),
    );

    // User Profile Use Cases
    i.addLazySingleton<GetUserProfileByUserId>(
      () => GetUserProfileByUserId(i<UserProfileRepository>()),
    );

    i.addLazySingleton<CreateUserProfile>(
      () => CreateUserProfile(i<UserProfileRepository>()),
    );

    i.addLazySingleton<UpdateUserProfile>(
      () => UpdateUserProfile(i<UserProfileRepository>()),
    );

    i.addLazySingleton<PickAndCompressImageUseCase>(
      () => PickAndCompressImageUseCase(
        imagePickerService: i<ImagePickerService>(),
        imageCompressorService: i<ImageCompressorService>(),
      ),
    );

    i.addLazySingleton<UploadProfilePictureUseCase>(
      () => UploadProfilePictureUseCase(
        pickAndCompressImageUseCase: i<PickAndCompressImageUseCase>(),
        storageService: i<IStorageService>(),
        userProfileRepository: i<UserProfileRepository>(),
      ),
    );

    // User Profile Controllers (global scope)
    i.addLazySingleton<UserProfileController>(
      () => UserProfileController(
        getUserProfileByUserId: i<GetUserProfileByUserId>(),
        createUserProfile: i<CreateUserProfile>(),
        updateUserProfile: i<UpdateUserProfile>(),
        uploadProfilePictureUseCase: i<UploadProfilePictureUseCase>(),
      ),
    );

    i.addLazySingleton<UserTypeSelectionController>(
      () => UserTypeSelectionController(),
    );
  }

  @override
  void routes(RouteManager r) {
    // Rotas de autenticação
    r.module('/auth', module: AuthModule());
    
    // Rotas de agendamentos
    r.module('/appointments', module: AppointmentModule());
    
    // Rotas do profissional
    r.module('/professional', module: ProfessionalModule());
    
    // Rotas de gerenciamento de clientes
    r.module('/client-management', module: ClientManagementModule());
    
    // Rotas de serviços
    r.module('/services', module: ServicesModule());
    
    // Rotas de perfil de usuário
    r.module('/user-profile', module: UserProfileModule());
    
    // Rotas de busca de profissionais
    r.module('/professional-search', module: ProfessionalSearchModule());
    
    // Rotas de disponibilidade de profissionais
    r.module('/professional-availability', module: ProfessionalAvailabilityModule());
    
    // Dashboard do cliente
    r.child('/client-dashboard', child: (context) => const ClientDashboardScreen());
    
    // Rota inicial - wrapper que verifica autenticação
    r.child('/', child: (context) => const AuthWrapperPage());
  }
}

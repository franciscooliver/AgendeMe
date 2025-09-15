# 🏗️ Convenções de Arquitetura - Agende.Me

## 📁 Estrutura de Feature Modules

Cada feature module deve seguir rigorosamente a estrutura Clean Architecture com as seguintes camadas:

```
lib/features/<feature_name>/
├── domain/
│   ├── entities/
│   │   └── <feature_name>_entity.dart
│   ├── repositories/
│   │   └── <feature_name>_repository.dart
│   └── usecases/
│       ├── get_<feature_name>.dart
│       ├── create_<feature_name>.dart
│       ├── update_<feature_name>.dart
│       └── delete_<feature_name>.dart
├── data/
│   ├── datasources/
│   │   ├── <feature_name>_local_datasource.dart
│   │   └── <feature_name>_remote_datasource.dart
│   ├── models/
│   │   └── <feature_name>_model.dart
│   └── repositories/
│       └── <feature_name>_repository_impl.dart
└── presentation/
    ├── controllers/
    │   └── <feature_name>_controller.dart
    ├── pages/
    │   └── <feature_name>_page.dart
    ├── widgets/
    │   ├── <feature_name>_widget.dart
    │   └── components/
    │       └── <specific_component>_widget.dart
    └── <feature_name>_module.dart
```

## 🎯 Responsabilidades das Camadas

### Domain Layer (`lib/features/<feature_name>/domain/`)
- **Entities**: Objetos de negócio puros, sem dependências externas
- **Repositories**: Interfaces/contratos para acesso a dados
- **Use Cases**: Lógica de negócio específica da feature

### Data Layer (`lib/features/<feature_name>/data/`)
- **DataSources**: Implementações concretas para acesso a dados (API, Local Storage)
- **Models**: Representações de dados com serialização/deserialização
- **Repositories**: Implementações concretas das interfaces do domain

### Presentation Layer (`lib/features/<feature_name>/presentation/`)
- **Controllers**: Gerenciamento de estado usando GetX
- **Pages**: Telas principais da feature
- **Widgets**: Componentes visuais reutilizáveis
- **Module**: Configuração de DI e routing com Flutter Modular

## 📝 Convenções de Nomenclatura

### Arquivos
Todos os arquivos devem usar **snake_case**:

```
✅ Correto:
- user_profile_entity.dart
- get_user_profile.dart
- user_profile_controller.dart
- user_profile_page.dart

❌ Incorreto:
- UserProfileEntity.dart
- getUserProfile.dart
- userProfileController.dart
```

### Classes
As classes devem seguir **PascalCase** com sufixos específicos:

#### Domain Layer
```dart
// Entities
class UserProfileEntity extends BaseEntity { }

// Repository Interfaces
abstract class UserProfileRepository extends BaseRepository { }

// Use Cases
class GetUserProfile extends UseCase<UserProfileEntity, String> { }
class CreateUserProfile extends UseCase<void, UserProfileEntity> { }
```

#### Data Layer
```dart
// Models
class UserProfileModel extends UserProfileEntity { }

// DataSources
abstract class UserProfileRemoteDataSource { }
class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource { }

abstract class UserProfileLocalDataSource { }
class UserProfileLocalDataSourceImpl implements UserProfileLocalDataSource { }

// Repository Implementations
class UserProfileRepositoryImpl implements UserProfileRepository { }
```

#### Presentation Layer
```dart
// Controllers
class UserProfileController extends GetxController { }

// Pages
class UserProfilePage extends StatelessWidget { }

// Widgets
class UserProfileWidget extends StatelessWidget { }
class UserProfileCardWidget extends StatelessWidget { }

// Modules
class UserProfileModule extends Module { }
```

### Variáveis e Métodos
Use **camelCase** para variáveis e métodos:

```dart
✅ Correto:
String userName;
bool isLoading;
void getUserProfile() { }
Future<void> updateUserData() { }

❌ Incorreto:
String user_name;
bool is_loading;
void get_user_profile() { }
```

## 🔗 Padrões de Dependências

### Use Cases
```dart
class GetUserProfile extends UseCase<UserProfileEntity, String> {
  final UserProfileRepository repository;
  
  GetUserProfile(this.repository);
  
  @override
  Future<Either<Failure, UserProfileEntity>> call(String userId) async {
    return await repository.getUserProfile(userId);
  }
}
```

### Repository Implementation
```dart
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;
  final UserProfileLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  UserProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.getUserProfile(userId);
        await localDataSource.cacheUserProfile(userModel);
        return Right(userModel);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final userModel = await localDataSource.getUserProfile(userId);
        return Right(userModel);
      } catch (e) {
        return Left(CacheFailure(message: 'Dados não encontrados offline'));
      }
    }
  }
}
```

### Controller
```dart
class UserProfileController extends GetxController {
  final GetUserProfile getUserProfile;
  final UpdateUserProfile updateUserProfile;
  
  UserProfileController({
    required this.getUserProfile,
    required this.updateUserProfile,
  });
  
  final _userProfile = Rxn<UserProfileEntity>();
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  
  UserProfileEntity? get userProfile => _userProfile.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  
  Future<void> loadUserProfile(String userId) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    
    final result = await getUserProfile(userId);
    
    result.fold(
      (failure) => _errorMessage.value = failure.message,
      (user) => _userProfile.value = user,
    );
    
    _isLoading.value = false;
  }
}
```

### Module
```dart
class UserProfileModule extends Module {
  @override
  void binds(Injector i) {
    // DataSources
    i.addLazySingleton<UserProfileRemoteDataSource>(
      () => UserProfileRemoteDataSourceImpl(i()),
    );
    i.addLazySingleton<UserProfileLocalDataSource>(
      () => UserProfileLocalDataSourceImpl(),
    );
    
    // Repository
    i.addLazySingleton<UserProfileRepository>(
      () => UserProfileRepositoryImpl(
        remoteDataSource: i(),
        localDataSource: i(),
        networkInfo: i(),
      ),
    );
    
    // Use Cases
    i.addLazySingleton(() => GetUserProfile(i()));
    i.addLazySingleton(() => UpdateUserProfile(i()));
    
    // Controller
    i.addLazySingleton(() => UserProfileController(
      getUserProfile: i(),
      updateUserProfile: i(),
    ));
  }
  
  @override
  void routes(RouteManager r) {
    r.child(
      '/profile',
      child: (context) => const UserProfilePage(),
    );
    r.child(
      '/profile/edit',
      child: (context) => const UserProfileEditPage(),
    );
  }
}
```

## 📊 Estrutura de Models

### Model com FromJson/ToJson
```dart
class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    super.photoUrl,
    super.bio,
  });
  
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photo_url'] as String?,
      bio: json['bio'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photo_url': photoUrl,
      'bio': bio,
    };
  }
  
  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? bio,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
    );
  }
}
```

## 🧪 Estrutura de Testes

```
test/features/<feature_name>/
├── domain/
│   ├── entities/
│   │   └── <feature_name>_entity_test.dart
│   └── usecases/
│       ├── get_<feature_name>_test.dart
│       └── create_<feature_name>_test.dart
├── data/
│   ├── datasources/
│   │   ├── <feature_name>_local_datasource_test.dart
│   │   └── <feature_name>_remote_datasource_test.dart
│   ├── models/
│   │   └── <feature_name>_model_test.dart
│   └── repositories/
│       └── <feature_name>_repository_impl_test.dart
└── presentation/
    └── controllers/
        └── <feature_name>_controller_test.dart
```

## 🎨 Padrões de UI

### Page Structure
```dart
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
      ),
      body: GetBuilder<UserProfileController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Text(controller.errorMessage),
            );
          }
          
          return const UserProfileWidget();
        },
      ),
    );
  }
}
```

### Widget Structure
```dart
class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserProfileController>();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          UserProfileHeaderWidget(user: controller.userProfile!),
          const SizedBox(height: 16),
          UserProfileDetailsWidget(user: controller.userProfile!),
        ],
      ),
    );
  }
}
```

## 🔒 Regras de Importação

### Domain Layer
- ❌ **NÃO** pode importar nada de `data` ou `presentation`
- ✅ **PODE** importar apenas de `core`

### Data Layer
- ✅ **PODE** importar de `domain` e `core`
- ❌ **NÃO** pode importar de `presentation`

### Presentation Layer
- ✅ **PODE** importar de `domain` e `core`
- ⚠️ **PODE** importar de `data` apenas para DI no Module
- ✅ **PODE** importar packages de UI (Flutter, GetX)

## 📱 Exemplos de Features

### Authentication Feature
```
lib/features/authentication/
├── domain/
│   ├── entities/
│   │   └── user_entity.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── login_user.dart
│       ├── logout_user.dart
│       └── register_user.dart
├── data/
│   ├── datasources/
│   │   └── auth_remote_datasource.dart
│   ├── models/
│   │   └── user_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
└── presentation/
    ├── controllers/
    │   └── auth_controller.dart
    ├── pages/
    │   ├── login_page.dart
    │   └── register_page.dart
    ├── widgets/
    │   ├── login_form_widget.dart
    │   └── register_form_widget.dart
    └── auth_module.dart
```

### Appointment Feature
```
lib/features/appointment/
├── domain/
│   ├── entities/
│   │   └── appointment_entity.dart
│   ├── repositories/
│   │   └── appointment_repository.dart
│   └── usecases/
│       ├── get_appointments.dart
│       ├── create_appointment.dart
│       ├── update_appointment.dart
│       └── cancel_appointment.dart
├── data/
│   ├── datasources/
│   │   ├── appointment_local_datasource.dart
│   │   └── appointment_remote_datasource.dart
│   ├── models/
│   │   └── appointment_model.dart
│   └── repositories/
│       └── appointment_repository_impl.dart
└── presentation/
    ├── controllers/
    │   └── appointment_controller.dart
    ├── pages/
    │   ├── appointment_list_page.dart
    │   └── appointment_form_page.dart
    ├── widgets/
    │   ├── appointment_card_widget.dart
    │   └── appointment_calendar_widget.dart
    └── appointment_module.dart
```

---

Este documento serve como guia definitivo para implementação de features no projeto Agende.Me, garantindo consistência, manutenibilidade e aderência aos princípios SOLID e Clean Architecture.

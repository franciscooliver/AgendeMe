import 'package:get/get.dart';

import '../../domain/entities/service_entity.dart';
import '../../domain/usecases/add_service.dart';
import '../../domain/usecases/delete_service.dart';
import '../../domain/usecases/edit_service.dart';
import '../../domain/usecases/get_service_by_id.dart';
import '../../domain/usecases/get_services.dart';

/// Controller para gerenciar o estado dos serviços
/// 
/// Responsável por:
/// - Gerenciar estado reativo dos serviços
/// - Coordenar use cases de CRUD dos serviços
/// - Validar dados do formulário
/// - Feedback visual para o usuário
class ServiceController extends GetxController {
  final GetServices getServices;
  final GetServiceById getServiceById;
  final AddService addService;
  final EditService editService;
  final DeleteService deleteService;

  ServiceController({
    required this.getServices,
    required this.getServiceById,
    required this.addService,
    required this.editService,
    required this.deleteService,
  });

  // Estado reativo
  final RxList<ServiceEntity> _services = <ServiceEntity>[].obs;
  final Rx<ServiceEntity?> _currentService = Rx<ServiceEntity?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isSubmitting = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _successMessage = ''.obs;

  // Getters
  List<ServiceEntity> get services => _services;
  ServiceEntity? get currentService => _currentService.value;
  bool get isLoading => _isLoading.value;
  bool get isSubmitting => _isSubmitting.value;
  String get errorMessage => _errorMessage.value;
  String get successMessage => _successMessage.value;

  /// Carrega todos os serviços de um profissional
  Future<void> loadServices(String professionalId, {bool includeInactive = false}) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await getServices(
        GetServicesParams(
          professionalId: professionalId,
          includeInactive: includeInactive,
        ),
      );

      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          _services.clear();
        },
        (servicesList) {
          _services.assignAll(servicesList);
        },
      );
    } catch (e) {
      _errorMessage.value = 'Erro inesperado ao carregar serviços: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Carrega um serviço específico pelo ID
  Future<void> loadServiceById(String serviceId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await getServiceById(
        GetServiceByIdParams(serviceId: serviceId),
      );

      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          _currentService.value = null;
        },
        (service) {
          _currentService.value = service;
        },
      );
    } catch (e) {
      _errorMessage.value = 'Erro inesperado ao carregar serviço: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Adiciona um novo serviço
  Future<bool> createService({
    required String professionalId,
    required String name,
    required String description,
    required String category,
    required int duration,
    required double price,
    String? notes,
    String? imageUrl,
  }) async {
    try {
      _isSubmitting.value = true;
      _errorMessage.value = '';
      _successMessage.value = '';

      final service = ServiceEntity(
        id: '', // Será gerado pelo Firestore
        professionalId: professionalId,
        name: name,
        description: description,
        category: category,
        duration: duration,
        price: price,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notes: notes,
        imageUrl: imageUrl,
      );

      final result = await addService(AddServiceParams(service: service));

      return result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          return false;
        },
        (createdService) {
          _services.add(createdService);
          _successMessage.value = 'Serviço criado com sucesso!';
          return true;
        },
      );
    } catch (e) {
      _errorMessage.value = 'Erro inesperado ao criar serviço: $e';
      return false;
    } finally {
      _isSubmitting.value = false;
    }
  }

  /// Atualiza um serviço existente
  Future<bool> updateService({
    required String serviceId,
    required String professionalId,
    required String name,
    required String description,
    required String category,
    required int duration,
    required double price,
    required bool isActive,
    String? notes,
    String? imageUrl,
  }) async {
    try {
      _isSubmitting.value = true;
      _errorMessage.value = '';
      _successMessage.value = '';

      // Buscar o serviço atual para manter dados de criação
      final currentService = _services.firstWhereOrNull((s) => s.id == serviceId);
      if (currentService == null) {
        _errorMessage.value = 'Serviço não encontrado na lista local';
        return false;
      }

      final service = currentService.copyWith(
        professionalId: professionalId,
        name: name,
        description: description,
        category: category,
        duration: duration,
        price: price,
        isActive: isActive,
        updatedAt: DateTime.now(),
        notes: notes,
        imageUrl: imageUrl,
      );

      final result = await editService(EditServiceParams(service: service));

      return result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          return false;
        },
        (updatedService) {
          final index = _services.indexWhere((s) => s.id == serviceId);
          if (index != -1) {
            _services[index] = updatedService;
          }
          _currentService.value = updatedService;
          _successMessage.value = 'Serviço atualizado com sucesso!';
          return true;
        },
      );
    } catch (e) {
      _errorMessage.value = 'Erro inesperado ao atualizar serviço: $e';
      return false;
    } finally {
      _isSubmitting.value = false;
    }
  }

  /// Remove um serviço (soft delete)
  Future<bool> removeService(String serviceId) async {
    try {
      _isSubmitting.value = true;
      _errorMessage.value = '';
      _successMessage.value = '';

      final result = await deleteService(DeleteServiceParams(serviceId: serviceId));

      return result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          return false;
        },
        (_) {
          _services.removeWhere((s) => s.id == serviceId);
          _successMessage.value = 'Serviço removido com sucesso!';
          return true;
        },
      );
    } catch (e) {
      _errorMessage.value = 'Erro inesperado ao remover serviço: $e';
      return false;
    } finally {
      _isSubmitting.value = false;
    }
  }

  /// Filtra serviços por categoria
  List<ServiceEntity> getServicesByCategory(String category) {
    return _services.where((service) => service.category == category).toList();
  }

  /// Filtra serviços ativos
  List<ServiceEntity> get activeServices {
    return _services.where((service) => service.isActive).toList();
  }

  /// Filtra serviços inativos
  List<ServiceEntity> get inactiveServices {
    return _services.where((service) => !service.isActive).toList();
  }

  /// Busca serviços por nome
  List<ServiceEntity> searchServicesByName(String searchTerm) {
    if (searchTerm.isEmpty) return _services;
    
    final lowerSearchTerm = searchTerm.toLowerCase();
    return _services.where((service) {
      return service.name.toLowerCase().contains(lowerSearchTerm) ||
             service.description.toLowerCase().contains(lowerSearchTerm);
    }).toList();
  }

  /// Limpa mensagens de erro e sucesso
  void clearMessages() {
    _errorMessage.value = '';
    _successMessage.value = '';
  }

  /// Seleciona um serviço como atual
  void selectService(ServiceEntity service) {
    _currentService.value = service;
  }

  /// Limpa o serviço selecionado
  void clearSelectedService() {
    _currentService.value = null;
  }

  /// Ordena serviços por nome
  void sortServicesByName({bool ascending = true}) {
    _services.sort((a, b) {
      return ascending 
          ? a.name.compareTo(b.name)
          : b.name.compareTo(a.name);
    });
  }

  /// Ordena serviços por preço
  void sortServicesByPrice({bool ascending = true}) {
    _services.sort((a, b) {
      return ascending 
          ? a.price.compareTo(b.price)
          : b.price.compareTo(a.price);
    });
  }

  /// Ordena serviços por duração
  void sortServicesByDuration({bool ascending = true}) {
    _services.sort((a, b) {
      return ascending 
          ? a.duration.compareTo(b.duration)
          : b.duration.compareTo(a.duration);
    });
  }

  @override
  void onClose() {
    _services.clear();
    _currentService.value = null;
    super.onClose();
  }
}

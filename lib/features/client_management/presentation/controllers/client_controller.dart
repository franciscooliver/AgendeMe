import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';
import '../../domain/usecases/get_clients.dart';
import '../../domain/usecases/get_client_by_id.dart';
import '../../domain/usecases/search_clients.dart';
import '../../domain/usecases/add_client.dart';
import '../../domain/usecases/update_client_statistics.dart';

/// Controller para gerenciar o estado do módulo de clientes
/// 
/// Responsável por:
/// - Gerenciar estado reativo dos clientes
/// - Coordenar use cases de CRUD dos clientes
/// - Filtrar e organizar dados para a UI
/// - Feedback visual para o usuário
class ClientController extends GetxController {
  final GetClients getClients;
  final GetClientById getClientById;
  final SearchClients searchClients;
  final AddClient addClient;
  final UpdateClientStatistics updateClientStatistics;
  final ClientRepository clientRepository;

  ClientController({
    required this.getClients,
    required this.getClientById,
    required this.searchClients,
    required this.addClient,
    required this.updateClientStatistics,
    required this.clientRepository,
  });

  // Estado reativo
  final RxList<ClientEntity> _clients = <ClientEntity>[].obs;
  final RxList<ClientEntity> _filteredClients = <ClientEntity>[].obs;
  final Rx<ClientEntity?> _selectedClient = Rx<ClientEntity?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _successMessage = ''.obs;
  final RxString _searchQuery = ''.obs;
  final Rx<ClientStatus?> _statusFilter = Rx<ClientStatus?>(null);
  final Rx<ClientStatistics?> _statistics = Rx<ClientStatistics?>(null);

  // Paginação
  int _currentOffset = 0;
  final int _limit = 20;
  bool _hasMoreData = true;

  // Getters
  List<ClientEntity> get clients => _filteredClients;
  ClientEntity? get selectedClient => _selectedClient.value;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String get errorMessage => _errorMessage.value;
  String get successMessage => _successMessage.value;
  String get searchQuery => _searchQuery.value;
  ClientStatus? get statusFilter => _statusFilter.value;
  ClientStatistics? get statistics => _statistics.value;
  bool get hasMoreData => _hasMoreData;

  /// Carrega clientes do profissional atual
  Future<void> loadClients({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentOffset = 0;
        _hasMoreData = true;
        _clients.clear();
        _filteredClients.clear();
      }

      if (!_hasMoreData) return;

      if (_currentOffset == 0) {
        _isLoading.value = true;
      } else {
        _isLoadingMore.value = true;
      }

      _errorMessage.value = '';

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _errorMessage.value = 'Usuário não autenticado';
        return;
      }

      final result = await getClients(GetClientsParams(
        professionalId: currentUser.uid,
        includeInactive: _statusFilter.value == null,
        limit: _limit,
        offset: _currentOffset,
      ));

      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
        },
        (clientsList) {
          if (clientsList.length < _limit) {
            _hasMoreData = false;
          }

          if (_currentOffset == 0) {
            _clients.assignAll(clientsList);
          } else {
            _clients.addAll(clientsList);
          }

          _currentOffset += clientsList.length;
          _applyFilters();
        },
      );
    } catch (e) {
      _errorMessage.value = 'Erro inesperado ao carregar clientes: $e';
    } finally {
      _isLoading.value = false;
      _isLoadingMore.value = false;
    }
  }

  /// Carrega mais clientes (paginação)
  Future<void> loadMoreClients() async {
    if (!_hasMoreData || _isLoadingMore.value) return;
    await loadClients();
  }

  /// Busca clientes por termo de pesquisa
  Future<void> searchClientsByTerm(String searchTerm) async {
    try {
      _searchQuery.value = searchTerm.trim();
      
      if (_searchQuery.value.isEmpty) {
        _applyFilters();
        return;
      }

      _isLoading.value = true;
      _errorMessage.value = '';

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _errorMessage.value = 'Usuário não autenticado';
        return;
      }

      final result = await searchClients(SearchClientsParams(
        professionalId: currentUser.uid,
        searchTerm: _searchQuery.value,
        limit: 20,
      ));

      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
        },
        (searchResults) {
          _filteredClients.assignAll(searchResults);
        },
      );
    } catch (e) {
      _errorMessage.value = 'Erro ao buscar clientes: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Aplica filtros aos clientes carregados
  void _applyFilters() {
    List<ClientEntity> filtered = List.from(_clients);

    // Filtro por status
    if (_statusFilter.value != null) {
      filtered = filtered.where((client) => client.status == _statusFilter.value).toList();
    }

    // Filtro por pesquisa local (se não há busca remota ativa)
    if (_searchQuery.value.isNotEmpty && filtered == _clients) {
      final searchLower = _searchQuery.value.toLowerCase();
      filtered = filtered.where((client) {
        return client.name.toLowerCase().contains(searchLower) ||
               client.email.toLowerCase().contains(searchLower);
      }).toList();
    }

    _filteredClients.assignAll(filtered);
  }

  /// Define filtro por status
  void setStatusFilter(ClientStatus? status) {
    _statusFilter.value = status;
    _applyFilters();
  }

  /// Limpa filtros aplicados
  void clearFilters() {
    _statusFilter.value = null;
    _searchQuery.value = '';
    _applyFilters();
  }

  /// Seleciona um cliente específico
  void selectClient(ClientEntity client) {
    _selectedClient.value = client;
  }

  /// Limpa cliente selecionado
  void clearSelectedClient() {
    _selectedClient.value = null;
  }

  /// Carrega um cliente específico por ID
  Future<void> loadClientById(String clientId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await getClientById(GetClientByIdParams(clientId: clientId));

      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
        },
        (client) {
          _selectedClient.value = client;
        },
      );
    } catch (e) {
      _errorMessage.value = 'Erro ao carregar cliente: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Adiciona um novo cliente (registro automático)
  Future<bool> addNewClient(ClientEntity client) async {
    try {
      _errorMessage.value = '';
      _successMessage.value = '';

      final result = await addClient(AddClientParams(client: client));

      return result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          return false;
        },
        (newClient) {
          _clients.insert(0, newClient);
          _applyFilters();
          _successMessage.value = 'Cliente adicionado com sucesso!';
          return true;
        },
      );
    } catch (e) {
      _errorMessage.value = 'Erro ao adicionar cliente: $e';
      return false;
    }
  }

  /// Atualiza estatísticas de um cliente após agendamento
  Future<bool> updateClientAfterAppointment({
    required String clientId,
    required double servicePrice,
    required String serviceName,
  }) async {
    try {
      final result = await updateClientStatistics(UpdateClientStatisticsParams(
        clientId: clientId,
        servicePrice: servicePrice,
        serviceName: serviceName,
      ));

      return result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          return false;
        },
        (updatedClient) {
          // Atualizar na lista local
          final index = _clients.indexWhere((c) => c.id == clientId);
          if (index != -1) {
            _clients[index] = updatedClient;
            _applyFilters();
          }
          return true;
        },
      );
    } catch (e) {
      _errorMessage.value = 'Erro ao atualizar cliente: $e';
      return false;
    }
  }

  /// Carrega estatísticas dos clientes
  Future<void> loadStatistics() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final result = await clientRepository.getClientStatistics(currentUser.uid);

      result.fold(
        (failure) {
          // Erro silencioso para estatísticas
        },
        (stats) {
          _statistics.value = stats;
        },
      );
    } catch (e) {
      // Erro silencioso para estatísticas
    }
  }

  /// Filtra clientes por categoria específica
  List<ClientEntity> getClientsByCategory(ClientCategory category) {
    switch (category) {
      case ClientCategory.all:
        return _clients;
      case ClientCategory.active:
        return _clients.where((c) => c.status == ClientStatus.active).toList();
      case ClientCategory.vip:
        return _clients.where((c) => c.isVipClient).toList();
      case ClientCategory.new_clients:
        return _clients.where((c) => c.isNewClient).toList();
      case ClientCategory.inactive:
        return _clients.where((c) => c.isInactive).toList();
      case ClientCategory.frequent:
        return _clients.where((c) => c.isFrequentClient).toList();
    }
  }

  /// Ordena clientes por critério específico
  void sortClients(ClientSortCriteria criteria, {bool ascending = true}) {
    final sortedClients = List<ClientEntity>.from(_filteredClients);

    switch (criteria) {
      case ClientSortCriteria.name:
        sortedClients.sort((a, b) => ascending 
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case ClientSortCriteria.lastInteraction:
        sortedClients.sort((a, b) => ascending
            ? a.lastInteractionDate.compareTo(b.lastInteractionDate)
            : b.lastInteractionDate.compareTo(a.lastInteractionDate));
        break;
      case ClientSortCriteria.totalAppointments:
        sortedClients.sort((a, b) => ascending
            ? a.totalAppointments.compareTo(b.totalAppointments)
            : b.totalAppointments.compareTo(a.totalAppointments));
        break;
      case ClientSortCriteria.totalSpent:
        sortedClients.sort((a, b) => ascending
            ? a.totalSpent.compareTo(b.totalSpent)
            : b.totalSpent.compareTo(a.totalSpent));
        break;
    }

    _filteredClients.assignAll(sortedClients);
  }

  /// Limpa mensagens de erro e sucesso
  void clearMessages() {
    _errorMessage.value = '';
    _successMessage.value = '';
  }

  @override
  void onInit() {
    super.onInit();
    loadClients();
    loadStatistics();
  }

  @override
  void onClose() {
    _clients.clear();
    _filteredClients.clear();
    super.onClose();
  }
}

/// Enum para categorias de clientes
enum ClientCategory {
  all,
  active,
  vip,
  new_clients,
  inactive,
  frequent,
}

/// Enum para critérios de ordenação
enum ClientSortCriteria {
  name,
  lastInteraction,
  totalAppointments,
  totalSpent,
}

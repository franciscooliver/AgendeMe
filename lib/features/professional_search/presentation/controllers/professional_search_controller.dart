import 'package:flutter/material.dart';

import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../../domain/usecases/search_professionals_usecase.dart';

/// Controller para gerenciar o estado da busca de profissionais
/// 
/// Responsável por controlar o estado da UI, realizar buscas e gerenciar
/// os resultados encontrados
class ProfessionalSearchController extends ChangeNotifier {
  final SearchProfessionalsUseCase searchProfessionalsUseCase;

  ProfessionalSearchController(this.searchProfessionalsUseCase);

  // Estados da busca
  bool _isLoading = false;
  bool _hasSearched = false;
  String _searchTerm = '';
  String _searchType = 'all';
  String? _selectedCity;
  String? _selectedService;
  
  // Resultados
  List<UserProfileEntity> _searchResults = [];
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;
  String get searchTerm => _searchTerm;
  String get searchType => _searchType;
  String? get selectedCity => _selectedCity;
  String? get selectedService => _selectedService;
  List<UserProfileEntity> get searchResults => _searchResults;
  String? get errorMessage => _errorMessage;
  bool get hasResults => _searchResults.isNotEmpty;
  bool get hasError => _errorMessage != null;

  /// Atualiza o termo de busca
  void updateSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  /// Atualiza o tipo de busca
  void updateSearchType(String type) {
    _searchType = type;
    notifyListeners();
  }

  /// Atualiza a cidade selecionada
  void updateSelectedCity(String? city) {
    _selectedCity = city;
    notifyListeners();
  }

  /// Atualiza o serviço selecionado
  void updateSelectedService(String? service) {
    _selectedService = service;
    notifyListeners();
  }

  /// Limpa os resultados da busca
  void clearResults() {
    _searchResults.clear();
    _errorMessage = null;
    _hasSearched = false;
    notifyListeners();
  }

  /// Limpa todos os filtros e resultados
  void clearAll() {
    _searchTerm = '';
    _searchType = 'all';
    _selectedCity = null;
    _selectedService = null;
    _searchResults.clear();
    _errorMessage = null;
    _hasSearched = false;
    notifyListeners();
  }

  /// Realiza a busca de profissionais
  Future<void> searchProfessionals() async {
    if (_searchTerm.trim().isEmpty) {
      _errorMessage = 'Digite um termo para buscar';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final params = SearchProfessionalsParams(
        searchTerm: _searchTerm.trim(),
        searchType: _searchType,
        city: _selectedCity,
        service: _selectedService,
        limit: 20,
      );

      final result = await searchProfessionalsUseCase(params);

      result.fold(
        (failure) {
          _errorMessage = failure.message;
          _searchResults.clear();
        },
        (professionals) {
          _searchResults = professionals;
          _errorMessage = null;
        },
      );

      _hasSearched = true;
    } catch (e) {
      _errorMessage = 'Erro inesperado: $e';
      _searchResults.clear();
      _hasSearched = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Busca profissionais por nome
  Future<void> searchByName(String name) async {
    _searchType = 'name';
    _searchTerm = name;
    await searchProfessionals();
  }

  /// Busca profissionais por serviço
  Future<void> searchByService(String service) async {
    _searchType = 'service';
    _searchTerm = service;
    _selectedService = service;
    await searchProfessionals();
  }

  /// Busca profissionais por localização
  Future<void> searchByLocation(String location) async {
    _searchType = 'location';
    _searchTerm = location;
    _selectedCity = location;
    await searchProfessionals();
  }

  /// Filtra os resultados por cidade
  List<UserProfileEntity> getResultsByCity(String city) {
    return _searchResults.where((professional) {
      return professional.city?.toLowerCase() == city.toLowerCase();
    }).toList();
  }

  /// Filtra os resultados por serviço
  List<UserProfileEntity> getResultsByService(String service) {
    return _searchResults.where((professional) {
      return professional.services?.any((s) => 
        s.toLowerCase().contains(service.toLowerCase())
      ) ?? false;
    }).toList();
  }

  /// Obtém lista única de cidades dos resultados
  List<String> getAvailableCities() {
    final cities = _searchResults
        .map((p) => p.city)
        .where((city) => city != null && city.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    
    cities.sort();
    return cities;
  }

  /// Obtém lista única de serviços dos resultados
  List<String> getAvailableServices() {
    final services = <String>{};
    
    for (final professional in _searchResults) {
      if (professional.services != null) {
        services.addAll(professional.services!);
      }
    }
    
    final servicesList = services.toList();
    servicesList.sort();
    return servicesList;
  }

}

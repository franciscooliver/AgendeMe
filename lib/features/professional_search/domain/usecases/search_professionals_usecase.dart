import 'package:dartz/dartz.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/core.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';

/// Parâmetros para busca de profissionais
class SearchProfessionalsParams {
  /// Termo de busca (nome, serviço ou localização)
  final String searchTerm;
  
  /// Tipo de busca: 'name', 'service', 'location', 'all'
  final String searchType;
  
  /// Cidade específica para busca por localização
  final String? city;
  
  /// Serviço específico para busca por serviço
  final String? service;
  
  /// Limite de resultados
  final int limit;

  const SearchProfessionalsParams({
    required this.searchTerm,
    this.searchType = 'all',
    this.city,
    this.service,
    this.limit = 20,
  });

  /// Verifica se os parâmetros são válidos
  bool get isValid => searchTerm.isNotEmpty;
}

/// UseCase para buscar profissionais
/// 
/// Permite buscar profissionais por nome, serviço ou localização
/// Utiliza o UserProfileRepository para acessar os dados
class SearchProfessionalsUseCase extends UseCase<List<UserProfileEntity>, SearchProfessionalsParams> {
  UserProfileRepository get repository => Modular.get<UserProfileRepository>();

  @override
  Future<Either<Failure, List<UserProfileEntity>>> call(
    SearchProfessionalsParams params,
  ) async {
    if (!params.isValid) {
      return Left(ValidationFailure(message: 'Termo de busca não pode estar vazio'));
    }

    try {
      switch (params.searchType) {
        case 'name':
          return await _searchByName(params);
        case 'service':
          return await _searchByService(params);
        case 'location':
          return await _searchByLocation(params);
        case 'all':
        default:
          return await _searchAll(params);
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Erro ao buscar profissionais: $e'));
    }
  }

  /// Busca profissionais por nome
  Future<Either<Failure, List<UserProfileEntity>>> _searchByName(
    SearchProfessionalsParams params,
  ) async {
    // Busca todos os profissionais e filtra por nome localmente
    // Em uma implementação mais robusta, seria melhor usar Firestore text search
    final result = await repository.getUserProfilesByType(
      'professional',
      limit: 100, // Busca mais resultados para filtrar localmente
    );

    return result.fold(
      (failure) => Left(failure),
      (professionals) {
        final filtered = professionals.where((professional) {
          return professional.name.toLowerCase().contains(
            params.searchTerm.toLowerCase(),
          );
        }).toList();

        // Limita os resultados conforme solicitado
        final limitedResults = filtered.take(params.limit).toList();
        return Right(limitedResults);
      },
    );
  }

  /// Busca profissionais por serviço
  Future<Either<Failure, List<UserProfileEntity>>> _searchByService(
    SearchProfessionalsParams params,
  ) async {
    if (params.service != null && params.service!.isNotEmpty) {
      return await repository.getProfessionalsByService(
        params.service!,
        limit: params.limit,
      );
    }

    // Se não especificou serviço, busca todos e filtra localmente
    final result = await repository.getUserProfilesByType(
      'professional',
      limit: 100,
    );

    return result.fold(
      (failure) => Left(failure),
      (professionals) {
        final filtered = professionals.where((professional) {
          if (professional.services == null) return false;
          
          return professional.services!.any((service) {
            return service.toLowerCase().contains(
              params.searchTerm.toLowerCase(),
            );
          });
        }).toList();

        final limitedResults = filtered.take(params.limit).toList();
        return Right(limitedResults);
      },
    );
  }

  /// Busca profissionais por localização
  Future<Either<Failure, List<UserProfileEntity>>> _searchByLocation(
    SearchProfessionalsParams params,
  ) async {
    if (params.city != null && params.city!.isNotEmpty) {
      return await repository.getProfessionalsByCity(
        params.city!,
        limit: params.limit,
      );
    }

    // Se não especificou cidade, busca todos e filtra localmente
    final result = await repository.getUserProfilesByType(
      'professional',
      limit: 100,
    );

    return result.fold(
      (failure) => Left(failure),
      (professionals) {
        final filtered = professionals.where((professional) {
          final city = professional.city?.toLowerCase() ?? '';
          final state = professional.state?.toLowerCase() ?? '';
          final address = professional.address?.toLowerCase() ?? '';
          
          return city.contains(params.searchTerm.toLowerCase()) ||
                 state.contains(params.searchTerm.toLowerCase()) ||
                 address.contains(params.searchTerm.toLowerCase());
        }).toList();

        final limitedResults = filtered.take(params.limit).toList();
        return Right(limitedResults);
      },
    );
  }

  /// Busca em todos os campos
  Future<Either<Failure, List<UserProfileEntity>>> _searchAll(
    SearchProfessionalsParams params,
  ) async {
    final result = await repository.getUserProfilesByType(
      'professional',
      limit: 100,
    );

    return result.fold(
      (failure) => Left(failure),
      (professionals) {
        final filtered = professionals.where((professional) {
          final name = professional.name.toLowerCase();
          final city = professional.city?.toLowerCase() ?? '';
          final state = professional.state?.toLowerCase() ?? '';
          final address = professional.address?.toLowerCase() ?? '';
          final services = professional.services?.join(' ').toLowerCase() ?? '';
          
          final searchTerm = params.searchTerm.toLowerCase();
          
          return name.contains(searchTerm) ||
                 city.contains(searchTerm) ||
                 state.contains(searchTerm) ||
                 address.contains(searchTerm) ||
                 services.contains(searchTerm);
        }).toList();

        final limitedResults = filtered.take(params.limit).toList();
        return Right(limitedResults);
      },
    );
  }
}

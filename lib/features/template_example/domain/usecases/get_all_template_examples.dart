import 'package:dartz/dartz.dart';
import '../../../../core/core.dart';
import '../entities/template_example_entity.dart';
import '../repositories/template_example_repository.dart';

/// Parâmetros para buscar todos os Template Examples
class GetAllTemplateExamplesParams {
  final int page;
  final int limit;
  final bool? filterByStatus;
  final String? searchQuery;

  const GetAllTemplateExamplesParams({
    this.page = 1,
    this.limit = 20,
    this.filterByStatus,
    this.searchQuery,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetAllTemplateExamplesParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          filterByStatus == other.filterByStatus &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      filterByStatus.hashCode ^
      searchQuery.hashCode;
}

/// Caso de uso para buscar todos os Template Examples com filtros
class GetAllTemplateExamples
    extends UseCase<List<TemplateExampleEntity>, GetAllTemplateExamplesParams> {
  final TemplateExampleRepository repository;

  GetAllTemplateExamples(this.repository);

  @override
  Future<Either<Failure, List<TemplateExampleEntity>>> call(
    GetAllTemplateExamplesParams params,
  ) async {
    try {
      // Se há query de busca, usar busca por texto
      if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
        return await repository.search(
          params.searchQuery!,
          filters: _buildFilters(params),
          page: params.page,
          limit: params.limit,
        );
      }

      // Se há filtro por status, usar método específico
      if (params.filterByStatus != null) {
        return await repository.getByStatus(params.filterByStatus!);
      }

      // Busca geral
      return await repository.getAll(
        page: params.page,
        limit: params.limit,
      );
    } catch (e) {
      return Left(
        UnknownFailure(
          message: 'Erro inesperado ao buscar Template Examples',
          details: e.toString(),
        ),
      );
    }
  }

  Map<String, dynamic> _buildFilters(GetAllTemplateExamplesParams params) {
    final filters = <String, dynamic>{};

    if (params.filterByStatus != null) {
      filters['isActive'] = params.filterByStatus;
    }

    return filters;
  }
}

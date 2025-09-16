import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../controllers/professional_search_controller.dart';
import '../widgets/professional_card_widget.dart';
import '../widgets/search_filters_widget.dart';

/// Página de busca de profissionais
/// 
/// Interface para clientes buscarem profissionais por nome, serviço ou localização
class ProfessionalSearchPage extends StatefulWidget {
  const ProfessionalSearchPage({super.key});

  @override
  State<ProfessionalSearchPage> createState() => _ProfessionalSearchPageState();
}

class _ProfessionalSearchPageState extends State<ProfessionalSearchPage> {
  final ProfessionalSearchController _controller = Modular.get<ProfessionalSearchController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.text = _controller.searchTerm;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Profissionais'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _controller.clearAll,
            tooltip: 'Limpar busca',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca
          _buildSearchBar(),
          
          // Filtros de busca
          SearchFiltersWidget(
            controller: _controller,
            onFilterChanged: () => _performSearch(),
          ),
          
          // Resultados
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  /// Constrói a barra de busca
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Buscar por nome, serviço ou localização...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          _controller.updateSearchTerm('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                _controller.updateSearchTerm(value);
              },
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _controller.isLoading ? null : _performSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            child: _controller.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
          ),
        ],
      ),
    );
  }

  /// Constrói a área de resultados
  Widget _buildResults() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Buscando profissionais...'),
              ],
            ),
          );
        }

        if (_controller.hasError) {
          return _buildErrorState();
        }

        if (!_controller.hasSearched) {
          return _buildInitialState();
        }

        if (!_controller.hasResults) {
          return _buildEmptyState();
        }

        return _buildResultsList();
      },
    );
  }

  /// Estado inicial (antes de qualquer busca)
  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Encontre o profissional ideal',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Digite um termo de busca ou use os filtros',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Estado de erro
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Erro na busca',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _controller.errorMessage ?? 'Erro desconhecido',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _performSearch,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  /// Estado vazio (sem resultados)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum profissional encontrado',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os termos de busca ou filtros',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _controller.clearAll,
            child: const Text('Limpar busca'),
          ),
        ],
      ),
    );
  }

  /// Lista de resultados
  Widget _buildResultsList() {
    return Column(
      children: [
        // Contador de resultados
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Text(
            '${_controller.searchResults.length} profissional(ais) encontrado(s)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        
        // Lista de profissionais
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.searchResults.length,
            itemBuilder: (context, index) {
              final professional = _controller.searchResults[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProfessionalCardWidget(
                  professional: professional,
                  onTap: () => _navigateToProfessionalDetails(professional),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Realiza a busca
  void _performSearch() {
    _searchFocusNode.unfocus();
    _controller.searchProfessionals();
  }

  /// Navega para detalhes do profissional
  void _navigateToProfessionalDetails(UserProfileEntity professional) {
    // TODO: Implementar navegação para detalhes do profissional
    // Por enquanto, mostra um snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visualizar ${professional.name}'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}

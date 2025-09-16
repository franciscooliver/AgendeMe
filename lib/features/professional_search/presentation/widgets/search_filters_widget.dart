import 'package:flutter/material.dart';

import '../controllers/professional_search_controller.dart';

/// Widget para filtros de busca de profissionais
/// 
/// Permite filtrar por tipo de busca, cidade e serviço
class SearchFiltersWidget extends StatefulWidget {
  final ProfessionalSearchController controller;
  final VoidCallback? onFilterChanged;

  const SearchFiltersWidget({
    super.key,
    required this.controller,
    this.onFilterChanged,
  });

  @override
  State<SearchFiltersWidget> createState() => _SearchFiltersWidgetState();
}

class _SearchFiltersWidgetState extends State<SearchFiltersWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Botão para expandir/recolher filtros
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filtros',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          
          // Filtros expandidos
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tipo de busca
                  _buildSearchTypeFilter(),
                  const SizedBox(height: 16),
                  
                  // Filtro por cidade
                  _buildCityFilter(),
                  const SizedBox(height: 16),
                  
                  // Filtro por serviço
                  _buildServiceFilter(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Filtro de tipo de busca
  Widget _buildSearchTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de busca',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildFilterChip(
              label: 'Todos',
              value: 'all',
              isSelected: widget.controller.searchType == 'all',
              onSelected: (selected) {
                if (selected) {
                  widget.controller.updateSearchType('all');
                  widget.onFilterChanged?.call();
                }
              },
            ),
            _buildFilterChip(
              label: 'Nome',
              value: 'name',
              isSelected: widget.controller.searchType == 'name',
              onSelected: (selected) {
                if (selected) {
                  widget.controller.updateSearchType('name');
                  widget.onFilterChanged?.call();
                }
              },
            ),
            _buildFilterChip(
              label: 'Serviço',
              value: 'service',
              isSelected: widget.controller.searchType == 'service',
              onSelected: (selected) {
                if (selected) {
                  widget.controller.updateSearchType('service');
                  widget.onFilterChanged?.call();
                }
              },
            ),
            _buildFilterChip(
              label: 'Localização',
              value: 'location',
              isSelected: widget.controller.searchType == 'location',
              onSelected: (selected) {
                if (selected) {
                  widget.controller.updateSearchType('location');
                  widget.onFilterChanged?.call();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Filtro por cidade
  Widget _buildCityFilter() {
    final availableCities = widget.controller.getAvailableCities();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cidade',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        if (availableCities.isEmpty)
          Text(
            'Nenhuma cidade disponível',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          )
        else
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                label: 'Todas',
                value: null,
                isSelected: widget.controller.selectedCity == null,
                onSelected: (selected) {
                  if (selected) {
                    widget.controller.updateSelectedCity(null);
                    widget.onFilterChanged?.call();
                  }
                },
              ),
              ...availableCities.map((city) => _buildFilterChip(
                label: city,
                value: city,
                isSelected: widget.controller.selectedCity == city,
                onSelected: (selected) {
                  if (selected) {
                    widget.controller.updateSelectedCity(city);
                    widget.onFilterChanged?.call();
                  }
                },
              )),
            ],
          ),
      ],
    );
  }

  /// Filtro por serviço
  Widget _buildServiceFilter() {
    final availableServices = widget.controller.getAvailableServices();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Serviço',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        if (availableServices.isEmpty)
          Text(
            'Nenhum serviço disponível',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          )
        else
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                label: 'Todos',
                value: null,
                isSelected: widget.controller.selectedService == null,
                onSelected: (selected) {
                  if (selected) {
                    widget.controller.updateSelectedService(null);
                    widget.onFilterChanged?.call();
                  }
                },
              ),
              ...availableServices.map((service) => _buildFilterChip(
                label: service,
                value: service,
                isSelected: widget.controller.selectedService == service,
                onSelected: (selected) {
                  if (selected) {
                    widget.controller.updateSelectedService(service);
                    widget.onFilterChanged?.call();
                  }
                },
              )),
            ],
          ),
      ],
    );
  }

  /// Constrói um chip de filtro
  Widget _buildFilterChip({
    required String label,
    required String? value,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
        width: 1,
      ),
    );
  }
}

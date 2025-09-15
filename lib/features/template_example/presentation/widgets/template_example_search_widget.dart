import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/template_example_controller.dart';

/// Widget de busca e filtros para Template Examples
/// 
/// Demonstra como implementar widgets reutilizáveis seguindo as convenções
class TemplateExampleSearchWidget extends StatelessWidget {
  const TemplateExampleSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TemplateExampleController>(
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            children: [
              // Campo de busca
              TextField(
                onChanged: controller.updateSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Buscar por título ou descrição...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: controller.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => controller.updateSearchQuery(''),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Filtros
              Row(
                children: [
                  const Text(
                    'Filtros:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 12),
                  
                  // Filtro por status
                  Expanded(
                    child: DropdownButtonFormField<bool?>(
                      initialValue: controller.filterByStatus,
                      onChanged: controller.updateStatusFilter,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem<bool?>(
                          value: null,
                          child: Text('Todos'),
                        ),
                        DropdownMenuItem<bool?>(
                          value: true,
                          child: Text('Ativos'),
                        ),
                        DropdownMenuItem<bool?>(
                          value: false,
                          child: Text('Inativos'),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Botão limpar filtros
                  if (controller.searchQuery.isNotEmpty || 
                      controller.filterByStatus != null)
                    IconButton(
                      onPressed: controller.clearFilters,
                      icon: const Icon(Icons.filter_alt_off),
                      tooltip: 'Limpar filtros',
                    ),
                ],
              ),
              
              // Contador de resultados
              if (controller.searchQuery.isNotEmpty || 
                  controller.filterByStatus != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${controller.filteredTemplateExamples.length} resultado(s) encontrado(s)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

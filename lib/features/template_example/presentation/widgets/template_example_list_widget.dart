import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/core.dart';
import '../../domain/entities/template_example_entity.dart';
import '../controllers/template_example_controller.dart';
import 'template_example_card_widget.dart';

/// Widget que exibe a lista de Template Examples
/// 
/// Demonstra como implementar listas seguindo as convenções do projeto
class TemplateExampleListWidget extends StatelessWidget {
  const TemplateExampleListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TemplateExampleController>(
      builder: (controller) {
        return RefreshIndicator(
          onRefresh: controller.refreshTemplateExamples,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.filteredTemplateExamples.length,
            itemBuilder: (context, index) {
              final templateExample = controller.filteredTemplateExamples[index];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TemplateExampleCardWidget(
                  templateExample: templateExample,
                  onTap: () => _showDetailsBottomSheet(context, templateExample),
                  onEdit: () => _editTemplateExample(templateExample),
                  onDelete: () => _deleteTemplateExample(controller, templateExample),
                  onToggleStatus: () => _toggleStatus(controller, templateExample),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showDetailsBottomSheet(BuildContext context, TemplateExampleEntity templateExample) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Título
                Text(
                  templateExample.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Status
                Chip(
                  label: Text(
                    templateExample.isActive ? 'Ativo' : 'Inativo',
                    style: TextStyle(
                      color: templateExample.isActive ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: templateExample.isActive 
                      ? Colors.green.shade100 
                      : Colors.red.shade100,
                ),
                
                const SizedBox(height: 16),
                
                // Descrição
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Descrição',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          templateExample.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Informações adicionais
                        Text(
                          'Informações',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        _buildInfoRow(
                          context,
                          'ID',
                          templateExample.id,
                        ),
                        _buildInfoRow(
                          context,
                          'Criado em',
                          templateExample.createdAt.toBrazilianFormatWithTime,
                        ),
                        if (templateExample.updatedAt != null)
                          _buildInfoRow(
                            context,
                            'Atualizado em',
                            templateExample.updatedAt!.toBrazilianFormatWithTime,
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Botões de ação
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _editTemplateExample(templateExample);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('Fechar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _editTemplateExample(TemplateExampleEntity templateExample) {
    AppUtils.showInfoSnackbar(
      title: 'Em desenvolvimento',
      message: 'Funcionalidade de edição será implementada em breve',
    );
  }

  Future<void> _deleteTemplateExample(
    TemplateExampleController controller,
    TemplateExampleEntity templateExample,
  ) async {
    final confirmed = await controller.showConfirmationDialog(
      title: 'Confirmar exclusão',
      message: 'Tem certeza que deseja excluir "${templateExample.title}"?',
      confirmText: 'Excluir',
      cancelText: 'Cancelar',
    );

    if (confirmed) {
      AppUtils.showInfoSnackbar(
        title: 'Em desenvolvimento',
        message: 'Funcionalidade de exclusão será implementada em breve',
      );
    }
  }

  void _toggleStatus(
    TemplateExampleController controller,
    TemplateExampleEntity templateExample,
  ) {
    AppUtils.showInfoSnackbar(
      title: 'Em desenvolvimento',
      message: 'Funcionalidade de alternar status será implementada em breve',
    );
  }
}

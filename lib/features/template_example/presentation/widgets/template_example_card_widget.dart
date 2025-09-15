import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../domain/entities/template_example_entity.dart';

/// Widget de card para exibir um Template Example
/// 
/// Demonstra como implementar widgets de card seguindo as convenções
class TemplateExampleCardWidget extends StatelessWidget {
  final TemplateExampleEntity templateExample;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;

  const TemplateExampleCardWidget({
    super.key,
    required this.templateExample,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com título e status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      templateExample.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Indicator de status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: templateExample.isActive 
                          ? Colors.green.shade100 
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      templateExample.isActive ? 'Ativo' : 'Inativo',
                      style: TextStyle(
                        color: templateExample.isActive 
                            ? Colors.green.shade700 
                            : Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Descrição
              Text(
                templateExample.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Informações da data
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Criado em ${templateExample.createdAt.toBrazilianFormat}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  
                  if (templateExample.updatedAt != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.update,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Atualizado em ${templateExample.updatedAt!.toBrazilianFormat}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Botões de ação
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botão editar
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Editar',
                    iconSize: 20,
                  ),
                  
                  // Botão alternar status
                  IconButton(
                    onPressed: onToggleStatus,
                    icon: Icon(
                      templateExample.isActive 
                          ? Icons.toggle_on 
                          : Icons.toggle_off,
                    ),
                    tooltip: templateExample.isActive 
                        ? 'Desativar' 
                        : 'Ativar',
                    iconSize: 20,
                    color: templateExample.isActive 
                        ? Colors.green.shade600 
                        : Colors.grey.shade400,
                  ),
                  
                  // Botão deletar
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Excluir',
                    iconSize: 20,
                    color: Colors.red.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

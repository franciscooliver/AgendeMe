import 'package:flutter/material.dart';

import '../../../services/domain/entities/service_entity.dart';

/// Widget para seleção de serviços
class ServiceSelectorWidget extends StatelessWidget {
  final List<ServiceEntity> services;
  final ServiceEntity? selectedService;
  final Function(ServiceEntity?) onServiceSelected;

  const ServiceSelectorWidget({
    super.key,
    required this.services,
    required this.selectedService,
    required this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.orange[700],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Este profissional ainda não possui serviços cadastrados.',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecione um serviço:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                final isSelected = selectedService?.id == service.id;
                
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  child: _buildServiceCard(context, service, isSelected),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o card de um serviço
  Widget _buildServiceCard(BuildContext context, ServiceEntity service, bool isSelected) {
    return GestureDetector(
      onTap: () => onServiceSelected(service),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    service.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  service.formattedDuration,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  service.formattedPrice,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isSelected 
                        ? Theme.of(context).primaryColor
                        : Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (service.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  service.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

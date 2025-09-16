import 'package:flutter/material.dart';

import '../../../user_profile/domain/entities/user_profile_entity.dart';

/// Widget de card para exibir informações de um profissional
/// 
/// Mostra informações básicas como nome, foto, localização e serviços
class ProfessionalCardWidget extends StatelessWidget {
  final UserProfileEntity professional;
  final VoidCallback? onTap;

  const ProfessionalCardWidget({
    super.key,
    required this.professional,
    this.onTap,
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
              // Header com foto e informações básicas
              Row(
                children: [
                  // Foto do profissional
                  _buildProfileImage(context),
                  const SizedBox(width: 12),
                  
                  // Informações básicas
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          professional.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        
                        // Localização
                        if (professional.city != null || professional.state != null)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _buildLocationText(),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  
                  // Indicador de status
                  _buildStatusIndicator(),
                ],
              ),
              
              // Biografia (se disponível)
              if (professional.bio != null && professional.bio!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  professional.bio!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Serviços oferecidos
              if (professional.services != null && professional.services!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildServicesSection(context),
              ],
              
              // Informações de contato
              const SizedBox(height: 12),
              _buildContactInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói a imagem do perfil
  Widget _buildProfileImage(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: professional.profileImageUrl != null
            ? Image.network(
                professional.profileImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar(context);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildDefaultAvatar(context);
                },
              )
            : _buildDefaultAvatar(context),
      ),
    );
  }

  /// Avatar padrão quando não há imagem
  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: 30,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  /// Constrói o texto de localização
  String _buildLocationText() {
    final parts = <String>[];
    
    if (professional.city != null && professional.city!.isNotEmpty) {
      parts.add(professional.city!);
    }
    
    if (professional.state != null && professional.state!.isNotEmpty) {
      parts.add(professional.state!);
    }
    
    return parts.join(', ');
  }

  /// Constrói o indicador de status
  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: professional.isActive 
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: professional.isActive 
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Text(
        professional.isActive ? 'Ativo' : 'Inativo',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: professional.isActive ? Colors.green[700] : Colors.red[700],
        ),
      ),
    );
  }

  /// Seção de serviços oferecidos
  Widget _buildServicesSection(BuildContext context) {
    final services = professional.services!;
    final displayServices = services.take(3).toList();
    final hasMoreServices = services.length > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Serviços oferecidos:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            ...displayServices.map((service) => _buildServiceChip(context, service)),
            if (hasMoreServices)
              _buildMoreServicesChip(services.length - 3),
          ],
        ),
      ],
    );
  }

  /// Chip de serviço
  Widget _buildServiceChip(BuildContext context, String service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        service,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Chip para indicar mais serviços
  Widget _buildMoreServicesChip(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Text(
        '+$count mais',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Informações de contato
  Widget _buildContactInfo(BuildContext context) {
    return Row(
      children: [
        // Telefone (se disponível)
        if (professional.phone != null && professional.phone!.isNotEmpty) ...[
          Icon(
            Icons.phone,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            professional.phone!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 16),
        ],
        
        // Email
        Icon(
          Icons.email,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            professional.email,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // Botão de ação
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).primaryColor,
        ),
      ],
    );
  }
}

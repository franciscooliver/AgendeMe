import 'package:flutter/material.dart';

import '../../../user_profile/domain/entities/user_profile_entity.dart';

/// Widget para exibir informações básicas do profissional
class ProfessionalInfoWidget extends StatelessWidget {
  final UserProfileEntity professional;

  const ProfessionalInfoWidget({
    super.key,
    required this.professional,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar do profissional
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            backgroundImage: professional.profileImageUrl != null
                ? NetworkImage(professional.profileImageUrl!)
                : null,
            child: professional.profileImageUrl == null
                ? Icon(
                    Icons.person,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          
          // Informações do profissional
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  professional.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (professional.bio != null && professional.bio!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    professional.bio!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (professional.city != null && professional.state != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${professional.city}, ${professional.state}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

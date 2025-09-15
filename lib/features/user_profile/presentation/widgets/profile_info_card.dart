import 'package:flutter/material.dart';

import '../../domain/entities/user_type.dart';

/// Card com informações principais do perfil do usuário
class ProfileInfoCard extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final UserType userType;
  final String? bio;
  final bool isActive;

  const ProfileInfoCard({
    super.key,
    this.imageUrl,
    required this.name,
    required this.userType,
    this.bio,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildProfileImage(),
            const SizedBox(height: 16),
            _buildNameAndType(context),
            if (bio != null && bio!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildBio(context),
            ],
            const SizedBox(height: 12),
            _buildStatusChip(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey[600],
                )
              : null,
        ),
        if (!isActive)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.block,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNameAndType(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _getUserTypeColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getUserTypeColor()),
          ),
          child: Text(
            userType.displayName,
            style: TextStyle(
              color: _getUserTypeColor(),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBio(BuildContext context) {
    return Text(
      bio!,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.grey[700],
      ),
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStatusChip() {
    return Chip(
      label: Text(
        isActive ? 'Conta Ativa' : 'Conta Inativa',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      backgroundColor: isActive ? Colors.green : Colors.red,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Color _getUserTypeColor() {
    switch (userType) {
      case UserType.professional:
        return Colors.blue;
      case UserType.client:
        return Colors.purple;
    }
  }
}

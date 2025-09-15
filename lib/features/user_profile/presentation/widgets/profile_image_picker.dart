import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/user_profile_controller.dart';

/// Widget para seleção/upload da foto de perfil
class ProfileImagePicker extends StatelessWidget {
  final String? imageUrl;
  final Function(String?) onImageChanged;
  final double size;
  late final UserProfileController controller;

  ProfileImagePicker({
    super.key,
    this.imageUrl,
    required this.onImageChanged,
    this.size = 120,
  }) {
    controller = Modular.get<UserProfileController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      children: [
        Stack(
          children: [
            _buildImageContainer(context),
            if (controller.isUploadingProfilePicture)
              _buildUploadingOverlay(),
          ],
        ),
        const SizedBox(height: 12),
        _buildActionButtons(context),
        if (controller.profilePictureError.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildErrorMessage(context),
        ],
      ],
    ));
  }

  Widget _buildImageContainer(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: controller.hasProfilePicture
            ? _buildNetworkImage()
            : _buildPlaceholder(context),
      ),
    );
  }

  Widget _buildNetworkImage() {
    return CachedNetworkImage(
      imageUrl: controller.currentProfilePictureUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildLoadingIndicator(),
      errorWidget: (context, url, error) => _buildPlaceholder(context),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: controller.isUploadingProfilePicture 
              ? null 
              : () => _pickImage(context),
          icon: controller.isUploadingProfilePicture 
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Icon(Icons.camera_alt, size: 18),
          label: Text(controller.isUploadingProfilePicture 
              ? 'Enviando...' 
              : 'Alterar'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        if (controller.hasProfilePicture && !controller.isUploadingProfilePicture)
          OutlinedButton.icon(
            onPressed: () => _removeImage(context),
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Remover'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              foregroundColor: Colors.red,
            ),
          ),
      ],
    );
  }

  void _pickImage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Selecionar Foto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  context,
                  icon: Icons.camera_alt,
                  label: 'Câmera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromCamera();
                  },
                ),
                _buildImageSourceOption(
                  context,
                  icon: Icons.photo_library,
                  label: 'Galeria',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromGallery();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _pickFromCamera() async {
    final success = await controller.uploadProfilePictureFromCamera();
    if (success && controller.currentProfilePictureUrl != null) {
      onImageChanged(controller.currentProfilePictureUrl);
    }
  }

  void _pickFromGallery() async {
    final success = await controller.uploadProfilePictureFromGallery();
    if (success && controller.currentProfilePictureUrl != null) {
      onImageChanged(controller.currentProfilePictureUrl);
    }
  }

  void _removeImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Foto'),
        content: const Text('Tem certeza que deseja remover sua foto de perfil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.clearProfilePictureError();
              onImageChanged(null);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadingOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.5),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.profilePictureError,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
            ),
          ),
          InkWell(
            onTap: controller.clearProfilePictureError,
            child: Icon(Icons.close, color: Colors.red[700], size: 16),
          ),
        ],
      ),
    );
  }
}

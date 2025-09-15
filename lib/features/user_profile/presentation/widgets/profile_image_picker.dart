import 'package:flutter/material.dart';

/// Widget para seleção/upload da foto de perfil
class ProfileImagePicker extends StatelessWidget {
  final String? imageUrl;
  final Function(String?) onImageChanged;
  final double size;

  const ProfileImagePicker({
    super.key,
    this.imageUrl,
    required this.onImageChanged,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildImageContainer(context),
        const SizedBox(height: 12),
        _buildActionButtons(context),
      ],
    );
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
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? _buildNetworkImage()
            : _buildPlaceholder(context),
      ),
    );
  }

  Widget _buildNetworkImage() {
    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder(context);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingIndicator();
      },
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
          onPressed: () => _pickImage(context),
          icon: const Icon(Icons.camera_alt, size: 18),
          label: const Text('Alterar'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        if (imageUrl != null && imageUrl!.isNotEmpty)
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

  void _pickFromCamera() {
    // TODO: Implementar seleção da câmera
    // Usar image_picker package
    _showNotImplemented();
  }

  void _pickFromGallery() {
    // TODO: Implementar seleção da galeria
    // Usar image_picker package
    _showNotImplemented();
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
              onImageChanged(null);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _showNotImplemented() {
    // Placeholder para funcionalidade não implementada
    // TODO: Remover quando implementar image_picker
  }
}

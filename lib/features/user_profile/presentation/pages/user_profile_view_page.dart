import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../../domain/entities/user_profile_entity.dart';
import '../controllers/user_profile_controller.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_section.dart';

/// Página de visualização do perfil do usuário
class UserProfileViewPage extends StatefulWidget {
  final String? userId;

  const UserProfileViewPage({
    super.key,
    this.userId,
  });

  @override
  State<UserProfileViewPage> createState() => _UserProfileViewPageState();
}

class _UserProfileViewPageState extends State<UserProfileViewPage> {
  late final UserProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Modular.get<UserProfileController>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userId != null) {
        controller.loadUserProfile(widget.userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        elevation: 0,
        actions: [
          Obx(() => controller.hasProfile
              ? IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Modular.to.pushNamed(
                    '/user-profile/profile/edit',
                    arguments: {'userId': widget.userId},
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() => _buildBody()),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (!controller.hasProfile || controller.userProfile == null) {
      return _buildEmptyState();
    }

    return _buildProfileContent();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar perfil',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.userId != null) {
                  controller.loadUserProfile(widget.userId!);
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Perfil não encontrado',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Parece que você ainda não criou seu perfil.\nVamos começar?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Modular.to.pushNamed('/user-profile/edit'),
              icon: const Icon(Icons.person_add),
              label: const Text('Criar Perfil'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    final profile = controller.userProfile!;

    return RefreshIndicator(
      onRefresh: () async {
        if (widget.userId != null) {
          await controller.loadUserProfile(widget.userId!);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(profile),
            const SizedBox(height: 24),
            _buildBasicInfoSection(profile),
            const SizedBox(height: 16),
            _buildContactInfoSection(profile),
            const SizedBox(height: 16),
            _buildLocationSection(profile),
            if (profile.isProfessional) ...[
              const SizedBox(height: 16),
              _buildProfessionalSection(profile),
            ],
            if (profile.isClient) ...[
              const SizedBox(height: 16),
              _buildClientSection(profile),
            ],
            const SizedBox(height: 24),
            _buildAccountInfoSection(profile),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileEntity profile) {
    return ProfileInfoCard(
      imageUrl: profile.profileImageUrl,
      name: profile.name,
      userType: profile.userType,
      bio: profile.bio,
      isActive: profile.isActive,
    );
  }

  Widget _buildBasicInfoSection(UserProfileEntity profile) {
    return ProfileSection(
      title: 'Informações Básicas',
      icon: Icons.person,
      children: [
        _buildInfoTile(
          icon: Icons.email,
          title: 'Email',
          value: profile.email,
        ),
        if (profile.bio != null && profile.bio!.isNotEmpty)
          _buildInfoTile(
            icon: Icons.description,
            title: 'Biografia',
            value: profile.bio!,
            maxLines: 3,
          ),
      ],
    );
  }

  Widget _buildContactInfoSection(UserProfileEntity profile) {
    final hasContactInfo = profile.phone != null && profile.phone!.isNotEmpty;

    return ProfileSection(
      title: 'Contato',
      icon: Icons.contact_phone,
      children: [
        if (hasContactInfo)
          _buildInfoTile(
            icon: Icons.phone,
            title: 'Telefone',
            value: profile.phone!,
            onTap: () {
              // TODO: Implementar ação de ligar
            },
          )
        else
          _buildEmptyInfoTile('Nenhuma informação de contato cadastrada'),
      ],
    );
  }

  Widget _buildLocationSection(UserProfileEntity profile) {
    final hasLocation = profile.hasLocation;

    return ProfileSection(
      title: 'Localização',
      icon: Icons.location_on,
      children: [
        if (hasLocation) ...[
          if (profile.address != null && profile.address!.isNotEmpty)
            _buildInfoTile(
              icon: Icons.home,
              title: 'Endereço',
              value: profile.address!,
            ),
          if (profile.city != null && profile.city!.isNotEmpty)
            _buildInfoTile(
              icon: Icons.location_city,
              title: 'Cidade',
              value: profile.city!,
            ),
          if (profile.state != null && profile.state!.isNotEmpty)
            _buildInfoTile(
              icon: Icons.map,
              title: 'Estado',
              value: profile.state!,
            ),
        ] else
          _buildEmptyInfoTile('Nenhuma informação de localização cadastrada'),
      ],
    );
  }

  Widget _buildProfessionalSection(UserProfileEntity profile) {
    final hasServices = profile.services != null && profile.services!.isNotEmpty;

    return ProfileSection(
      title: 'Informações Profissionais',
      icon: Icons.work,
      children: [
        if (hasServices)
          _buildInfoTile(
            icon: Icons.build,
            title: 'Serviços',
            value: profile.services!.join(', '),
            maxLines: 3,
          )
        else
          _buildEmptyInfoTile('Nenhum serviço cadastrado'),
        
        // TODO: Adicionar horário de funcionamento e preços quando implementados
      ],
    );
  }

  Widget _buildClientSection(UserProfileEntity profile) {
    final hasFavorites = profile.favoriteProfessionals != null && 
                        profile.favoriteProfessionals!.isNotEmpty;

    return ProfileSection(
      title: 'Preferências',
      icon: Icons.favorite,
      children: [
        if (hasFavorites)
          _buildInfoTile(
            icon: Icons.favorite,
            title: 'Profissionais Favoritos',
            value: '${profile.favoriteProfessionals!.length} profissionais',
          )
        else
          _buildEmptyInfoTile('Nenhum profissional favorito'),
      ],
    );
  }

  Widget _buildAccountInfoSection(UserProfileEntity profile) {
    return ProfileSection(
      title: 'Informações da Conta',
      icon: Icons.info,
      children: [
        _buildInfoTile(
          icon: Icons.person_outline,
          title: 'Tipo de Usuário',
          value: profile.userTypeDisplayName,
        ),
        _buildInfoTile(
          icon: Icons.verified_user,
          title: 'Status da Conta',
          value: profile.isActive ? 'Ativa' : 'Inativa',
          valueColor: profile.isActive ? Colors.green : Colors.red,
        ),
        _buildInfoTile(
          icon: Icons.calendar_today,
          title: 'Membro desde',
          value: _formatDate(profile.createdAt),
        ),
        _buildInfoTile(
          icon: Icons.update,
          title: 'Última atualização',
          value: _formatDate(profile.updatedAt),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    int maxLines = 1,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        value,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: valueColor),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildEmptyInfoTile(String message) {
    return ListTile(
      leading: Icon(Icons.info_outline, color: Colors.grey[400]),
      title: Text(
        message,
        style: TextStyle(
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

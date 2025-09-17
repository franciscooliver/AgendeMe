import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../user_profile/presentation/controllers/user_profile_controller.dart';

/// Dashboard principal do profissional com navegação para diferentes módulos
class ProfessionalDashboardScreen extends StatefulWidget {
  const ProfessionalDashboardScreen({super.key});

  @override
  State<ProfessionalDashboardScreen> createState() => _ProfessionalDashboardScreenState();
}

class _ProfessionalDashboardScreenState extends State<ProfessionalDashboardScreen> {
  late final AuthController authController;
  late final UserProfileController userProfileController;

  @override
  void initState() {
    super.initState();
    authController = Modular.get<AuthController>();
    userProfileController = Modular.get<UserProfileController>();
    
    // Carregar perfil do usuário se ainda não estiver carregado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!userProfileController.hasProfile && authController.currentUser != null) {
        userProfileController.loadUserProfile(authController.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('AgendeMe - Profissional'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, authController),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de boas-vindas
              _buildWelcomeHeader(),
              
              const SizedBox(height: 32),
              
              // Cards de funcionalidades principais
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildFeatureCard(
                      icon: Icons.calendar_today,
                      title: 'Calendário',
                      subtitle: 'Visualizar agendamentos',
                      color: Colors.blue,
                      onTap: () => Modular.to.pushNamed('/professional/calendar'),
                    ),
                    _buildFeatureCard(
                      icon: Icons.people,
                      title: 'Meus Clientes',
                      subtitle: 'Gerenciar clientes',
                      color: Colors.green,
                      onTap: () => Modular.to.pushNamed('/client-management/clients'),
                    ),
                    _buildFeatureCard(
                      icon: Icons.work,
                      title: 'Meus Serviços',
                      subtitle: 'Gerenciar serviços',
                      color: Colors.orange,
                      onTap: () => Modular.to.pushNamed('/services'),
                    ),
                    _buildFeatureCard(
                      icon: Icons.settings,
                      title: 'Configurações',
                      subtitle: 'Perfil e horários',
                      color: Colors.purple,
                      onTap: () => Modular.to.pushNamed('/professional/config'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Obx(() {
      final userProfile = userProfileController.userProfile;
      final currentUser = authController.currentUser;
      
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.purple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  backgroundImage: userProfile?.profileImageUrl != null
                      ? NetworkImage(userProfile!.profileImageUrl!)
                      : null,
                  child: userProfile?.profileImageUrl == null
                      ? const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 24,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bem-vindo!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userProfile?.name ?? currentUser?.email ?? 'Profissional',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Gerencie seus agendamentos e clientes de forma eficiente!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () {
              print('🔍 DEBUG: Usuário cancelou logout');
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              print('🔍 DEBUG: Usuário confirmou logout, fechando dialog...');
              Navigator.of(context).pop();
              print('🔍 DEBUG: Chamando authController.signOut()...');
              authController.signOut();
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

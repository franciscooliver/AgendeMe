import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';

/// Tela de dashboard para usuários do tipo Cliente
/// 
/// Serve como home principal após login para clientes
class ClientDashboardScreen extends StatelessWidget {
  const ClientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Modular.get<AuthController>();
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('AgendeMe - Cliente'),
        backgroundColor: Colors.blue,
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
              _buildWelcomeHeader(authController),
              
              const SizedBox(height: 32),
              
              // Cards de funcionalidades principais
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildFeatureCard(
                      icon: Icons.search,
                      title: 'Buscar Profissionais',
                      subtitle: 'Encontre profissionais perto de você',
                      color: Colors.blue,
                      onTap: () {
                        // TODO: Implementar busca de profissionais
                        _showComingSoonDialog(context);
                      },
                    ),
                    _buildFeatureCard(
                      icon: Icons.calendar_today,
                      title: 'Meus Agendamentos',
                      subtitle: 'Veja seus compromissos',
                      color: Colors.green,
                      onTap: () {
                        // TODO: Implementar lista de agendamentos
                        _showComingSoonDialog(context);
                      },
                    ),
                    _buildFeatureCard(
                      icon: Icons.person,
                      title: 'Meu Perfil',
                      subtitle: 'Edite suas informações',
                      color: Colors.orange,
                      onTap: () {
                        // TODO: Implementar edição de perfil
                        _showComingSoonDialog(context);
                      },
                    ),
                    _buildFeatureCard(
                      icon: Icons.history,
                      title: 'Histórico',
                      subtitle: 'Veja serviços anteriores',
                      color: Colors.purple,
                      onTap: () {
                        // TODO: Implementar histórico
                        _showComingSoonDialog(context);
                      },
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

  Widget _buildWelcomeHeader(AuthController authController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
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
              const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              const Text(
                'Bem-vindo!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            authController.currentUser?.email ?? 'Cliente',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Encontre e agende serviços com os melhores profissionais!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.construction, color: Colors.orange, size: 48),
        title: const Text('Em Desenvolvimento'),
        content: const Text(
          'Esta funcionalidade está sendo desenvolvida e estará disponível em breve!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              authController.signOut();
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

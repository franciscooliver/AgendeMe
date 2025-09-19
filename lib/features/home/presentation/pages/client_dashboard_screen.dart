import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/domain/services/i_local_cache_service.dart';

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
          // Botão de teste para forçar logout do Firebase
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => _testCache(context, authController),
          ),
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
                        Modular.to.pushNamed('/professional-search/search');
                      },
                    ),
                    _buildFeatureCard(
                      icon: Icons.calendar_today,
                      title: 'Meus Agendamentos',
                      subtitle: 'Veja seus compromissos',
                      color: Colors.green,
                      onTap: () {
                        Modular.to.pushNamed('/appointments/my-appointments');
                      },
                    ),
                    _buildFeatureCard(
                      icon: Icons.person,
                      title: 'Meu Perfil',
                      subtitle: 'Edite suas informações',
                      color: Colors.orange,
                      onTap: () {
                        // Navegar para a página de perfil do usuário atual
                        final currentUserId = authController.currentUser?.id;
                        if (currentUserId != null) {
                          Modular.to.pushNamed(
                            '/user-profile/profile',
                            arguments: {'userId': currentUserId},
                          );
                        } else {
                          _showErrorDialog(context, 'Erro ao acessar perfil', 'Usuário não encontrado');
                        }
                      },
                    ),
                    _buildFeatureCard(
                      icon: Icons.history,
                      title: 'Histórico',
                      subtitle: 'Veja serviços anteriores',
                      color: Colors.purple,
                      onTap: () {
                        Modular.to.pushNamed('/appointments/history');
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


  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error, color: Colors.red, size: 48),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Teste para verificar cache - força logout do Firebase
  Future<void> _testCache(BuildContext context, AuthController authController) async {
    try {
      print('🔍 DEBUG: TESTE CACHE - Forçando logout do Firebase...');
      
      // Forçar logout do Firebase sem limpar cache
      final firebaseAuth = FirebaseAuth.instance;
      await firebaseAuth.signOut();
      
      print('🔍 DEBUG: TESTE CACHE - Firebase logout concluído');
      print('🔍 DEBUG: TESTE CACHE - Verificando cache...');
      
      // Verificar cache
      final cacheService = Modular.get<ILocalCacheService>();
      final cacheData = cacheService.getAuthData();
      print('🔍 DEBUG: TESTE CACHE - Cache data: $cacheData');
      
      // Verificar se AuthController ainda detecta usuário
      await authController.checkCurrentUser();
      print('🔍 DEBUG: TESTE CACHE - AuthController.isAuthenticated: ${authController.isAuthenticated}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Teste cache concluído. Auth: ${authController.isAuthenticated}'),
          backgroundColor: authController.isAuthenticated ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      print('🔍 DEBUG: TESTE CACHE - Erro: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro no teste: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

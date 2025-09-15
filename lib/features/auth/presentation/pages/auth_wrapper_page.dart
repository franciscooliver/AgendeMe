import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../../../user_profile/domain/entities/user_type.dart';
import '../../../user_profile/presentation/controllers/user_profile_controller.dart';
import '../controllers/auth_controller.dart';
import 'login_page.dart';

class AuthWrapperPage extends StatefulWidget {
  const AuthWrapperPage({super.key});

  @override
  State<AuthWrapperPage> createState() => _AuthWrapperPageState();
}

class _AuthWrapperPageState extends State<AuthWrapperPage> {
  bool _hasCheckedProfile = false;
  bool _isCheckingProfile = false;

  @override
  Widget build(BuildContext context) {
    final authController = Modular.get<AuthController>();

    return Obx(() {
      // Se está carregando autenticação, mostrar loading
      if (authController.isLoading) {
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.deepPurple),
                SizedBox(height: 16),
                Text(
                  'Verificando autenticação...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }

      // Se está autenticado, verificar perfil e navegar apropriadamente
      if (authController.isAuthenticated) {
        // Só verificar perfil uma vez
        if (!_hasCheckedProfile && !_isCheckingProfile) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkUserProfileAndNavigate(authController.currentUser!.id);
          });
        }
        
        // Mostrar loading enquanto verifica perfil
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.deepPurple),
                SizedBox(height: 16),
                Text(
                  'Verificando seu perfil...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }

      // Se não está autenticado, mostrar tela de login
      return const LoginPage();
    });
  }

  /// Verifica se o usuário tem perfil e navega para tela apropriada
  Future<void> _checkUserProfileAndNavigate(String userId) async {
    if (_isCheckingProfile || _hasCheckedProfile) return; // Evitar múltiplas chamadas

    setState(() {
      _isCheckingProfile = true;
    });

    try {
      final userProfileController = Modular.get<UserProfileController>();
      
      // Tentar carregar perfil do usuário
      await userProfileController.loadUserProfile(userId);
      
      if (userProfileController.hasProfile && userProfileController.userProfile != null) {
        // Usuário já tem perfil, navegar para dashboard apropriado
        final userType = userProfileController.userProfile!.userType;
        
        switch (userType) {
          case UserType.client:
            // TODO: Navegar para dashboard do cliente quando implementado
            // Por enquanto vai para home
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/');
            }
            break;
            
          case UserType.professional:
            // Navegar para calendário profissional
            if (mounted) {
              Modular.to.pushReplacementNamed('/professional/calendar');
            }
            break;
        }
      } else {
        // Usuário não tem perfil, navegar para seleção de tipo
        if (mounted) {
          Modular.to.pushReplacementNamed('/user-profile/user-type-selection');
        }
      }
    } catch (e) {
      // Em caso de erro, assumir que não tem perfil e ir para seleção
      // Log do erro para debug (pode ser removido em produção)
      if (mounted) {
        Modular.to.pushReplacementNamed('/user-profile/user-type-selection');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingProfile = false;
          _hasCheckedProfile = true;
        });
      }
    }
  }
}

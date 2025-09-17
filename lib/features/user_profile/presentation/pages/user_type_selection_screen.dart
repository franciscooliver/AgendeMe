import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../../domain/entities/user_type.dart';
import '../controllers/user_type_selection_controller.dart';
import '../controllers/user_profile_controller.dart';

/// Tela para seleção do tipo de usuário após primeiro login
/// 
/// Permite ao usuário escolher entre Cliente ou Profissional
/// e cria o perfil inicial no Firestore
class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get controller from UserProfileModule scope
    late final UserTypeSelectionController controller;
    late final UserProfileController profileController;
    
    try {
      controller = Modular.get<UserTypeSelectionController>();
      profileController = Modular.get<UserProfileController>();
      print('✅ Controllers obtidos com sucesso');
    } catch (e) {
      print('❌ Erro ao obter controllers: $e');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Erro ao carregar controlador'),
              const SizedBox(height: 8),
              Text('$e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Modular.to.pushReplacementNamed('/auth/login'),
                child: const Text('Voltar ao Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Obx(() {
          // Observar sucesso da criação do perfil para navegação direta
          if (profileController.lastOperationSuccess) {
            // Navegar direto após sucesso
            WidgetsBinding.instance.addPostFrameCallback((_) {
              profileController.clearSuccess();
              _navigateAfterSuccess(controller.selectedUserType!);
            });
          }

          // Observar erros do controller principal ou do perfil
          final hasError = controller.errorMessage.isNotEmpty || 
                         profileController.errorMessage.isNotEmpty;
          
          if (hasError && !controller.isLoading) {
            final errorMessage = controller.errorMessage.isNotEmpty 
                ? controller.errorMessage 
                : profileController.errorMessage;
                
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showErrorDialog(context, errorMessage, () {
                controller.clearError();
                profileController.clearError();
              });
            });
          }

          if (controller.isLoading) {
            return const _LoadingView();
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Header
                const _HeaderSection(),
                
                const SizedBox(height: 48),
                
                // Cards de seleção
                Expanded(
                  child: Column(
                    children: [
                      // Card Cliente
                      _UserTypeCard(
                        userType: UserType.client,
                        title: 'Sou Cliente',
                        subtitle: 'Quero agendar serviços',
                        description: 'Encontre profissionais e agende seus serviços de forma prática e rápida.',
                        icon: Icons.person,
                        color: Colors.blue,
                        onTap: () => controller.selectUserType(UserType.client),
                        isSelected: controller.selectedUserType == UserType.client,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Card Profissional
                      _UserTypeCard(
                        userType: UserType.professional,
                        title: 'Sou Profissional',
                        subtitle: 'Quero oferecer serviços',
                        description: 'Gerencie sua agenda, clientes e ofereça seus serviços com facilidade.',
                        icon: Icons.work,
                        color: Colors.deepPurple,
                        onTap: () => controller.selectUserType(UserType.professional),
                        isSelected: controller.selectedUserType == UserType.professional,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Botão Continuar
                _ContinueButton(controller: controller),
                
                const SizedBox(height: 16),
                
                // Link de logout
                const _LogoutLink(),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Navega após sucesso na criação do perfil
  void _navigateAfterSuccess(UserType userType) {
    print('🚀 Navegando após sucesso para tipo: $userType');
    
    switch (userType) {
      case UserType.client:
        print('✅ Navegando para dashboard do cliente');
        Modular.to.pushReplacementNamed('/client-dashboard');
        break;
        
      case UserType.professional:
        print('✅ Navegando para dashboard profissional');
        Modular.to.pushReplacementNamed('/professional/dashboard');
        break;
    }
  }

  /// Mostra dialog de erro
  void _showErrorDialog(BuildContext context, String message, VoidCallback onDismiss) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error, color: Colors.red, size: 48),
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss();
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }
}

/// Header da tela com título e descrição
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo ou ícone do app
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Icon(
            Icons.calendar_month,
            color: Colors.white,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'Bem-vindo ao AgendeMe!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'Para personalizar sua experiência, nos conte como você pretende usar o app:',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Card para seleção de tipo de usuário
class _UserTypeCard extends StatelessWidget {
  final UserType userType;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isSelected;

  const _UserTypeCard({
    required this.userType,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Ícone
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 28,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Título e subtítulo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Checkbox visual
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? color : Colors.grey[400]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Descrição
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botão para continuar com a seleção
class _ContinueButton extends StatelessWidget {
  final UserTypeSelectionController controller;

  const _ContinueButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: controller.selectedUserType != null
            ? () {
                print('🔘 Botão Continuar pressionado');
                controller.createProfile();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[500],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: controller.selectedUserType != null ? 4 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_forward),
            const SizedBox(width: 12),
            Text(
              'Continuar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Link para fazer logout
class _LogoutLink extends StatelessWidget {
  const _LogoutLink();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        // Confirmar logout
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sair da conta'),
            content: const Text('Tem certeza que deseja sair? Você precisará fazer login novamente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Modular.get<UserTypeSelectionController>().logout();
                },
                child: const Text('Sair'),
              ),
            ],
          ),
        );
      },
      child: Text(
        'Não é você? Faça logout',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey[600],
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

/// View de loading
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.deepPurple),
          SizedBox(height: 24),
          Text(
            'Criando seu perfil...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

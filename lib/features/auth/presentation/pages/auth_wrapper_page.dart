import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../../../home/home_page.dart';
import '../controllers/auth_controller.dart';
import 'login_page.dart';

class AuthWrapperPage extends StatelessWidget {
  const AuthWrapperPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      // Se está carregando, mostrar loading
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

      // Se está autenticado, mostrar tela principal
      if (authController.isAuthenticated) {
        return const HomePage();
      }

      // Se não está autenticado, mostrar tela de login
      return const LoginPage();
    });
  }
}

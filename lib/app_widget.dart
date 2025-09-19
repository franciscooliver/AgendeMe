import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  @override
  void initState() {
    super.initState();
    print('🔍 DEBUG: AppWidget.initState() iniciado');
    
    // FORÇAR inicialização do AuthController após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔍 DEBUG: AppWidget.initState() - PostFrameCallback executado');
      _initializeAuthController();
    });
  }
  
  void _initializeAuthController() {
    print('🔍 DEBUG: AppWidget - Forçando inicialização do AuthController');
    try {
      Modular.get<AuthController>();
      print('🔍 DEBUG: AppWidget - AuthController obtido com sucesso');
    } catch (e) {
      print('🔍 DEBUG: AppWidget - Erro ao obter AuthController: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AgendeMe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: Modular.routerConfig,
    );
  }
}

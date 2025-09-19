import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    print('🔍 DEBUG: AuthWrapperPage.initState() iniciado');
    
    // Aguardar um frame para garantir que o AuthController seja inicializado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔍 DEBUG: AuthWrapperPage.initState() - PostFrameCallback executado');
      setState(() {
        _isInitialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Modular.get<AuthController>();

    return Obx(() {
      print('🔍 DEBUG: AuthWrapperPage build - _isInitialized: $_isInitialized, isLoading: ${authController.isLoading}, isAuthenticated: ${authController.isAuthenticated}');
      
      // Se ainda não foi inicializado, mostrar loading
      if (!_isInitialized) {
        print('🔍 DEBUG: AuthWrapperPage - Aguardando inicialização...');
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.deepPurple),
                SizedBox(height: 16),
                Text(
                  'Inicializando...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }
      
      // Se está carregando autenticação, mostrar loading
      if (authController.isLoading) {
        print('🔍 DEBUG: AuthWrapperPage - Mostrando loading de autenticação');
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
        print('🔍 DEBUG: AuthWrapperPage - Usuário autenticado, verificando perfil');
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
      print('🔍 DEBUG: AuthWrapperPage - Usuário não autenticado, mostrando login');
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
      
      print('🔍 DEBUG: Carregando perfil para userId: $userId');
      
      // Primeiro, tentar carregar perfil do usuário
      await userProfileController.loadUserProfile(userId);
      
      print('🔍 DEBUG: hasProfile = ${userProfileController.hasProfile}');
      print('🔍 DEBUG: userProfile = ${userProfileController.userProfile}');
      print('🔍 DEBUG: errorMessage = ${userProfileController.errorMessage}');
      
      // Se carregou perfil com sucesso, navegar diretamente
      if (userProfileController.hasProfile && userProfileController.userProfile != null) {
        await _navigateToUserDashboard(userProfileController.userProfile!.userType);
        return;
      }
      
      // Se não carregou, verificar se perfil existe no Firestore
      print('🔍 DEBUG: Perfil não carregou. Verificando se existe no Firestore...');
      final exists = await userProfileController.userProfileExists(userId);
      print('🔍 DEBUG: userProfileExists retornou: $exists');
      
      if (exists) {
        // Perfil existe mas não carregou - tentar busca direta via Firestore
        print('🔍 DEBUG: PROBLEMA DETECTADO: Perfil existe mas não carregou!');
        print('🔍 DEBUG: Tentando busca direta no Firestore...');
        
        final profileData = await _getProfileDirectlyFromFirestore(userId);
        if (profileData != null) {
          print('🔍 DEBUG: Perfil encontrado via busca direta! Tipo: ${profileData['userType']}');
          await _navigateToUserDashboard(profileData['userType']);
          return;
        }
        
        // Se ainda assim não conseguiu, tentar reload forçado uma vez
        print('🔍 DEBUG: Tentando reload forçado...');
        await userProfileController.loadUserProfile(userId);
        
        if (userProfileController.hasProfile && userProfileController.userProfile != null) {
          await _navigateToUserDashboard(userProfileController.userProfile!.userType);
          return;
        }
      }
      
      // Se chegou até aqui, usuário realmente não tem perfil válido
      print('🔍 DEBUG: Usuário não tem perfil válido. Navegando para seleção de tipo.');
      if (mounted) {
        Modular.to.pushReplacementNamed('/user-profile/user-type-selection');
      }
      
    } catch (e) {
      print('🔍 DEBUG: Erro durante verificação de perfil: $e');
      // Em caso de erro, assumir que não tem perfil e ir para seleção
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

  /// Navega para o dashboard apropriado baseado no tipo de usuário
  Future<void> _navigateToUserDashboard(UserType userType) async {
    print('🔍 DEBUG: Usuario tem perfil! Tipo: $userType');
    
    if (!mounted) return;
    
    switch (userType) {
      case UserType.client:
        print('🔍 DEBUG: Navegando para client-dashboard');
        Modular.to.pushReplacementNamed('/client-dashboard');
        break;
        
      case UserType.professional:
        print('🔍 DEBUG: Navegando para professional/dashboard');
        Modular.to.pushReplacementNamed('/professional/dashboard');
        break;
    }
  }

  /// Busca perfil diretamente no Firestore quando o método normal falha
  Future<Map<String, dynamic>?> _getProfileDirectlyFromFirestore(String userId) async {
    try {
      // Importar Firestore
      final firestore = FirebaseFirestore.instance;
      
      print('🔍 DEBUG: Buscando diretamente no Firestore para userId: $userId');
      
      final querySnapshot = await firestore
          .collection('user_profiles')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();
      
      print('🔍 DEBUG: Busca direta encontrou ${querySnapshot.docs.length} documentos');
      
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        
        print('🔍 DEBUG: Dados encontrados: ${data['name']} - ${data['user_type']}');
        
        // Converter user_type string para UserType enum
        UserType userType;
        switch (data['user_type']) {
          case 'client':
            userType = UserType.client;
            break;
          case 'professional':
            userType = UserType.professional;
            break;
          default:
            print('🔍 DEBUG: Tipo de usuário desconhecido: ${data['user_type']}');
            return null;
        }
        
        return {
          'userType': userType,
          'name': data['name'],
          'email': data['email'],
        };
      }
      
      return null;
    } catch (e) {
      print('🔍 DEBUG: Erro na busca direta no Firestore: $e');
      return null;
    }
  }
}

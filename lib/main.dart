import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_storage/get_storage.dart';

import 'app_module.dart';
import 'app_widget.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

void main() async {
  print('🔍 DEBUG: main() iniciado');
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar GetStorage
  print('🔍 DEBUG: Inicializando GetStorage...');
  await GetStorage.init();
  print('🔍 DEBUG: GetStorage inicializado com sucesso');
  
  // Inicializar Firebase
  print('🔍 DEBUG: Inicializando Firebase...');
  await Firebase.initializeApp();
  print('🔍 DEBUG: Firebase inicializado com sucesso');
  
  print('🔍 DEBUG: Executando app...');
  runApp(ModularApp(
    module: AppModule(),
    child: const AppWidget(),
  ));
}

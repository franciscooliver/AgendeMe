import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Classe utilitária com métodos auxiliares para a aplicação
class AppUtils {
  // Impede instanciação desta classe
  AppUtils._();

  /// Gera um ID único baseado em timestamp e número aleatório
  static String generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return '${timestamp}_$random';
  }

  /// Exibe um snackbar de sucesso
  static void showSuccessSnackbar({
    required String title,
    required String message,
    int duration = 3,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      duration: Duration(seconds: duration),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  /// Exibe um snackbar de erro
  static void showErrorSnackbar({
    required String title,
    required String message,
    int duration = 4,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      duration: Duration(seconds: duration),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  /// Exibe um snackbar de aviso
  static void showWarningSnackbar({
    required String title,
    required String message,
    int duration = 3,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.orange.shade600,
      colorText: Colors.white,
      duration: Duration(seconds: duration),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.warning, color: Colors.white),
    );
  }

  /// Exibe um snackbar de informação
  static void showInfoSnackbar({
    required String title,
    required String message,
    int duration = 3,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.blue.shade600,
      colorText: Colors.white,
      duration: Duration(seconds: duration),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }

  /// Exibe um dialog de confirmação
  static Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color? confirmColor,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  /// Exibe um loading dialog
  static void showLoadingDialog({String? message}) {
    Get.dialog(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message),
            ],
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Fecha o loading dialog
  static void hideLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// Executa uma ação com loading
  static Future<T> executeWithLoading<T>(
    Future<T> Function() action, {
    String? loadingMessage,
  }) async {
    showLoadingDialog(message: loadingMessage);
    try {
      final result = await action();
      hideLoadingDialog();
      return result;
    } catch (e) {
      hideLoadingDialog();
      rethrow;
    }
  }

  /// Formata um valor monetário para o formato brasileiro
  static String formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Remove caracteres especiais de uma string mantendo apenas letras e números
  static String removeSpecialCharacters(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
  }

  /// Valida se uma string não está vazia ou nula
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Debounce para evitar múltiplas execuções rápidas
  static Timer? _debounceTimer;
  
  static void debounce(
    VoidCallback action, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, action);
  }

  /// Calcula a idade com base na data de nascimento
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }

  /// Gera uma cor aleatória
  static Color generateRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  /// Converte bytes para formato legível (KB, MB, GB)
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Valida se um horário está dentro do horário comercial
  static bool isBusinessHour(DateTime dateTime) {
    final hour = dateTime.hour;
    return hour >= 8 && hour <= 18 && dateTime.weekday <= 5;
  }
}

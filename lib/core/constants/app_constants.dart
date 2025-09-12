/// Constantes da aplicação
/// 
/// Esta classe centraliza todas as constantes utilizadas na aplicação
/// para facilitar manutenção e evitar duplicação de código
class AppConstants {
  // Impede instanciação desta classe
  AppConstants._();

  /// Timeout padrão para requisições HTTP (em segundos)
  static const int httpTimeoutSeconds = 30;

  /// Timeout padrão para conexão (em segundos)
  static const int connectionTimeoutSeconds = 15;

  /// Duração padrão para animações (em milissegundos)
  static const int defaultAnimationDuration = 300;

  /// Duração para exibição de snackbars (em milissegundos)
  static const int snackbarDuration = 3000;

  /// Número máximo de tentativas para retry em operações
  static const int maxRetryAttempts = 3;

  /// Delay entre tentativas de retry (em milissegundos)
  static const int retryDelayMs = 1000;

  /// Tamanho máximo de arquivo para upload (em bytes) - 10MB
  static const int maxFileUploadSize = 10 * 1024 * 1024;

  /// Formatos de arquivo aceitos para upload de imagens
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp'
  ];

  /// Chaves para SharedPreferences
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String userTypeKey = 'user_type';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';

  /// Tipos de usuário
  static const String userTypeClient = 'client';
  static const String userTypeProfessional = 'professional';

  /// Mensagens de erro padrão
  static const String genericErrorMessage = 
      'Ocorreu um erro inesperado. Tente novamente.';
  static const String networkErrorMessage = 
      'Verifique sua conexão com a internet e tente novamente.';
  static const String serverErrorMessage = 
      'Problema no servidor. Tente novamente mais tarde.';
  static const String authErrorMessage = 
      'Sessão expirada. Faça login novamente.';
  static const String validationErrorMessage = 
      'Dados inválidos. Verifique os campos e tente novamente.';
}

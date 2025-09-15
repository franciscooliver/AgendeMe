/// Classe base para exceções da aplicação
/// 
/// Exceções são usadas na camada de dados e infraestrutura
/// e são convertidas em Failures na camada de domínio
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

/// Exceção relacionada a operações de servidor
class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

/// Exceção relacionada a problemas de rede
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

/// Exceção relacionada a cache local
class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

/// Exceção relacionada a autenticação
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// Exceção relacionada a validação de dados
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

/// Exceção relacionada a permissões
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
}

/// Exceção relacionada a operações de storage
class StorageException extends AppException {
  const StorageException(super.message, {super.code});
}

/// Exceções específicas para operações de imagem

/// Exceção para problemas na seleção de imagem
class ImageSelectionException extends AppException {
  const ImageSelectionException(super.message, {super.code});
}

/// Exceção para problemas na compressão de imagem
class ImageCompressionException extends AppException {
  const ImageCompressionException(super.message, {super.code});
}

/// Exceção para problemas no upload de imagem
class ImageUploadException extends AppException {
  const ImageUploadException(super.message, {super.code});
}

/// Exceção para problemas no processamento de imagem
class ImageProcessingException extends AppException {
  const ImageProcessingException(super.message, {super.code});
}

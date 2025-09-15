import 'package:equatable/equatable.dart';

/// Classe abstrata que representa falhas no domínio da aplicação
/// Todas as falhas devem herdar desta classe para garantir consistência
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];

  @override
  String toString() => 'Failure(message: $message, code: $code, details: $details)';
}

/// Falha relacionada a problemas de servidor ou API
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Falha relacionada a problemas de conectividade de rede
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Falha relacionada a cache local
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Falha relacionada a autenticação
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Falha relacionada a validação de dados
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Falha relacionada a permissões
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Falha genérica para casos não especificados
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Falha relacionada a operações de storage/armazenamento
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Falha relacionada ao Firebase
class FirebaseFailure extends Failure {
  const FirebaseFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Falha quando um recurso não é encontrado (diferente de erro de sistema)
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code,
    super.details,
  });
}

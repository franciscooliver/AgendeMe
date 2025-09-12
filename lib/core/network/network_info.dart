import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Interface que define os métodos para verificação de conectividade de rede
abstract class NetworkInfo {
  /// Verifica se há conexão com a internet
  /// 
  /// Retorna [true] se há conexão ativa, [false] caso contrário
  Future<bool> get isConnected;
  
  /// Verifica se há conexão com a internet de forma síncrona
  /// 
  /// Retorna [true] se há conexão ativa, [false] caso contrário
  /// Nota: Este método pode bloquear a thread, use com cuidado
  bool get hasConnection;
  
  /// Stream que monitora mudanças no status da conectividade
  Stream<InternetConnectionStatus> get onStatusChange;
}

/// Implementação concreta da interface [NetworkInfo]
/// usando o pacote [internet_connection_checker]
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  const NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;

  @override
  bool get hasConnection => false; // Implementação síncrona não disponível no pacote atual

  @override
  Stream<InternetConnectionStatus> get onStatusChange => 
      connectionChecker.onStatusChange;
}

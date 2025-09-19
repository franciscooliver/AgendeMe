/// Interface para serviços de cache local
abstract class ILocalCacheService {
  /// Salvar dados de autenticação
  Future<void> saveAuthData({
    required String uid,
    required String email,
    required bool isProfessional,
  });

  /// Obter dados de autenticação salvos
  Map<String, dynamic>? getAuthData();

  /// Limpar dados de autenticação
  Future<void> clearAuthData();

  /// Verificar se há dados de autenticação salvos
  bool hasAuthData();

  /// Salvar dados genéricos
  Future<void> saveData(String key, dynamic value);

  /// Obter dados genéricos
  T? getData<T>(String key);

  /// Remover dados genéricos
  Future<void> removeData(String key);

  /// Limpar todos os dados
  Future<void> clearAll();

  // === MÉTODOS PARA PADRÃO CACHE-FIRST ===

  /// Verificar se cache existe e é válido (não expirado)
  bool hasValidCache(String key, {Duration? expiration});

  /// Obter timestamp do cache para verificar expiração
  DateTime? getCacheTimestamp(String key);

  /// Salvar dados com timestamp para controle de expiração
  Future<void> saveDataWithTimestamp(String key, dynamic value);

  /// Invalida cache específico (remove dados e timestamp)
  Future<void> invalidateCache(String key);
}


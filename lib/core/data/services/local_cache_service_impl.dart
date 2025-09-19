import 'package:get_storage/get_storage.dart';

import '../../domain/services/i_local_cache_service.dart';

/// Implementação do serviço de cache local usando GetStorage
class LocalCacheServiceImpl implements ILocalCacheService {
  final GetStorage _storage = GetStorage();

  // Chaves para armazenamento
  static const String _authUidKey = 'auth_uid';
  static const String _authEmailKey = 'auth_email';
  static const String _authIsProfessionalKey = 'auth_is_professional';

  LocalCacheServiceImpl() {
    print('🔍 DEBUG: LocalCacheServiceImpl constructor - Inicializado');
    print('🔍 DEBUG: LocalCacheServiceImpl constructor - GetStorage instance: ${_storage.runtimeType}');
  }

  @override
  Future<void> saveAuthData({
    required String uid,
    required String email,
    required bool isProfessional,
  }) async {
    try {
      print('🔍 DEBUG: LocalCacheService.saveAuthData() - Salvando: uid=$uid, email=$email, isProfessional=$isProfessional');
      await _storage.write(_authUidKey, uid);
      await _storage.write(_authEmailKey, email);
      await _storage.write(_authIsProfessionalKey, isProfessional);
      print('🔍 DEBUG: LocalCacheService.saveAuthData() - Dados salvos com sucesso');
    } catch (e) {
      print('🔍 DEBUG: LocalCacheService.saveAuthData() - Erro ao salvar: $e');
      throw Exception('Erro ao salvar dados de autenticação: $e');
    }
  }

  @override
  Map<String, dynamic>? getAuthData() {
    try {
      final uid = _storage.read(_authUidKey);
      final email = _storage.read(_authEmailKey);
      final isProfessional = _storage.read(_authIsProfessionalKey);

      print('🔍 DEBUG: LocalCacheService.getAuthData() - uid: $uid, email: $email, isProfessional: $isProfessional');

      if (uid == null || email == null || isProfessional == null) {
        print('🔍 DEBUG: LocalCacheService.getAuthData() - Dados incompletos, retornando null');
        return null;
      }

      final authData = {
        'uid': uid,
        'email': email,
        'isProfessional': isProfessional,
      };
      
      print('🔍 DEBUG: LocalCacheService.getAuthData() - Retornando dados: $authData');
      return authData;
    } catch (e) {
      print('🔍 DEBUG: LocalCacheService.getAuthData() - Erro: $e');
      return null;
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      print('🔍 DEBUG: LocalCacheService.clearAuthData() - Limpando dados de autenticação');
      await _storage.remove(_authUidKey);
      await _storage.remove(_authEmailKey);
      await _storage.remove(_authIsProfessionalKey);
      print('🔍 DEBUG: LocalCacheService.clearAuthData() - Dados limpos com sucesso');
    } catch (e) {
      print('🔍 DEBUG: LocalCacheService.clearAuthData() - Erro ao limpar: $e');
      throw Exception('Erro ao limpar dados de autenticação: $e');
    }
  }

  @override
  bool hasAuthData() {
    try {
      final uid = _storage.read(_authUidKey);
      final email = _storage.read(_authEmailKey);
      final isProfessional = _storage.read(_authIsProfessionalKey);
      
      return uid != null && email != null && isProfessional != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> saveData(String key, dynamic value) async {
    try {
      await _storage.write(key, value);
    } catch (e) {
      throw Exception('Erro ao salvar dados: $e');
    }
  }

  @override
  T? getData<T>(String key) {
    try {
      return _storage.read<T>(key);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> removeData(String key) async {
    try {
      await _storage.remove(key);
    } catch (e) {
      throw Exception('Erro ao remover dados: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _storage.erase();
    } catch (e) {
      throw Exception('Erro ao limpar todos os dados: $e');
    }
  }

  // === IMPLEMENTAÇÃO DOS MÉTODOS CACHE-FIRST ===

  @override
  bool hasValidCache(String key, {Duration? expiration}) {
    try {
      final timestamp = getCacheTimestamp(key);
      if (timestamp == null) return false;
      
      if (expiration != null) {
        final now = DateTime.now();
        return now.difference(timestamp) < expiration;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  DateTime? getCacheTimestamp(String key) {
    try {
      final timestampKey = '${key}_timestamp';
      final timestamp = _storage.read(timestampKey);
      if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveDataWithTimestamp(String key, dynamic value) async {
    try {
      // Salvar os dados
      await _storage.write(key, value);
      
      // Salvar timestamp
      final timestampKey = '${key}_timestamp';
      await _storage.write(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      throw Exception('Erro ao salvar dados com timestamp: $e');
    }
  }

  @override
  Future<void> invalidateCache(String key) async {
    try {
      await _storage.remove(key);
      await _storage.remove('${key}_timestamp');
    } catch (e) {
      throw Exception('Erro ao invalidar cache: $e');
    }
  }

  /// Método de teste para verificar se o GetStorage está funcionando
  void testGetStorage() {
    try {
      print('🔍 DEBUG: Testando GetStorage...');
      _storage.write('test_key', 'test_value');
      final testValue = _storage.read('test_key');
      print('🔍 DEBUG: GetStorage test - Valor lido: $testValue');
      _storage.remove('test_key');
      print('🔍 DEBUG: GetStorage test - Funcionando corretamente');
    } catch (e) {
      print('🔍 DEBUG: GetStorage test - Erro: $e');
    }
  }
}


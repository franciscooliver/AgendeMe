import '../../../../core/core.dart';
import '../models/template_example_model.dart';

/// Interface para fonte de dados local
/// 
/// Define métodos para cache local (SharedPreferences, SQLite, Hive, etc.)
abstract class TemplateExampleLocalDataSource {
  /// Busca um Template Example do cache
  Future<TemplateExampleModel> getTemplateExample(String id);

  /// Busca todos os Template Examples do cache
  Future<List<TemplateExampleModel>> getAllTemplateExamples();

  /// Salva um Template Example no cache
  Future<void> cacheTemplateExample(TemplateExampleModel model);

  /// Salva múltiplos Template Examples no cache
  Future<void> cacheTemplateExamples(List<TemplateExampleModel> models);

  /// Remove um Template Example do cache
  Future<void> removeTemplateExample(String id);

  /// Limpa todo o cache
  Future<void> clearCache();

  /// Verifica se um Template Example existe no cache
  Future<bool> hasTemplateExample(String id);
}

/// Implementação da fonte de dados local
/// 
/// Esta é uma implementação simulada - em um projeto real,
/// você implementaria usando SharedPreferences, Hive, SQLite, etc.
class TemplateExampleLocalDataSourceImpl implements TemplateExampleLocalDataSource {
  // Simulação de cache em memória
  static final Map<String, TemplateExampleModel> _cache = {};
  static final List<TemplateExampleModel> _allCache = [];

  @override
  Future<TemplateExampleModel> getTemplateExample(String id) async {
    // Simulação de delay de acesso local
    await Future.delayed(const Duration(milliseconds: 50));
    
    final model = _cache[id];
    if (model == null) {
      throw const CacheFailure(message: 'Template Example não encontrado no cache');
    }
    
    return model;
  }

  @override
  Future<List<TemplateExampleModel>> getAllTemplateExamples() async {
    // Simulação de delay de acesso local
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (_allCache.isEmpty) {
      throw const CacheFailure(message: 'Nenhum Template Example no cache');
    }
    
    return List.from(_allCache);
  }

  @override
  Future<void> cacheTemplateExample(TemplateExampleModel model) async {
    // Simulação de delay de escrita local
    await Future.delayed(const Duration(milliseconds: 30));
    
    _cache[model.id] = model;
    
    // Atualiza também a lista geral
    final existingIndex = _allCache.indexWhere((item) => item.id == model.id);
    if (existingIndex >= 0) {
      _allCache[existingIndex] = model;
    } else {
      _allCache.add(model);
    }
  }

  @override
  Future<void> cacheTemplateExamples(List<TemplateExampleModel> models) async {
    // Simulação de delay de escrita em lote
    await Future.delayed(const Duration(milliseconds: 80));
    
    for (final model in models) {
      _cache[model.id] = model;
    }
    
    _allCache.clear();
    _allCache.addAll(models);
  }

  @override
  Future<void> removeTemplateExample(String id) async {
    // Simulação de delay de remoção
    await Future.delayed(const Duration(milliseconds: 20));
    
    _cache.remove(id);
    _allCache.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> clearCache() async {
    // Simulação de delay de limpeza
    await Future.delayed(const Duration(milliseconds: 50));
    
    _cache.clear();
    _allCache.clear();
  }

  @override
  Future<bool> hasTemplateExample(String id) async {
    // Simulação de delay de verificação
    await Future.delayed(const Duration(milliseconds: 10));
    
    return _cache.containsKey(id);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_model.dart';

/// Interface abstrata para data source remoto de serviços
abstract class ServiceRemoteDataSource {
  Future<ServiceModel> getService(String id);
  Future<List<ServiceModel>> getServicesByProfessional(String professionalId, {bool includeInactive = false});
  Future<ServiceModel> createService(ServiceModel service);
  Future<ServiceModel> updateService(ServiceModel service);
  Future<void> deleteService(String id);
  Future<void> permanentDeleteService(String id);
  Future<List<ServiceModel>> getAllServices({int limit = 20, int offset = 0});
  Future<List<ServiceModel>> getServicesByCategory(String category, {int limit = 20, int offset = 0});
  Future<List<ServiceModel>> getServicesByPriceRange({double? minPrice, double? maxPrice, int limit = 20});
  Future<List<ServiceModel>> getServicesByDuration({int? minDuration, int? maxDuration, int limit = 20});
  Future<List<ServiceModel>> searchServicesByName(String searchTerm, {int limit = 20});
  Future<void> toggleServiceStatus(String id, bool isActive);
  Future<bool> serviceExists(String id);
  Future<Map<String, dynamic>> getServiceStatistics(String professionalId);
}

/// Implementação do data source remoto usando Firestore
class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'services';

  ServiceRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<ServiceModel> getService(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      
      if (!doc.exists) {
        throw Exception('Serviço não encontrado');
      }

      return ServiceModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erro ao buscar serviço: $e');
    }
  }

  @override
  Future<List<ServiceModel>> getServicesByProfessional(
    String professionalId, {
    bool includeInactive = false,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('professional_id', isEqualTo: professionalId);

      if (!includeInactive) {
        query = query.where('is_active', isEqualTo: true);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar serviços do profissional: $e');
    }
  }

  @override
  Future<ServiceModel> createService(ServiceModel service) async {
    try {
      // Criar documento com ID gerado automaticamente
      final docRef = _firestore.collection(_collectionName).doc();
      
      // Criar o modelo com o ID gerado
      final modelWithId = service.copyWith(id: docRef.id);
      
      // Salvar no Firestore (sem o ID no documento)
      await docRef.set(modelWithId.toFirestore());
      
      return modelWithId;
    } catch (e) {
      throw Exception('Erro ao criar serviço: $e');
    }
  }

  @override
  Future<ServiceModel> updateService(ServiceModel service) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(service.id)
          .update(service.toFirestore());
      
      return service;
    } catch (e) {
      throw Exception('Erro ao atualizar serviço: $e');
    }
  }

  @override
  Future<void> deleteService(String id) async {
    try {
      // Soft delete - apenas marca como inativo
      await _firestore.collection(_collectionName).doc(id).update({
        'is_active': false,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erro ao deletar serviço: $e');
    }
  }

  @override
  Future<void> permanentDeleteService(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar permanentemente o serviço: $e');
    }
  }

  @override
  Future<List<ServiceModel>> getAllServices({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('is_active', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .limit(limit);

      if (offset > 0) {
        final offsetSnapshot = await _firestore
            .collection(_collectionName)
            .where('is_active', isEqualTo: true)
            .orderBy('created_at', descending: true)
            .limit(offset)
            .get();

        if (offsetSnapshot.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetSnapshot.docs.last);
        }
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar todos os serviços: $e');
    }
  }

  @override
  Future<List<ServiceModel>> getServicesByCategory(
    String category, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('category', isEqualTo: category)
          .where('is_active', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .limit(limit);

      if (offset > 0) {
        final offsetSnapshot = await _firestore
            .collection(_collectionName)
            .where('category', isEqualTo: category)
            .where('is_active', isEqualTo: true)
            .orderBy('created_at', descending: true)
            .limit(offset)
            .get();

        if (offsetSnapshot.docs.isNotEmpty) {
          query = query.startAfterDocument(offsetSnapshot.docs.last);
        }
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar serviços por categoria: $e');
    }
  }

  @override
  Future<List<ServiceModel>> getServicesByPriceRange({
    double? minPrice,
    double? maxPrice,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('is_active', isEqualTo: true);

      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      query = query.orderBy('price').limit(limit);

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar serviços por faixa de preço: $e');
    }
  }

  @override
  Future<List<ServiceModel>> getServicesByDuration({
    int? minDuration,
    int? maxDuration,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('is_active', isEqualTo: true);

      if (minDuration != null) {
        query = query.where('duration', isGreaterThanOrEqualTo: minDuration);
      }

      if (maxDuration != null) {
        query = query.where('duration', isLessThanOrEqualTo: maxDuration);
      }

      query = query.orderBy('duration').limit(limit);

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar serviços por duração: $e');
    }
  }

  @override
  Future<List<ServiceModel>> searchServicesByName(
    String searchTerm, {
    int limit = 20,
  }) async {
    try {
      // Para busca textual simples, vamos usar where com >= e < para simular LIKE
      final searchTermLower = searchTerm.toLowerCase();
      
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('is_active', isEqualTo: true)
          .orderBy('name')
          .startAt([searchTermLower])
          .endAt(['$searchTermLower\uf8ff'])
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar serviços por nome: $e');
    }
  }

  @override
  Future<void> toggleServiceStatus(String id, bool isActive) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'is_active': isActive,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erro ao alterar status do serviço: $e');
    }
  }

  @override
  Future<bool> serviceExists(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Erro ao verificar existência do serviço: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getServiceStatistics(String professionalId) async {
    try {
      final servicesSnapshot = await _firestore
          .collection(_collectionName)
          .where('professional_id', isEqualTo: professionalId)
          .get();

      final services = servicesSnapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();

      final activeServices = services.where((s) => s.isActive).length;
      final inactiveServices = services.where((s) => !s.isActive).length;
      final averagePrice = services.isNotEmpty 
          ? services.map((s) => s.price).reduce((a, b) => a + b) / services.length
          : 0.0;
      final averageDuration = services.isNotEmpty
          ? services.map((s) => s.duration).reduce((a, b) => a + b) ~/ services.length
          : 0;

      // Estatísticas por categoria
      final categoriesCount = <String, int>{};
      for (final service in services) {
        categoriesCount[service.category] = (categoriesCount[service.category] ?? 0) + 1;
      }

      return {
        'total_services': services.length,
        'active_services': activeServices,
        'inactive_services': inactiveServices,
        'average_price': averagePrice,
        'average_duration': averageDuration,
        'categories_count': categoriesCount,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas de serviços: $e');
    }
  }
}

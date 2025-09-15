import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile_model.dart';

/// Interface abstrata para data source remoto de perfis de usuário
abstract class UserProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String id);
  Future<UserProfileModel> getUserProfileByUserId(String userId);
  Future<UserProfileModel> createUserProfile(UserProfileModel userProfile);
  Future<UserProfileModel> updateUserProfile(UserProfileModel userProfile);
  Future<void> deleteUserProfile(String id);
  Future<List<UserProfileModel>> getAllUserProfiles({int limit = 20, int offset = 0});
  Future<List<UserProfileModel>> getUserProfilesByType(String userType, {int limit = 20, int offset = 0});
  Future<List<UserProfileModel>> getProfessionalsByCity(String city, {int limit = 20});
  Future<List<UserProfileModel>> getProfessionalsByService(String service, {int limit = 20});
  Future<bool> userProfileExists(String userId);
}

/// Implementação do data source remoto usando Firestore
class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'user_profiles';

  UserProfileRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserProfileModel> getUserProfile(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      
      if (!doc.exists) {
        throw Exception('Perfil de usuário não encontrado');
      }

      return UserProfileModel.fromDocumentSnapshot(doc);
    } catch (e) {
      throw Exception('Erro ao buscar perfil de usuário: $e');
    }
  }

  @override
  Future<UserProfileModel> getUserProfileByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Perfil de usuário não encontrado');
      }

      return UserProfileModel.fromDocumentSnapshot(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Erro ao buscar perfil por userId: $e');
    }
  }

  @override
  Future<UserProfileModel> createUserProfile(UserProfileModel userProfile) async {
    try {
      // Criar documento com ID gerado automaticamente
      final docRef = _firestore.collection(_collectionName).doc();
      
      // Criar o modelo com o ID gerado
      final modelWithId = userProfile.copyWith(id: docRef.id);
      
      // Salvar no Firestore
      await docRef.set(modelWithId.toJson());
      
      return modelWithId;
    } catch (e) {
      throw Exception('Erro ao criar perfil de usuário: $e');
    }
  }

  @override
  Future<UserProfileModel> updateUserProfile(UserProfileModel userProfile) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc(userProfile.id);
      
      // Verificar se o documento existe
      final doc = await docRef.get();
      if (!doc.exists) {
        throw Exception('Perfil de usuário não encontrado');
      }
      
      // Atualizar no Firestore
      await docRef.update(userProfile.toJson());
      
      return userProfile;
    } catch (e) {
      throw Exception('Erro ao atualizar perfil de usuário: $e');
    }
  }

  @override
  Future<void> deleteUserProfile(String id) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc(id);
      
      // Verificar se o documento existe
      final doc = await docRef.get();
      if (!doc.exists) {
        throw Exception('Perfil de usuário não encontrado');
      }
      
      // Deletar do Firestore
      await docRef.delete();
    } catch (e) {
      throw Exception('Erro ao deletar perfil de usuário: $e');
    }
  }

  @override
  Future<List<UserProfileModel>> getAllUserProfiles({int limit = 20, int offset = 0}) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('is_active', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .limit(limit);

      // Implementar offset usando startAfterDocument se necessário
      if (offset > 0) {
        // Para simplificar, vamos usar skip (não é o ideal para grandes datasets)
        // Em produção, seria melhor usar startAfterDocument com cursor
        final skipQuery = await _firestore
            .collection(_collectionName)
            .where('is_active', isEqualTo: true)
            .orderBy('created_at', descending: true)
            .limit(offset)
            .get();
            
        if (skipQuery.docs.isNotEmpty) {
          query = query.startAfterDocument(skipQuery.docs.last);
        }
      }

      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => UserProfileModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar perfis de usuário: $e');
    }
  }

  @override
  Future<List<UserProfileModel>> getUserProfilesByType(
    String userType, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('user_type', isEqualTo: userType)
          .where('is_active', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .limit(limit);

      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => UserProfileModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar perfis por tipo: $e');
    }
  }

  @override
  Future<List<UserProfileModel>> getProfessionalsByCity(
    String city, {
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('user_type', isEqualTo: 'professional')
          .where('city', isEqualTo: city)
          .where('is_active', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => UserProfileModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar profissionais por cidade: $e');
    }
  }

  @override
  Future<List<UserProfileModel>> getProfessionalsByService(
    String service, {
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('user_type', isEqualTo: 'professional')
          .where('services', arrayContains: service)
          .where('is_active', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => UserProfileModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar profissionais por serviço: $e');
    }
  }

  @override
  Future<bool> userProfileExists(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Erro ao verificar existência do perfil: $e');
    }
  }
}

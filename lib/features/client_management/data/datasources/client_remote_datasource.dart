import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/client_model.dart';
import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';

/// Interface abstrata para data source remoto de clientes
abstract class ClientRemoteDataSource {
  Future<List<ClientModel>> getClientsByProfessional(
    String professionalId, {
    bool includeInactive = false,
    int limit = 20,
    int offset = 0,
  });

  Future<ClientModel> getClientById(String clientId);

  Future<List<ClientModel>> searchClients(
    String professionalId,
    String searchTerm, {
    int limit = 10,
  });

  Future<ClientModel> addClient(ClientModel client, String professionalId);

  Future<ClientModel> updateClient(ClientModel client);

  Future<ClientModel> updateClientStatistics(
    String clientId,
    double servicePrice,
    String serviceName,
  );

  Future<void> removeClientAssociation(String professionalId, String clientId);

  Future<List<ClientModel>> getClientsByStatus(
    String professionalId,
    ClientStatus status, {
    int limit = 20,
  });

  Future<bool> hasClientAssociation(String professionalId, String clientUserId);

  Future<ClientStatistics> getClientStatistics(String professionalId);
}

/// Implementação do data source remoto usando Firestore
class ClientRemoteDataSourceImpl implements ClientRemoteDataSource {
  final FirebaseFirestore _firestore;
  
  // Collections do Firestore
  static const String _clientsCollection = 'clients';
  static const String _professionalClientsCollection = 'professional_clients';

  ClientRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ClientModel>> getClientsByProfessional(
    String professionalId, {
    bool includeInactive = false,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      Query query = _firestore
          .collection(_professionalClientsCollection)
          .doc(professionalId)
          .collection('clients')
          .orderBy('last_interaction_date', descending: true);

      if (!includeInactive) {
        query = query.where('is_active', isEqualTo: true);
      }

      final querySnapshot = await query
          .limit(limit)
          .get();

      final clients = <ClientModel>[];
      for (final doc in querySnapshot.docs) {
        clients.add(ClientModel.fromDocumentSnapshot(doc));
      }

      return clients;
    } catch (e) {
      throw Exception('Erro ao buscar clientes do profissional: $e');
    }
  }

  @override
  Future<ClientModel> getClientById(String clientId) async {
    try {
      final doc = await _firestore
          .collection(_clientsCollection)
          .doc(clientId)
          .get();

      if (!doc.exists) {
        throw Exception('Cliente não encontrado');
      }

      return ClientModel.fromDocumentSnapshot(doc);
    } catch (e) {
      throw Exception('Erro ao buscar cliente por ID: $e');
    }
  }

  @override
  Future<List<ClientModel>> searchClients(
    String professionalId,
    String searchTerm, {
    int limit = 10,
  }) async {
    try {
      final searchTermLower = searchTerm.toLowerCase();
      
      // Busca por nome
      final nameQuery = await _firestore
          .collection(_professionalClientsCollection)
          .doc(professionalId)
          .collection('clients')
          .where('name_lowercase', isGreaterThanOrEqualTo: searchTermLower)
          .where('name_lowercase', isLessThan: '${searchTermLower}z')
          .limit(limit)
          .get();

      // Busca por email
      final emailQuery = await _firestore
          .collection(_professionalClientsCollection)
          .doc(professionalId)
          .collection('clients')
          .where('email', isGreaterThanOrEqualTo: searchTermLower)
          .where('email', isLessThan: '${searchTermLower}z')
          .limit(limit)
          .get();

      final Set<String> addedIds = {};
      final List<ClientModel> clients = [];

      // Combinar resultados evitando duplicatas
      for (final doc in [...nameQuery.docs, ...emailQuery.docs]) {
        if (!addedIds.contains(doc.id)) {
          addedIds.add(doc.id);
          clients.add(ClientModel.fromDocumentSnapshot(doc));
        }
      }

      return clients;
    } catch (e) {
      throw Exception('Erro ao buscar clientes: $e');
    }
  }

  @override
  Future<ClientModel> addClient(ClientModel client, String professionalId) async {
    try {
      // Criar documento na coleção geral de clientes
      final clientRef = _firestore.collection(_clientsCollection).doc();
      final clientWithId = client.copyWith(id: clientRef.id);
      
      await clientRef.set(clientWithId.toJson());

      // Criar associação profissional-cliente
      await _firestore
          .collection(_professionalClientsCollection)
          .doc(professionalId)
          .collection('clients')
          .doc(clientRef.id)
          .set({
        ...clientWithId.toJson(),
        'name_lowercase': client.name.toLowerCase(), // Para busca
        'professional_id': professionalId,
      });

      return clientWithId;
    } catch (e) {
      throw Exception('Erro ao adicionar cliente: $e');
    }
  }

  @override
  Future<ClientModel> updateClient(ClientModel client) async {
    try {
      final updateData = client.toJson();
      updateData['updated_at'] = FieldValue.serverTimestamp();

      // Atualizar na coleção geral
      await _firestore
          .collection(_clientsCollection)
          .doc(client.id)
          .update(updateData);

      // Buscar todas as associações profissional-cliente para este cliente
      final professionalClientsQuery = await _firestore
          .collectionGroup('clients')
          .where('user_id', isEqualTo: client.userId)
          .get();

      // Atualizar em todas as associações
      final batch = _firestore.batch();
      for (final doc in professionalClientsQuery.docs) {
        batch.update(doc.reference, {
          ...updateData,
          'name_lowercase': client.name.toLowerCase(),
        });
      }
      await batch.commit();

      return client.copyWith(lastInteractionDate: DateTime.now());
    } catch (e) {
      throw Exception('Erro ao atualizar cliente: $e');
    }
  }

  @override
  Future<ClientModel> updateClientStatistics(
    String clientId,
    double servicePrice,
    String serviceName,
  ) async {
    try {
      final clientRef = _firestore.collection(_clientsCollection).doc(clientId);
      
      return await _firestore.runTransaction((transaction) async {
        final clientDoc = await transaction.get(clientRef);
        
        if (!clientDoc.exists) {
          throw Exception('Cliente não encontrado');
        }

        final currentClient = ClientModel.fromDocumentSnapshot(clientDoc);
        
        // Atualizar estatísticas
        final updatedServicesUsed = List<String>.from(currentClient.servicesUsed);
        if (!updatedServicesUsed.contains(serviceName)) {
          updatedServicesUsed.add(serviceName);
        }

        final updatedClient = currentClient.copyWith(
          totalAppointments: currentClient.totalAppointments + 1,
          totalSpent: currentClient.totalSpent + servicePrice,
          lastInteractionDate: DateTime.now(),
          servicesUsed: updatedServicesUsed,
        );

        // Atualizar na coleção geral
        transaction.update(clientRef, updatedClient.toJson());

        // Buscar e atualizar todas as associações profissional-cliente
        final professionalClientsQuery = await _firestore
            .collectionGroup('clients')
            .where('user_id', isEqualTo: currentClient.userId)
            .get();

        for (final doc in professionalClientsQuery.docs) {
          transaction.update(doc.reference, updatedClient.toJson());
        }

        return updatedClient;
      });
    } catch (e) {
      throw Exception('Erro ao atualizar estatísticas do cliente: $e');
    }
  }

  @override
  Future<void> removeClientAssociation(String professionalId, String clientId) async {
    try {
      await _firestore
          .collection(_professionalClientsCollection)
          .doc(professionalId)
          .collection('clients')
          .doc(clientId)
          .delete();
    } catch (e) {
      throw Exception('Erro ao remover associação cliente-profissional: $e');
    }
  }

  @override
  Future<List<ClientModel>> getClientsByStatus(
    String professionalId,
    ClientStatus status, {
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_professionalClientsCollection)
          .doc(professionalId)
          .collection('clients')
          .where('status', isEqualTo: status.value)
          .orderBy('last_interaction_date', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ClientModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar clientes por status: $e');
    }
  }

  @override
  Future<bool> hasClientAssociation(String professionalId, String clientUserId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_professionalClientsCollection)
          .doc(professionalId)
          .collection('clients')
          .where('user_id', isEqualTo: clientUserId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Erro ao verificar associação cliente-profissional: $e');
    }
  }

  @override
  Future<ClientStatistics> getClientStatistics(String professionalId) async {
    try {
      final clientsSnapshot = await _firestore
          .collection(_professionalClientsCollection)
          .doc(professionalId)
          .collection('clients')
          .get();

      int totalClients = 0;
      int activeClients = 0;
      int newClientsThisMonth = 0;
      int vipClients = 0;
      double totalRevenue = 0.0;
      DateTime? lastClientAddedDate;

      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      for (final doc in clientsSnapshot.docs) {
        final client = ClientModel.fromDocumentSnapshot(doc);
        
        totalClients++;
        totalRevenue += client.totalSpent;
        
        if (client.isActive) activeClients++;
        
        if (client.firstAppointmentDate.isAfter(firstDayOfMonth)) {
          newClientsThisMonth++;
        }
        
        if (client.isVipClient) vipClients++;
        
        if (lastClientAddedDate == null || 
            client.firstAppointmentDate.isAfter(lastClientAddedDate)) {
          lastClientAddedDate = client.firstAppointmentDate;
        }
      }

      final averageRevenuePerClient = totalClients > 0 ? totalRevenue / totalClients : 0.0;

      return ClientStatistics(
        totalClients: totalClients,
        activeClients: activeClients,
        newClientsThisMonth: newClientsThisMonth,
        vipClients: vipClients,
        totalRevenue: totalRevenue,
        averageRevenuePerClient: averageRevenuePerClient,
        lastClientAddedDate: lastClientAddedDate,
      );
    } catch (e) {
      throw Exception('Erro ao obter estatísticas de clientes: $e');
    }
  }
}

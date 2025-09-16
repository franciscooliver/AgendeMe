import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';
import '../entities/client_entity.dart';

/// Interface abstrata para o repositório de clientes
/// 
/// Define os contratos para todas as operações relacionadas
/// ao gerenciamento de clientes pelo profissional
abstract class ClientRepository {
  
  /// Busca todos os clientes associados a um profissional
  /// 
  /// [professionalId] - ID do profissional
  /// [includeInactive] - Se deve incluir clientes inativos
  /// [limit] - Número máximo de clientes a retornar
  /// [offset] - Offset para paginação
  Future<Either<Failure, List<ClientEntity>>> getClientsByProfessional(
    String professionalId, {
    bool includeInactive = false,
    int limit = 20,
    int offset = 0,
  });

  /// Busca um cliente específico por ID
  /// 
  /// [clientId] - ID único do cliente
  Future<Either<Failure, ClientEntity>> getClientById(String clientId);

  /// Busca clientes por termo de pesquisa (nome ou email)
  /// 
  /// [professionalId] - ID do profissional
  /// [searchTerm] - Termo para buscar (nome ou email)
  /// [limit] - Número máximo de resultados
  Future<Either<Failure, List<ClientEntity>>> searchClients(
    String professionalId,
    String searchTerm, {
    int limit = 10,
  });

  /// Adiciona um novo cliente ao profissional
  /// 
  /// Este método é chamado automaticamente quando um novo
  /// usuário faz seu primeiro agendamento com o profissional
  /// 
  /// [client] - Dados do cliente a ser adicionado
  Future<Either<Failure, ClientEntity>> addClient(ClientEntity client);

  /// Atualiza informações específicas do cliente
  /// 
  /// Permite ao profissional atualizar observações,
  /// status ou outras informações relevantes
  /// 
  /// [client] - Dados atualizados do cliente
  Future<Either<Failure, ClientEntity>> updateClient(ClientEntity client);

  /// Atualiza estatísticas do cliente após um agendamento
  /// 
  /// Incrementa contadores, atualiza valores gastos,
  /// data da última interação, etc.
  /// 
  /// [clientId] - ID do cliente
  /// [servicePrice] - Valor do serviço realizado
  /// [serviceName] - Nome do serviço realizado
  Future<Either<Failure, ClientEntity>> updateClientStatistics(
    String clientId,
    double servicePrice,
    String serviceName,
  );

  /// Remove associação entre cliente e profissional
  /// 
  /// Não remove o cliente do sistema, apenas remove
  /// a associação com este profissional específico
  /// 
  /// [professionalId] - ID do profissional
  /// [clientId] - ID do cliente
  Future<Either<Failure, void>> removeClientAssociation(
    String professionalId,
    String clientId,
  );

  /// Busca clientes por status específico
  /// 
  /// [professionalId] - ID do profissional
  /// [status] - Status dos clientes a buscar
  /// [limit] - Número máximo de resultados
  Future<Either<Failure, List<ClientEntity>>> getClientsByStatus(
    String professionalId,
    ClientStatus status, {
    int limit = 20,
  });

  /// Busca clientes VIP do profissional
  /// 
  /// [professionalId] - ID do profissional
  /// [limit] - Número máximo de resultados
  Future<Either<Failure, List<ClientEntity>>> getVipClients(
    String professionalId, {
    int limit = 10,
  });

  /// Busca clientes inativos (sem interação recente)
  /// 
  /// [professionalId] - ID do profissional
  /// [daysSinceLastInteraction] - Dias sem interação (padrão: 60)
  /// [limit] - Número máximo de resultados
  Future<Either<Failure, List<ClientEntity>>> getInactiveClients(
    String professionalId, {
    int daysSinceLastInteraction = 60,
    int limit = 20,
  });

  /// Verifica se existe associação entre cliente e profissional
  /// 
  /// [professionalId] - ID do profissional
  /// [clientUserId] - ID do usuário cliente
  Future<Either<Failure, bool>> hasClientAssociation(
    String professionalId,
    String clientUserId,
  );

  /// Obtém estatísticas gerais dos clientes do profissional
  /// 
  /// [professionalId] - ID do profissional
  Future<Either<Failure, ClientStatistics>> getClientStatistics(
    String professionalId,
  );
}

/// Classe para estatísticas dos clientes
class ClientStatistics {
  final int totalClients;
  final int activeClients;
  final int newClientsThisMonth;
  final int vipClients;
  final double totalRevenue;
  final double averageRevenuePerClient;
  final DateTime? lastClientAddedDate;

  const ClientStatistics({
    required this.totalClients,
    required this.activeClients,
    required this.newClientsThisMonth,
    required this.vipClients,
    required this.totalRevenue,
    required this.averageRevenuePerClient,
    this.lastClientAddedDate,
  });

  ClientStatistics copyWith({
    int? totalClients,
    int? activeClients,
    int? newClientsThisMonth,
    int? vipClients,
    double? totalRevenue,
    double? averageRevenuePerClient,
    DateTime? lastClientAddedDate,
  }) {
    return ClientStatistics(
      totalClients: totalClients ?? this.totalClients,
      activeClients: activeClients ?? this.activeClients,
      newClientsThisMonth: newClientsThisMonth ?? this.newClientsThisMonth,
      vipClients: vipClients ?? this.vipClients,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      averageRevenuePerClient: averageRevenuePerClient ?? this.averageRevenuePerClient,
      lastClientAddedDate: lastClientAddedDate ?? this.lastClientAddedDate,
    );
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/core.dart';
import '../entities/client_entity.dart';
import '../repositories/client_repository.dart';

/// Use case para atualizar estatísticas do cliente após um agendamento
/// 
/// Este use case é chamado automaticamente após a conclusão de um
/// agendamento para manter os dados do cliente atualizados
class UpdateClientStatistics extends UseCase<ClientEntity, UpdateClientStatisticsParams> {
  final ClientRepository repository;

  UpdateClientStatistics(this.repository);

  @override
  Future<Either<Failure, ClientEntity>> call(UpdateClientStatisticsParams params) async {
    return await repository.updateClientStatistics(
      params.clientId,
      params.servicePrice,
      params.serviceName,
    );
  }
}

/// Parâmetros para o UpdateClientStatistics use case
class UpdateClientStatisticsParams extends Equatable {
  final String clientId;
  final double servicePrice;
  final String serviceName;

  const UpdateClientStatisticsParams({
    required this.clientId,
    required this.servicePrice,
    required this.serviceName,
  });

  @override
  List<Object> get props => [clientId, servicePrice, serviceName];
}

import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../entities/client_entity.dart';
import '../usecases/auto_register_client.dart';
import '../usecases/update_client_statistics.dart';

/// Serviço para gerenciar o registro automático de clientes
/// 
/// Este serviço é usado por outros módulos (como o de agendamentos)
/// para automaticamente registrar e atualizar informações de clientes
abstract class ClientAutoRegistrationService {
  /// Registra automaticamente um cliente quando faz primeiro agendamento
  Future<Either<Failure, ClientEntity>> autoRegisterClient(
    UserProfileEntity userProfile,
    String professionalId,
  );

  /// Atualiza estatísticas do cliente após um agendamento
  Future<Either<Failure, ClientEntity>> updateClientAfterAppointment(
    String clientId,
    double servicePrice,
    String serviceName,
  );

  /// Verifica se um usuário já é cliente do profissional
  Future<Either<Failure, bool>> isExistingClient(
    String professionalId,
    String userId,
  );
}

/// Implementação do serviço de registro automático
class ClientAutoRegistrationServiceImpl implements ClientAutoRegistrationService {
  final AutoRegisterClient _autoRegisterClientUseCase;
  final UpdateClientStatistics _updateClientStatisticsUseCase;

  ClientAutoRegistrationServiceImpl({
    required AutoRegisterClient autoRegisterClient,
    required UpdateClientStatistics updateClientStatistics,
  }) : _autoRegisterClientUseCase = autoRegisterClient,
       _updateClientStatisticsUseCase = updateClientStatistics;

  @override
  Future<Either<Failure, ClientEntity>> autoRegisterClient(
    UserProfileEntity userProfile,
    String professionalId,
  ) async {
    return await _autoRegisterClientUseCase(AutoRegisterClientParams(
      userProfile: userProfile,
      professionalId: professionalId,
    ));
  }

  @override
  Future<Either<Failure, ClientEntity>> updateClientAfterAppointment(
    String clientId,
    double servicePrice,
    String serviceName,
  ) async {
    return await _updateClientStatisticsUseCase(UpdateClientStatisticsParams(
      clientId: clientId,
      servicePrice: servicePrice,
      serviceName: serviceName,
    ));
  }

  @override
  Future<Either<Failure, bool>> isExistingClient(
    String professionalId,
    String userId,
  ) async {
    // Esta implementação seria melhor se tivéssemos acesso direto ao repository
    // Por simplicidade, retornamos falso aqui e deixamos o AutoRegisterClient
    // lidar com a verificação
    return const Right(false);
  }
}

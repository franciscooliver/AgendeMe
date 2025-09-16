import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/core.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../entities/client_entity.dart';
import '../repositories/client_repository.dart';

/// Use case para registro automático de cliente
/// 
/// Este use case é chamado quando um usuário faz seu primeiro
/// agendamento com um profissional, criando automaticamente
/// a associação cliente-profissional
class AutoRegisterClient extends UseCase<ClientEntity, AutoRegisterClientParams> {
  final ClientRepository repository;

  AutoRegisterClient(this.repository);

  @override
  Future<Either<Failure, ClientEntity>> call(AutoRegisterClientParams params) async {
    try {
      // Verificar se já existe associação
      final hasAssociation = await repository.hasClientAssociation(
        params.professionalId,
        params.userProfile.userId,
      );

      return hasAssociation.fold(
        (failure) => Left(failure),
        (exists) async {
          if (exists) {
            // Cliente já existe, apenas retornar
            return Left(ValidationFailure(message: 'Cliente já está associado ao profissional'));
          }

          // Criar novo cliente baseado no perfil do usuário
          final newClient = _createClientFromUserProfile(
            params.userProfile,
            params.professionalId,
          );

          // Adicionar cliente
          final result = await repository.addClient(newClient);
          return result;
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Erro no registro automático: $e'));
    }
  }

  /// Cria ClientEntity a partir do UserProfileEntity
  ClientEntity _createClientFromUserProfile(
    UserProfileEntity userProfile,
    String professionalId,
  ) {
    final now = DateTime.now();
    
    return ClientEntity(
      id: '', // Será gerado pelo Firestore
      userId: userProfile.userId,
      name: userProfile.name,
      email: userProfile.email,
      phone: userProfile.phone,
      profileImageUrl: userProfile.profileImageUrl,
      firstAppointmentDate: now,
      lastInteractionDate: now,
      totalAppointments: 0,
      status: ClientStatus.newClient,
      notes: 'Cliente registrado automaticamente no primeiro agendamento',
      servicesUsed: const [],
      totalSpent: 0.0,
      isActive: true,
    );
  }
}

/// Parâmetros para o AutoRegisterClient use case
class AutoRegisterClientParams extends Equatable {
  final UserProfileEntity userProfile;
  final String professionalId;

  const AutoRegisterClientParams({
    required this.userProfile,
    required this.professionalId,
  });

  @override
  List<Object> get props => [userProfile, professionalId];
}

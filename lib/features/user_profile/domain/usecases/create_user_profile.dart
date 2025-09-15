import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/core.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

/// Use case para criar um novo perfil de usuário
class CreateUserProfile extends UseCase<UserProfileEntity, CreateUserProfileParams> {
  final UserProfileRepository repository;

  CreateUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfileEntity>> call(CreateUserProfileParams params) async {
    // Validações de negócio antes da criação
    if (params.userProfile.name.isEmpty) {
      return Left(ValidationFailure(message: 'Nome é obrigatório'));
    }

    if (params.userProfile.email.isEmpty) {
      return Left(ValidationFailure(message: 'Email é obrigatório'));
    }

    if (params.userProfile.userId.isEmpty) {
      return Left(ValidationFailure(message: 'UserId é obrigatório'));
    }

    // Verificar se já existe um perfil para este userId
    final existsResult = await repository.userProfileExists(params.userProfile.userId);
    
    return existsResult.fold(
      (failure) => Left(failure),
      (exists) {
        if (exists) {
          return Left(ValidationFailure(message: 'Já existe um perfil para este usuário'));
        }
        
        // Criar o perfil com timestamps atualizados
        final profileToCreate = params.userProfile.copyWith(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        return repository.createUserProfile(profileToCreate);
      },
    );
  }
}

/// Parâmetros para o CreateUserProfile use case
class CreateUserProfileParams extends Equatable {
  final UserProfileEntity userProfile;

  const CreateUserProfileParams({required this.userProfile});

  @override
  List<Object> get props => [userProfile];
}

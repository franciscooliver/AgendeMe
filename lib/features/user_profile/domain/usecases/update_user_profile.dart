import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/core.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

/// Use case para atualizar um perfil de usuário existente
class UpdateUserProfile extends UseCase<UserProfileEntity, UpdateUserProfileParams> {
  final UserProfileRepository repository;

  UpdateUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfileEntity>> call(UpdateUserProfileParams params) async {
    // Validações de negócio antes da atualização
    if (params.userProfile.name.isEmpty) {
      return Left(ValidationFailure(message: 'Nome é obrigatório'));
    }

    if (params.userProfile.email.isEmpty) {
      return Left(ValidationFailure(message: 'Email é obrigatório'));
    }

    if (params.userProfile.id.isEmpty) {
      return Left(ValidationFailure(message: 'ID do perfil é obrigatório'));
    }

    // Verificar se o perfil existe antes de atualizar
    final existingProfileResult = await repository.getUserProfile(params.userProfile.id);
    
    return existingProfileResult.fold(
      (failure) => Left(failure),
      (existingProfile) {
        // Atualizar o perfil mantendo alguns campos imutáveis
        final profileToUpdate = params.userProfile.copyWith(
          userId: existingProfile.userId, // userId não pode ser alterado
          createdAt: existingProfile.createdAt, // createdAt não pode ser alterado
          updatedAt: DateTime.now(), // updatedAt sempre atualizado
        );
        
        return repository.updateUserProfile(profileToUpdate);
      },
    );
  }
}

/// Parâmetros para o UpdateUserProfile use case
class UpdateUserProfileParams extends Equatable {
  final UserProfileEntity userProfile;

  const UpdateUserProfileParams({required this.userProfile});

  @override
  List<Object> get props => [userProfile];
}

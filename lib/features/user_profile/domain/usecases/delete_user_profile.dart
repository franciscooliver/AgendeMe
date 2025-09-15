import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/core.dart';
import '../repositories/user_profile_repository.dart';

/// Use case para remover um perfil de usuário
class DeleteUserProfile extends UseCase<void, DeleteUserProfileParams> {
  final UserProfileRepository repository;

  DeleteUserProfile(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteUserProfileParams params) async {
    // Validação básica
    if (params.id.isEmpty) {
      return Left(ValidationFailure(message: 'ID do perfil é obrigatório'));
    }

    // Verificar se o perfil existe antes de deletar
    final existingProfileResult = await repository.getUserProfile(params.id);
    
    return existingProfileResult.fold(
      (failure) => Left(failure),
      (existingProfile) {
        // Perfil existe, proceder com a remoção
        return repository.deleteUserProfile(params.id);
      },
    );
  }
}

/// Parâmetros para o DeleteUserProfile use case
class DeleteUserProfileParams extends Equatable {
  final String id;

  const DeleteUserProfileParams({required this.id});

  @override
  List<Object> get props => [id];
}

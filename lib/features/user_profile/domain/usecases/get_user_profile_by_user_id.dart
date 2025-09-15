import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/core.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

/// Use case para buscar perfil de usuário pelo userId do Firebase Auth
class GetUserProfileByUserId extends UseCase<UserProfileEntity, GetUserProfileByUserIdParams> {
  final UserProfileRepository repository;

  GetUserProfileByUserId(this.repository);

  @override
  Future<Either<Failure, UserProfileEntity>> call(GetUserProfileByUserIdParams params) async {
    return await repository.getUserProfileByUserId(params.userId);
  }
}

/// Parâmetros para o GetUserProfileByUserId use case
class GetUserProfileByUserIdParams extends Equatable {
  final String userId;

  const GetUserProfileByUserIdParams({required this.userId});

  @override
  List<Object> get props => [userId];
}

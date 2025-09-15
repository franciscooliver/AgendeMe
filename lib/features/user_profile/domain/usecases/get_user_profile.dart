import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/core.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

/// Use case para buscar perfil de usuário por ID
class GetUserProfile extends UseCase<UserProfileEntity, GetUserProfileParams> {
  final UserProfileRepository repository;

  GetUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfileEntity>> call(GetUserProfileParams params) async {
    return await repository.getUserProfile(params.id);
  }
}

/// Parâmetros para o GetUserProfile use case
class GetUserProfileParams extends Equatable {
  final String id;

  const GetUserProfileParams({required this.id});

  @override
  List<Object> get props => [id];
}

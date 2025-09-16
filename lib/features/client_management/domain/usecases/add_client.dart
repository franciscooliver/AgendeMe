import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/core.dart';
import '../entities/client_entity.dart';
import '../repositories/client_repository.dart';

/// Use case para adicionar um novo cliente ao profissional
/// 
/// Este use case é utilizado principalmente durante o registro automático
/// quando um usuário faz seu primeiro agendamento com um profissional
class AddClient extends UseCase<ClientEntity, AddClientParams> {
  final ClientRepository repository;

  AddClient(this.repository);

  @override
  Future<Either<Failure, ClientEntity>> call(AddClientParams params) async {
    return await repository.addClient(params.client);
  }
}

/// Parâmetros para o AddClient use case
class AddClientParams extends Equatable {
  final ClientEntity client;

  const AddClientParams({required this.client});

  @override
  List<Object> get props => [client];
}

import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';
import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

/// Use case para criação de agendamentos
/// 
/// Orquestra a criação de um novo agendamento validando
/// os dados e persistindo no repositório
class CreateAppointmentUseCase extends UseCase<AppointmentEntity, CreateAppointmentParams> {
  final AppointmentRepository _repository;

  CreateAppointmentUseCase({
    required AppointmentRepository repository,
  }) : _repository = repository;

  @override
  Future<Either<Failure, AppointmentEntity>> call(CreateAppointmentParams params) async {
    try {
      // Validar parâmetros
      final validationResult = _validateParams(params);
      if (validationResult != null) {
        return Left(ValidationFailure(message: validationResult));
      }

      // Verificar conflitos de horário
      final conflictResult = await _repository.hasTimeConflict(
        params.professionalId,
        params.appointmentDateTime,
        params.duration,
      );

      return conflictResult.fold(
        (failure) => Left(failure),
        (hasConflict) {
          if (hasConflict) {
            return Left(ValidationFailure(
              message: 'Horário não disponível. Por favor, selecione outro horário.',
            ));
          }

          // Criar entidade do agendamento
          final appointment = AppointmentEntity(
            id: '', // Será definido pelo repositório
            professionalId: params.professionalId,
            clientId: params.clientId,
            serviceId: params.serviceId,
            appointmentDateTime: params.appointmentDateTime,
            price: params.price,
            estimatedDuration: params.duration,
            status: AppointmentStatus.pending,
            notes: params.notes,
            clientNotes: params.clientNotes,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // Persistir no repositório
          return _repository.createAppointment(appointment);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Erro interno ao criar agendamento: $e'));
    }
  }

  /// Valida os parâmetros de entrada
  String? _validateParams(CreateAppointmentParams params) {
    if (params.professionalId.isEmpty) {
      return 'ID do profissional é obrigatório';
    }

    if (params.clientId.isEmpty) {
      return 'ID do cliente é obrigatório';
    }

    if (params.serviceId.isEmpty) {
      return 'ID do serviço é obrigatório';
    }

    if (params.appointmentDateTime.isBefore(DateTime.now())) {
      return 'Data e hora do agendamento devem ser futuras';
    }

    if (params.price < 0) {
      return 'Preço deve ser maior ou igual a zero';
    }

    if (params.duration <= 0) {
      return 'Duração deve ser maior que zero';
    }

    return null;
  }
}

/// Parâmetros para criação de agendamento
class CreateAppointmentParams {
  /// ID do profissional
  final String professionalId;

  /// ID do cliente
  final String clientId;

  /// ID do serviço
  final String serviceId;

  /// Data e hora do agendamento
  final DateTime appointmentDateTime;

  /// Preço do serviço
  final double price;

  /// Duração estimada em minutos
  final int duration;

  /// Observações gerais
  final String? notes;

  /// Observações específicas do cliente
  final String? clientNotes;

  const CreateAppointmentParams({
    required this.professionalId,
    required this.clientId,
    required this.serviceId,
    required this.appointmentDateTime,
    required this.price,
    required this.duration,
    this.notes,
    this.clientNotes,
  });

  @override
  String toString() {
    return 'CreateAppointmentParams(professionalId: $professionalId, '
           'clientId: $clientId, serviceId: $serviceId, '
           'appointmentDateTime: $appointmentDateTime, price: $price, '
           'duration: $duration)';
  }
}

import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_datasource.dart';
import '../models/appointment_model.dart';

/// Implementação do repositório de agendamentos
/// 
/// Responsável por coordenar as operações de dados entre
/// as fontes remotas e locais, aplicando regras de negócio
class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AppointmentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AppointmentEntity>> getAppointment(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final appointment = await remoteDataSource.getAppointment(id);
        return Right(appointment);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao buscar agendamento: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> createAppointment(
    AppointmentEntity appointment,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final appointmentModel = AppointmentModel.fromEntity(appointment);
        final createdAppointment = await remoteDataSource.createAppointment(appointmentModel);
        return Right(createdAppointment);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao criar agendamento: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> updateAppointment(
    AppointmentEntity appointment,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final appointmentModel = AppointmentModel.fromEntity(appointment);
        final updatedAppointment = await remoteDataSource.updateAppointment(appointmentModel);
        return Right(updatedAppointment);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao atualizar agendamento: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAppointment(
    String id, {
    String? reason,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteAppointment(id, reason: reason);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao cancelar agendamento: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> permanentDeleteAppointment(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.permanentDeleteAppointment(id);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao remover agendamento: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getAppointmentsByProfessional(
    String professionalId, {
    bool includeFinished = false,
    int limit = 20,
    int offset = 0,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final appointments = await remoteDataSource.getAppointmentsByProfessional(
          professionalId,
          includeFinished: includeFinished,
          limit: limit,
          offset: offset,
        );
        return Right(appointments);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao buscar agendamentos do profissional: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getAppointmentsByClient(
    String clientId, {
    bool includeFinished = false,
    int limit = 20,
    int offset = 0,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final appointments = await remoteDataSource.getAppointmentsByClient(
          clientId,
          includeFinished: includeFinished,
          limit: limit,
          offset: offset,
        );
        return Right(appointments);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao buscar agendamentos do cliente: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getAppointmentsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? professionalId,
    String? clientId,
    bool includeFinished = false,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final appointments = await remoteDataSource.getAppointmentsByDateRange(
          startDate,
          endDate,
          professionalId: professionalId,
          clientId: clientId,
          includeFinished: includeFinished,
        );
        return Right(appointments);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao buscar agendamentos por período: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getAppointmentsByStatus(
    AppointmentStatus status, {
    String? professionalId,
    String? clientId,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final appointments = await remoteDataSource.getAppointmentsByStatus(
          status,
          professionalId: professionalId,
          clientId: clientId,
          limit: limit,
        );
        return Right(appointments);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao buscar agendamentos por status: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getUpcomingAppointments(
    String userId, {
    required bool isProfessional,
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final appointments = await remoteDataSource.getUpcomingAppointments(
          userId,
          isProfessional: isProfessional,
          limit: limit,
        );
        return Right(appointments);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao buscar próximos agendamentos: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getTodayAppointments(
    String professionalId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final appointments = await remoteDataSource.getTodayAppointments(professionalId);
        return Right(appointments);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao buscar agendamentos de hoje: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getWeekAppointments(
    DateTime startOfWeek, {
    String? professionalId,
    String? clientId,
  }) async {
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    
    return await getAppointmentsByDateRange(
      startOfWeek,
      endOfWeek,
      professionalId: professionalId,
      clientId: clientId,
    );
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getMonthAppointments(
    int year,
    int month, {
    String? professionalId,
    String? clientId,
  }) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);
    
    return await getAppointmentsByDateRange(
      startOfMonth,
      endOfMonth,
      professionalId: professionalId,
      clientId: clientId,
    );
  }

  @override
  Future<Either<Failure, bool>> hasTimeConflict(
    String professionalId,
    DateTime appointmentDateTime,
    int duration, {
    String? excludeAppointmentId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final hasConflict = await remoteDataSource.hasTimeConflict(
          professionalId,
          appointmentDateTime,
          duration,
          excludeAppointmentId: excludeAppointmentId,
        );
        return Right(hasConflict);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao verificar conflito: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, List<DateTime>>> getAvailableTimeSlots(
    String professionalId,
    DateTime date,
    int serviceDuration, {
    required String workingHoursStart,
    required String workingHoursEnd,
    int intervalMinutes = 30,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final availableSlots = await remoteDataSource.getAvailableTimeSlots(
          professionalId,
          date,
          serviceDuration,
          workingHoursStart: workingHoursStart,
          workingHoursEnd: workingHoursEnd,
          intervalMinutes: intervalMinutes,
        );
        return Right(availableSlots);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao buscar horários disponíveis: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> confirmAppointment(
    String appointmentId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final appointment = await remoteDataSource.confirmAppointment(appointmentId);
        return Right(appointment);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao confirmar agendamento: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> cancelAppointment(
    String appointmentId,
    String reason, {
    required String cancelledBy,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final appointment = await remoteDataSource.cancelAppointment(
          appointmentId,
          reason,
          cancelledBy: cancelledBy,
        );
        return Right(appointment);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao cancelar agendamento: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> completeAppointment(
    String appointmentId, {
    String? professionalNotes,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final appointment = await remoteDataSource.completeAppointment(
          appointmentId,
          professionalNotes: professionalNotes,
        );
        return Right(appointment);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao concluir agendamento: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> markAsNoShow(String appointmentId) async {
    if (await networkInfo.isConnected) {
      try {
        final appointment = await remoteDataSource.markAsNoShow(appointmentId);
        return Right(appointment);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao marcar falta: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> rescheduleAppointment(
    String appointmentId,
    DateTime newDateTime, {
    String? reason,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final appointment = await remoteDataSource.rescheduleAppointment(
          appointmentId,
          newDateTime,
          reason: reason,
        );
        return Right(appointment);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao reagendar: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, AppointmentStatistics>> getAppointmentStatistics(
    String professionalId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final statistics = await remoteDataSource.getAppointmentStatistics(
          professionalId,
          startDate: startDate,
          endDate: endDate,
        );
        return Right(statistics);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao obter estatísticas: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, bool>> appointmentExists(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final exists = await remoteDataSource.appointmentExists(id);
        return Right(exists);
      } catch (e) {
        return Left(ServerFailure(message: 'Erro ao verificar agendamento: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'Sem conexão com a internet'));
    }
  }
}

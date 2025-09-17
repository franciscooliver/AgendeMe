import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/appointment_model.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';

/// Interface abstrata para data source remoto de agendamentos
abstract class AppointmentRemoteDataSource {
  Future<AppointmentModel> getAppointment(String id);
  
  Future<AppointmentModel> createAppointment(AppointmentModel appointment);
  
  Future<AppointmentModel> updateAppointment(AppointmentModel appointment);
  
  Future<void> deleteAppointment(String id, {String? reason});
  
  Future<void> permanentDeleteAppointment(String id);
  
  Future<List<AppointmentModel>> getAppointmentsByProfessional(
    String professionalId, {
    bool includeFinished = false,
    int limit = 20,
    int offset = 0,
  });
  
  Future<List<AppointmentModel>> getAppointmentsByClient(
    String clientId, {
    bool includeFinished = false,
    int limit = 20,
    int offset = 0,
  });

  Future<List<AppointmentModel>> getHistoricalAppointmentsByClient(
    String clientId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  });
  
  Future<List<AppointmentModel>> getAppointmentsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? professionalId,
    String? clientId,
    bool includeFinished = false,
  });
  
  Future<List<AppointmentModel>> getAppointmentsByStatus(
    AppointmentStatus status, {
    String? professionalId,
    String? clientId,
    int limit = 20,
  });
  
  Future<List<AppointmentModel>> getUpcomingAppointments(
    String userId, {
    required bool isProfessional,
    int limit = 10,
  });
  
  Future<List<AppointmentModel>> getTodayAppointments(String professionalId);
  
  Future<bool> hasTimeConflict(
    String professionalId,
    DateTime appointmentDateTime,
    int duration, {
    String? excludeAppointmentId,
  });
  
  Future<List<DateTime>> getAvailableTimeSlots(
    String professionalId,
    DateTime date,
    int serviceDuration, {
    required String workingHoursStart,
    required String workingHoursEnd,
    int intervalMinutes = 30,
  });
  
  Future<AppointmentModel> confirmAppointment(String appointmentId);
  
  Future<AppointmentModel> cancelAppointment(
    String appointmentId,
    String reason, {
    required String cancelledBy,
  });
  
  Future<AppointmentModel> completeAppointment(
    String appointmentId, {
    String? professionalNotes,
  });
  
  Future<AppointmentModel> markAsNoShow(String appointmentId);
  
  Future<AppointmentModel> rescheduleAppointment(
    String appointmentId,
    DateTime newDateTime, {
    String? reason,
  });
  
  Future<AppointmentStatistics> getAppointmentStatistics(
    String professionalId, {
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<bool> appointmentExists(String id);
}

/// Implementação do data source remoto usando Firestore
class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final FirebaseFirestore _firestore;
  
  // Collection do Firestore
  static const String _appointmentsCollection = 'appointments';

  AppointmentRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<AppointmentModel> getAppointment(String id) async {
    try {
      final doc = await _firestore
          .collection(_appointmentsCollection)
          .doc(id)
          .get();

      if (!doc.exists) {
        throw Exception('Agendamento não encontrado');
      }

      return AppointmentModel.fromDocumentSnapshot(doc);
    } catch (e) {
      throw Exception('Erro ao buscar agendamento: $e');
    }
  }

  @override
  Future<AppointmentModel> createAppointment(AppointmentModel appointment) async {
    try {
      final appointmentRef = _firestore.collection(_appointmentsCollection).doc();
      final appointmentWithId = appointment.copyWith(id: appointmentRef.id);
      
      await appointmentRef.set(appointmentWithId.toFirestore());
      
      return appointmentWithId;
    } catch (e) {
      throw Exception('Erro ao criar agendamento: $e');
    }
  }

  @override
  Future<AppointmentModel> updateAppointment(AppointmentModel appointment) async {
    try {
      final updateData = appointment.toFirestore();
      updateData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointment.id)
          .update(updateData);

      return appointment.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      throw Exception('Erro ao atualizar agendamento: $e');
    }
  }

  @override
  Future<void> deleteAppointment(String id, {String? reason}) async {
    try {
      await _firestore
          .collection(_appointmentsCollection)
          .doc(id)
          .update({
        'status': AppointmentStatus.cancelled.value,
        'cancellation_reason': reason,
        'cancelled_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao cancelar agendamento: $e');
    }
  }

  @override
  Future<void> permanentDeleteAppointment(String id) async {
    try {
      await _firestore
          .collection(_appointmentsCollection)
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Erro ao remover agendamento permanentemente: $e');
    }
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsByProfessional(
    String professionalId, {
    bool includeFinished = false,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      Query query = _firestore
          .collection(_appointmentsCollection)
          .where('professional_id', isEqualTo: professionalId)
          .orderBy('appointment_date_time', descending: false);

      if (!includeFinished) {
        query = query.where('status', whereIn: [
          AppointmentStatus.pending.value,
          AppointmentStatus.confirmed.value,
          AppointmentStatus.inProgress.value,
        ]);
      }

      final querySnapshot = await query
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar agendamentos do profissional: $e');
    }
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsByClient(
    String clientId, {
    bool includeFinished = false,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      Query query = _firestore
          .collection(_appointmentsCollection)
          .where('client_id', isEqualTo: clientId)
          .orderBy('appointment_date_time', descending: false);

      if (!includeFinished) {
        query = query.where('status', whereIn: [
          AppointmentStatus.pending.value,
          AppointmentStatus.confirmed.value,
          AppointmentStatus.inProgress.value,
        ]);
      }

      final querySnapshot = await query
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar agendamentos do cliente: $e');
    }
  }

  @override
  Future<List<AppointmentModel>> getHistoricalAppointmentsByClient(
    String clientId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      print('🔍 DEBUG: Buscando histórico de agendamentos para cliente: $clientId');
      print('🔍 DEBUG: Período: $startDate até $endDate');
      
      // Query simplificada - apenas por client_id para evitar problemas de índice
      Query query = _firestore
          .collection(_appointmentsCollection)
          .where('client_id', isEqualTo: clientId);

      final querySnapshot = await query
          .limit(limit * 2) // Buscar mais para compensar filtros locais
          .get();

      // Filtrar localmente para evitar problemas de índice
      final allAppointments = querySnapshot.docs
          .map((doc) => AppointmentModel.fromDocumentSnapshot(doc))
          .toList();

      // Filtrar por status histórico
      final historicalAppointments = allAppointments.where((appointment) {
        final isHistorical = appointment.status == AppointmentStatus.completed ||
                            appointment.status == AppointmentStatus.cancelled ||
                            appointment.status == AppointmentStatus.noShow;
        
        // Aplicar filtro de data se fornecido
        if (startDate != null && appointment.appointmentDateTime.isBefore(startDate)) {
          return false;
        }
        
        if (endDate != null && appointment.appointmentDateTime.isAfter(endDate)) {
          return false;
        }
        
        return isHistorical;
      }).toList();

      // Ordenar por data (mais recentes primeiro)
      historicalAppointments.sort((a, b) => b.appointmentDateTime.compareTo(a.appointmentDateTime));

      // Limitar resultados
      final limitedAppointments = historicalAppointments.take(limit).toList();

      print('🔍 DEBUG: Agendamentos históricos encontrados: ${limitedAppointments.length}');
      
      return limitedAppointments;
    } catch (e) {
      print('❌ DEBUG: Erro ao buscar histórico: $e');
      throw Exception('Erro ao buscar histórico de agendamentos: $e');
    }
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? professionalId,
    String? clientId,
    bool includeFinished = false,
  }) async {
    try {
      Query query = _firestore
          .collection(_appointmentsCollection)
          .where('appointment_date_time', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('appointment_date_time', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('appointment_date_time', descending: false);

      if (professionalId != null) {
        query = query.where('professional_id', isEqualTo: professionalId);
      }

      if (clientId != null) {
        query = query.where('client_id', isEqualTo: clientId);
      }

      if (!includeFinished) {
        query = query.where('status', whereIn: [
          AppointmentStatus.pending.value,
          AppointmentStatus.confirmed.value,
          AppointmentStatus.inProgress.value,
        ]);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar agendamentos por período: $e');
    }
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsByStatus(
    AppointmentStatus status, {
    String? professionalId,
    String? clientId,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_appointmentsCollection)
          .where('status', isEqualTo: status.value)
          .orderBy('appointment_date_time', descending: false);

      if (professionalId != null) {
        query = query.where('professional_id', isEqualTo: professionalId);
      }

      if (clientId != null) {
        query = query.where('client_id', isEqualTo: clientId);
      }

      final querySnapshot = await query
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar agendamentos por status: $e');
    }
  }

  @override
  Future<List<AppointmentModel>> getUpcomingAppointments(
    String userId, {
    required bool isProfessional,
    int limit = 10,
  }) async {
    try {
      final now = DateTime.now();
      final field = isProfessional ? 'professional_id' : 'client_id';
      
      final querySnapshot = await _firestore
          .collection(_appointmentsCollection)
          .where(field, isEqualTo: userId)
          .where('appointment_date_time', isGreaterThan: Timestamp.fromDate(now))
          .where('status', whereIn: [
            AppointmentStatus.pending.value,
            AppointmentStatus.confirmed.value,
          ])
          .orderBy('appointment_date_time', descending: false)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar próximos agendamentos: $e');
    }
  }

  @override
  Future<List<AppointmentModel>> getTodayAppointments(String professionalId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection(_appointmentsCollection)
          .where('professional_id', isEqualTo: professionalId)
          .where('appointment_date_time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('appointment_date_time', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('appointment_date_time', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar agendamentos de hoje: $e');
    }
  }

  @override
  Future<bool> hasTimeConflict(
    String professionalId,
    DateTime appointmentDateTime,
    int duration, {
    String? excludeAppointmentId,
  }) async {
    try {
      final startTime = appointmentDateTime;
      final endTime = appointmentDateTime.add(Duration(minutes: duration));

      Query query = _firestore
          .collection(_appointmentsCollection)
          .where('professional_id', isEqualTo: professionalId)
          .where('status', whereIn: [
            AppointmentStatus.pending.value,
            AppointmentStatus.confirmed.value,
            AppointmentStatus.inProgress.value,
          ]);

      if (excludeAppointmentId != null) {
        // Não é possível usar whereNotEqualTo diretamente no Firestore
        // Vamos fazer a verificação após buscar os resultados
      }

      final querySnapshot = await query.get();

      for (final doc in querySnapshot.docs) {
        if (excludeAppointmentId != null && doc.id == excludeAppointmentId) {
          continue;
        }

        final appointment = AppointmentModel.fromDocumentSnapshot(doc);
        final existingStart = appointment.appointmentDateTime;
        final existingEnd = existingStart.add(Duration(minutes: appointment.estimatedDuration));

        // Verifica sobreposição de horários
        if (startTime.isBefore(existingEnd) && endTime.isAfter(existingStart)) {
          return true; // Há conflito
        }
      }

      return false; // Não há conflito
    } catch (e) {
      throw Exception('Erro ao verificar conflito de horário: $e');
    }
  }

  @override
  Future<List<DateTime>> getAvailableTimeSlots(
    String professionalId,
    DateTime date,
    int serviceDuration, {
    required String workingHoursStart,
    required String workingHoursEnd,
    int intervalMinutes = 30,
  }) async {
    try {
      // Parse working hours
      final startHour = int.parse(workingHoursStart.split(':')[0]);
      final startMinute = int.parse(workingHoursStart.split(':')[1]);
      final endHour = int.parse(workingHoursEnd.split(':')[0]);
      final endMinute = int.parse(workingHoursEnd.split(':')[1]);

      final workStart = DateTime(date.year, date.month, date.day, startHour, startMinute);
      final workEnd = DateTime(date.year, date.month, date.day, endHour, endMinute);

      // Buscar agendamentos existentes do dia
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection(_appointmentsCollection)
          .where('professional_id', isEqualTo: professionalId)
          .where('appointment_date_time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('appointment_date_time', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('status', whereIn: [
            AppointmentStatus.pending.value,
            AppointmentStatus.confirmed.value,
            AppointmentStatus.inProgress.value,
          ])
          .get();

      final existingAppointments = querySnapshot.docs
          .map((doc) => AppointmentModel.fromDocumentSnapshot(doc))
          .toList();

      // Gerar todos os slots possíveis
      final availableSlots = <DateTime>[];
      DateTime currentSlot = workStart;

      while (currentSlot.add(Duration(minutes: serviceDuration)).isBefore(workEnd) ||
             currentSlot.add(Duration(minutes: serviceDuration)).isAtSameMomentAs(workEnd)) {
        
        final slotEnd = currentSlot.add(Duration(minutes: serviceDuration));
        bool hasConflict = false;

        // Verificar conflito com agendamentos existentes
        for (final appointment in existingAppointments) {
          final existingStart = appointment.appointmentDateTime;
          final existingEnd = existingStart.add(Duration(minutes: appointment.estimatedDuration));

          if (currentSlot.isBefore(existingEnd) && slotEnd.isAfter(existingStart)) {
            hasConflict = true;
            break;
          }
        }

        if (!hasConflict) {
          availableSlots.add(currentSlot);
        }

        currentSlot = currentSlot.add(Duration(minutes: intervalMinutes));
      }

      return availableSlots;
    } catch (e) {
      throw Exception('Erro ao buscar horários disponíveis: $e');
    }
  }

  @override
  Future<AppointmentModel> confirmAppointment(String appointmentId) async {
    try {
      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointmentId)
          .update({
        'status': AppointmentStatus.confirmed.value,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return await getAppointment(appointmentId);
    } catch (e) {
      throw Exception('Erro ao confirmar agendamento: $e');
    }
  }

  @override
  Future<AppointmentModel> cancelAppointment(
    String appointmentId,
    String reason, {
    required String cancelledBy,
  }) async {
    try {
      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointmentId)
          .update({
        'status': AppointmentStatus.cancelled.value,
        'cancellation_reason': reason,
        'cancelled_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return await getAppointment(appointmentId);
    } catch (e) {
      throw Exception('Erro ao cancelar agendamento: $e');
    }
  }

  @override
  Future<AppointmentModel> completeAppointment(
    String appointmentId, {
    String? professionalNotes,
  }) async {
    try {
      final updateData = {
        'status': AppointmentStatus.completed.value,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (professionalNotes != null) {
        updateData['professional_notes'] = professionalNotes;
      }

      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointmentId)
          .update(updateData);

      return await getAppointment(appointmentId);
    } catch (e) {
      throw Exception('Erro ao concluir agendamento: $e');
    }
  }

  @override
  Future<AppointmentModel> markAsNoShow(String appointmentId) async {
    try {
      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointmentId)
          .update({
        'status': AppointmentStatus.noShow.value,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return await getAppointment(appointmentId);
    } catch (e) {
      throw Exception('Erro ao marcar como falta: $e');
    }
  }

  @override
  Future<AppointmentModel> rescheduleAppointment(
    String appointmentId,
    DateTime newDateTime, {
    String? reason,
  }) async {
    try {
      final updateData = {
        'appointment_date_time': Timestamp.fromDate(newDateTime),
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (reason != null) {
        updateData['notes'] = reason;
      }

      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointmentId)
          .update(updateData);

      return await getAppointment(appointmentId);
    } catch (e) {
      throw Exception('Erro ao reagendar: $e');
    }
  }

  @override
  Future<AppointmentStatistics> getAppointmentStatistics(
    String professionalId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection(_appointmentsCollection)
          .where('professional_id', isEqualTo: professionalId);

      if (startDate != null) {
        query = query.where('appointment_date_time', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('appointment_date_time', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final querySnapshot = await query.get();
      final appointments = querySnapshot.docs
          .map((doc) => AppointmentModel.fromDocumentSnapshot(doc))
          .toList();

      // Calcular estatísticas
      int totalAppointments = appointments.length;
      int pendingAppointments = 0;
      int confirmedAppointments = 0;
      int completedAppointments = 0;
      int cancelledAppointments = 0;
      int noShowAppointments = 0;
      double totalRevenue = 0.0;

      final appointmentsByStatus = <String, int>{};
      final appointmentsByDay = <String, int>{};
      final revenueByMonth = <String, double>{};

      DateTime? lastAppointmentDate;
      DateTime? nextAppointmentDate;
      final now = DateTime.now();

      for (final appointment in appointments) {
        // Contadores por status
        switch (appointment.status) {
          case AppointmentStatus.pending:
            pendingAppointments++;
            break;
          case AppointmentStatus.confirmed:
            confirmedAppointments++;
            break;
          case AppointmentStatus.completed:
            completedAppointments++;
            totalRevenue += appointment.price;
            break;
          case AppointmentStatus.cancelled:
            cancelledAppointments++;
            break;
          case AppointmentStatus.noShow:
            noShowAppointments++;
            break;
          case AppointmentStatus.inProgress:
            confirmedAppointments++;
            break;
        }

        // Estatísticas por status
        final statusKey = appointment.status.description;
        appointmentsByStatus[statusKey] = (appointmentsByStatus[statusKey] ?? 0) + 1;

        // Estatísticas por dia da semana
        final dayOfWeek = _getDayOfWeekName(appointment.appointmentDateTime.weekday);
        appointmentsByDay[dayOfWeek] = (appointmentsByDay[dayOfWeek] ?? 0) + 1;

        // Receita por mês
        final monthKey = '${appointment.appointmentDateTime.year}-${appointment.appointmentDateTime.month.toString().padLeft(2, '0')}';
        if (appointment.status == AppointmentStatus.completed) {
          revenueByMonth[monthKey] = (revenueByMonth[monthKey] ?? 0.0) + appointment.price;
        }

        // Última data de agendamento
        if (appointment.appointmentDateTime.isBefore(now) &&
            (lastAppointmentDate == null || appointment.appointmentDateTime.isAfter(lastAppointmentDate))) {
          lastAppointmentDate = appointment.appointmentDateTime;
        }

        // Próxima data de agendamento
        if (appointment.appointmentDateTime.isAfter(now) &&
            appointment.status != AppointmentStatus.cancelled &&
            (nextAppointmentDate == null || appointment.appointmentDateTime.isBefore(nextAppointmentDate))) {
          nextAppointmentDate = appointment.appointmentDateTime;
        }
      }

      final averageRevenue = totalAppointments > 0 ? totalRevenue / totalAppointments : 0.0;

      return AppointmentStatistics(
        totalAppointments: totalAppointments,
        pendingAppointments: pendingAppointments,
        confirmedAppointments: confirmedAppointments,
        completedAppointments: completedAppointments,
        cancelledAppointments: cancelledAppointments,
        noShowAppointments: noShowAppointments,
        totalRevenue: totalRevenue,
        averageRevenue: averageRevenue,
        appointmentsByStatus: appointmentsByStatus,
        appointmentsByDay: appointmentsByDay,
        revenueByMonth: revenueByMonth,
        lastAppointmentDate: lastAppointmentDate,
        nextAppointmentDate: nextAppointmentDate,
      );
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }

  @override
  Future<bool> appointmentExists(String id) async {
    try {
      final doc = await _firestore
          .collection(_appointmentsCollection)
          .doc(id)
          .get();

      return doc.exists;
    } catch (e) {
      throw Exception('Erro ao verificar se agendamento existe: $e');
    }
  }

  String _getDayOfWeekName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Segunda';
      case 2:
        return 'Terça';
      case 3:
        return 'Quarta';
      case 4:
        return 'Quinta';
      case 5:
        return 'Sexta';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return 'Desconhecido';
    }
  }
}

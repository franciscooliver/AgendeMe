import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/professional_availability_controller.dart';
import '../../domain/entities/available_time_slot_entity.dart';

/// Widget para exibir os horários disponíveis
class AvailableSlotsWidget extends StatelessWidget {
  final ProfessionalAvailabilityController controller;

  const AvailableSlotsWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção
          Row(
            children: [
              Text(
                'Horários Disponíveis',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (controller.isLoadingSlots)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Conteúdo dos slots
          Expanded(
            child: Obx(() {
              if (controller.isLoadingSlots) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.errorMessage.isNotEmpty) {
                return _buildErrorState(context);
              }

              if (!controller.hasAvailableSlots) {
                return _buildNoSlotsState(context);
              }

              return _buildSlotsList(context);
            }),
          ),
        ],
      ),
    );
  }

  /// Lista de slots disponíveis
  Widget _buildSlotsList(BuildContext context) {
    final groupedSlots = controller.groupedSlots;
    
    return ListView.builder(
      itemCount: groupedSlots.length,
      itemBuilder: (context, index) {
        final period = groupedSlots.keys.elementAt(index);
        final slots = groupedSlots[period]!;
        
        return _buildPeriodSection(context, period, slots);
      },
    );
  }

  /// Seção de um período do dia
  Widget _buildPeriodSection(BuildContext context, String period, List<AvailableTimeSlotEntity> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho do período
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _getPeriodColor(period).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                _getPeriodIcon(period),
                size: 16,
                color: _getPeriodColor(period),
              ),
              const SizedBox(width: 8),
              Text(
                period,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: _getPeriodColor(period),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${slots.length} horário(s)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _getPeriodColor(period).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Grid de slots
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            return _buildSlotChip(context, slot);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Chip de um slot de tempo
  Widget _buildSlotChip(BuildContext context, AvailableTimeSlotEntity slot) {
    final isPast = slot.isPast;
    final isToday = slot.isToday;
    final isTomorrow = slot.isTomorrow;
    
    return GestureDetector(
      onTap: isPast ? null : () => controller.selectTimeSlot(slot),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isPast 
              ? Colors.grey[200]
              : Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isPast 
                ? Colors.grey[300]!
                : Theme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              slot.formattedTime,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isPast 
                    ? Colors.grey[500]
                    : Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isToday || isTomorrow) ...[
              const SizedBox(height: 2),
              Text(
                isToday ? 'Hoje' : 'Amanhã',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isPast 
                      ? Colors.grey[400]
                      : Theme.of(context).primaryColor.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Estado quando não há slots disponíveis
  Widget _buildNoSlotsState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum horário disponível',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.noSlotsMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Atualizar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado de erro
  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar horários',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  /// Retorna a cor para um período do dia
  Color _getPeriodColor(String period) {
    switch (period) {
      case 'Manhã':
        return Colors.orange;
      case 'Tarde':
        return Colors.blue;
      case 'Noite':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// Retorna o ícone para um período do dia
  IconData _getPeriodIcon(String period) {
    switch (period) {
      case 'Manhã':
        return Icons.wb_sunny;
      case 'Tarde':
        return Icons.wb_sunny_outlined;
      case 'Noite':
        return Icons.nights_stay;
      default:
        return Icons.schedule;
    }
  }
}

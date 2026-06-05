import 'package:flutter/material.dart';
import '../models/time_slot.dart';
import '../utils/constants.dart';

class TimeSlotPicker extends StatelessWidget {
  final List<TimeSlot> slots;
  final TimeSlot? selectedSlot;
  final ValueChanged<TimeSlot> onSelect;

  const TimeSlotPicker({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.access_time, color: AppColors.textSecondary, size: 32),
              SizedBox(height: 8),
              Text('No time slots available right now',
                  style: TextStyle(color: AppColors.textSecondary)),
              SizedBox(height: 4),
              Text('The canteen may be closed for today',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Each slot is 30 min. Max 30 orders per slot. Slots close 15 min before.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          // Slots grid
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slots.map((slot) {
                final isSelected = selectedSlot?.startTime == slot.startTime;
                final isDisabled = !slot.isAvailable || slot.isFull;

                return GestureDetector(
                  onTap: isDisabled ? null : () => onSelect(slot),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isDisabled ? Colors.grey.shade100 : Colors.white),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDisabled ? Colors.grey.shade200 : Colors.grey.shade300),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          slot.shortLabel,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            fontSize: 13,
                            color: isSelected
                                ? Colors.white
                                : (isDisabled ? Colors.grey : AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          slot.isFull ? 'Full' : '${slot.remainingSpots} left',
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? Colors.white70
                                : (slot.isFull ? AppColors.error : AppColors.success),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

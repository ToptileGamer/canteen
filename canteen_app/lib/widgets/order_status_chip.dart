import 'package:flutter/material.dart';
import '../models/order.dart';
import '../utils/constants.dart';

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor().withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(), size: 14, color: _color()),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _color(),
            ),
          ),
        ],
      ),
    );
  }

  Color _color() {
    switch (status) {
      case OrderStatus.paidPendingApproval: return AppColors.pending;
      case OrderStatus.preparing: return AppColors.preparing;
      case OrderStatus.readyForPickup: return AppColors.ready;
      case OrderStatus.completed: return AppColors.completed;
      case OrderStatus.cancelled: return AppColors.error;
    }
  }

  Color _bgColor() {
    switch (status) {
      case OrderStatus.paidPendingApproval: return AppColors.pending;
      case OrderStatus.preparing: return AppColors.preparing;
      case OrderStatus.readyForPickup: return AppColors.ready;
      case OrderStatus.completed: return AppColors.completed;
      case OrderStatus.cancelled: return AppColors.error;
    }
  }

  IconData _icon() {
    switch (status) {
      case OrderStatus.paidPendingApproval: return Icons.payment;
      case OrderStatus.preparing: return Icons.restaurant;
      case OrderStatus.readyForPickup: return Icons.check_circle_outline;
      case OrderStatus.completed: return Icons.done_all;
      case OrderStatus.cancelled: return Icons.cancel;
    }
  }
}

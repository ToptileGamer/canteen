import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadActiveOrders();
    });
  }

  Future<void> _updateStatus(String orderId, OrderStatus newStatus) async {
    final success = await context.read<OrderProvider>().updateOrderStatus(orderId, newStatus);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Order updated' : 'Failed to update order'),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return RefreshIndicator(
      onRefresh: () => orderProvider.loadActiveOrders(),
      color: AppColors.primary,
      child: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : (orderProvider.pendingOrders.isEmpty &&
                  orderProvider.preparingOrders.isEmpty &&
                  orderProvider.readyOrders.isEmpty)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No active orders',
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
                      const SizedBox(height: 8),
                      Text('New orders will appear here automatically!',
                          style: TextStyle(color: Colors.grey.shade400)),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Pending column
                    if (orderProvider.pendingOrders.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Pending Approval',
                        count: orderProvider.pendingOrders.length,
                        color: AppColors.pending,
                        icon: Icons.payment,
                      ),
                      const SizedBox(height: 8),
                      ...orderProvider.pendingOrders.map((order) =>
                          _OrderKanbanCard(
                            order: order,
                            primaryActionLabel: 'Accept & Prepare',
                            primaryActionColor: AppColors.success,
                            primaryIcon: Icons.check_circle,
                            onPrimary: () => _updateStatus(
                                order.id, OrderStatus.preparing),
                            secondaryActionLabel: 'Cancel',
                            secondaryActionColor: AppColors.error,
                            onSecondary: () => _updateStatus(
                                order.id, OrderStatus.cancelled),
                          )),
                      const SizedBox(height: 20),
                    ],

                    // Preparing column
                    if (orderProvider.preparingOrders.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Preparing',
                        count: orderProvider.preparingOrders.length,
                        color: AppColors.preparing,
                        icon: Icons.restaurant,
                      ),
                      const SizedBox(height: 8),
                      ...orderProvider.preparingOrders.map((order) =>
                          _OrderKanbanCard(
                            order: order,
                            primaryActionLabel: 'Ready for Pickup',
                            primaryActionColor: AppColors.ready,
                            primaryIcon: Icons.check_circle_outline,
                            onPrimary: () => _updateStatus(
                                order.id, OrderStatus.readyForPickup),
                          )),
                      const SizedBox(height: 20),
                    ],

                    // Ready column
                    if (orderProvider.readyOrders.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Ready for Pickup',
                        count: orderProvider.readyOrders.length,
                        color: AppColors.ready,
                        icon: Icons.check_circle,
                      ),
                      const SizedBox(height: 8),
                      ...orderProvider.readyOrders.map((order) =>
                          _OrderKanbanCard(
                            order: order,
                            primaryActionLabel: 'Mark Collected',
                            primaryActionColor: AppColors.completed,
                            primaryIcon: Icons.done_all,
                            onPrimary: () => _updateStatus(
                                order.id, OrderStatus.completed),
                          )),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$count',
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }
}

class _OrderKanbanCard extends StatelessWidget {
  final Order order;
  final String primaryActionLabel;
  final Color primaryActionColor;
  final IconData primaryIcon;
  final VoidCallback onPrimary;
  final String? secondaryActionLabel;
  final Color? secondaryActionColor;
  final VoidCallback? onSecondary;

  const _OrderKanbanCard({
    required this.order,
    required this.primaryActionLabel,
    required this.primaryActionColor,
    required this.primaryIcon,
    required this.onPrimary,
    this.secondaryActionLabel,
    this.secondaryActionColor,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(order.id.substring(0, 8),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, size: 12, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(order.pickupSlotLabel,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Items
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('${item.quantity}x', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(width: 8),
                      Text(item.menuItemName, style: const TextStyle(fontSize: 13)),
                      const Spacer(),
                      Text('₹${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                )),
            const SizedBox(height: 8),

            // Total
            Row(
              children: [
                const Spacer(),
                Text('Total: ₹${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 10),

            // Action buttons
            Row(
              children: [
                if (secondaryActionLabel != null && onSecondary != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSecondary,
                      icon: const Icon(Icons.close, size: 16),
                      label: Text(secondaryActionLabel!, style: const TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: secondaryActionColor,
                        side: BorderSide(color: secondaryActionColor!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                if (secondaryActionLabel != null) const SizedBox(width: 8),
                Expanded(
                  flex: secondaryActionLabel != null ? 2 : 1,
                  child: ElevatedButton.icon(
                    onPressed: onPrimary,
                    icon: Icon(primaryIcon, size: 16),
                    label: Text(primaryActionLabel, style: const TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryActionColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

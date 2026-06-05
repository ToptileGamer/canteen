import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return RefreshIndicator(
      onRefresh: () => orderProvider.loadAnalytics(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date header
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text('Today\'s Overview — ${_todayDate()}',
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ),

          // Stats cards row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.receipt_long,
                  label: 'Orders Fulfilled',
                  value: '${orderProvider.todayOrderCount}',
                  color: AppColors.success,
                  backgroundColor: AppColors.success.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.currency_rupee,
                  label: 'Total Revenue',
                  value: '₹${orderProvider.todayRevenue.toStringAsFixed(0)}',
                  color: AppColors.primary,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.pending_actions,
                  label: 'Pending',
                  value: '${orderProvider.pendingOrders.length}',
                  color: AppColors.pending,
                  backgroundColor: AppColors.pending.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.restaurant,
                  label: 'Preparing',
                  value: '${orderProvider.preparingOrders.length}',
                  color: AppColors.preparing,
                  backgroundColor: AppColors.preparing.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  label: 'Ready',
                  value: '${orderProvider.readyOrders.length}',
                  color: AppColors.ready,
                  backgroundColor: AppColors.ready.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.inventory,
                  label: 'Total Items',
                  value: '${orderProvider.activeOrders.fold(0, (sum, o) => sum + o.items.length)}',
                  color: AppColors.warning,
                  backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Active orders summary
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('Active Orders',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),

          if (orderProvider.activeOrders.isEmpty)
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No active orders',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            )
          else
            ...orderProvider.activeOrders.map((order) => Card(
                  elevation: 0,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('#${order.id.substring(0, 6)}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            order.items.map((i) => '${i.quantity}x ${i.menuItemName}').join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusBgColor(order.status),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(order.status.displayName,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _statusTextColor(order.status))),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  String _todayDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Color _statusBgColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.paidPendingApproval: return AppColors.pending.withValues(alpha: 0.1);
      case OrderStatus.preparing: return AppColors.preparing.withValues(alpha: 0.1);
      case OrderStatus.readyForPickup: return AppColors.ready.withValues(alpha: 0.1);
      default: return Colors.grey.shade100;
    }
  }

  Color _statusTextColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.paidPendingApproval: return AppColors.pending;
      case OrderStatus.preparing: return AppColors.preparing;
      case OrderStatus.readyForPickup: return AppColors.ready;
      default: return AppColors.textSecondary;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color backgroundColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

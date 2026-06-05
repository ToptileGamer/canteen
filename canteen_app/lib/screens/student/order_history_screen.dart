import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import 'order_tracking_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn) {
        context.read<OrderProvider>().loadUserOrders(auth.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();

    if (orderProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final orders = orderProvider.userOrders;

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No orders yet',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
            const SizedBox(height: 8),
            Text('Place your first order from the menu!',
                style: TextStyle(color: Colors.grey.shade400)),
          ],
        ),
      );
    }

    // Split into active and past
    final activeOrders = orders.where((o) =>
        o.status != OrderStatus.completed &&
        o.status != OrderStatus.cancelled).toList();
    final pastOrders = orders.where((o) =>
        o.status == OrderStatus.completed ||
        o.status == OrderStatus.cancelled).toList();

    return RefreshIndicator(
      onRefresh: () => orderProvider.loadUserOrders(auth.user!.id),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (activeOrders.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('Active Orders',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ...activeOrders.map((order) => _OrderCard(
                  order: order,
                  isActive: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OrderTrackingScreen(orderId: order.id),
                      ),
                    );
                  },
                )),
            const SizedBox(height: 24),
          ],

          if (pastOrders.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('Past Orders',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ...pastOrders.map((order) => _OrderCard(
                  order: order,
                  isActive: false,
                  onTap: () {},
                )),
          ],
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final bool isActive;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(order.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status.displayName,
                      style: TextStyle(
                        color: _statusColor(order.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text('#${order.id.substring(0, 10)}...',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                order.items.map((i) => '${i.quantity}x ${i.menuItemName}').join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(order.pickupSlotLabel,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const Spacer(),
                  Text('₹${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.paidPendingApproval: return AppColors.pending;
      case OrderStatus.preparing: return AppColors.preparing;
      case OrderStatus.readyForPickup: return AppColors.ready;
      case OrderStatus.completed: return AppColors.completed;
      case OrderStatus.cancelled: return AppColors.error;
    }
  }
}

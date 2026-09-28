import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification.dart';
import '../../providers/notification_provider.dart';
import '../../utils/constants.dart';
import '../student/order_tracking_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          TextButton.icon(
            onPressed: notifications.isEmpty
                ? null
                : () => context.read<NotificationProvider>().markAllRead(),
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text('Mark all read'),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No notifications yet',
                      style: TextStyle(
                          fontSize: 18, color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  Text('Updates about your orders appear here',
                      style: TextStyle(color: Colors.grey.shade400)),
                ],
              ),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                final userId = notifications.first.userId;
                await context.read<NotificationProvider>().load(userId);
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _NotificationCard(
                    notification: notification,
                    onTap: notification.orderId == null
                        ? null
                        : () {
                            context
                                .read<NotificationProvider>()
                                .markRead(notification.id);
                            if (notification.orderId != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OrderTrackingScreen(
                                      orderId: notification.orderId!),
                                ),
                              );
                            }
                          },
                  );
                },
              ),
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const _NotificationCard({required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isNewOrder = notification.type == 'new_order';
    final isStatus = notification.type == 'order_status';
    final icon = isNewOrder
        ? Icons.shopping_bag_outlined
        : isStatus
            ? Icons.takeout_dining_outlined
            : Icons.notifications_outlined;
    final color = isNewOrder
        ? AppColors.warning
        : isStatus
            ? AppColors.success
            : AppColors.primary;

    return Material(
      color: notification.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead
                  ? Colors.grey.shade200
                  : color.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (notification.body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _timeAgo(notification.createdAt),
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              if (notification.orderId != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.chevron_right,
                      color: Colors.grey.shade400, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
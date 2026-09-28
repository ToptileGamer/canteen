import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/notification.dart';
import '../services/local_notifier.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  RealtimeChannel? _channel;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> load(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _service.fetchForUser(userId);
      _refreshUnread();
    } catch (_) {
      // keep existing list on failure
    }
    _isLoading = false;
    notifyListeners();
  }

  void subscribe(String userId) {
    unsubscribe();
    try {
      final supabase = AppConfig.supabase;
      _channel = supabase
          .channel('notifications_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              if (payload.eventType == PostgresChangeEvent.insert) {
                final row = payload.newRecord;
                final notification = AppNotification(
                  id: row['id'],
                  userId: row['user_id'],
                  title: row['title'],
                  body: row['body'] ?? '',
                  type: row['type'] ?? 'general',
                  orderId: row['order_id'],
                  isRead: row['is_read'] ?? false,
                  createdAt: DateTime.parse(row['created_at']),
                );
                _notifications.insert(0, notification);
                if (_notifications.length > 50) _notifications.removeLast();
                _refreshUnread();
                LocalNotifier.show(
                  title: notification.title,
                  body: notification.body,
                );
              }
              load(userId);
            },
          )
          .subscribe();
    } catch (_) {
      // realtime unavailable (e.g. not initialized in tests)
    }
  }

  void unsubscribe() {
    try {
      _channel?.unsubscribe();
    } catch (_) {}
    _channel = null;
  }

  Future<void> markAllRead() async {
    _prepNotificationsForUpdate();
    if (_notifications.isEmpty) return;
    await _service.markAllRead(_notifications.first.userId);
  }

  Future<void> markRead(String notificationId) async {
    await _service.markRead(notificationId);
    final index =
        _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = AppNotification(
        id: _notifications[index].id,
        userId: _notifications[index].userId,
        title: _notifications[index].title,
        body: _notifications[index].body,
        type: _notifications[index].type,
        orderId: _notifications[index].orderId,
        isRead: true,
        createdAt: _notifications[index].createdAt,
      );
      _refreshUnread();
    }
  }

  void _refreshUnread() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  void _prepNotificationsForUpdate() {
    _notifications = _notifications
        .map((n) => n.isRead
            ? n
            : AppNotification(
                id: n.id,
                userId: n.userId,
                title: n.title,
                body: n.body,
                type: n.type,
                orderId: n.orderId,
                isRead: true,
                createdAt: n.createdAt,
              ))
        .toList();
    _refreshUnread();
    notifyListeners();
  }
}
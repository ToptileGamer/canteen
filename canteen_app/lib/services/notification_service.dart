import '../config/app_config.dart';
import '../models/notification.dart';

class NotificationService {
  Future<List<AppNotification>> fetchForUser(String userId) async {
    final supabase = AppConfig.supabase;
    final rows = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
    return rows.map(AppNotification.fromJson).toList();
  }

  Future<void> markAllRead(String userId) async {
    final supabase = AppConfig.supabase;
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  Future<void> markRead(String notificationId) async {
    final supabase = AppConfig.supabase;
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId)
        .eq('is_read', false);
  }
}
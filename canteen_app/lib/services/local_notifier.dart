import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/constants.dart';

/// Shows OS-level push notifications (Android / iOS / desktop) and in-app
/// banners. Falls back gracefully on web where OS push is not available.
class LocalNotifier {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized || kIsWeb) return;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    try {
      await _plugin.initialize(settings: settings);

      if (!kIsWeb) {
        final android =
            _plugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (android != null) {
          await android.requestNotificationsPermission();
        }
      }

      _initialized = true;
    } catch (_) {
      // Notifications are best-effort per-platform; ignore failures.
    }
  }

  static Future<void> show({
    required String title,
    required String body,
  }) async {
    // In-app banner on every platform including web.
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.notifications_active,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$title\n$body',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
    }

    if (kIsWeb || !_initialized) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'canteen_orders',
        'Order Updates',
        channelDescription: 'Updates about your canteen orders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentSound: true,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentSound: true,
      ),
    );

    try {
      await _plugin.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        notificationDetails: details,
      );
    } catch (_) {
      // ignore platform notification failures
    }
  }
}
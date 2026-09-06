import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Foreground push presentation (G-61).
///
/// FCM notification messages are NOT shown by the OS while the app is in the
/// foreground; this bridges onMessage to a local notification so a birthday
/// reminder is visible even while the user is in the app. Taps re-emit the
/// original FCM data through the onTap callback so routing stays in one place.
class ForegroundNotifications {
  ForegroundNotifications._(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _channel = AndroidNotificationChannel(
    'birthday_reminders',
    'Birthday reminders',
    description: "Reminders before your friends' birthdays",
    importance: Importance.high,
  );

  /// Initialize the plugin, register the Android channel, and start bridging
  /// foreground FCM messages. [onTap] receives the tapped message's data map.
  static Future<ForegroundNotifications> initialize({
    required void Function(Map<String, dynamic> data) onTap,
  }) async {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          onTap({'route': payload});
        }
      },
    );

    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    final instance = ForegroundNotifications._(plugin);
    FirebaseMessaging.onMessage.listen(instance._show);
    return instance;
  }

  void _show(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    _plugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      // Carry the route so a tap navigates like a background tap does.
      payload: message.data['route'] as String?,
    );
  }
}

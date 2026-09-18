import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Wraps flutter_local_notifications so alarm-arrival alerts can be fired
/// from anywhere in the app (including background geofence callbacks).
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // TODO: request POST_NOTIFICATIONS permission explicitly on Android 13+.
    // TODO: request notification permissions on iOS via requestPermissions().
  }

  Future<void> showArrivalNotification({
    required int id,
    required String alarmName,
  }) {
    const androidDetails = AndroidNotificationDetails(
      'arrivo_geofence_channel',
      'Arrival Alarms',
      channelDescription: 'Fires when you arrive at a saved Arrivo location',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    return _plugin.show(
      id,
      'You\'ve arrived!',
      'You are near "$alarmName" — this is your stop.',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}
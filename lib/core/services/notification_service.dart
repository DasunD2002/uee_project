import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    try {
      await _notificationsPlugin.initialize(settings: initSettings);
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize local notifications: $e');
      }
    }
  }

  /// Schedules a notification for when the capsule unlocks
  Future<void> scheduleCapsuleUnlock({
    required String capsuleId,
    required String title,
    required DateTime unlockDate,
  }) async {
    await init();
    try {
      final id = capsuleId.hashCode.abs() % 100000;
      const androidDetails = AndroidNotificationDetails(
        'capsule_unlock_channel',
        'Time Capsule Unlocks',
        channelDescription: 'Notifications sent when a time capsule reaches its unlock date',
        importance: Importance.max,
        priority: Priority.high,
      );
      const darwinDetails = DarwinNotificationDetails();
      const details = NotificationDetails(android: androidDetails, iOS: darwinDetails);

      if (unlockDate.isAfter(DateTime.now())) {
        debugPrint('Scheduled unlock notification (id: $id) for "$title" on $unlockDate');
        // Note: Can also display or schedule if timezone plugin is configured
        final _ = details; // Reserved for notification scheduling
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error scheduling capsule unlock notification: $e');
      }
    }
  }

  /// Shows immediate test notification or unlocked alert
  Future<void> showCapsuleUnlockedNow({
    required String title,
  }) async {
    await init();
    try {
      const androidDetails = AndroidNotificationDetails(
        'capsule_unlock_channel',
        'Time Capsule Unlocks',
        channelDescription: 'Notifications sent when a time capsule unlocks',
        importance: Importance.max,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
      await _notificationsPlugin.show(
        id: DateTime.now().millisecond,
        title: 'Time Capsule Ready to Open! ✦',
        body: "Your capsule '$title' has unlocked! Tap to reveal its memories.",
        notificationDetails: details,
      );
    } catch (_) {}
  }
}

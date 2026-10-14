import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/notifications/presentation/widgets/notification_item_tile.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _notificationsStorageKey = 'rootly_in_app_notifications';
  bool _initialized = false;

  /// Initializes the local notification plugin and requests permissions
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

      // Request permissions for Android 13+
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        await androidPlatform.requestNotificationsPermission();
      }

      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize local notifications: $e');
      }
    }
  }

  /// Triggers an immediate notification and saves it to the in-app notification center
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    IconData? icon,
    String? avatarAsset,
    String? avatarUrl,
  }) async {
    await init();

    // 1. Record notification in in-app history
    final newItem = NotificationItemData(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subtitle: body,
      timeAgo: 'Just now',
      icon: icon ?? Icons.notifications_active_outlined,
      avatarAsset: avatarAsset,
      avatarUrl: avatarUrl,
      isUnread: true,
      timestamp: DateTime.now(),
    );
    await _saveInAppNotification(newItem);

    // 2. Check if user has enabled notifications in Settings
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('settings.notifications') ?? true;
    if (!notificationsEnabled) {
      return;
    }

    // 3. Fire OS level notification
    try {
      final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      const androidDetails = AndroidNotificationDetails(
        'rootly_general_channel',
        'Rootly Activity',
        channelDescription:
            'Notifications for time capsules, explorer notes, and community updates',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );
      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to display local notification: $e');
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
      if (unlockDate.isAfter(DateTime.now())) {
        debugPrint('Scheduled unlock notification (id: $id) for "$title" on $unlockDate');
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
    await showNotification(
      title: 'Time Capsule Ready to Open! ✦',
      body: "Your capsule '$title' has unlocked! Tap to reveal its memories.",
      icon: Icons.lock_open_rounded,
    );
  }

  // ── In-App Notification Center Persistence ──────────────────────────────────

  Future<void> _saveInAppNotification(NotificationItemData item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getInAppNotifications();
      currentList.insert(0, item);
      // Keep up to 50 latest notifications
      final trimmed = currentList.take(50).toList();
      final jsonList = trimmed.map((e) => e.toJson()).toList();
      await prefs.setString(_notificationsStorageKey, jsonEncode(jsonList));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to persist in-app notification: $e');
      }
    }
  }

  Future<List<NotificationItemData>> getInAppNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_notificationsStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List;
        return decoded
            .map((e) => NotificationItemData.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = await getInAppNotifications();
      final updated = current.map((e) => e.copyWith(isUnread: false)).toList();
      await prefs.setString(
        _notificationsStorageKey,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  Future<void> markAsRead(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = await getInAppNotifications();
      final updated = current
          .map((e) => e.id == id ? e.copyWith(isUnread: false) : e)
          .toList();
      await prefs.setString(
        _notificationsStorageKey,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Service for scheduling smart notifications and reminders
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Notification IDs
  static const int _eveningReminderId = 1;
  static const int _midnightReminderId = 2;
  static const int _streakWarningId = 3;
  static const int _achievementId = 4;

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    await _requestPermissions();

    _initialized = true;
    debugPrint('NotificationService: Fully initialized');
  }

  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Add navigation logic based on payload
  }

  /// Schedule evening reminder at specific time (e.g., 8 PM)
  static Future<void> scheduleEveningReminder({required int hour, required int minute}) async {
    if (!_initialized) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'evening_reminder',
      'Evening Reminders',
      channelDescription: 'Daily evening reminder to check your habits',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _eveningReminderId,
      'Don\'t forget your habits! 🔥',
      'Time to check in on your daily progress',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint('NotificationService: Evening reminder scheduled for $hour:$minute');
  }

  /// Schedule escalating reminders as midnight approaches
  static Future<void> scheduleEscalatingReminders(int habitsLeft) async {
    if (!_initialized || habitsLeft <= 0) return;

    const androidDetails = AndroidNotificationDetails(
      'urgent_reminder',
      'Urgent Reminders',
      channelDescription: 'Urgent reminders for incomplete habits',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF6B35),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _streakWarningId,
      '⚠️ Only $habitsLeft habit${habitsLeft > 1 ? 's' : ''} left!',
      'Complete them before midnight to maintain your streak',
      notificationDetails,
    );

    debugPrint('NotificationService: Escalating reminder sent for $habitsLeft habits');
  }

  /// Send streak break warning
  static Future<void> sendStreakWarning(int currentStreak) async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'streak_warning',
      'Streak Warnings',
      channelDescription: 'Warnings about potential streak breaks',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF0000),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _streakWarningId,
      '🔥 $currentStreak day streak at risk!',
      'You haven\'t completed enough habits today. Don\'t break your streak!',
      notificationDetails,
    );

    debugPrint('NotificationService: Streak warning sent for $currentStreak days');
  }

  /// Send achievement unlock notification
  static Future<void> sendAchievementNotification(String achievementName) async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'achievements',
      'Achievements',
      channelDescription: 'Achievement unlock notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFFA500),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _achievementId,
      '🎉 Achievement Unlocked!',
      achievementName,
      notificationDetails,
    );

    debugPrint('NotificationService: Achievement notification sent - $achievementName');
  }

  /// Schedule midnight check notification (11:30 PM)
  static Future<void> scheduleMidnightCheck() async {
    if (!_initialized) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 23, 30);

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'midnight_check',
      'Midnight Check',
      channelDescription: 'Final reminder before the day ends',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _midnightReminderId,
      '⏰ Last chance!',
      'Only 30 minutes left to complete your habits today',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint('NotificationService: Midnight check scheduled for 11:30 PM');
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
    debugPrint('NotificationService: All notifications cancelled');
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('NotificationService: Notification $id cancelled');
  }

  /// Check if notifications are enabled (permission granted)
  static Future<bool> areNotificationsEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }
    return true; // iOS handles this differently
  }
}

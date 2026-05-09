import 'dart:async';
import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/day_log.dart';

/// Service that monitors for midnight and handles day transitions
class MidnightService {
  static Timer? _midnightTimer;
  static VoidCallback? _onMidnightCallback;

  /// Initialize the midnight monitoring service
  static void initialize({VoidCallback? onMidnight}) {
    _onMidnightCallback = onMidnight;
    _scheduleMidnightCheck();
  }

  /// Schedule the next midnight check
  static void _scheduleMidnightCheck() {
    // Cancel existing timer
    _midnightTimer?.cancel();

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    // Schedule timer for midnight + 1 second to ensure we're in the new day
    _midnightTimer = Timer(timeUntilMidnight + const Duration(seconds: 1), () {
      _handleMidnight();
      // Reschedule for next midnight
      _scheduleMidnightCheck();
    });

    debugPrint('MidnightService: Next check scheduled for $tomorrow (in ${timeUntilMidnight.inHours}h ${timeUntilMidnight.inMinutes % 60}m)');
  }

  /// Handle midnight transition
  static Future<void> _handleMidnight() async {
    debugPrint('MidnightService: Midnight detected! Processing day transition...');

    try {
      // Get yesterday's date
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);

      debugPrint('MidnightService: Processing streak for $yesterday');

      // Process yesterday's streak (will check if user met requirements)
      // This will be handled by the streak calculation on next app open or habit log
      // For now, we just ensure a new day log is created
      final today = DateTime(now.year, now.month, now.day);
      final existingLog = HiveService.getDayLogByDate(today);

      if (existingLog == null) {
        final newLog = DayLog.createEmpty(today);
        await HiveService.saveDayLog(newLog);
        debugPrint('MidnightService: New day log created for $today');
      }

      // Trigger callback to notify UI
      _onMidnightCallback?.call();

      debugPrint('MidnightService: Day transition complete');
    } catch (e) {
      debugPrint('MidnightService: Error during midnight transition: $e');
    }
  }

  /// Manually trigger midnight check (useful for testing)
  static Future<void> triggerMidnightCheck() async {
    await _handleMidnight();
  }

  /// Get time until next midnight
  static Duration getTimeUntilMidnight() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow.difference(now);
  }

  /// Check if we've crossed midnight since last check
  static bool hasCrossedMidnight(DateTime lastCheck) {
    final now = DateTime.now();
    final lastCheckDay = DateTime(lastCheck.year, lastCheck.month, lastCheck.day);
    final today = DateTime(now.year, now.month, now.day);
    return today.isAfter(lastCheckDay);
  }

  /// Dispose the service
  static void dispose() {
    _midnightTimer?.cancel();
    _midnightTimer = null;
    _onMidnightCallback = null;
    debugPrint('MidnightService: Disposed');
  }
}

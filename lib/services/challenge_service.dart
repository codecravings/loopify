import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/challenge.dart';
import 'hive_service.dart';
import 'notification_service.dart';

class ChallengeService {
  static Timer? _timer;
  static void Function(Challenge challenge)? _onDeadlineReached;

  static void initialize({required void Function(Challenge challenge) onDeadlineReached}) {
    _onDeadlineReached = onDeadlineReached;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _checkDeadlines());
    // Expire old challenges on startup
    expireOldChallenges();
  }

  static void updateCallback(void Function(Challenge challenge) onDeadlineReached) {
    _onDeadlineReached = onDeadlineReached;
  }

  static void _checkDeadlines() {
    final activeChallenges = HiveService.getActiveChallenges();
    for (final challenge in activeChallenges) {
      if (challenge.isSnoozed) continue; // Still snoozed, skip
      if (challenge.isOverdue && _onDeadlineReached != null) {
        debugPrint('ChallengeService: Deadline reached for ${challenge.habitDisplayName}');
        _onDeadlineReached!(challenge);
      }
    }
  }

  /// Returns overdue challenges (called on app resume)
  static List<Challenge> checkMissedDeadlines() {
    final activeChallenges = HiveService.getActiveChallenges();
    return activeChallenges
        .where((c) => !c.isSnoozed && c.isOverdue)
        .toList()
      ..sort((a, b) => a.effectiveDeadline.compareTo(b.effectiveDeadline));
  }

  /// Schedule a system notification for a challenge deadline
  static Future<void> scheduleNotification(Challenge challenge) async {
    await NotificationService.scheduleChallengeDeadline(
      challengeId: challenge.id,
      habitDisplayName: challenge.habitDisplayName,
      deadlineTime: challenge.effectiveDeadline,
    );
  }

  static Future<Challenge> completeChallenge(String id, int saveChoice) async {
    final challenge = HiveService.getChallenge(id);
    if (challenge == null) throw Exception('Challenge not found: $id');

    final updated = challenge.copyWith(
      status: 1,
      completedAt: DateTime.now(),
      saveChoice: saveChoice,
    );
    await HiveService.saveChallenge(updated);
    await NotificationService.cancelChallengeDeadline(id);
    return updated;
  }

  static Future<Challenge> snoozeChallenge(String id, int minutes) async {
    final challenge = HiveService.getChallenge(id);
    if (challenge == null) throw Exception('Challenge not found: $id');

    final snoozedUntil = DateTime.now().add(Duration(minutes: minutes));
    final updated = challenge.copyWith(
      snoozedUntil: snoozedUntil,
      snoozeCount: challenge.snoozeCount + 1,
    );
    await HiveService.saveChallenge(updated);

    // Cancel old notification and schedule new one at snooze time
    await NotificationService.cancelChallengeDeadline(id);
    await NotificationService.scheduleChallengeDeadline(
      challengeId: id,
      habitDisplayName: challenge.habitDisplayName,
      deadlineTime: snoozedUntil,
    );

    return updated;
  }

  static Future<Challenge> cancelChallenge(String id) async {
    final challenge = HiveService.getChallenge(id);
    if (challenge == null) throw Exception('Challenge not found: $id');

    final updated = challenge.copyWith(status: 2);
    await HiveService.saveChallenge(updated);
    await NotificationService.cancelChallengeDeadline(id);
    return updated;
  }

  static Future<void> expireOldChallenges() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final allChallenges = HiveService.getAllChallenges();

    for (final challenge in allChallenges) {
      if (challenge.isActive && challenge.createdAt.isBefore(todayStart)) {
        final updated = challenge.copyWith(status: 3);
        await HiveService.saveChallenge(updated);
        await NotificationService.cancelChallengeDeadline(challenge.id);
      }
    }
  }

  /// Reschedule notifications for all active, non-overdue challenges.
  /// Call after notification permissions are granted to fix missed schedules.
  static Future<void> rescheduleAllNotifications() async {
    final activeChallenges = HiveService.getActiveChallenges();
    for (final challenge in activeChallenges) {
      if (!challenge.isOverdue) {
        await scheduleNotification(challenge);
      }
    }
  }

  static void dispose() {
    _timer?.cancel();
    _timer = null;
    _onDeadlineReached = null;
  }
}

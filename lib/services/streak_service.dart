import 'package:flutter/foundation.dart';
import '../models/streak_state.dart';
import '../models/day_log.dart';
import '../services/hive_service.dart';

class StreakCalculationResult {
  final StreakState state;
  final bool streakBroken;
  final int brokenStreakValue;
  final DateTime? breakDate;

  StreakCalculationResult({
    required this.state,
    this.streakBroken = false,
    this.brokenStreakValue = 0,
    this.breakDate,
  });
}

class StreakService {
  /// Calculate streak based on consecutive days with habits logged
  /// Returns result with streak break information
  static Future<StreakCalculationResult> calculateStreakWithResult(bool strictMode) async {
    final currentState = HiveService.getStreakState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    bool streakBroken = false;
    int brokenStreakValue = 0;

    // Check if we need to reset grace passes (new week)
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    StreakState updatedState = currentState;

    if (weekStart.isAfter(currentState.weekStartDate)) {
      // New week started, reset grace passes
      updatedState = currentState.copyWith(
        gracePassesUsedThisWeek: 0,
        weekStartDate: weekStart,
      );
      await HiveService.saveStreakState(updatedState);
    }

    // Check if we need to process yesterday's streak
    if (currentState.lastLoggedDate != null) {
      final lastLoggedDay = DateTime(
        currentState.lastLoggedDate!.year,
        currentState.lastLoggedDate!.month,
        currentState.lastLoggedDate!.day,
      );

      final daysSinceLastLog = today.difference(lastLoggedDay).inDays;

      if (daysSinceLastLog == 1) {
        // Check yesterday's habits
        final yesterday = today.subtract(const Duration(days: 1));
        final yesterdayLog = HiveService.getDayLogByDate(yesterday);

        if (yesterdayLog != null) {
          final requiredHabits = strictMode ? 3 : 1;

          if (yesterdayLog.totalHabitsLogged >= requiredHabits) {
            // Increment streak
            final newStreak = updatedState.currentStreak + 1;
            final newBest = newStreak > updatedState.bestStreak ? newStreak : updatedState.bestStreak;

            updatedState = updatedState.copyWith(
              currentStreak: newStreak,
              bestStreak: newBest,
              lastLoggedDate: today,
            );
            await HiveService.saveStreakState(updatedState);
          } else {
            // Try to use grace pass
            if (updatedState.gracePassesUsedThisWeek < 1) {
              updatedState = updatedState.copyWith(
                gracePassesUsedThisWeek: updatedState.gracePassesUsedThisWeek + 1,
                lastLoggedDate: today,
              );
              await HiveService.saveStreakState(updatedState);
            } else {
              // Reset streak - STREAK BROKEN!
              streakBroken = true;
              brokenStreakValue = updatedState.currentStreak;
              updatedState = updatedState.copyWith(
                currentStreak: 0,
                lastLoggedDate: today,
              );
              await HiveService.saveStreakState(updatedState);
              debugPrint('StreakService: STREAK BROKEN! Lost $brokenStreakValue days');
            }
          }
        }
      } else if (daysSinceLastLog > 1) {
        // More than 1 day missed, reset streak - STREAK BROKEN!
        streakBroken = true;
        brokenStreakValue = updatedState.currentStreak;
        updatedState = updatedState.copyWith(
          currentStreak: 0,
          lastLoggedDate: today,
        );
        await HiveService.saveStreakState(updatedState);
        debugPrint('StreakService: STREAK BROKEN! Lost $brokenStreakValue days ($daysSinceLastLog days missed)');
      }
    }

    return StreakCalculationResult(
      state: updatedState,
      streakBroken: streakBroken,
      brokenStreakValue: brokenStreakValue,
      breakDate: streakBroken ? today : null,
    );
  }

  /// Legacy method for backwards compatibility
  static Future<StreakState> calculateStreak(bool strictMode) async {
    final result = await calculateStreakWithResult(strictMode);
    return result.state;
  }

  /// Check if today's progress should increment streak
  static Future<void> checkTodayProgress(int totalHabits, bool strictMode) async {
    final currentState = HiveService.getStreakState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Only update lastLoggedDate if we have enough habits
    final requiredHabits = strictMode ? 3 : 1;

    if (totalHabits >= requiredHabits) {
      final lastLoggedDay = currentState.lastLoggedDate != null
          ? DateTime(
              currentState.lastLoggedDate!.year,
              currentState.lastLoggedDate!.month,
              currentState.lastLoggedDate!.day,
            )
          : null;

      if (lastLoggedDay == null || !isSameDay(lastLoggedDay, today)) {
        // First time hitting requirement today
        final daysSince = lastLoggedDay != null ? today.difference(lastLoggedDay).inDays : 0;

        if (daysSince == 1 || lastLoggedDay == null) {
          // Consecutive day or first ever
          final newStreak = currentState.currentStreak + 1;
          final newBest = newStreak > currentState.bestStreak ? newStreak : currentState.bestStreak;

          final updated = currentState.copyWith(
            currentStreak: newStreak,
            bestStreak: newBest,
            lastLoggedDate: today,
          );
          await HiveService.saveStreakState(updated);
          debugPrint('StreakService: Streak incremented to $newStreak (Best: $newBest)');
        } else if (daysSince > 1) {
          // More than 1 day gap - streak should be reset
          debugPrint('StreakService: Streak broken! Gap of $daysSince days detected');
        }
      }
    }
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get time until midnight
  static Duration getTimeUntilMidnight() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow.difference(now);
  }

  /// Format countdown timer
  static String formatCountdown(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return 'New day in ${hours}h ${minutes}m';
  }

  /// Check if we should show milestone celebration
  static int? getMilestoneToShow(int oldStreak, int newStreak) {
    const milestones = [3, 7, 21, 100];

    for (final milestone in milestones) {
      if (oldStreak < milestone && newStreak >= milestone) {
        return milestone;
      }
    }
    return null;
  }

  /// Restore streak after recovery
  /// Called when user fills in yesterday's habits via recovery flow
  static Future<StreakState> restoreStreakAfterRecovery(int streakToRestore) async {
    final currentState = HiveService.getStreakState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Restore the streak + 1 (for the recovered day)
    final restoredStreak = streakToRestore + 1;
    final newBest = restoredStreak > currentState.bestStreak
        ? restoredStreak
        : currentState.bestStreak;

    final updatedState = currentState.copyWith(
      currentStreak: restoredStreak,
      bestStreak: newBest,
      lastLoggedDate: today,
    );

    await HiveService.saveStreakState(updatedState);
    debugPrint('StreakService: Streak restored to $restoredStreak (was $streakToRestore + 1 for recovered day)');

    return updatedState;
  }
}

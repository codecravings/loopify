import '../models/day_log.dart';
import '../services/hive_service.dart';
import '../services/streak_service.dart';

class RecoveryEligibility {
  final bool isEligible;
  final String? reason;
  final int? brokenStreakValue;
  final DateTime? yesterday;

  RecoveryEligibility({
    required this.isEligible,
    this.reason,
    this.brokenStreakValue,
    this.yesterday,
  });
}

class RecoveryService {
  /// Manually enable recovery for a broken streak
  /// Use this when streak broke before the recording code was in place
  static Future<void> manuallyEnableRecovery(int brokenStreakValue) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final userStats = HiveService.getUserStats();

    final updated = userStats.copyWith(
      lastBrokenStreak: brokenStreakValue,
      lastStreakBreakDate: today,
      streakRecoveryTokens: userStats.streakRecoveryTokens > 0
          ? userStats.streakRecoveryTokens
          : 1, // Give a token if they have none
    );

    await HiveService.saveUserStats(updated);
  }

  /// Check if recovery is available
  static RecoveryEligibility checkEligibility() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final userStats = HiveService.getUserStats();

    // Check 1: Has recovery tokens?
    if (userStats.streakRecoveryTokens <= 0) {
      return RecoveryEligibility(
        isEligible: false,
        reason: 'No recovery tokens available',
      );
    }

    // Check 2: Already recovered today?
    if (userStats.lastRecoveryDate != null) {
      final lastRecoveryDay = DateTime(
        userStats.lastRecoveryDate!.year,
        userStats.lastRecoveryDate!.month,
        userStats.lastRecoveryDate!.day,
      );
      if (lastRecoveryDay == today) {
        return RecoveryEligibility(
          isEligible: false,
          reason: 'Already recovered today',
        );
      }
    }

    // Check 3: Streak broke TODAY?
    if (userStats.lastStreakBreakDate == null) {
      return RecoveryEligibility(
        isEligible: false,
        reason: 'No streak break recorded',
      );
    }

    final breakDay = DateTime(
      userStats.lastStreakBreakDate!.year,
      userStats.lastStreakBreakDate!.month,
      userStats.lastStreakBreakDate!.day,
    );

    if (breakDay != today) {
      return RecoveryEligibility(
        isEligible: false,
        reason: 'Streak did not break today',
      );
    }

    // Check 4: Yesterday was missed (no log or insufficient habits)?
    final yesterdayLog = HiveService.getDayLogByDate(yesterday);
    if (yesterdayLog != null && yesterdayLog.totalHabitsLogged > 0) {
      return RecoveryEligibility(
        isEligible: false,
        reason: 'Yesterday already has habits logged',
      );
    }

    // Check 5: Had a streak to recover (lastBrokenStreak > 0)
    if (userStats.lastBrokenStreak <= 0) {
      return RecoveryEligibility(
        isEligible: false,
        reason: 'No streak value to recover',
      );
    }

    // All checks passed - eligible for recovery
    return RecoveryEligibility(
      isEligible: true,
      brokenStreakValue: userStats.lastBrokenStreak,
      yesterday: yesterday,
    );
  }

  /// Execute recovery after user fills yesterday's habits
  /// Returns true if successful
  static Future<bool> executeRecovery(DayLog yesterdayLog, bool strictMode) async {
    try {
      final userStats = HiveService.getUserStats();
      final requiredHabits = strictMode ? 3 : 1;

      // Verify yesterday's log has enough habits
      if (yesterdayLog.totalHabitsLogged < requiredHabits) {
        return false;
      }

      // 1. Save yesterday's DayLog (should already be saved by EditDayScreen)
      await HiveService.saveDayLog(yesterdayLog);

      // 2. Restore streak to lastBrokenStreak value
      await StreakService.restoreStreakAfterRecovery(
        userStats.lastBrokenStreak,
      );

      // 3. Update stats
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final updatedStats = userStats.copyWith(
        coldStreak: 0,
        lifetimeHabitsCompleted: userStats.lifetimeHabitsCompleted + yesterdayLog.totalHabitsLogged,
        totalDaysActive: userStats.totalDaysActive + 1,
        streakRecoveryTokens: userStats.streakRecoveryTokens - 1,
        lastRecoveryDate: today,
        totalRecoveriesUsed: userStats.totalRecoveriesUsed + 1,
        // Undo the streak break record since we recovered
        totalStreakBreaks: userStats.totalStreakBreaks > 0 ? userStats.totalStreakBreaks - 1 : 0,
      );

      await HiveService.saveUserStats(updatedStats);

      return true;
    } catch (e) {
      return false;
    }
  }
}

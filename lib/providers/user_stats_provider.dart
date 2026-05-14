import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_stats.dart';
import '../services/hive_service.dart';

final userStatsProvider = StateNotifierProvider<UserStatsNotifier, UserStats>((ref) {
  return UserStatsNotifier();
});

class UserStatsNotifier extends StateNotifier<UserStats> {
  UserStatsNotifier() : super(HiveService.getUserStats());

  /// Reload stats from Hive
  void reload() {
    state = HiveService.getUserStats();
  }

  /// Increment cold streak
  Future<void> incrementColdStreak() async {
    final updated = state.copyWith(
      coldStreak: state.coldStreak + 1,
      longestColdStreak: state.coldStreak + 1 > state.longestColdStreak
          ? state.coldStreak + 1
          : state.longestColdStreak,
    );
    state = updated;
    await HiveService.saveUserStats(updated);
  }

  /// Reset cold streak to 0
  Future<void> resetColdStreak() async {
    final updated = state.copyWith(coldStreak: 0);
    state = updated;
    await HiveService.saveUserStats(updated);
  }

  /// Record a streak break
  Future<void> recordStreakBreak(int brokenStreak, DateTime breakDate) async {
    final history = List<DateTime>.from(state.streakBreakHistory)..add(breakDate);

    final updated = state.copyWith(
      totalStreakBreaks: state.totalStreakBreaks + 1,
      lastStreakBreakDate: breakDate,
      lastBrokenStreak: brokenStreak,
      streakBreakHistory: history,
    );
    state = updated;
    await HiveService.saveUserStats(updated);
  }

  /// Increment lifetime habits completed
  Future<void> incrementLifetimeHabits() async {
    final updated = state.copyWith(
      lifetimeHabitsCompleted: state.lifetimeHabitsCompleted + 1,
    );
    state = updated;
    await HiveService.saveUserStats(updated);
  }

  /// Increment days active
  Future<void> incrementDaysActive() async {
    final updated = state.copyWith(
      totalDaysActive: state.totalDaysActive + 1,
    );
    state = updated;
    await HiveService.saveUserStats(updated);
  }

  /// Add an unlocked badge
  Future<void> unlockBadge(String badgeId) async {
    if (state.unlockedBadges.contains(badgeId)) return;

    final badges = List<String>.from(state.unlockedBadges)..add(badgeId);
    final updated = state.copyWith(unlockedBadges: badges);
    state = updated;
    await HiveService.saveUserStats(updated);
  }

  /// Add recovery tokens
  Future<void> addRecoveryTokens(int count) async {
    final updated = state.copyWith(
      streakRecoveryTokens: state.streakRecoveryTokens + count,
    );
    state = updated;
    await HiveService.saveUserStats(updated);
  }

  /// Use a recovery token
  Future<bool> useRecoveryToken() async {
    if (state.streakRecoveryTokens <= 0) return false;

    final updated = state.copyWith(
      streakRecoveryTokens: state.streakRecoveryTokens - 1,
    );
    state = updated;
    await HiveService.saveUserStats(updated);
    return true;
  }

  /// Update habit level
  Future<void> updateHabitLevel(String habitName, int level) async {
    final levels = Map<String, int>.from(state.habitLevels);
    levels[habitName] = level;

    final updated = state.copyWith(habitLevels: levels);
    state = updated;
    await HiveService.saveUserStats(updated);
  }

  /// Change theme
  Future<void> setTheme(String themeName) async {
    final updated = state.copyWith(currentTheme: themeName);
    state = updated;
    await HiveService.saveUserStats(updated);
  }

  /// Consume a recovery token and record recovery
  Future<bool> consumeRecoveryToken() async {
    if (state.streakRecoveryTokens <= 0) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final updated = state.copyWith(
      streakRecoveryTokens: state.streakRecoveryTokens - 1,
      lastRecoveryDate: today,
      totalRecoveriesUsed: state.totalRecoveriesUsed + 1,
    );
    state = updated;
    await HiveService.saveUserStats(updated);
    return true;
  }

  /// Full recovery update - resets cold streak, updates stats
  Future<void> applyRecoveryStats(int habitsRecovered) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final updated = state.copyWith(
      coldStreak: 0,
      lifetimeHabitsCompleted: state.lifetimeHabitsCompleted + habitsRecovered,
      totalDaysActive: state.totalDaysActive + 1,
      streakRecoveryTokens: state.streakRecoveryTokens - 1,
      lastRecoveryDate: today,
      totalRecoveriesUsed: state.totalRecoveriesUsed + 1,
      // Undo the streak break since we recovered
      totalStreakBreaks: state.totalStreakBreaks > 0 ? state.totalStreakBreaks - 1 : 0,
    );
    state = updated;
    await HiveService.saveUserStats(updated);
  }
}

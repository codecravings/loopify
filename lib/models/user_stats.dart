import 'package:hive/hive.dart';

part 'user_stats.g.dart';

@HiveType(typeId: 6)
class UserStats {
  @HiveField(0)
  final int coldStreak; // Consecutive days of failure

  @HiveField(1)
  final int totalStreakBreaks;

  @HiveField(2)
  final DateTime? lastStreakBreakDate;

  @HiveField(3)
  final int lastBrokenStreak; // How long was the streak when it broke

  @HiveField(4)
  final int lifetimeHabitsCompleted;

  @HiveField(5)
  final int totalDaysActive;

  @HiveField(6)
  final List<String> unlockedBadges;

  @HiveField(7)
  final int streakRecoveryTokens;

  @HiveField(8)
  final Map<String, int> habitLevels; // habitName -> level

  @HiveField(9)
  final String currentTheme; // Unlocked theme

  @HiveField(10)
  final List<DateTime> streakBreakHistory;

  @HiveField(11)
  final int longestColdStreak;

  @HiveField(12)
  final double totalMoneyLost; // For financial accountability

  UserStats({
    this.coldStreak = 0,
    this.totalStreakBreaks = 0,
    this.lastStreakBreakDate,
    this.lastBrokenStreak = 0,
    this.lifetimeHabitsCompleted = 0,
    this.totalDaysActive = 0,
    this.unlockedBadges = const [],
    this.streakRecoveryTokens = 0,
    this.habitLevels = const {},
    this.currentTheme = 'default',
    this.streakBreakHistory = const [],
    this.longestColdStreak = 0,
    this.totalMoneyLost = 0.0,
  });

  UserStats copyWith({
    int? coldStreak,
    int? totalStreakBreaks,
    DateTime? lastStreakBreakDate,
    int? lastBrokenStreak,
    int? lifetimeHabitsCompleted,
    int? totalDaysActive,
    List<String>? unlockedBadges,
    int? streakRecoveryTokens,
    Map<String, int>? habitLevels,
    String? currentTheme,
    List<DateTime>? streakBreakHistory,
    int? longestColdStreak,
    double? totalMoneyLost,
  }) {
    return UserStats(
      coldStreak: coldStreak ?? this.coldStreak,
      totalStreakBreaks: totalStreakBreaks ?? this.totalStreakBreaks,
      lastStreakBreakDate: lastStreakBreakDate ?? this.lastStreakBreakDate,
      lastBrokenStreak: lastBrokenStreak ?? this.lastBrokenStreak,
      lifetimeHabitsCompleted: lifetimeHabitsCompleted ?? this.lifetimeHabitsCompleted,
      totalDaysActive: totalDaysActive ?? this.totalDaysActive,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      streakRecoveryTokens: streakRecoveryTokens ?? this.streakRecoveryTokens,
      habitLevels: habitLevels ?? this.habitLevels,
      currentTheme: currentTheme ?? this.currentTheme,
      streakBreakHistory: streakBreakHistory ?? this.streakBreakHistory,
      longestColdStreak: longestColdStreak ?? this.longestColdStreak,
      totalMoneyLost: totalMoneyLost ?? this.totalMoneyLost,
    );
  }

  static UserStats createInitial() {
    return UserStats();
  }

  // Calculate success rate based on actual habit completion from day logs
  double get successRate {
    try {
      // Access the dayLogs box directly
      final box = Hive.box('dayLogs');

      if (box.isEmpty) return 0.0;

      // Calculate average habit completion percentage across all days
      int totalHabitsCompleted = 0;
      int totalPossibleHabits = 0;

      for (final log in box.values) {
        // Access totalHabitsLogged using dynamic property access
        final habitsLogged = (log as dynamic).totalHabitsLogged;
        if (habitsLogged != null) {
          totalHabitsCompleted += habitsLogged as int;
          totalPossibleHabits += 11; // 11 default habits per day
        }
      }

      if (totalPossibleHabits == 0) return 0.0;

      return (totalHabitsCompleted / totalPossibleHabits) * 100;
    } catch (e) {
      // If there's any error, return 0
      return 0.0;
    }
  }

  // Get grade based on success rate
  String get gradeLabel {
    if (successRate >= 95) return 'A+';
    if (successRate >= 90) return 'A';
    if (successRate >= 85) return 'B+';
    if (successRate >= 80) return 'B';
    if (successRate >= 75) return 'C+';
    if (successRate >= 70) return 'C';
    if (successRate >= 60) return 'D';
    return 'F';
  }

  // Motivational message based on cold streak
  String get coldStreakMessage {
    if (coldStreak == 0) return '🔥 On fire!';
    if (coldStreak == 1) return '⚠️ Get back on track!';
    if (coldStreak == 2) return '🚨 Emergency! Act now!';
    if (coldStreak >= 3) return '💀 Rock bottom. Time to rise.';
    return '';
  }
}

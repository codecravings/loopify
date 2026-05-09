import 'package:hive/hive.dart';

part 'streak_state.g.dart';

@HiveType(typeId: 3)
class StreakState {
  @HiveField(0)
  final int currentStreak;

  @HiveField(1)
  final int bestStreak;

  @HiveField(2)
  final DateTime? lastLoggedDate;

  @HiveField(3)
  final int gracePassesUsedThisWeek;

  @HiveField(4)
  final DateTime weekStartDate;

  StreakState({
    required this.currentStreak,
    required this.bestStreak,
    this.lastLoggedDate,
    required this.gracePassesUsedThisWeek,
    required this.weekStartDate,
  });

  StreakState copyWith({
    int? currentStreak,
    int? bestStreak,
    DateTime? lastLoggedDate,
    int? gracePassesUsedThisWeek,
    DateTime? weekStartDate,
  }) {
    return StreakState(
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastLoggedDate: lastLoggedDate ?? this.lastLoggedDate,
      gracePassesUsedThisWeek: gracePassesUsedThisWeek ?? this.gracePassesUsedThisWeek,
      weekStartDate: weekStartDate ?? this.weekStartDate,
    );
  }

  static StreakState createInitial() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return StreakState(
      currentStreak: 0,
      bestStreak: 0,
      gracePassesUsedThisWeek: 0,
      weekStartDate: DateTime(weekStart.year, weekStart.month, weekStart.day),
    );
  }

  String get milestoneLabel {
    if (currentStreak >= 100) return 'Centurion';
    if (currentStreak >= 21) return 'Habit Forged';
    if (currentStreak >= 7) return 'First Flame';
    if (currentStreak >= 3) return 'Spark Ignited';
    if (currentStreak >= 1) return 'Origin Story';
    return 'Start Your Journey';
  }
}

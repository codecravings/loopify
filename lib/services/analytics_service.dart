import 'package:flutter/foundation.dart';
import '../services/hive_service.dart';
import '../models/day_log.dart';

class DayPerformance {
  final DateTime date;
  final int habitsCompleted;
  final double completionRate;

  DayPerformance({
    required this.date,
    required this.habitsCompleted,
    required this.completionRate,
  });
}

class WeekdayStats {
  final String dayName;
  final int totalDays;
  final int successfulDays;
  final double averageHabits;

  WeekdayStats({
    required this.dayName,
    required this.totalDays,
    required this.successfulDays,
    required this.averageHabits,
  });

  double get successRate => totalDays > 0 ? (successfulDays / totalDays) * 100 : 0;
}

class HabitCorrelation {
  final String habit1;
  final String habit2;
  final double correlationScore; // 0-1, how often they're done together

  HabitCorrelation({
    required this.habit1,
    required this.habit2,
    required this.correlationScore,
  });
}

class HabitPerformance {
  final String habitName;
  final int timesCompleted;
  final int totalDays;
  final double completionRate;

  HabitPerformance({
    required this.habitName,
    required this.timesCompleted,
    required this.totalDays,
    required this.completionRate,
  });
}

class AnalyticsService {
  /// Get best performing days of the week
  static Future<List<WeekdayStats>> getBestWorstDays() async {
    final allLogs = HiveService.getAllDayLogs();

    // Group by weekday
    Map<int, List<DayLog>> weekdayLogs = {};
    for (int i = 1; i <= 7; i++) {
      weekdayLogs[i] = [];
    }

    for (final log in allLogs) {
      weekdayLogs[log.date.weekday]!.add(log);
    }

    // Calculate stats for each day
    List<WeekdayStats> stats = [];
    final dayNames = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    for (int i = 1; i <= 7; i++) {
      final logs = weekdayLogs[i]!;
      if (logs.isEmpty) continue;

      final successfulDays = logs.where((log) => log.totalHabitsLogged >= 3).length;
      final avgHabits = logs.fold<int>(0, (sum, log) => sum + log.totalHabitsLogged) / logs.length;

      stats.add(WeekdayStats(
        dayName: dayNames[i],
        totalDays: logs.length,
        successfulDays: successfulDays,
        averageHabits: avgHabits,
      ));
    }

    // Sort by success rate
    stats.sort((a, b) => b.successRate.compareTo(a.successRate));
    return stats;
  }

  /// Get habit completion heatmap data for the last N days
  static Future<List<DayPerformance>> getHeatmapData(int days) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<DayPerformance> heatmap = [];

    for (int i = days - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final log = HiveService.getDayLogByDate(date);

      final habitsCompleted = log?.totalHabitsLogged ?? 0;
      final completionRate = habitsCompleted / 11.0; // 11 default habits

      heatmap.add(DayPerformance(
        date: date,
        habitsCompleted: habitsCompleted,
        completionRate: completionRate,
      ));
    }

    return heatmap;
  }

  /// Find habit correlations (which habits are done together)
  static Future<List<HabitCorrelation>> getHabitCorrelations() async {
    final allLogs = HiveService.getAllDayLogs();
    if (allLogs.length < 7) return []; // Need at least a week of data

    // Habit pairs and their co-occurrence count
    Map<String, int> coOccurrences = {};
    Map<String, int> individualCounts = {};

    final habitFields = [
      'meditation', 'serum', 'coldShower', 'jawGym', 'chewQuest',
      'protein', 'study', 'chess', 'cycling', 'buildStreak', 'madScientist'
    ];

    for (final log in allLogs) {
      List<String> completedHabits = [];

      // Check which habits were completed
      if (log.meditation.logged) completedHabits.add('meditation');
      if (log.serum.logged) completedHabits.add('serum');
      if (log.coldShower.logged) completedHabits.add('coldShower');
      if (log.jawGym.logged) completedHabits.add('jawGym');
      if (log.chewQuest.logged) completedHabits.add('chewQuest');
      if (log.protein.logged) completedHabits.add('protein');
      if (log.study.logged) completedHabits.add('study');
      if (log.chess.logged) completedHabits.add('chess');
      if (log.cycling.logged) completedHabits.add('cycling');
      if (log.buildStreak.logged) completedHabits.add('buildStreak');
      if (log.madScientist.logged) completedHabits.add('madScientist');

      // Include custom habits
      if (log.customHabits != null) {
        for (final entry in log.customHabits!.entries) {
          if (entry.value.logged) {
            completedHabits.add('custom_${entry.key}');
          }
        }
      }

      // Count individual occurrences
      for (final habit in completedHabits) {
        individualCounts[habit] = (individualCounts[habit] ?? 0) + 1;
      }

      // Count co-occurrences
      for (int i = 0; i < completedHabits.length; i++) {
        for (int j = i + 1; j < completedHabits.length; j++) {
          final pair = '${completedHabits[i]}_${completedHabits[j]}';
          coOccurrences[pair] = (coOccurrences[pair] ?? 0) + 1;
        }
      }
    }

    // Calculate correlation scores
    List<HabitCorrelation> correlations = [];
    coOccurrences.forEach((pair, count) {
      final habits = pair.split('_');
      final habit1Count = individualCounts[habits[0]] ?? 1;
      final habit2Count = individualCounts[habits[1]] ?? 1;

      // Jaccard similarity: intersection / union
      final score = count / (habit1Count + habit2Count - count);

      if (score > 0.5) { // Only show strong correlations
        correlations.add(HabitCorrelation(
          habit1: _getHabitDisplayName(habits[0]),
          habit2: _getHabitDisplayName(habits[1]),
          correlationScore: score,
        ));
      }
    });

    // Sort by correlation strength
    correlations.sort((a, b) => b.correlationScore.compareTo(a.correlationScore));
    return correlations.take(5).toList(); // Top 5 correlations
  }

  static String _getHabitDisplayName(String habitKey) {
    const names = {
      'meditation': 'Sit & Shine',
      'serum': 'Glow Potion',
      'coldShower': 'Ice Warrior',
      'jawGym': 'Jaw Gym',
      'chewQuest': 'Chew Quest',
      'protein': 'Protein Power',
      'study': 'Study Grind',
      'chess': 'Mind Gambit',
      'cycling': 'Pedal Power',
      'buildStreak': 'Build Streak',
      'madScientist': 'Mad Scientist',
    };

    // Handle custom habits
    if (habitKey.startsWith('custom_')) {
      final customHabitId = habitKey.substring(7); // Remove 'custom_' prefix
      final customHabit = HiveService.getCustomHabit(customHabitId);
      return customHabit?.name ?? habitKey;
    }

    return names[habitKey] ?? habitKey;
  }

  /// Get best and worst performing habits
  static Future<List<HabitPerformance>> getBestWorstHabits() async {
    final allLogs = HiveService.getAllDayLogs();
    if (allLogs.isEmpty) return [];

    final totalDays = allLogs.length;
    Map<String, int> habitCompletionCounts = {};

    // Count completions for each habit (including custom habits)
    for (final log in allLogs) {
      if (log.meditation.logged) habitCompletionCounts['Sit & Shine'] = (habitCompletionCounts['Sit & Shine'] ?? 0) + 1;
      if (log.serum.logged) habitCompletionCounts['Glow Potion'] = (habitCompletionCounts['Glow Potion'] ?? 0) + 1;
      if (log.coldShower.logged) habitCompletionCounts['Ice Warrior'] = (habitCompletionCounts['Ice Warrior'] ?? 0) + 1;
      if (log.jawGym.logged) habitCompletionCounts['Jaw Gym'] = (habitCompletionCounts['Jaw Gym'] ?? 0) + 1;
      if (log.chewQuest.logged) habitCompletionCounts['Chew Quest'] = (habitCompletionCounts['Chew Quest'] ?? 0) + 1;
      if (log.protein.logged) habitCompletionCounts['Protein Power'] = (habitCompletionCounts['Protein Power'] ?? 0) + 1;
      if (log.study.logged) habitCompletionCounts['Study Grind'] = (habitCompletionCounts['Study Grind'] ?? 0) + 1;
      if (log.chess.logged) habitCompletionCounts['Mind Gambit'] = (habitCompletionCounts['Mind Gambit'] ?? 0) + 1;
      if (log.cycling.logged) habitCompletionCounts['Pedal Power'] = (habitCompletionCounts['Pedal Power'] ?? 0) + 1;
      if (log.buildStreak.logged) habitCompletionCounts['Build Streak'] = (habitCompletionCounts['Build Streak'] ?? 0) + 1;
      if (log.madScientist.logged) habitCompletionCounts['Mad Scientist'] = (habitCompletionCounts['Mad Scientist'] ?? 0) + 1;

      // Include custom habits
      if (log.customHabits != null) {
        for (final entry in log.customHabits!.entries) {
          if (entry.value.logged) {
            final customHabit = HiveService.getCustomHabit(entry.key);
            if (customHabit != null) {
              habitCompletionCounts[customHabit.name] = (habitCompletionCounts[customHabit.name] ?? 0) + 1;
            }
          }
        }
      }
    }

    // Convert to HabitPerformance objects
    List<HabitPerformance> performances = habitCompletionCounts.entries.map((entry) {
      return HabitPerformance(
        habitName: entry.key,
        timesCompleted: entry.value,
        totalDays: totalDays,
        completionRate: (entry.value / totalDays) * 100,
      );
    }).toList();

    // Sort by completion rate
    performances.sort((a, b) => b.completionRate.compareTo(a.completionRate));
    return performances;
  }

  /// Calculate weekly performance grade
  static Future<String> getWeeklyGrade() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    List<DayLog> weekLogs = [];
    for (int i = 0; i < 7; i++) {
      final date = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
      final log = HiveService.getDayLogByDate(date);
      if (log != null) weekLogs.add(log);
    }

    if (weekLogs.isEmpty) return 'F';

    final avgHabits = weekLogs.fold<int>(0, (sum, log) => sum + log.totalHabitsLogged) / weekLogs.length;
    final avgRate = (avgHabits / 11.0) * 100;

    if (avgRate >= 90) return 'A+';
    if (avgRate >= 85) return 'A';
    if (avgRate >= 80) return 'B+';
    if (avgRate >= 75) return 'B';
    if (avgRate >= 70) return 'C+';
    if (avgRate >= 65) return 'C';
    if (avgRate >= 60) return 'D';
    return 'F';
  }

  /// Get comprehensive weekly report data
  static Future<Map<String, dynamic>> getWeeklyReport() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    List<DayLog> weekLogs = [];
    for (int i = 0; i < 7; i++) {
      final date = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
      final log = HiveService.getDayLogByDate(date);
      if (log != null) weekLogs.add(log);
    }

    if (weekLogs.isEmpty) {
      return {
        'grade': 'F',
        'successRate': 0.0,
        'totalHabits': 0,
        'daysActive': 0,
        'bestDay': 'None',
        'worstDay': 'None',
        'topHabits': <String>[],
      };
    }

    final totalHabits = weekLogs.fold<int>(0, (sum, log) => sum + log.totalHabitsLogged);
    final avgHabits = totalHabits / weekLogs.length;
    final successRate = (avgHabits / 11.0) * 100;

    // Calculate grade
    String grade = 'F';
    if (successRate >= 90) {
      grade = 'A+';
    } else if (successRate >= 85) {
      grade = 'A';
    } else if (successRate >= 80) {
      grade = 'B+';
    } else if (successRate >= 75) {
      grade = 'B';
    } else if (successRate >= 70) {
      grade = 'C+';
    } else if (successRate >= 65) {
      grade = 'C';
    } else if (successRate >= 60) {
      grade = 'D';
    }

    // Find best and worst days
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    String bestDay = 'None';
    String worstDay = 'None';
    int maxHabits = -1;
    int minHabits = 999;

    for (final log in weekLogs) {
      final dayName = dayNames[log.date.weekday - 1];
      if (log.totalHabitsLogged > maxHabits) {
        maxHabits = log.totalHabitsLogged;
        bestDay = '$dayName (${log.totalHabitsLogged})';
      }
      if (log.totalHabitsLogged < minHabits) {
        minHabits = log.totalHabitsLogged;
        worstDay = '$dayName (${log.totalHabitsLogged})';
      }
    }

    // Calculate top habits
    Map<String, int> habitCounts = {};
    for (final log in weekLogs) {
      if (log.meditation.logged) habitCounts['Sit & Shine'] = (habitCounts['Sit & Shine'] ?? 0) + 1;
      if (log.serum.logged) habitCounts['Glow Potion'] = (habitCounts['Glow Potion'] ?? 0) + 1;
      if (log.coldShower.logged) habitCounts['Ice Warrior'] = (habitCounts['Ice Warrior'] ?? 0) + 1;
      if (log.jawGym.logged) habitCounts['Jaw Gym'] = (habitCounts['Jaw Gym'] ?? 0) + 1;
      if (log.chewQuest.logged) habitCounts['Chew Quest'] = (habitCounts['Chew Quest'] ?? 0) + 1;
      if (log.protein.logged) habitCounts['Protein Power'] = (habitCounts['Protein Power'] ?? 0) + 1;
      if (log.study.logged) habitCounts['Study Grind'] = (habitCounts['Study Grind'] ?? 0) + 1;
      if (log.chess.logged) habitCounts['Mind Gambit'] = (habitCounts['Mind Gambit'] ?? 0) + 1;
      if (log.cycling.logged) habitCounts['Pedal Power'] = (habitCounts['Pedal Power'] ?? 0) + 1;
      if (log.buildStreak.logged) habitCounts['Build Streak'] = (habitCounts['Build Streak'] ?? 0) + 1;
      if (log.madScientist.logged) habitCounts['Mad Scientist'] = (habitCounts['Mad Scientist'] ?? 0) + 1;

      // Include custom habits
      if (log.customHabits != null) {
        for (final entry in log.customHabits!.entries) {
          if (entry.value.logged) {
            final customHabit = HiveService.getCustomHabit(entry.key);
            if (customHabit != null) {
              habitCounts[customHabit.name] = (habitCounts[customHabit.name] ?? 0) + 1;
            }
          }
        }
      }
    }

    final sortedHabits = habitCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topHabits = sortedHabits.take(3).map((e) => '${e.key} (${e.value}x)').toList();

    return {
      'grade': grade,
      'successRate': successRate,
      'totalHabits': totalHabits,
      'daysActive': weekLogs.length,
      'bestDay': bestDay,
      'worstDay': worstDay,
      'topHabits': topHabits,
    };
  }
}

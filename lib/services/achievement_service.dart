import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/user_stats.dart';
import '../providers/user_stats_provider.dart';
import '../widgets/achievement_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AchievementService {
  /// Check and unlock achievements based on current stats
  static Future<List<Achievement>> checkAndUnlock(
    BuildContext context,
    WidgetRef ref,
    UserStats stats,
    int currentStreak,
  ) async {
    final unlockedAchievements = <Achievement>[];
    final allAchievements = achievements.values;

    for (final achievement in allAchievements) {
      // Skip if already unlocked
      if (stats.unlockedBadges.contains(achievement.id)) continue;

      bool shouldUnlock = false;

      // Check unlock condition
      switch (achievement.id) {
        case 'first_blood':
          shouldUnlock = stats.lifetimeHabitsCompleted >= 1;
          break;
        case 'spark':
          shouldUnlock = currentStreak >= 3;
          break;
        case 'first_flame':
          shouldUnlock = currentStreak >= 7;
          break;
        case 'habit_forged':
          shouldUnlock = currentStreak >= 21;
          break;
        case 'month_warrior':
          shouldUnlock = currentStreak >= 30;
          break;
        case 'iron_will':
          shouldUnlock = currentStreak >= 50;
          break;
        case 'centurion':
          shouldUnlock = currentStreak >= 100;
          break;
        case 'legend':
          shouldUnlock = currentStreak >= 365;
          break;
        case 'phoenix':
          shouldUnlock = stats.totalStreakBreaks >= 3 && currentStreak >= 7;
          break;
        case 'comeback_king':
          shouldUnlock = stats.streakRecoveryTokens >= 1;
          break;
        case 'habit_hoarder':
          shouldUnlock = stats.lifetimeHabitsCompleted >= 100;
          break;
        case 'consistency_master':
          shouldUnlock = stats.totalDaysActive >= 30;
          break;
      }

      if (shouldUnlock) {
        // Unlock the achievement
        await ref.read(userStatsProvider.notifier).unlockBadge(achievement.id);
        unlockedAchievements.add(achievement);

        // Show achievement modal
        if (context.mounted) {
          await Future.delayed(const Duration(milliseconds: 300));
          if (context.mounted) {
            AchievementModal.show(context, achievement);
          }
        }
      }
    }

    return unlockedAchievements;
  }

  /// Quick check for specific achievement (doesn't show modal)
  static Future<bool> checkSpecificAchievement(
    WidgetRef ref,
    String achievementId,
    UserStats stats,
    int currentStreak,
  ) async {
    if (stats.unlockedBadges.contains(achievementId)) return false;

    bool shouldUnlock = false;

    switch (achievementId) {
      case 'first_blood':
        shouldUnlock = stats.lifetimeHabitsCompleted >= 1;
        break;
      case 'spark':
        shouldUnlock = currentStreak >= 3;
        break;
      case 'first_flame':
        shouldUnlock = currentStreak >= 7;
        break;
      case 'habit_forged':
        shouldUnlock = currentStreak >= 21;
        break;
      case 'month_warrior':
        shouldUnlock = currentStreak >= 30;
        break;
      case 'iron_will':
        shouldUnlock = currentStreak >= 50;
        break;
      case 'centurion':
        shouldUnlock = currentStreak >= 100;
        break;
      case 'legend':
        shouldUnlock = currentStreak >= 365;
        break;
      case 'phoenix':
        shouldUnlock = stats.totalStreakBreaks >= 3 && currentStreak >= 7;
        break;
      case 'comeback_king':
        shouldUnlock = stats.streakRecoveryTokens >= 1;
        break;
      case 'habit_hoarder':
        shouldUnlock = stats.lifetimeHabitsCompleted >= 100;
        break;
      case 'consistency_master':
        shouldUnlock = stats.totalDaysActive >= 30;
        break;
    }

    if (shouldUnlock) {
      await ref.read(userStatsProvider.notifier).unlockBadge(achievementId);
      return true;
    }

    return false;
  }

  /// Get progress towards next achievement
  static Map<String, dynamic> getNextAchievementProgress(
    UserStats stats,
    int currentStreak,
  ) {
    final allAchievements = achievements.values;

    for (final achievement in allAchievements) {
      if (stats.unlockedBadges.contains(achievement.id)) continue;

      double progress = 0;
      int current = 0;
      int target = 0;
      String metric = '';

      switch (achievement.id) {
        case 'first_blood':
          current = stats.lifetimeHabitsCompleted;
          target = 1;
          metric = 'habits';
          break;
        case 'spark':
          current = currentStreak;
          target = 3;
          metric = 'day streak';
          break;
        case 'first_flame':
          current = currentStreak;
          target = 7;
          metric = 'day streak';
          break;
        case 'habit_forged':
          current = currentStreak;
          target = 21;
          metric = 'day streak';
          break;
        case 'month_warrior':
          current = currentStreak;
          target = 30;
          metric = 'day streak';
          break;
        case 'iron_will':
          current = currentStreak;
          target = 50;
          metric = 'day streak';
          break;
        case 'centurion':
          current = currentStreak;
          target = 100;
          metric = 'day streak';
          break;
        case 'legend':
          current = currentStreak;
          target = 365;
          metric = 'day streak';
          break;
        case 'habit_hoarder':
          current = stats.lifetimeHabitsCompleted;
          target = 100;
          metric = 'habits';
          break;
        case 'consistency_master':
          current = stats.totalDaysActive;
          target = 30;
          metric = 'active days';
          break;
        default:
          continue;
      }

      progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0;

      return {
        'achievement': achievement,
        'progress': progress,
        'current': current,
        'target': target,
        'metric': metric,
      };
    }

    return {};
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/streak_state.dart';
import '../services/hive_service.dart';

final streakProvider = StateNotifierProvider<StreakNotifier, StreakState>((ref) {
  return StreakNotifier();
});

class StreakNotifier extends StateNotifier<StreakState> {
  StreakNotifier() : super(HiveService.getStreakState());

  /// Reload streak state from Hive (useful after StreakService updates)
  void reload() {
    state = HiveService.getStreakState();
  }

  /// Update state with new StreakState
  void updateState(StreakState newState) {
    state = newState;
  }

  Future<void> incrementStreak() async {
    final newStreak = state.currentStreak + 1;
    final newBest = newStreak > state.bestStreak ? newStreak : state.bestStreak;
    final updated = state.copyWith(
      currentStreak: newStreak,
      bestStreak: newBest,
      lastLoggedDate: DateTime.now(),
    );
    state = updated;
    await HiveService.saveStreakState(updated);
  }

  Future<void> resetStreak() async {
    final updated = state.copyWith(
      currentStreak: 0,
      lastLoggedDate: DateTime.now(),
    );
    state = updated;
    await HiveService.saveStreakState(updated);
  }

  Future<void> useGracePass() async {
    final updated = state.copyWith(
      gracePassesUsedThisWeek: state.gracePassesUsedThisWeek + 1,
      lastLoggedDate: DateTime.now(),
    );
    state = updated;
    await HiveService.saveStreakState(updated);
  }

  Future<void> resetWeeklyGracePasses() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final normalized = DateTime(weekStart.year, weekStart.month, weekStart.day);

    final updated = state.copyWith(
      gracePassesUsedThisWeek: 0,
      weekStartDate: normalized,
    );
    state = updated;
    await HiveService.saveStreakState(updated);
  }

  bool canUseGracePass() {
    return state.gracePassesUsedThisWeek < 1;
  }

  int get gracePassesLeft => 1 - state.gracePassesUsedThisWeek;
}

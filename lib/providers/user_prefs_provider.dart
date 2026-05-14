import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_prefs.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

final userPrefsProvider = StateNotifierProvider<UserPrefsNotifier, UserPrefs>((ref) {
  return UserPrefsNotifier();
});

class UserPrefsNotifier extends StateNotifier<UserPrefs> {
  UserPrefsNotifier() : super(HiveService.getUserPrefs());

  Future<void> updatePrefs(UserPrefs prefs) async {
    state = prefs;
    await HiveService.saveUserPrefs(prefs);
  }

  Future<void> setProteinTarget(int target) async {
    await updatePrefs(state.copyWith(proteinTarget: target));
  }

  Future<void> setStrictMode(bool enabled) async {
    await updatePrefs(state.copyWith(strictStreakMode: enabled));
  }

  Future<void> completeOnboarding() async {
    await updatePrefs(state.copyWith(onboardingComplete: true));
  }

  Future<void> toggleHaptics() async {
    await updatePrefs(state.copyWith(hapticsEnabled: !state.hapticsEnabled));
  }

  Future<void> toggleHighContrast() async {
    await updatePrefs(state.copyWith(highContrastMode: !state.highContrastMode));
  }

  Future<void> toggleNotifications() async {
    final newValue = !state.notificationsEnabled;
    await updatePrefs(state.copyWith(notificationsEnabled: newValue));

    // Schedule or cancel notifications based on the new value
    if (newValue) {
      await NotificationService.scheduleEveningReminder(
        hour: state.reminderHour,
        minute: state.reminderMinute,
      );
      await NotificationService.scheduleMidnightCheck();
    } else {
      await NotificationService.cancelAll();
    }
  }

  Future<void> setReminderTime(int hour, int minute) async {
    await updatePrefs(state.copyWith(reminderHour: hour, reminderMinute: minute));

    // Reschedule notifications with new time if enabled
    if (state.notificationsEnabled) {
      await NotificationService.scheduleEveningReminder(hour: hour, minute: minute);
    }
  }

  Future<void> hideHabit(String habitName) async {
    if (state.hiddenHabits.contains(habitName)) return;
    final updated = List<String>.from(state.hiddenHabits)..add(habitName);
    await updatePrefs(state.copyWith(hiddenHabits: updated));
  }

  Future<void> showHabit(String habitName) async {
    if (!state.hiddenHabits.contains(habitName)) return;
    final updated = List<String>.from(state.hiddenHabits)..remove(habitName);
    await updatePrefs(state.copyWith(hiddenHabits: updated));
  }

  Future<void> toggleHabitVisibility(String habitName) async {
    if (state.hiddenHabits.contains(habitName)) {
      await showHabit(habitName);
    } else {
      await hideHabit(habitName);
    }
  }

  bool isHabitHidden(String habitName) {
    return state.hiddenHabits.contains(habitName);
  }
}

import 'package:hive/hive.dart';

part 'user_prefs.g.dart';

@HiveType(typeId: 4)
class UserPrefs {
  @HiveField(0)
  final int proteinTarget; // 80, 100, 120, or 150

  @HiveField(1)
  final int meditationDefault; // in minutes

  @HiveField(2)
  final int studyDefault; // in minutes

  @HiveField(3)
  final int chessDefault; // in minutes

  @HiveField(4)
  final int cyclingDefault; // in minutes

  @HiveField(5)
  final bool strictStreakMode; // false = ≥1 habit, true = ≥3 habits

  @HiveField(6)
  final bool hapticsEnabled;

  @HiveField(7)
  final bool highContrastMode;

  @HiveField(8)
  final bool onboardingComplete;

  @HiveField(9)
  final bool notificationsEnabled;

  @HiveField(10)
  final int reminderHour; // Hour for evening reminder (0-23)

  @HiveField(11)
  final int reminderMinute; // Minute for evening reminder (0-59)

  UserPrefs({
    required this.proteinTarget,
    required this.meditationDefault,
    required this.studyDefault,
    required this.chessDefault,
    required this.cyclingDefault,
    required this.strictStreakMode,
    required this.hapticsEnabled,
    required this.highContrastMode,
    required this.onboardingComplete,
    required this.notificationsEnabled,
    required this.reminderHour,
    required this.reminderMinute,
  });

  UserPrefs copyWith({
    int? proteinTarget,
    int? meditationDefault,
    int? studyDefault,
    int? chessDefault,
    int? cyclingDefault,
    bool? strictStreakMode,
    bool? hapticsEnabled,
    bool? highContrastMode,
    bool? onboardingComplete,
    bool? notificationsEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return UserPrefs(
      proteinTarget: proteinTarget ?? this.proteinTarget,
      meditationDefault: meditationDefault ?? this.meditationDefault,
      studyDefault: studyDefault ?? this.studyDefault,
      chessDefault: chessDefault ?? this.chessDefault,
      cyclingDefault: cyclingDefault ?? this.cyclingDefault,
      strictStreakMode: strictStreakMode ?? this.strictStreakMode,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }

  static UserPrefs createDefault() {
    return UserPrefs(
      proteinTarget: 100,
      meditationDefault: 10,
      studyDefault: 30,
      chessDefault: 10,
      cyclingDefault: 10,
      strictStreakMode: false,
      hapticsEnabled: true,
      highContrastMode: false,
      onboardingComplete: false,
      notificationsEnabled: true,
      reminderHour: 20, // 8 PM default
      reminderMinute: 0,
    );
  }
}

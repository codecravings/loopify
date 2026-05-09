import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit_log.dart';
import '../models/day_log.dart';
import '../models/project.dart';
import '../models/streak_state.dart';
import '../models/user_prefs.dart';
import '../models/custom_habit.dart';
import '../models/user_stats.dart';
import '../models/achievement_note.dart';

class HiveService {
  static const String _dayLogsBox = 'dayLogs';
  static const String _projectsBox = 'projects';
  static const String _streakStateBox = 'streakState';
  static const String _userPrefsBox = 'userPrefs';
  static const String _customHabitsBox = 'customHabits';
  static const String _userStatsBox = 'userStats';
  static const String _achievementNotesBox = 'achievementNotes';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(HabitLogAdapter());
    Hive.registerAdapter(DayLogAdapter());
    Hive.registerAdapter(ProjectAdapter());
    Hive.registerAdapter(StreakStateAdapter());
    Hive.registerAdapter(UserPrefsAdapter());
    Hive.registerAdapter(CustomHabitAdapter());
    Hive.registerAdapter(UserStatsAdapter());
    Hive.registerAdapter(AchievementNoteAdapter());

    // Open boxes
    await Hive.openBox<DayLog>(_dayLogsBox);
    await Hive.openBox<Project>(_projectsBox);
    await Hive.openBox<StreakState>(_streakStateBox);
    await Hive.openBox<UserPrefs>(_userPrefsBox);
    await Hive.openBox<CustomHabit>(_customHabitsBox);
    await Hive.openBox<UserStats>(_userStatsBox);
    await Hive.openBox<AchievementNote>(_achievementNotesBox);
  }

  // Day Logs
  static Box<DayLog> get dayLogsBox => Hive.box<DayLog>(_dayLogsBox);

  static Future<void> saveDayLog(DayLog dayLog) async {
    await dayLogsBox.put(dayLog.id, dayLog);
  }

  static DayLog? getDayLog(String id) {
    return dayLogsBox.get(id);
  }

  static DayLog? getDayLogByDate(DateTime date) {
    final id = 'day_${date.toIso8601String().split('T')[0]}';
    return getDayLog(id);
  }

  static List<DayLog> getAllDayLogs() {
    return dayLogsBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<DayLog> getLastNDays(int n) {
    final allLogs = getAllDayLogs();
    return allLogs.take(n).toList();
  }

  // Projects
  static Box<Project> get projectsBox => Hive.box<Project>(_projectsBox);

  static Future<void> saveProject(Project project) async {
    await projectsBox.put(project.id, project);
  }

  static Future<void> deleteProject(String id) async {
    await projectsBox.delete(id);
  }

  static Project? getProject(String id) {
    return projectsBox.get(id);
  }

  static List<Project> getAllProjects() {
    return projectsBox.values.toList();
  }

  static List<Project> getActiveProjects() {
    return projectsBox.values.where((p) => p.active).toList();
  }

  // Streak State
  static Box<StreakState> get streakStateBox => Hive.box<StreakState>(_streakStateBox);

  static Future<void> saveStreakState(StreakState state) async {
    await streakStateBox.put('current', state);
  }

  static StreakState getStreakState() {
    return streakStateBox.get('current') ?? StreakState.createInitial();
  }

  // User Prefs
  static Box<UserPrefs> get userPrefsBox => Hive.box<UserPrefs>(_userPrefsBox);

  static Future<void> saveUserPrefs(UserPrefs prefs) async {
    await userPrefsBox.put('current', prefs);
  }

  static UserPrefs getUserPrefs() {
    return userPrefsBox.get('current') ?? UserPrefs.createDefault();
  }

  // Custom Habits
  static Box<CustomHabit> get customHabitsBox => Hive.box<CustomHabit>(_customHabitsBox);

  static Future<void> saveCustomHabit(CustomHabit habit) async {
    await customHabitsBox.put(habit.id, habit);
  }

  static Future<void> deleteCustomHabit(String id) async {
    await customHabitsBox.delete(id);
  }

  static CustomHabit? getCustomHabit(String id) {
    return customHabitsBox.get(id);
  }

  static List<CustomHabit> getAllCustomHabits() {
    return customHabitsBox.values.toList();
  }

  static List<CustomHabit> getActiveCustomHabits() {
    return customHabitsBox.values.where((h) => h.active).toList();
  }

  // User Stats
  static Box<UserStats> get userStatsBox => Hive.box<UserStats>(_userStatsBox);

  static UserStats getUserStats() {
    return userStatsBox.get('user_stats') ?? UserStats.createInitial();
  }

  static Future<void> saveUserStats(UserStats stats) async {
    await userStatsBox.put('user_stats', stats);
  }

  // Achievement Notes
  static Box<AchievementNote> get achievementNotesBox => Hive.box<AchievementNote>(_achievementNotesBox);

  static Future<void> saveAchievementNote(AchievementNote note) async {
    await achievementNotesBox.put(note.id, note);
  }

  static Future<void> deleteAchievementNote(String id) async {
    await achievementNotesBox.delete(id);
  }

  static AchievementNote? getAchievementNote(String id) {
    return achievementNotesBox.get(id);
  }

  static List<AchievementNote> getAllAchievementNotes() {
    return achievementNotesBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<AchievementNote> getRecentAchievementNotes(int count) {
    final allNotes = getAllAchievementNotes();
    return allNotes.take(count).toList();
  }
}

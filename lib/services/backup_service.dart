import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/achievement_note.dart';
import '../models/challenge.dart';
import '../models/custom_habit.dart';
import '../models/day_log.dart';
import '../models/project.dart';
import '../models/streak_state.dart';
import '../models/user_prefs.dart';
import '../models/user_stats.dart';
import 'hive_service.dart';

class BackupSummary {
  final int dayLogs;
  final int projects;
  final int customHabits;
  final int achievementNotes;
  final int challenges;
  final int currentStreak;
  final int bestStreak;
  final int recoveryTokens;
  final DateTime? exportedAt;
  final String? appVersion;

  BackupSummary({
    required this.dayLogs,
    required this.projects,
    required this.customHabits,
    required this.achievementNotes,
    required this.challenges,
    required this.currentStreak,
    required this.bestStreak,
    required this.recoveryTokens,
    this.exportedAt,
    this.appVersion,
  });
}

class BackupService {
  static const int schemaVersion = 1;
  static const String appVersion = '1.0.0';

  /// Serialize every Hive box to a single JSON map.
  static Map<String, dynamic> _exportToMap() {
    final dayLogsMap = <String, dynamic>{};
    for (final entry in HiveService.dayLogsBox.toMap().entries) {
      dayLogsMap[entry.key.toString()] = (entry.value as DayLog).toJson();
    }

    final projectsMap = <String, dynamic>{};
    for (final entry in HiveService.projectsBox.toMap().entries) {
      projectsMap[entry.key.toString()] = (entry.value as Project).toJson();
    }

    final customHabitsMap = <String, dynamic>{};
    for (final entry in HiveService.customHabitsBox.toMap().entries) {
      customHabitsMap[entry.key.toString()] = (entry.value as CustomHabit).toJson();
    }

    final achievementNotesMap = <String, dynamic>{};
    for (final entry in HiveService.achievementNotesBox.toMap().entries) {
      achievementNotesMap[entry.key.toString()] = (entry.value as AchievementNote).toJson();
    }

    final challengesMap = <String, dynamic>{};
    for (final entry in HiveService.challengesBox.toMap().entries) {
      challengesMap[entry.key.toString()] = (entry.value as Challenge).toJson();
    }

    return {
      'schemaVersion': schemaVersion,
      'appVersion': appVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'dayLogs': dayLogsMap,
      'projects': projectsMap,
      'streakState': HiveService.getStreakState().toJson(),
      'userPrefs': HiveService.getUserPrefs().toJson(),
      'customHabits': customHabitsMap,
      'userStats': HiveService.getUserStats().toJson(),
      'achievementNotes': achievementNotesMap,
      'challenges': challengesMap,
    };
  }

  /// Generate backup JSON string.
  static String exportToJsonString() {
    return const JsonEncoder.withIndent('  ').convert(_exportToMap());
  }

  /// Write backup to a timestamped file in app temp dir.
  static Future<File> writeBackupToFile() async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .split('.')
        .first
        .replaceAll(':', '-');
    final file = File('${dir.path}/loopify-backup-$timestamp.json');
    await file.writeAsString(exportToJsonString());
    return file;
  }

  /// Trigger system share sheet (Gmail, Drive, WhatsApp, Files...).
  static Future<ShareResult> shareBackup() async {
    final file = await writeBackupToFile();
    final result = await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'Loopify Backup',
      text:
          'Loopify habit-tracker backup. Open Loopify on the target device → Settings → Backup & Restore → Import.',
    );
    return result;
  }

  /// Parse a JSON string and return a summary (no writes).
  static BackupSummary previewFromJsonString(String jsonStr) {
    final Map<String, dynamic> json = jsonDecode(jsonStr) as Map<String, dynamic>;

    final streakJson = json['streakState'] as Map<String, dynamic>?;
    final userStatsJson = json['userStats'] as Map<String, dynamic>?;

    return BackupSummary(
      dayLogs: (json['dayLogs'] as Map?)?.length ?? 0,
      projects: (json['projects'] as Map?)?.length ?? 0,
      customHabits: (json['customHabits'] as Map?)?.length ?? 0,
      achievementNotes: (json['achievementNotes'] as Map?)?.length ?? 0,
      challenges: (json['challenges'] as Map?)?.length ?? 0,
      currentStreak: streakJson?['currentStreak'] as int? ?? 0,
      bestStreak: streakJson?['bestStreak'] as int? ?? 0,
      recoveryTokens: userStatsJson?['streakRecoveryTokens'] as int? ?? 0,
      exportedAt: json['exportedAt'] == null
          ? null
          : DateTime.tryParse(json['exportedAt'] as String),
      appVersion: json['appVersion'] as String?,
    );
  }

  /// Summary of CURRENT on-device data (for the import preview dialog).
  static BackupSummary currentSummary() {
    final streak = HiveService.getStreakState();
    final stats = HiveService.getUserStats();
    return BackupSummary(
      dayLogs: HiveService.dayLogsBox.length,
      projects: HiveService.projectsBox.length,
      customHabits: HiveService.customHabitsBox.length,
      achievementNotes: HiveService.achievementNotesBox.length,
      challenges: HiveService.challengesBox.length,
      currentStreak: streak.currentStreak,
      bestStreak: streak.bestStreak,
      recoveryTokens: stats.streakRecoveryTokens,
    );
  }

  /// Save current data as a safety backup before destructive import.
  /// Returns the file written so the UI can show its path.
  static Future<File> createSafetyBackup() async {
    Directory? dir;
    try {
      dir = await getDownloadsDirectory();
    } catch (_) {}
    dir ??= await getApplicationDocumentsDirectory();

    final timestamp = DateTime.now()
        .toIso8601String()
        .split('.')
        .first
        .replaceAll(':', '-');
    final file = File('${dir.path}/loopify-pre-restore-$timestamp.json');
    await file.writeAsString(exportToJsonString());
    return file;
  }

  /// Wipe all boxes and restore from JSON.
  /// Caller MUST call `createSafetyBackup()` first.
  /// After this returns, the app should prompt for a restart so providers
  /// reload from Hive cleanly.
  static Future<void> restoreFromJsonString(String jsonStr) async {
    final Map<String, dynamic> json = jsonDecode(jsonStr) as Map<String, dynamic>;

    final schemaV = json['schemaVersion'] as int? ?? 1;
    if (schemaV > schemaVersion) {
      throw FormatException(
        'Backup uses schema v$schemaV but this app supports up to v$schemaVersion. '
        'Update the app before importing.',
      );
    }

    // 1. dayLogs
    await HiveService.dayLogsBox.clear();
    final dayLogsJson = json['dayLogs'] as Map?;
    if (dayLogsJson != null) {
      for (final entry in dayLogsJson.entries) {
        final log = DayLog.fromJson(Map<String, dynamic>.from(entry.value as Map));
        await HiveService.dayLogsBox.put(entry.key as String, log);
      }
    }

    // 2. projects
    await HiveService.projectsBox.clear();
    final projectsJson = json['projects'] as Map?;
    if (projectsJson != null) {
      for (final entry in projectsJson.entries) {
        final p = Project.fromJson(Map<String, dynamic>.from(entry.value as Map));
        await HiveService.projectsBox.put(entry.key as String, p);
      }
    }

    // 3. streakState (singleton at key 'current')
    final streakJson = json['streakState'] as Map?;
    if (streakJson != null) {
      await HiveService.saveStreakState(
        StreakState.fromJson(Map<String, dynamic>.from(streakJson)),
      );
    }

    // 4. userPrefs (singleton at key 'current')
    final prefsJson = json['userPrefs'] as Map?;
    if (prefsJson != null) {
      await HiveService.saveUserPrefs(
        UserPrefs.fromJson(Map<String, dynamic>.from(prefsJson)),
      );
    }

    // 5. customHabits
    await HiveService.customHabitsBox.clear();
    final customHabitsJson = json['customHabits'] as Map?;
    if (customHabitsJson != null) {
      for (final entry in customHabitsJson.entries) {
        final h = CustomHabit.fromJson(Map<String, dynamic>.from(entry.value as Map));
        await HiveService.customHabitsBox.put(entry.key as String, h);
      }
    }

    // 6. userStats (singleton at key 'user_stats')
    final statsJson = json['userStats'] as Map?;
    if (statsJson != null) {
      await HiveService.saveUserStats(
        UserStats.fromJson(Map<String, dynamic>.from(statsJson)),
      );
    }

    // 7. achievementNotes
    await HiveService.achievementNotesBox.clear();
    final notesJson = json['achievementNotes'] as Map?;
    if (notesJson != null) {
      for (final entry in notesJson.entries) {
        final n = AchievementNote.fromJson(Map<String, dynamic>.from(entry.value as Map));
        await HiveService.achievementNotesBox.put(entry.key as String, n);
      }
    }

    // 8. challenges
    await HiveService.challengesBox.clear();
    final challengesJson = json['challenges'] as Map?;
    if (challengesJson != null) {
      for (final entry in challengesJson.entries) {
        final c = Challenge.fromJson(Map<String, dynamic>.from(entry.value as Map));
        await HiveService.challengesBox.put(entry.key as String, c);
      }
    }
  }
}

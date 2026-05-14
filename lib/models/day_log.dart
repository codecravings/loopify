import 'package:hive/hive.dart';
import 'habit_log.dart';

part 'day_log.g.dart';

@HiveType(typeId: 1)
class DayLog {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String? mood;

  @HiveField(3)
  final String? notes;

  @HiveField(4)
  final HabitLog meditation;

  @HiveField(5)
  final HabitLog serum;

  @HiveField(6)
  final HabitLog coldShower;

  @HiveField(7)
  final HabitLog jawGym;

  @HiveField(8)
  final HabitLog chewQuest;

  @HiveField(9)
  final HabitLog protein;

  @HiveField(10)
  final HabitLog study;

  @HiveField(11)
  final HabitLog chess;

  @HiveField(12)
  final HabitLog cycling;

  @HiveField(13)
  final HabitLog buildStreak;

  @HiveField(14)
  final HabitLog madScientist;

  @HiveField(15)
  final Map<String, HabitLog>? customHabits;

  DayLog({
    required this.id,
    required this.date,
    this.mood,
    this.notes,
    required this.meditation,
    required this.serum,
    required this.coldShower,
    required this.jawGym,
    required this.chewQuest,
    required this.protein,
    required this.study,
    required this.chess,
    required this.cycling,
    required this.buildStreak,
    required this.madScientist,
    this.customHabits,
  });

  int get totalHabitsLogged {
    int count = 0;
    if (meditation.logged) count++;
    if (serum.logged) count++;
    if (coldShower.logged) count++;
    if (jawGym.logged) count++;
    if (chewQuest.logged) count++;
    if (protein.logged) count++;
    if (study.logged) count++;
    if (chess.logged) count++;
    if (cycling.logged) count++;
    if (buildStreak.logged) count++;
    if (madScientist.logged) count++;
    // Add custom habits count
    if (customHabits != null) {
      count += customHabits!.values.where((h) => h.logged).length;
    }
    return count;
  }

  int get totalFocusMinutes {
    int total = 0;
    if (meditation.seconds != null) total += (meditation.seconds! / 60).round();
    if (study.seconds != null) total += (study.seconds! / 60).round();
    if (chess.seconds != null) total += (chess.seconds! / 60).round();
    if (cycling.seconds != null) total += (cycling.seconds! / 60).round();
    return total;
  }

  DayLog copyWith({
    String? id,
    DateTime? date,
    String? mood,
    String? notes,
    HabitLog? meditation,
    HabitLog? serum,
    HabitLog? coldShower,
    HabitLog? jawGym,
    HabitLog? chewQuest,
    HabitLog? protein,
    HabitLog? study,
    HabitLog? chess,
    HabitLog? cycling,
    HabitLog? buildStreak,
    HabitLog? madScientist,
    Map<String, HabitLog>? customHabits,
  }) {
    return DayLog(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      notes: notes ?? this.notes,
      meditation: meditation ?? this.meditation,
      serum: serum ?? this.serum,
      coldShower: coldShower ?? this.coldShower,
      jawGym: jawGym ?? this.jawGym,
      chewQuest: chewQuest ?? this.chewQuest,
      protein: protein ?? this.protein,
      study: study ?? this.study,
      chess: chess ?? this.chess,
      cycling: cycling ?? this.cycling,
      buildStreak: buildStreak ?? this.buildStreak,
      madScientist: madScientist ?? this.madScientist,
      customHabits: customHabits ?? this.customHabits,
    );
  }

  static DayLog createEmpty(DateTime date) {
    return DayLog(
      id: 'day_${date.toIso8601String().split('T')[0]}',
      date: date,
      meditation: HabitLog(logged: false),
      serum: HabitLog(logged: false),
      coldShower: HabitLog(logged: false),
      jawGym: HabitLog(logged: false),
      chewQuest: HabitLog(logged: false),
      protein: HabitLog(logged: false),
      study: HabitLog(logged: false),
      chess: HabitLog(logged: false),
      cycling: HabitLog(logged: false),
      buildStreak: HabitLog(logged: false),
      madScientist: HabitLog(logged: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'mood': mood,
        'notes': notes,
        'meditation': meditation.toJson(),
        'serum': serum.toJson(),
        'coldShower': coldShower.toJson(),
        'jawGym': jawGym.toJson(),
        'chewQuest': chewQuest.toJson(),
        'protein': protein.toJson(),
        'study': study.toJson(),
        'chess': chess.toJson(),
        'cycling': cycling.toJson(),
        'buildStreak': buildStreak.toJson(),
        'madScientist': madScientist.toJson(),
        'customHabits': customHabits?.map((k, v) => MapEntry(k, v.toJson())),
      };

  factory DayLog.fromJson(Map<String, dynamic> json) => DayLog(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        mood: json['mood'] as String?,
        notes: json['notes'] as String?,
        meditation: HabitLog.fromJson(Map<String, dynamic>.from(json['meditation'] as Map)),
        serum: HabitLog.fromJson(Map<String, dynamic>.from(json['serum'] as Map)),
        coldShower: HabitLog.fromJson(Map<String, dynamic>.from(json['coldShower'] as Map)),
        jawGym: HabitLog.fromJson(Map<String, dynamic>.from(json['jawGym'] as Map)),
        chewQuest: HabitLog.fromJson(Map<String, dynamic>.from(json['chewQuest'] as Map)),
        protein: HabitLog.fromJson(Map<String, dynamic>.from(json['protein'] as Map)),
        study: HabitLog.fromJson(Map<String, dynamic>.from(json['study'] as Map)),
        chess: HabitLog.fromJson(Map<String, dynamic>.from(json['chess'] as Map)),
        cycling: HabitLog.fromJson(Map<String, dynamic>.from(json['cycling'] as Map)),
        buildStreak: HabitLog.fromJson(Map<String, dynamic>.from(json['buildStreak'] as Map)),
        madScientist: HabitLog.fromJson(Map<String, dynamic>.from(json['madScientist'] as Map)),
        customHabits: (json['customHabits'] as Map?)?.map(
          (k, v) => MapEntry(k as String, HabitLog.fromJson(Map<String, dynamic>.from(v as Map))),
        ),
      );
}

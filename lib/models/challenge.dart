import 'package:hive/hive.dart';

part 'challenge.g.dart';

@HiveType(typeId: 8)
class Challenge {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitName; // DayLog field name or custom habit ID

  @HiveField(2)
  final String habitDisplayName;

  @HiveField(3)
  final bool isCustomHabit;

  @HiveField(4)
  final DateTime deadlineTime;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final int status; // 0=active, 1=completed, 2=cancelled, 3=expired

  @HiveField(7)
  final DateTime? completedAt;

  @HiveField(8)
  final int saveChoice; // 0=not chosen, 1=save to DayLog, 2=save as badge

  @HiveField(9)
  final DateTime? snoozedUntil;

  @HiveField(10)
  final int snoozeCount;

  Challenge({
    required this.id,
    required this.habitName,
    required this.habitDisplayName,
    required this.isCustomHabit,
    required this.deadlineTime,
    required this.createdAt,
    this.status = 0,
    this.completedAt,
    this.saveChoice = 0,
    this.snoozedUntil,
    this.snoozeCount = 0,
  });

  bool get isActive => status == 0;
  bool get isCompleted => status == 1;
  bool get isCancelled => status == 2;
  bool get isExpired => status == 3;

  bool get isSnoozed =>
      snoozedUntil != null && DateTime.now().isBefore(snoozedUntil!);

  DateTime get effectiveDeadline => snoozedUntil ?? deadlineTime;

  bool get isOverdue => isActive && DateTime.now().isAfter(effectiveDeadline);

  factory Challenge.create({
    required String habitName,
    required String habitDisplayName,
    required bool isCustomHabit,
    required DateTime deadlineTime,
  }) {
    return Challenge(
      id: 'challenge_${DateTime.now().millisecondsSinceEpoch}',
      habitName: habitName,
      habitDisplayName: habitDisplayName,
      isCustomHabit: isCustomHabit,
      deadlineTime: deadlineTime,
      createdAt: DateTime.now(),
    );
  }

  Challenge copyWith({
    String? id,
    String? habitName,
    String? habitDisplayName,
    bool? isCustomHabit,
    DateTime? deadlineTime,
    DateTime? createdAt,
    int? status,
    DateTime? completedAt,
    int? saveChoice,
    DateTime? snoozedUntil,
    int? snoozeCount,
  }) {
    return Challenge(
      id: id ?? this.id,
      habitName: habitName ?? this.habitName,
      habitDisplayName: habitDisplayName ?? this.habitDisplayName,
      isCustomHabit: isCustomHabit ?? this.isCustomHabit,
      deadlineTime: deadlineTime ?? this.deadlineTime,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      saveChoice: saveChoice ?? this.saveChoice,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      snoozeCount: snoozeCount ?? this.snoozeCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'habitName': habitName,
        'habitDisplayName': habitDisplayName,
        'isCustomHabit': isCustomHabit,
        'deadlineTime': deadlineTime.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'status': status,
        'completedAt': completedAt?.toIso8601String(),
        'saveChoice': saveChoice,
        'snoozedUntil': snoozedUntil?.toIso8601String(),
        'snoozeCount': snoozeCount,
      };

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
        id: json['id'] as String,
        habitName: json['habitName'] as String,
        habitDisplayName: json['habitDisplayName'] as String,
        isCustomHabit: json['isCustomHabit'] as bool,
        deadlineTime: DateTime.parse(json['deadlineTime'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: json['status'] as int? ?? 0,
        completedAt: json['completedAt'] == null
            ? null
            : DateTime.parse(json['completedAt'] as String),
        saveChoice: json['saveChoice'] as int? ?? 0,
        snoozedUntil: json['snoozedUntil'] == null
            ? null
            : DateTime.parse(json['snoozedUntil'] as String),
        snoozeCount: json['snoozeCount'] as int? ?? 0,
      );
}

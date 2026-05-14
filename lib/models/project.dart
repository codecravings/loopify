import 'package:hive/hive.dart';

part 'project.g.dart';

@HiveType(typeId: 2)
class Project {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String colorHex;

  @HiveField(3)
  final String icon;

  @HiveField(4)
  final bool active;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime? archivedAt;

  @HiveField(7, defaultValue: '')
  final String description;

  @HiveField(8, defaultValue: [])
  final List<String> milestones;

  @HiveField(9, defaultValue: [])
  final List<bool> milestoneCompleted;

  @HiveField(10)
  final DateTime? targetDate;

  @HiveField(11, defaultValue: 0)
  final int hoursSpent;

  @HiveField(12, defaultValue: [])
  final List<DateTime> sessionDates;

  Project({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.icon,
    required this.active,
    required this.createdAt,
    this.archivedAt,
    this.description = '',
    List<String>? milestones,
    List<bool>? milestoneCompleted,
    this.targetDate,
    this.hoursSpent = 0,
    List<DateTime>? sessionDates,
  })  : milestones = milestones ?? const [],
        milestoneCompleted = milestoneCompleted ?? const [],
        sessionDates = sessionDates ?? const [];

  Project copyWith({
    String? id,
    String? name,
    String? colorHex,
    String? icon,
    bool? active,
    DateTime? createdAt,
    DateTime? archivedAt,
    String? description,
    List<String>? milestones,
    List<bool>? milestoneCompleted,
    DateTime? targetDate,
    int? hoursSpent,
    List<DateTime>? sessionDates,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      icon: icon ?? this.icon,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      description: description ?? this.description,
      milestones: milestones ?? this.milestones,
      milestoneCompleted: milestoneCompleted ?? this.milestoneCompleted,
      targetDate: targetDate ?? this.targetDate,
      hoursSpent: hoursSpent ?? this.hoursSpent,
      sessionDates: sessionDates ?? this.sessionDates,
    );
  }

  // Calculate project completion percentage
  double get completionPercentage {
    if (milestones.isEmpty) return 0.0;
    final completed = milestoneCompleted.where((m) => m).length;
    return (completed / milestones.length) * 100;
  }

  // Get number of days since project started
  int get daysActive {
    return DateTime.now().difference(createdAt).inDays;
  }

  // Get number of working sessions
  int get totalSessions {
    return sessionDates.length;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorHex': colorHex,
        'icon': icon,
        'active': active,
        'createdAt': createdAt.toIso8601String(),
        'archivedAt': archivedAt?.toIso8601String(),
        'description': description,
        'milestones': milestones,
        'milestoneCompleted': milestoneCompleted,
        'targetDate': targetDate?.toIso8601String(),
        'hoursSpent': hoursSpent,
        'sessionDates': sessionDates.map((d) => d.toIso8601String()).toList(),
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        name: json['name'] as String,
        colorHex: json['colorHex'] as String,
        icon: json['icon'] as String,
        active: json['active'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        archivedAt: json['archivedAt'] == null ? null : DateTime.parse(json['archivedAt'] as String),
        description: json['description'] as String? ?? '',
        milestones: (json['milestones'] as List?)?.map((e) => e as String).toList() ?? const [],
        milestoneCompleted:
            (json['milestoneCompleted'] as List?)?.map((e) => e as bool).toList() ?? const [],
        targetDate: json['targetDate'] == null ? null : DateTime.parse(json['targetDate'] as String),
        hoursSpent: json['hoursSpent'] as int? ?? 0,
        sessionDates:
            (json['sessionDates'] as List?)?.map((e) => DateTime.parse(e as String)).toList() ??
                const [],
      );
}

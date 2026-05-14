import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'custom_habit.g.dart';

@HiveType(typeId: 5)
class CustomHabit {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String microcopy;

  @HiveField(3)
  final int iconCodePoint;

  @HiveField(4)
  final int colorValue;

  @HiveField(5)
  final bool isDuration;

  @HiveField(6)
  final bool isNumeric;

  @HiveField(7)
  final String? unit; // For numeric habits (e.g., "cups", "pages", "reps")

  @HiveField(8)
  final int? target; // For numeric habits

  @HiveField(9)
  final bool active;

  @HiveField(10)
  final DateTime createdAt;

  CustomHabit({
    required this.id,
    required this.name,
    required this.microcopy,
    required this.iconCodePoint,
    required this.colorValue,
    this.isDuration = false,
    this.isNumeric = false,
    this.unit,
    this.target,
    this.active = true,
    required this.createdAt,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  CustomHabit copyWith({
    String? id,
    String? name,
    String? microcopy,
    int? iconCodePoint,
    int? colorValue,
    bool? isDuration,
    bool? isNumeric,
    String? unit,
    int? target,
    bool? active,
    DateTime? createdAt,
  }) {
    return CustomHabit(
      id: id ?? this.id,
      name: name ?? this.name,
      microcopy: microcopy ?? this.microcopy,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      isDuration: isDuration ?? this.isDuration,
      isNumeric: isNumeric ?? this.isNumeric,
      unit: unit ?? this.unit,
      target: target ?? this.target,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static CustomHabit create({
    required String name,
    required String microcopy,
    required IconData icon,
    required Color color,
    bool isDuration = false,
    bool isNumeric = false,
    String? unit,
    int? target,
  }) {
    return CustomHabit(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      microcopy: microcopy,
      iconCodePoint: icon.codePoint,
      colorValue: color.value,
      isDuration: isDuration,
      isNumeric: isNumeric,
      unit: unit,
      target: target,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'microcopy': microcopy,
        'iconCodePoint': iconCodePoint,
        'colorValue': colorValue,
        'isDuration': isDuration,
        'isNumeric': isNumeric,
        'unit': unit,
        'target': target,
        'active': active,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CustomHabit.fromJson(Map<String, dynamic> json) => CustomHabit(
        id: json['id'] as String,
        name: json['name'] as String,
        microcopy: json['microcopy'] as String,
        iconCodePoint: json['iconCodePoint'] as int,
        colorValue: json['colorValue'] as int,
        isDuration: json['isDuration'] as bool? ?? false,
        isNumeric: json['isNumeric'] as bool? ?? false,
        unit: json['unit'] as String?,
        target: json['target'] as int?,
        active: json['active'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

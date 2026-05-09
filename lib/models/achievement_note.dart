import 'package:hive/hive.dart';

part 'achievement_note.g.dart';

@HiveType(typeId: 10)
class AchievementNote {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String note;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String emoji;

  @HiveField(4)
  final int category; // 0: Personal, 1: Fitness, 2: Learning, 3: Work, 4: Other

  AchievementNote({
    required this.id,
    required this.note,
    required this.date,
    this.emoji = '🏆',
    this.category = 0,
  });

  String get categoryName {
    switch (category) {
      case 0:
        return 'Personal';
      case 1:
        return 'Fitness';
      case 2:
        return 'Learning';
      case 3:
        return 'Work';
      default:
        return 'Other';
    }
  }

  String get categoryEmoji {
    switch (category) {
      case 0:
        return '✨';
      case 1:
        return '💪';
      case 2:
        return '📚';
      case 3:
        return '💼';
      default:
        return '🎯';
    }
  }
}

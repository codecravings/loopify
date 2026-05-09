import 'package:hive/hive.dart';

part 'habit_log.g.dart';

@HiveType(typeId: 0)
class HabitLog {
  @HiveField(0)
  final bool logged;

  @HiveField(1)
  final int? seconds; // For meditation, study, chess, cycling (stored as seconds)

  @HiveField(2)
  final int? minutes; // For chewQuest

  @HiveField(3)
  final int? grams; // For protein

  @HiveField(4)
  final List<String>? projectIds; // For buildStreak

  HabitLog({
    required this.logged,
    this.seconds,
    this.minutes,
    this.grams,
    this.projectIds,
  });

  HabitLog copyWith({
    bool? logged,
    int? seconds,
    int? minutes,
    int? grams,
    List<String>? projectIds,
  }) {
    return HabitLog(
      logged: logged ?? this.logged,
      seconds: seconds ?? this.seconds,
      minutes: minutes ?? this.minutes,
      grams: grams ?? this.grams,
      projectIds: projectIds ?? this.projectIds,
    );
  }
}

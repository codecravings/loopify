import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/day_log.dart';
import '../models/habit_log.dart';
import '../services/hive_service.dart';

final currentDayLogProvider = StateNotifierProvider<DayLogNotifier, DayLog>((ref) {
  return DayLogNotifier();
});

class DayLogNotifier extends StateNotifier<DayLog> {
  DayLogNotifier() : super(_loadOrCreateToday()); 

  static DayLog _loadOrCreateToday() {
    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);
    final existing = HiveService.getDayLogByDate(normalized);
    if (existing != null) {
      return existing;
    }
    final newLog = DayLog.createEmpty(normalized);
    HiveService.saveDayLog(newLog);
    return newLog;
  }

  Future<void> updateHabit(String habitName, HabitLog habitLog) async {
    DayLog updated;
    switch (habitName) {
      case 'meditation':
        updated = state.copyWith(meditation: habitLog);
        break;
      case 'serum':
        updated = state.copyWith(serum: habitLog);
        break;
      case 'coldShower':
        updated = state.copyWith(coldShower: habitLog);
        break;
      case 'jawGym':
        updated = state.copyWith(jawGym: habitLog);
        break;
      case 'chewQuest':
        updated = state.copyWith(chewQuest: habitLog);
        break;
      case 'protein':
        updated = state.copyWith(protein: habitLog);
        break;
      case 'study':
        updated = state.copyWith(study: habitLog);
        break;
      case 'chess':
        updated = state.copyWith(chess: habitLog);
        break;
      case 'cycling':
        updated = state.copyWith(cycling: habitLog);
        break;
      case 'buildStreak':
        updated = state.copyWith(buildStreak: habitLog);
        break;
      case 'madScientist':
        updated = state.copyWith(madScientist: habitLog);
        break;
      default:
        // Handle custom habits
        final customHabits = Map<String, HabitLog>.from(state.customHabits ?? {});
        customHabits[habitName] = habitLog;
        updated = state.copyWith(customHabits: customHabits);
    }
    state = updated;
    await HiveService.saveDayLog(updated);
  }

  HabitLog getHabit(String habitName) {
    switch (habitName) {
      case 'meditation':
        return state.meditation;
      case 'serum':
        return state.serum;
      case 'coldShower':
        return state.coldShower;
      case 'jawGym':
        return state.jawGym;
      case 'chewQuest':
        return state.chewQuest;
      case 'protein':
        return state.protein;
      case 'study':
        return state.study;
      case 'chess':
        return state.chess;
      case 'cycling':
        return state.cycling;
      case 'buildStreak':
        return state.buildStreak;
      case 'madScientist':
        return state.madScientist;
      default:
        // Check custom habits
        if (state.customHabits != null && state.customHabits!.containsKey(habitName)) {
          return state.customHabits![habitName]!;
        }
        return HabitLog(logged: false);
    }
  }

  void resetForNewDay() {
    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);
    final newLog = DayLog.createEmpty(normalized);
    state = newLog;
    HiveService.saveDayLog(newLog);
  }
}

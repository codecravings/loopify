import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/custom_habit.dart';
import '../services/hive_service.dart';

class CustomHabitNotifier extends StateNotifier<List<CustomHabit>> {
  CustomHabitNotifier() : super([]) {
    _loadCustomHabits();
  }

  void _loadCustomHabits() {
    state = HiveService.getAllCustomHabits();
  }

  Future<void> addCustomHabit(CustomHabit habit) async {
    await HiveService.saveCustomHabit(habit);
    state = [...state, habit];
  }

  Future<void> updateCustomHabit(CustomHabit habit) async {
    await HiveService.saveCustomHabit(habit);
    state = [
      for (final h in state)
        if (h.id == habit.id) habit else h
    ];
  }

  Future<void> deleteCustomHabit(String id) async {
    await HiveService.deleteCustomHabit(id);
    state = state.where((h) => h.id != id).toList();
  }

  Future<void> toggleActive(String id) async {
    final habit = state.firstWhere((h) => h.id == id);
    final updated = habit.copyWith(active: !habit.active);
    await updateCustomHabit(updated);
  }
}

final customHabitsProvider = StateNotifierProvider<CustomHabitNotifier, List<CustomHabit>>((ref) {
  return CustomHabitNotifier();
});

final activeCustomHabitsProvider = Provider<List<CustomHabit>>((ref) {
  final allHabits = ref.watch(customHabitsProvider);
  return allHabits.where((h) => h.active).toList();
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/custom_habit.dart';
import '../providers/custom_habit_provider.dart';
import '../providers/user_prefs_provider.dart';
import '../constants/habits.dart';
import '../widgets/add_custom_habit_dialog.dart';

class ManageHabitsScreen extends ConsumerWidget {
  const ManageHabitsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customHabits = ref.watch(customHabitsProvider);
    final userPrefs = ref.watch(userPrefsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E21),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1D1E33),
          title: const Text('Manage Habits'),
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Color(0xFFFF6B35),
            labelColor: Color(0xFFFF6B35),
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Default Habits'),
              Tab(text: 'Custom Habits'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AddCustomHabitDialog(),
            );
          },
          backgroundColor: const Color(0xFFFF6B35),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add Habit',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: TabBarView(
          children: [
            // Default Habits Tab
            _DefaultHabitsTab(hiddenHabits: userPrefs.hiddenHabits),
            // Custom Habits Tab
            _CustomHabitsTab(customHabits: customHabits),
          ],
        ),
      ),
    );
  }
}

class _DefaultHabitsTab extends ConsumerWidget {
  final List<String> hiddenHabits;

  const _DefaultHabitsTab({required this.hiddenHabits});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: HabitType.values.length,
      itemBuilder: (context, index) {
        final habitType = HabitType.values[index];
        final info = habitDetails[habitType]!;
        final habitName = habitType.toString().split('.').last;
        final isHidden = hiddenHabits.contains(habitName);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1D1E33),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHidden
                  ? Colors.white.withOpacity(0.1)
                  : info.color.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isHidden
                    ? Colors.grey.withOpacity(0.2)
                    : info.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                info.icon,
                color: isHidden ? Colors.grey : info.color,
                size: 24,
              ),
            ),
            title: Text(
              info.name,
              style: TextStyle(
                color: isHidden ? Colors.white38 : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: isHidden ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              info.microcopy,
              style: TextStyle(
                color: Colors.white.withOpacity(isHidden ? 0.3 : 0.6),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Switch(
              value: !isHidden,
              onChanged: (value) {
                ref.read(userPrefsProvider.notifier).toggleHabitVisibility(habitName);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value ? '${info.name} enabled' : '${info.name} hidden',
                    ),
                    backgroundColor: value ? info.color : Colors.grey,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              activeColor: info.color,
              activeTrackColor: info.color.withOpacity(0.3),
            ),
          ),
        );
      },
    );
  }
}

class _CustomHabitsTab extends StatelessWidget {
  final List<CustomHabit> customHabits;

  const _CustomHabitsTab({required this.customHabits});

  @override
  Widget build(BuildContext context) {
    if (customHabits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No custom habits yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to create your first custom habit!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: customHabits.length,
      itemBuilder: (context, index) {
        final habit = customHabits[index];
        return _CustomHabitCard(habit: habit);
      },
    );
  }
}

class _CustomHabitCard extends ConsumerWidget {
  final CustomHabit habit;

  const _CustomHabitCard({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: habit.active
              ? habit.color.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: habit.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                habit.icon,
                color: habit.color,
                size: 28,
              ),
            ),
            title: Text(
              habit.name,
              style: TextStyle(
                color: habit.active ? Colors.white : Colors.white.withOpacity(0.5),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  habit.microcopy,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _TypeBadge(
                      label: habit.isDuration
                          ? 'Duration'
                          : habit.isNumeric
                              ? 'Numeric'
                              : 'Simple',
                      color: habit.color,
                    ),
                    if (!habit.active) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Inactive',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white.withOpacity(0.7),
              ),
              color: const Color(0xFF0A0E21),
              onSelected: (value) {
                switch (value) {
                  case 'toggle':
                    ref.read(customHabitsProvider.notifier).toggleActive(habit.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          habit.active
                              ? '${habit.name} disabled'
                              : '${habit.name} enabled',
                        ),
                        backgroundColor: habit.color,
                      ),
                    );
                    break;
                  case 'delete':
                    _showDeleteDialog(context, ref, habit);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        habit.active ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        habit.active ? 'Disable' : 'Enable',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, CustomHabit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Custom Habit?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${habit.name}"? All progress data will be lost.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(customHabitsProvider.notifier).deleteCustomHabit(habit.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${habit.name} deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/custom_habit.dart';
import '../models/habit_log.dart';
import 'morph_chip.dart';

class CustomHabitChip extends StatelessWidget {
  final CustomHabit habit;
  final HabitLog habitLog;
  final Function(HabitLog) onConfirm;

  const CustomHabitChip({
    Key? key,
    required this.habit,
    required this.habitLog,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (habitLog.logged) return;

        if (habit.isDuration) {
          _showDurationPicker(context);
        } else if (habit.isNumeric) {
          _showNumericPicker(context);
        } else {
          // Simple habit - just log it
          onConfirm(HabitLog(logged: true));
        }
      },
      onLongPress: habitLog.logged ? () => _showEditDeleteDialog(context) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: habitLog.logged
              ? habit.color.withOpacity(0.2)
              : const Color(0xFF1D1E33),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: habitLog.logged
                ? habit.color
                : habit.color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: habit.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                habit.icon,
                color: habit.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    habit.microcopy,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                  if (habitLog.logged && habitLog.seconds != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${(habitLog.seconds! / 60).round()} min',
                        style: TextStyle(
                          color: habit.color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (habitLog.logged && habitLog.grams != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${habitLog.grams} ${habit.unit ?? ''}',
                        style: TextStyle(
                          color: habit.color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Checkmark
            if (habitLog.logged)
              Icon(
                Icons.check_circle,
                color: habit.color,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  void _showDurationPicker(BuildContext context) {
    int selectedMinutes = 5;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1D1E33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            habit.name,
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How long? (minutes)',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (selectedMinutes > 5) {
                        setState(() => selectedMinutes -= 5);
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                  ),
                  Text(
                    '$selectedMinutes min',
                    style: TextStyle(
                      color: habit.color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => selectedMinutes += 5),
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                onConfirm(HabitLog(
                  logged: true,
                  seconds: selectedMinutes * 60,
                ));
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: habit.color,
              ),
              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showNumericPicker(BuildContext context) {
    int selectedCount = habit.target ?? 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1D1E33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            habit.name,
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How many ${habit.unit ?? 'times'}?',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (selectedCount > 1) {
                        setState(() => selectedCount--);
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                  ),
                  Text(
                    '$selectedCount ${habit.unit ?? ''}',
                    style: TextStyle(
                      color: habit.color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => selectedCount++),
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                onConfirm(HabitLog(
                  logged: true,
                  grams: selectedCount, // Using grams field for numeric values
                ));
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: habit.color,
              ),
              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          habit.name,
          style: const TextStyle(color: Colors.white),
        ),
        content: const Text(
          'What would you like to do?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editCustomHabit(context);
            },
            child: Text(
              'Edit',
              style: TextStyle(color: habit.color),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCustomHabit(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editCustomHabit(BuildContext context) {
    if (habit.isDuration) {
      _editDuration(context);
    } else if (habit.isNumeric) {
      _editNumeric(context);
    } else {
      // Simple habits can only be deleted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Simple habits can only be deleted, not edited.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _editDuration(BuildContext context) {
    int selectedMinutes = ((habitLog.seconds ?? 300) / 60).round();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1D1E33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Edit ${habit.name}',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How long? (minutes)',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (selectedMinutes > 5) {
                        setState(() => selectedMinutes -= 5);
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                  ),
                  Text(
                    '$selectedMinutes min',
                    style: TextStyle(
                      color: habit.color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => selectedMinutes += 5),
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                onConfirm(HabitLog(
                  logged: true,
                  seconds: selectedMinutes * 60,
                ));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${habit.name} updated!'),
                    backgroundColor: habit.color,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: habit.color,
              ),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _editNumeric(BuildContext context) {
    int selectedCount = habitLog.grams ?? habit.target ?? 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1D1E33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Edit ${habit.name}',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How many ${habit.unit ?? 'times'}?',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (selectedCount > 1) {
                        setState(() => selectedCount--);
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                  ),
                  Text(
                    '$selectedCount ${habit.unit ?? ''}',
                    style: TextStyle(
                      color: habit.color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => selectedCount++),
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                onConfirm(HabitLog(
                  logged: true,
                  grams: selectedCount,
                ));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${habit.name} updated!'),
                    backgroundColor: habit.color,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: habit.color,
              ),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCustomHabit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Habit?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove ${habit.name} from today\'s log?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm(HabitLog(logged: false));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${habit.name} removed from today\'s log'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

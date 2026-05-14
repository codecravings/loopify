import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/habits.dart';
import '../models/challenge.dart';
import '../providers/challenge_provider.dart';
import '../providers/user_prefs_provider.dart';
import '../providers/custom_habit_provider.dart';

class SetChallengeDialog extends ConsumerStatefulWidget {
  const SetChallengeDialog({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SetChallengeDialog(),
    );
  }

  @override
  ConsumerState<SetChallengeDialog> createState() => _SetChallengeDialogState();
}

class _SetChallengeDialogState extends ConsumerState<SetChallengeDialog> {
  String? _selectedHabitName;
  String? _selectedDisplayName;
  bool _selectedIsCustom = false;
  bool _isCustomEntry = false;
  TimeOfDay? _selectedTime;
  final _customNameController = TextEditingController();

  @override
  void dispose() {
    _customNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userPrefs = ref.watch(userPrefsProvider);
    final customHabits = ref.watch(activeCustomHabitsProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // Build list of visible predefined habits
    final visibleHabits = HabitType.values
        .where((h) => !userPrefs.hiddenHabits.contains(h.toString().split('.').last))
        .toList();

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF1D1E33),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              const Row(
                children: [
                  Icon(Icons.timer, color: Colors.purpleAccent, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'SET A CHALLENGE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Challenge yourself — pick a habit or type anything',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // Custom text entry
              const Text(
                'CUSTOM CHALLENGE',
                style: TextStyle(
                  color: Colors.purpleAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _customNameController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'e.g. "Finish homework", "Call mom", "Run 2km"...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 13),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  prefixIcon: Icon(Icons.edit, color: Colors.purpleAccent.withOpacity(0.5), size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.purpleAccent),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.trim().isNotEmpty) {
                      _isCustomEntry = true;
                      _selectedHabitName = 'custom_challenge';
                      _selectedDisplayName = value.trim();
                      _selectedIsCustom = false;
                    } else {
                      _isCustomEntry = false;
                      if (_selectedHabitName == 'custom_challenge') {
                        _selectedHabitName = null;
                        _selectedDisplayName = null;
                      }
                    }
                  });
                },
              ),

              const SizedBox(height: 16),

              // Divider with OR
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR PICK A HABIT',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                ],
              ),

              const SizedBox(height: 12),

              // Predefined habits section
              Text(
                'YOUR HABITS',
                style: TextStyle(
                  color: _isCustomEntry ? Colors.white.withOpacity(0.2) : Colors.purpleAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...visibleHabits.map((habitType) {
                    final info = habitDetails[habitType]!;
                    final habitName = habitType.toString().split('.').last;
                    final isSelected = !_isCustomEntry && _selectedHabitName == habitName;
                    return _HabitChip(
                      label: info.name,
                      icon: info.icon,
                      color: info.color,
                      isSelected: isSelected,
                      dimmed: _isCustomEntry,
                      onTap: () {
                        setState(() {
                          _isCustomEntry = false;
                          _customNameController.clear();
                          _selectedHabitName = habitName;
                          _selectedDisplayName = info.name;
                          _selectedIsCustom = false;
                        });
                      },
                    );
                  }),
                ],
              ),

              // Custom habits section
              if (customHabits.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'CUSTOM HABITS',
                  style: TextStyle(
                    color: _isCustomEntry ? Colors.white.withOpacity(0.2) : Colors.purpleAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: customHabits.map((habit) {
                    final isSelected = !_isCustomEntry && _selectedHabitName == habit.id;
                    return _HabitChip(
                      label: habit.name,
                      icon: habit.icon,
                      color: habit.color,
                      isSelected: isSelected,
                      dimmed: _isCustomEntry,
                      onTap: () {
                        setState(() {
                          _isCustomEntry = false;
                          _customNameController.clear();
                          _selectedHabitName = habit.id;
                          _selectedDisplayName = habit.name;
                          _selectedIsCustom = true;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 20),

              // Deadline section
              const Text(
                'DEADLINE',
                style: TextStyle(
                  color: Colors.purpleAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now().replacing(
                      hour: (TimeOfDay.now().hour + 1) % 24,
                    ),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Colors.purpleAccent,
                            surface: Color(0xFF1D1E33),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTime = time;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedTime != null
                          ? Colors.purpleAccent.withOpacity(0.5)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: _selectedTime != null ? Colors.purpleAccent : Colors.white38,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime != null
                            ? 'Before ${_selectedTime!.format(context)}'
                            : 'Tap to set deadline time',
                        style: TextStyle(
                          color: _selectedTime != null ? Colors.white : Colors.white38,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quick time presets
              const SizedBox(height: 10),
              Row(
                children: [
                  _TimePreset(
                    label: '+30m',
                    isSelected: false,
                    onTap: () {
                      final now = TimeOfDay.now();
                      final totalMinutes = now.hour * 60 + now.minute + 30;
                      setState(() {
                        _selectedTime = TimeOfDay(
                          hour: (totalMinutes ~/ 60) % 24,
                          minute: totalMinutes % 60,
                        );
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _TimePreset(
                    label: '+1h',
                    isSelected: false,
                    onTap: () {
                      final now = TimeOfDay.now();
                      setState(() {
                        _selectedTime = TimeOfDay(
                          hour: (now.hour + 1) % 24,
                          minute: now.minute,
                        );
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _TimePreset(
                    label: '+2h',
                    isSelected: false,
                    onTap: () {
                      final now = TimeOfDay.now();
                      setState(() {
                        _selectedTime = TimeOfDay(
                          hour: (now.hour + 2) % 24,
                          minute: now.minute,
                        );
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _TimePreset(
                    label: '+4h',
                    isSelected: false,
                    onTap: () {
                      final now = TimeOfDay.now();
                      setState(() {
                        _selectedTime = TimeOfDay(
                          hour: (now.hour + 4) % 24,
                          minute: now.minute,
                        );
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _canSubmit ? () => _createChallenge(context) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.purpleAccent.withOpacity(0.2),
                        disabledForegroundColor: Colors.white.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'SET CHALLENGE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canSubmit {
    final hasSelection = _selectedHabitName != null && _selectedDisplayName != null;
    final hasTime = _selectedTime != null;
    return hasSelection && hasTime;
  }

  void _createChallenge(BuildContext context) {
    final now = DateTime.now();
    final deadline = DateTime(
      now.year, now.month, now.day,
      _selectedTime!.hour, _selectedTime!.minute,
    );

    if (deadline.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deadline must be in the future!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final challenge = Challenge.create(
      habitName: _isCustomEntry ? 'custom_challenge' : _selectedHabitName!,
      habitDisplayName: _selectedDisplayName!,
      isCustomHabit: _isCustomEntry || _selectedIsCustom,
      deadlineTime: deadline,
    );

    ref.read(challengeProvider.notifier).addChallenge(challenge);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Challenge set: $_selectedDisplayName before ${_selectedTime!.format(context)}'),
        backgroundColor: Colors.purpleAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _HabitChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final bool dimmed;
  final VoidCallback onTap;

  const _HabitChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    this.dimmed = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = dimmed ? color.withOpacity(0.3) : color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? effectiveColor.withOpacity(0.3) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? effectiveColor : Colors.white.withOpacity(dimmed ? 0.05 : 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? effectiveColor : (dimmed ? Colors.white24 : Colors.white54), size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : (dimmed ? Colors.white24 : Colors.white54),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePreset extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimePreset({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.purpleAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.purpleAccent,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

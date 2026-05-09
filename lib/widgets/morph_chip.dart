import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/habits.dart';
import '../models/habit_log.dart';

class MorphChip extends StatefulWidget {
  final HabitType habitType;
  final HabitLog habitLog;
  final Function(HabitLog) onConfirm;
  final VoidCallback? onEdit; // Callback for editing the habit
  final int? defaultDuration; // in minutes
  final int? proteinTarget;
  final List<String>? availableProjects; // for buildStreak

  const MorphChip({
    Key? key,
    required this.habitType,
    required this.habitLog,
    required this.onConfirm,
    this.onEdit,
    this.defaultDuration,
    this.proteinTarget,
    this.availableProjects,
  }) : super(key: key);

  @override
  State<MorphChip> createState() => _MorphChipState();
}

class _MorphChipState extends State<MorphChip> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  // For duration habits
  int _selectedMinutes = 0;
  int _selectedSeconds = 0;

  // For protein
  int _selectedGrams = 0;

  // For projects
  Set<String> _selectedProjects = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _heightAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Initialize with default values
    if (habitDetails[widget.habitType]!.isDuration) {
      _selectedMinutes = widget.defaultDuration ?? 10;
    }
    if (habitDetails[widget.habitType]!.isProtein) {
      _selectedGrams = widget.proteinTarget ?? 100;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    if (widget.habitLog.logged) return;

    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _confirm() {
    if (widget.habitLog.logged) return;

    final info = habitDetails[widget.habitType]!;
    HabitLog newLog;

    if (info.isDuration) {
      final totalSeconds = (_selectedMinutes * 60) + _selectedSeconds;
      // Check for warm-up (< 5 min for chess/cycling)
      if ((widget.habitType == HabitType.chess || widget.habitType == HabitType.cycling) &&
          totalSeconds < 300) {
        _showWarmupDialog(totalSeconds);
        return;
      }
      newLog = HabitLog(logged: true, seconds: totalSeconds);
    } else if (info.isProtein) {
      newLog = HabitLog(logged: true, grams: _selectedGrams);
    } else if (info.isProject) {
      if (_selectedProjects.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least one project')),
        );
        return;
      }
      newLog = HabitLog(logged: true, projectIds: _selectedProjects.toList());
    } else {
      newLog = HabitLog(logged: true);
    }

    if (mounted) {
      HapticFeedback.lightImpact();
    }
    widget.onConfirm(newLog);
    setState(() {
      _isExpanded = false;
      _controller.reverse();
    });
  }

  void _showWarmupDialog(int totalSeconds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Count as warm-up?'),
        content: const Text('Won\'t add to streak requirement'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final newLog = HabitLog(logged: false, seconds: totalSeconds);
              widget.onConfirm(newLog);
              setState(() {
                _isExpanded = false;
                _controller.reverse();
              });
            },
            child: const Text('Yes, log it'),
          ),
        ],
      ),
    );
  }

  void _showEditDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          habitDetails[widget.habitType]!.name,
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
              _editHabit();
            },
            child: Text(
              'Edit',
              style: TextStyle(color: habitDetails[widget.habitType]!.color),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteHabit();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editHabit() {
    final info = habitDetails[widget.habitType]!;

    if (info.isDuration) {
      _editDuration();
    } else if (info.isProtein) {
      _editProtein();
    } else if (info.isProject) {
      _editProjects();
    } else {
      // For simple habits, just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Simple habits can only be deleted, not edited.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _editDuration() {
    final currentSeconds = widget.habitLog.seconds ?? 0;
    int editMinutes = (currentSeconds / 60).floor();
    int editSeconds = currentSeconds % 60;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1D1E33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Edit ${habitDetails[widget.habitType]!.name}',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNumberPicker(
                    'min',
                    editMinutes,
                    0,
                    120,
                    (val) => setDialogState(() => editMinutes = val),
                  ),
                  const SizedBox(width: 8),
                  const Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  _buildNumberPicker(
                    'sec',
                    editSeconds,
                    0,
                    59,
                    (val) => setDialogState(() => editSeconds = val),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                final totalSeconds = (editMinutes * 60) + editSeconds;
                final newLog = HabitLog(logged: true, seconds: totalSeconds);
                widget.onConfirm(newLog);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${habitDetails[widget.habitType]!.name} updated!'),
                    backgroundColor: habitDetails[widget.habitType]!.color,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: habitDetails[widget.habitType]!.color,
              ),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _editProtein() {
    int editGrams = widget.habitLog.grams ?? widget.proteinTarget ?? 100;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1D1E33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Edit Protein',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [80, 100, 120, 150].map((target) {
                  return ElevatedButton(
                    onPressed: () => setDialogState(() => editGrams = target),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: editGrams == target ? Colors.amber : Colors.grey[300],
                    ),
                    child: Text('${target}g'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Exact grams',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: editGrams.toString()),
                onChanged: (val) {
                  final grams = int.tryParse(val);
                  if (grams != null) {
                    setDialogState(() => editGrams = grams);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                final newLog = HabitLog(logged: true, grams: editGrams);
                widget.onConfirm(newLog);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Protein updated!'),
                    backgroundColor: Colors.amber,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: habitDetails[widget.habitType]!.color,
              ),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _editProjects() {
    Set<String> editSelectedProjects = Set.from(widget.habitLog.projectIds ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1D1E33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Edit Build Streak',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.availableProjects != null && widget.availableProjects!.isNotEmpty)
                ...widget.availableProjects!.map((projectName) {
                  return CheckboxListTile(
                    title: Text(projectName, style: const TextStyle(color: Colors.white)),
                    value: editSelectedProjects.contains(projectName),
                    onChanged: (checked) {
                      setDialogState(() {
                        if (checked == true) {
                          editSelectedProjects.add(projectName);
                        } else {
                          editSelectedProjects.remove(projectName);
                        }
                      });
                    },
                  );
                }).toList()
              else
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'No active projects. Add one in Projects tab!',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                if (editSelectedProjects.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select at least one project')),
                  );
                  return;
                }
                final newLog = HabitLog(logged: true, projectIds: editSelectedProjects.toList());
                widget.onConfirm(newLog);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Build Streak updated!'),
                    backgroundColor: habitDetails[widget.habitType]!.color,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: habitDetails[widget.habitType]!.color,
              ),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteHabit() {
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
          'Are you sure you want to remove ${habitDetails[widget.habitType]!.name} from today\'s log?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              final newLog = HabitLog(logged: false);
              widget.onConfirm(newLog);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${habitDetails[widget.habitType]!.name} removed from today\'s log'),
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

  @override
  Widget build(BuildContext context) {
    final info = habitDetails[widget.habitType]!;
    final isLocked = widget.habitLog.logged;

    return GestureDetector(
      onTap: _toggleExpand,
      onLongPress: isLocked ? _showEditDeleteDialog : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: isLocked ? info.color : const Color(0xFF1D1E33),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked ? info.color : Colors.grey[800]!,
            width: 2,
          ),
          boxShadow: _isExpanded
              ? [BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 6))]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(info.icon, color: isLocked ? Colors.white : Colors.white70),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isLocked ? Colors.white : Colors.white,
                        ),
                      ),
                      if (!isLocked)
                        Text(
                          info.microcopy,
                          style: const TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                    ],
                  ),
                ),
                if (isLocked)
                  const Icon(Icons.check_circle, color: Colors.white),
              ],
            ),
            SizeTransition(
              sizeFactor: _heightAnimation,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildControls(info),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(HabitInfo info) {
    if (info.isDuration) {
      return _buildDurationPicker();
    } else if (info.isProtein) {
      return _buildProteinPicker();
    } else if (info.isProject) {
      return _buildProjectPicker();
    } else {
      return _buildBinaryButton();
    }
  }

  Widget _buildDurationPicker() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPresetButton(5),
            _buildPresetButton(10),
            _buildPresetButton(15),
            _buildPresetButton(30),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberPicker(
              'min',
              _selectedMinutes,
              0,
              120,
              (val) => setState(() => _selectedMinutes = val),
            ),
            const SizedBox(width: 8),
            const Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            _buildNumberPicker(
              'sec',
              _selectedSeconds,
              0,
              59,
              (val) => setState(() => _selectedSeconds = val),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _confirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: habitDetails[widget.habitType]!.color,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  Widget _buildPresetButton(int minutes) {
    return ElevatedButton(
      onPressed: () => setState(() {
        _selectedMinutes = minutes;
        _selectedSeconds = 0;
      }),
      child: Text('$minutes min'),
    );
  }

  Widget _buildNumberPicker(String label, int value, int min, int max, Function(int) onChanged) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
        Container(
          height: 100,
          width: 60,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 40,
            perspective: 0.005,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            controller: FixedExtentScrollController(initialItem: value),
            onSelectedItemChanged: (index) => onChanged(index),
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index < min || index > max) return null;
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 20),
                  ),
                );
              },
              childCount: max + 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProteinPicker() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [80, 100, 120, 150].map((target) {
            return ElevatedButton(
              onPressed: () => setState(() => _selectedGrams = target),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedGrams == target ? Colors.amber : Colors.grey[300],
              ),
              child: Text('${target}g'),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Exact grams (optional)',
            border: OutlineInputBorder(),
          ),
          onChanged: (val) {
            final grams = int.tryParse(val);
            if (grams != null) {
              setState(() => _selectedGrams = grams);
            }
          },
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _confirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: habitDetails[widget.habitType]!.color,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  Widget _buildProjectPicker() {
    return Column(
      children: [
        if (widget.availableProjects != null && widget.availableProjects!.isNotEmpty)
          ...widget.availableProjects!.map((projectName) {
            return CheckboxListTile(
              title: Text(projectName),
              value: _selectedProjects.contains(projectName),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedProjects.add(projectName);
                  } else {
                    _selectedProjects.remove(projectName);
                  }
                });
              },
            );
          }).toList()
        else
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No active projects. Add one in Projects tab!'),
          ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _confirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: habitDetails[widget.habitType]!.color,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  Widget _buildBinaryButton() {
    return ElevatedButton(
      onPressed: _confirm,
      style: ElevatedButton.styleFrom(
        backgroundColor: habitDetails[widget.habitType]!.color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
      ),
      child: const Text('Done', style: TextStyle(fontSize: 16)),
    );
  }
}

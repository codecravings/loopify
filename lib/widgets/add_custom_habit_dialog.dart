import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/custom_habit.dart';
import '../providers/custom_habit_provider.dart';

class AddCustomHabitDialog extends ConsumerStatefulWidget {
  const AddCustomHabitDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<AddCustomHabitDialog> createState() => _AddCustomHabitDialogState();
}

class _AddCustomHabitDialogState extends ConsumerState<AddCustomHabitDialog> {
  final _nameController = TextEditingController();
  final _microcopyController = TextEditingController();

  IconData _selectedIcon = Icons.star;
  Color _selectedColor = const Color(0xFFFF6B35);

  String _habitType = 'simple'; // simple, duration, numeric
  String? _unit;
  int? _target;

  final List<IconData> _popularIcons = [
    Icons.star,
    Icons.favorite,
    Icons.local_fire_department,
    Icons.flash_on,
    Icons.emoji_events,
    Icons.book,
    Icons.music_note,
    Icons.brush,
    Icons.restaurant,
    Icons.spa,
    Icons.bedtime,
    Icons.lightbulb,
    Icons.pets,
    Icons.eco,
    Icons.coffee,
    Icons.sports_basketball,
  ];

  final List<Color> _popularColors = [
    const Color(0xFFFF6B35), // Orange
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFE91E63), // Pink
    const Color(0xFF2196F3), // Blue
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFF9800), // Amber
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFF8BC34A), // Light Green
    const Color(0xFFFF5722), // Deep Orange
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _microcopyController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }

    final habit = CustomHabit.create(
      name: _nameController.text.trim(),
      microcopy: _microcopyController.text.trim().isEmpty
          ? 'You got this!'
          : _microcopyController.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor,
      isDuration: _habitType == 'duration',
      isNumeric: _habitType == 'numeric',
      unit: _unit,
      target: _target,
    );

    ref.read(customHabitsProvider.notifier).addCustomHabit(habit);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${habit.name} added! 🎉'),
        backgroundColor: _selectedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1D1E33),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Create Custom Habit',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Design your own habit from scratch! 🚀',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Name
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Habit Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'e.g., Morning Journaling',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: const Color(0xFF0A0E21),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Microcopy
              TextField(
                controller: _microcopyController,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Motivational Quote (optional)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'e.g., Reflect. Reset. Rise.',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: const Color(0xFF0A0E21),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Habit Type
              const Text(
                'Habit Type',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _TypeChip(
                      label: 'Simple',
                      isSelected: _habitType == 'simple',
                      onTap: () => setState(() => _habitType = 'simple'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TypeChip(
                      label: 'Duration',
                      isSelected: _habitType == 'duration',
                      onTap: () => setState(() => _habitType = 'duration'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TypeChip(
                      label: 'Numeric',
                      isSelected: _habitType == 'numeric',
                      onTap: () => setState(() => _habitType = 'numeric'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Icon Selection
              const Text(
                'Choose Icon',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _popularIcons.map((icon) {
                  final isSelected = icon == _selectedIcon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? _selectedColor : const Color(0xFF0A0E21),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? _selectedColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Color Selection
              const Text(
                'Choose Color',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _popularColors.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveHabit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Create',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35) : const Color(0xFF0A0E21),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B35) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

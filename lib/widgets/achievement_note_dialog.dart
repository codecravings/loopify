import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/achievement_note.dart';
import '../services/hive_service.dart';

class AchievementNoteDialog extends StatefulWidget {
  const AchievementNoteDialog({Key? key}) : super(key: key);

  @override
  State<AchievementNoteDialog> createState() => _AchievementNoteDialogState();
}

class _AchievementNoteDialogState extends State<AchievementNoteDialog> {
  final _noteController = TextEditingController();
  String _selectedEmoji = '🏆';
  int _selectedCategory = 0;

  final List<String> _emojis = [
    '🏆', '🎯', '⭐', '🔥', '💪', '🚀', '✨', '🎉',
    '💯', '👑', '🌟', '⚡', '🎖️', '🏅', '🥇', '💎'
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Personal', 'emoji': '✨', 'color': Colors.purple},
    {'name': 'Fitness', 'emoji': '💪', 'color': Colors.orange},
    {'name': 'Learning', 'emoji': '📚', 'color': Colors.blue},
    {'name': 'Work', 'emoji': '💼', 'color': Colors.green},
    {'name': 'Other', 'emoji': '🎯', 'color': Colors.pink},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write your achievement! 📝'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final note = AchievementNote(
      id: const Uuid().v4(),
      note: _noteController.text.trim(),
      date: DateTime.now(),
      emoji: _selectedEmoji,
      category: _selectedCategory,
    );

    await HiveService.saveAchievementNote(note);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Achievement logged! $_selectedEmoji'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1D1E33),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '🏆',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Log Achievement',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Celebrate your wins!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Category Selection
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_categories.length, (index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (category['color'] as Color).withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? (category['color'] as Color)
                              : Colors.white.withValues(alpha: 0.1),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            category['emoji'],
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category['name'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? (category['color'] as Color)
                                  : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Emoji Selection
              const Text(
                'Pick an Emoji',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _emojis.map((emoji) {
                    final isSelected = _selectedEmoji == emoji;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedEmoji = emoji;
                        });
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF6B35).withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFF6B35)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Note Input
              const Text(
                'Your Achievement',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 4,
                maxLength: 200,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., Completed 30-day meditation streak!',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF6B35),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'SAVE ACHIEVEMENT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

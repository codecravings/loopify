import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/day_log.dart';
import '../models/habit_log.dart';
import '../models/achievement_note.dart';
import '../services/hive_service.dart';
import '../constants/habits.dart';
import 'package:intl/intl.dart';
import '../widgets/morph_chip.dart';
import '../widgets/custom_habit_chip.dart';
import '../providers/user_prefs_provider.dart';
import '../providers/project_provider.dart';
import '../providers/custom_habit_provider.dart';
import '../services/widget_service.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLogs = HiveService.getAllDayLogs();
    final achievementNotes = HiveService.getAllAchievementNotes();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1E33),
        title: const Text('Progress History'),
        elevation: 0,
      ),
      body: allLogs.isEmpty && achievementNotes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No history yet',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start logging habits to see your progress!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Achievement Notes Section
                  if (achievementNotes.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Color(0xFFFF6B35), size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Your Achievements',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...achievementNotes.take(10).map((note) => _AchievementNoteCard(note: note)),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 24),
                  ],

                  // Day Logs Section
                  if (allLogs.isNotEmpty) ...[
                    const Row(
                      children: [
                        Icon(Icons.calendar_today, color: Color(0xFFFF6B35), size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Daily Progress',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...allLogs.map((dayLog) {
                      return _DayLogCard(
                        dayLog: dayLog,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditDayScreen(dayLog: dayLog),
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ],
              ),
            ),
    );
  }
}

class _AchievementNoteCard extends StatelessWidget {
  final AchievementNote note;

  const _AchievementNoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(note.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              note.emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            note.categoryEmoji,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            note.categoryName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: categoryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM d, y').format(note.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  note.note,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1D1E33),
                  title: const Text('Delete Achievement?', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'This will permanently remove this achievement from your history.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await HiveService.deleteAchievementNote(note.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Achievement deleted'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  // Force rebuild
                  (context as Element).markNeedsBuild();
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(int category) {
    switch (category) {
      case 0:
        return Colors.purple;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      default:
        return Colors.pink;
    }
  }
}

class _DayLogCard extends ConsumerWidget {
  final DayLog dayLog;
  final VoidCallback? onTap;

  const _DayLogCard({required this.dayLog, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customHabits = ref.watch(customHabitsProvider);
    final isToday = _isToday(dayLog.date);
    final dateStr = isToday
        ? 'Today'
        : dayLog.date.difference(DateTime.now()).inDays == -1
            ? 'Yesterday'
            : DateFormat('EEE, MMM d').format(dayLog.date);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
        border: isToday
            ? Border.all(color: const Color(0xFFFF6B35), width: 2)
            : null,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isToday
                  ? const Color(0xFFFF6B35).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isToday ? Icons.today : Icons.calendar_today,
                  color: isToday ? const Color(0xFFFF6B35) : Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  dateStr,
                  style: TextStyle(
                    color: isToday ? const Color(0xFFFF6B35) : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getProgressColor(dayLog.totalHabitsLogged)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${dayLog.totalHabitsLogged} habits',
                    style: TextStyle(
                      color: _getProgressColor(dayLog.totalHabitsLogged),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.edit,
                  color: Colors.white.withOpacity(0.4),
                  size: 18,
                ),
              ],
            ),
          ),
          // Habits Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HabitBadge(
                  name: 'Meditation',
                  logged: dayLog.meditation.logged,
                  color: habitDetails[HabitType.meditation]!.color,
                  icon: habitDetails[HabitType.meditation]!.icon,
                  details: dayLog.meditation.seconds != null
                      ? '${(dayLog.meditation.seconds! / 60).round()}m'
                      : null,
                ),
                _HabitBadge(
                  name: 'Serum',
                  logged: dayLog.serum.logged,
                  color: habitDetails[HabitType.serum]!.color,
                  icon: habitDetails[HabitType.serum]!.icon,
                ),
                _HabitBadge(
                  name: 'Cold Shower',
                  logged: dayLog.coldShower.logged,
                  color: habitDetails[HabitType.coldShower]!.color,
                  icon: habitDetails[HabitType.coldShower]!.icon,
                ),
                _HabitBadge(
                  name: 'Jaw Gym',
                  logged: dayLog.jawGym.logged,
                  color: habitDetails[HabitType.jawGym]!.color,
                  icon: habitDetails[HabitType.jawGym]!.icon,
                ),
                _HabitBadge(
                  name: 'Chew Quest',
                  logged: dayLog.chewQuest.logged,
                  color: habitDetails[HabitType.chewQuest]!.color,
                  icon: habitDetails[HabitType.chewQuest]!.icon,
                ),
                _HabitBadge(
                  name: 'Protein',
                  logged: dayLog.protein.logged,
                  color: habitDetails[HabitType.protein]!.color,
                  icon: habitDetails[HabitType.protein]!.icon,
                  details: dayLog.protein.grams != null
                      ? '${dayLog.protein.grams}g'
                      : null,
                ),
                _HabitBadge(
                  name: 'Study',
                  logged: dayLog.study.logged,
                  color: habitDetails[HabitType.study]!.color,
                  icon: habitDetails[HabitType.study]!.icon,
                  details: dayLog.study.seconds != null
                      ? '${(dayLog.study.seconds! / 60).round()}m'
                      : null,
                ),
                _HabitBadge(
                  name: 'Chess',
                  logged: dayLog.chess.logged,
                  color: habitDetails[HabitType.chess]!.color,
                  icon: habitDetails[HabitType.chess]!.icon,
                  details: dayLog.chess.seconds != null
                      ? '${(dayLog.chess.seconds! / 60).round()}m'
                      : null,
                ),
                _HabitBadge(
                  name: 'Cycling',
                  logged: dayLog.cycling.logged,
                  color: habitDetails[HabitType.cycling]!.color,
                  icon: habitDetails[HabitType.cycling]!.icon,
                  details: dayLog.cycling.seconds != null
                      ? '${(dayLog.cycling.seconds! / 60).round()}m'
                      : null,
                ),
                _HabitBadge(
                  name: 'Build',
                  logged: dayLog.buildStreak.logged,
                  color: habitDetails[HabitType.buildStreak]!.color,
                  icon: habitDetails[HabitType.buildStreak]!.icon,
                ),
                _HabitBadge(
                  name: 'Scientist',
                  logged: dayLog.madScientist.logged,
                  color: habitDetails[HabitType.madScientist]!.color,
                  icon: habitDetails[HabitType.madScientist]!.icon,
                ),
                // Add custom habits
                if (dayLog.customHabits != null && dayLog.customHabits!.isNotEmpty)
                  ...dayLog.customHabits!.entries.map((entry) {
                    final habitId = entry.key;
                    final habitLog = entry.value;
                    // Find the custom habit definition
                    final customHabit = customHabits.firstWhere(
                      (h) => h.id == habitId,
                      orElse: () => customHabits.first, // Fallback, shouldn't happen
                    );
                    return _HabitBadge(
                      name: customHabit.name,
                      logged: habitLog.logged,
                      color: customHabit.color,
                      icon: customHabit.icon,
                      details: habitLog.seconds != null
                          ? '${(habitLog.seconds! / 60).round()}m'
                          : habitLog.grams != null
                              ? '${habitLog.grams}'
                              : null,
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Color _getProgressColor(int count) {
    if (count == 0) return Colors.grey;
    if (count < 3) return Colors.orange;
    if (count < 6) return Colors.amber;
    if (count < 11) return Colors.lightGreen;
    return Colors.green;
  }
}

class _HabitBadge extends StatelessWidget {
  final String name;
  final bool logged;
  final Color color;
  final IconData icon;
  final String? details;

  const _HabitBadge({
    required this.name,
    required this.logged,
    required this.color,
    required this.icon,
    this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: logged ? color.withOpacity(0.2) : const Color(0xFF0A0E21),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: logged ? color : Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            logged ? Icons.check_circle : icon,
            color: logged ? color : Colors.white.withOpacity(0.3),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              color: logged ? color : Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: logged ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (details != null) ...[
            const SizedBox(width: 4),
            Text(
              details!,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Edit Day Screen
class EditDayScreen extends ConsumerStatefulWidget {
  final DayLog dayLog;

  const EditDayScreen({Key? key, required this.dayLog}) : super(key: key);

  @override
  ConsumerState<EditDayScreen> createState() => _EditDayScreenState();
}

class _EditDayScreenState extends ConsumerState<EditDayScreen> {
  late DayLog _editedDayLog;

  @override
  void initState() {
    super.initState();
    _editedDayLog = widget.dayLog;
  }

  void _updateHabit(String habitName, HabitLog habitLog) {
    setState(() {
      switch (habitName) {
        case 'meditation':
          _editedDayLog = _editedDayLog.copyWith(meditation: habitLog);
          break;
        case 'serum':
          _editedDayLog = _editedDayLog.copyWith(serum: habitLog);
          break;
        case 'coldShower':
          _editedDayLog = _editedDayLog.copyWith(coldShower: habitLog);
          break;
        case 'jawGym':
          _editedDayLog = _editedDayLog.copyWith(jawGym: habitLog);
          break;
        case 'chewQuest':
          _editedDayLog = _editedDayLog.copyWith(chewQuest: habitLog);
          break;
        case 'protein':
          _editedDayLog = _editedDayLog.copyWith(protein: habitLog);
          break;
        case 'study':
          _editedDayLog = _editedDayLog.copyWith(study: habitLog);
          break;
        case 'chess':
          _editedDayLog = _editedDayLog.copyWith(chess: habitLog);
          break;
        case 'cycling':
          _editedDayLog = _editedDayLog.copyWith(cycling: habitLog);
          break;
        case 'buildStreak':
          _editedDayLog = _editedDayLog.copyWith(buildStreak: habitLog);
          break;
        case 'madScientist':
          _editedDayLog = _editedDayLog.copyWith(madScientist: habitLog);
          break;
        default:
          // Handle custom habits
          final customHabits = Map<String, HabitLog>.from(_editedDayLog.customHabits ?? {});
          customHabits[habitName] = habitLog;
          _editedDayLog = _editedDayLog.copyWith(customHabits: customHabits);
      }
    });
  }

  Future<void> _saveChanges() async {
    await HiveService.saveDayLog(_editedDayLog);

    // Update widget if editing today's log
    final today = DateTime.now();
    final isEditingToday = _editedDayLog.date.year == today.year &&
        _editedDayLog.date.month == today.month &&
        _editedDayLog.date.day == today.day;
    if (isEditingToday) {
      WidgetService.updateWidget();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes saved successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPrefs = ref.watch(userPrefsProvider);
    final projects = ref.watch(projectsProvider);
    final customHabits = ref.watch(customHabitsProvider);
    final activeProjectNames = projects.where((p) => p.active).map((p) => p.name).toList();
    final dateStr = DateFormat('EEEE, MMM d, yyyy').format(_editedDayLog.date);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1E33),
        title: Text('Edit $dateStr'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Color(0xFFFF6B35)),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tap any habit to edit',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            MorphChip(
              habitType: HabitType.meditation,
              habitLog: _editedDayLog.meditation,
              onConfirm: (log) => _updateHabit('meditation', log),
              defaultDuration: userPrefs.meditationDefault,
            ),
            MorphChip(
              habitType: HabitType.serum,
              habitLog: _editedDayLog.serum,
              onConfirm: (log) => _updateHabit('serum', log),
            ),
            MorphChip(
              habitType: HabitType.coldShower,
              habitLog: _editedDayLog.coldShower,
              onConfirm: (log) => _updateHabit('coldShower', log),
            ),
            MorphChip(
              habitType: HabitType.jawGym,
              habitLog: _editedDayLog.jawGym,
              onConfirm: (log) => _updateHabit('jawGym', log),
            ),
            MorphChip(
              habitType: HabitType.chewQuest,
              habitLog: _editedDayLog.chewQuest,
              onConfirm: (log) => _updateHabit('chewQuest', log),
            ),
            MorphChip(
              habitType: HabitType.protein,
              habitLog: _editedDayLog.protein,
              onConfirm: (log) => _updateHabit('protein', log),
              proteinTarget: userPrefs.proteinTarget,
            ),
            MorphChip(
              habitType: HabitType.study,
              habitLog: _editedDayLog.study,
              onConfirm: (log) => _updateHabit('study', log),
              defaultDuration: userPrefs.studyDefault,
            ),
            MorphChip(
              habitType: HabitType.chess,
              habitLog: _editedDayLog.chess,
              onConfirm: (log) => _updateHabit('chess', log),
              defaultDuration: userPrefs.chessDefault,
            ),
            MorphChip(
              habitType: HabitType.cycling,
              habitLog: _editedDayLog.cycling,
              onConfirm: (log) => _updateHabit('cycling', log),
              defaultDuration: userPrefs.cyclingDefault,
            ),
            MorphChip(
              habitType: HabitType.buildStreak,
              habitLog: _editedDayLog.buildStreak,
              onConfirm: (log) => _updateHabit('buildStreak', log),
              availableProjects: activeProjectNames,
            ),
            MorphChip(
              habitType: HabitType.madScientist,
              habitLog: _editedDayLog.madScientist,
              onConfirm: (log) => _updateHabit('madScientist', log),
            ),
            // Add custom habits
            ...customHabits.map((customHabit) {
              final habitLog = _editedDayLog.customHabits?[customHabit.id] ?? HabitLog(logged: false);
              return CustomHabitChip(
                habit: customHabit,
                habitLog: habitLog,
                onConfirm: (log) => _updateHabit(customHabit.id, log),
              );
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

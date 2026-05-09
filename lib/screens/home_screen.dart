import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;
import '../constants/habits.dart';
import '../providers/day_log_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/user_prefs_provider.dart';
import '../providers/project_provider.dart';
import '../providers/custom_habit_provider.dart';
import '../providers/user_stats_provider.dart';
import '../widgets/morph_chip.dart';
import '../widgets/progress_ring.dart';
import '../widgets/firebar.dart';
import '../widgets/midnight_countdown.dart';
import '../widgets/milestone_modal.dart';
import '../widgets/custom_habit_chip.dart';
import '../widgets/add_custom_habit_dialog.dart';
import '../widgets/cold_streak_banner.dart';
import '../widgets/streak_obituary_modal.dart';
import '../widgets/achievement_modal.dart';
import '../widgets/achievement_note_dialog.dart';
import '../models/habit_log.dart';
import '../services/streak_service.dart';
import '../services/widget_service.dart';
import '../services/midnight_service.dart';
import '../services/hive_service.dart';
import '../services/achievement_service.dart';
import 'manage_habits_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late ConfettiController _confettiController;
  int _lastHabitCount = 0;
  DateTime _lastCheckedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 700));
    _lastCheckedDate = DateTime.now();
    _checkStreakOnInit();
    _setupMidnightCallback();
  }

  void _setupMidnightCallback() {
    // Re-initialize midnight service with callback to this screen
    MidnightService.initialize(onMidnight: _handleMidnightRollover);
  }

  void _handleMidnightRollover() async {
    if (mounted) {
      debugPrint('HomeScreen: Midnight rollover detected, refreshing UI');

      final statsNotifier = ref.read(userStatsProvider.notifier);
      final userPrefs = ref.read(userPrefsProvider);

      // Check yesterday's completion before resetting
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayLog = HiveService.getDayLogByDate(yesterday);
      final requiredHabits = userPrefs.strictStreakMode ? 3 : 1;

      if (yesterdayLog == null || yesterdayLog.totalHabitsLogged < requiredHabits) {
        // Failed yesterday - increment cold streak
        await statsNotifier.incrementColdStreak();
      } else {
        // Succeeded yesterday - reset cold streak
        await statsNotifier.resetColdStreak();
        await statsNotifier.incrementDaysActive();
      }

      // Reset the day log provider for the new day
      final dayLogNotifier = ref.read(currentDayLogProvider.notifier);
      dayLogNotifier.resetForNewDay();

      // Recalculate streak (with break detection)
      final result = await StreakService.calculateStreakWithResult(userPrefs.strictStreakMode);
      ref.read(streakProvider.notifier).updateState(result.state);

      // Show streak obituary if broken
      if (result.streakBroken && result.brokenStreakValue > 0 && mounted) {
        // Record the streak break
        await statsNotifier.recordStreakBreak(
          result.brokenStreakValue,
          result.breakDate ?? DateTime.now(),
        );

        // Calculate days to next milestone
        final nextMilestone = _getNextMilestone(result.brokenStreakValue);
        final daysAway = nextMilestone - result.brokenStreakValue;

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            StreakObituaryModal.show(
              context,
              result.brokenStreakValue,
              result.breakDate ?? DateTime.now(),
              daysAway,
              _getMilestoneName(nextMilestone),
            );
          }
        });
      }

      // Update widget
      WidgetService.updateWidget();

      // Force UI rebuild
      setState(() {
        _lastCheckedDate = DateTime.now();
      });
    }
  }

  int _getNextMilestone(int currentStreak) {
    const milestones = [3, 7, 21, 30, 50, 100, 365];
    for (final milestone in milestones) {
      if (currentStreak < milestone) return milestone;
    }
    return 365;
  }

  String _getMilestoneName(int milestone) {
    switch (milestone) {
      case 3: return 'Spark Ignited';
      case 7: return 'First Flame';
      case 21: return 'Habit Forged';
      case 30: return 'Month Warrior';
      case 50: return 'Iron Will';
      case 100: return 'Centurion';
      case 365: return 'Legend';
      default: return 'Next Level';
    }
  }

  void _checkStreakOnInit() async {
    // Run async to avoid blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userPrefs = ref.read(userPrefsProvider);
      final updatedStreak = await StreakService.calculateStreak(userPrefs.strictStreakMode);

      // Update the streak provider with the new state
      final streakNotifier = ref.read(streakProvider.notifier);
      streakNotifier.updateState(updatedStreak);

      if (mounted) {
        setState(() {});
      }
    });
  }

  void _checkForDayChange() {
    // Check if day has changed since last check
    if (MidnightService.hasCrossedMidnight(_lastCheckedDate)) {
      debugPrint('HomeScreen: Day change detected via manual check');
      _handleMidnightRollover();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onHabitConfirm(HabitType habitType, HabitLog habitLog) async {
    final notifier = ref.read(currentDayLogProvider.notifier);
    final habitName = habitType.toString().split('.').last;
    final userPrefs = ref.read(userPrefsProvider);
    final streakState = ref.read(streakProvider);
    final oldStreak = streakState.currentStreak;
    final statsNotifier = ref.read(userStatsProvider.notifier);

    notifier.updateHabit(habitName, habitLog);

    // Track lifetime habit
    if (habitLog.logged) {
      await statsNotifier.incrementLifetimeHabits();
    }

    // Trigger confetti on first habit of the day
    final currentCount = ref.read(currentDayLogProvider).totalHabitsLogged;
    if (_lastHabitCount == 0 && currentCount == 1) {
      _confettiController.play();
    }
    _lastHabitCount = currentCount;

    // Check if streak should increment
    await StreakService.checkTodayProgress(currentCount, userPrefs.strictStreakMode);

    // Reload streak provider to reflect any changes
    ref.read(streakProvider.notifier).reload();

    // Check for milestone
    final newStreakState = ref.read(streakProvider);
    final milestone = StreakService.getMilestoneToShow(oldStreak, newStreakState.currentStreak);
    if (milestone != null && mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          MilestoneModal.show(context, milestone);
        }
      });
    }

    // Check for achievement unlocks
    final currentStats = ref.read(userStatsProvider);
    AchievementService.checkAndUnlock(
      context,
      ref,
      currentStats,
      newStreakState.currentStreak,
    );

    // Update home screen widget
    WidgetService.updateWidget();

    // Show success toast with humorous messages for >5 habits
    final info = habitDetails[habitType]!;

    String message;
    if (currentCount > 5) {
      message = completionQuips[math.Random().nextInt(completionQuips.length)];
    } else {
      message = '${info.name} logged. Flame lit.';
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          backgroundColor: info.color,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check for day change on every rebuild (lightweight check)
    _checkForDayChange();

    final dayLog = ref.watch(currentDayLogProvider);
    final streakState = ref.watch(streakProvider);
    final userPrefs = ref.watch(userPrefsProvider);
    final projects = ref.watch(projectsProvider);
    final activeProjectNames = projects.where((p) => p.active).map((p) => p.name).toList();
    final customHabits = ref.watch(activeCustomHabitsProvider);

    _lastHabitCount = dayLog.totalHabitsLogged;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Midnight Countdown (only shows after 10 PM)
                const MidnightCountdown(),
                // Cold Streak Banner (shows when failing)
                ColdStreakBanner(
                  coldStreak: ref.watch(userStatsProvider).coldStreak,
                  onTap: () {
                    // Show analytics screen or motivation message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Get back on track! Complete habits today.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                ),
                // Today Card
                ProgressRing(
                  current: dayLog.totalHabitsLogged,
                  total: 11,
                ),
                const SizedBox(height: 16),
                // Achievement Note Button
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AchievementNoteDialog(),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF6B35),
                          Color(0xFFFF8C35),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '🏆',
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'LOG AN ACHIEVEMENT',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Streak Firebar
                Firebar(
                  streakCount: streakState.currentStreak,
                  milestoneLabel: streakState.milestoneLabel,
                  gracePassesUsed: streakState.gracePassesUsedThisWeek,
                  totalGracePasses: 1,
                ),
                const SizedBox(height: 24),
                // Habit Chips
                MorphChip(
                  habitType: HabitType.meditation,
                  habitLog: dayLog.meditation,
                  onConfirm: (log) => _onHabitConfirm(HabitType.meditation, log),
                  defaultDuration: userPrefs.meditationDefault,
                ),
                MorphChip(
                  habitType: HabitType.serum,
                  habitLog: dayLog.serum,
                  onConfirm: (log) => _onHabitConfirm(HabitType.serum, log),
                ),
                MorphChip(
                  habitType: HabitType.coldShower,
                  habitLog: dayLog.coldShower,
                  onConfirm: (log) => _onHabitConfirm(HabitType.coldShower, log),
                ),
                MorphChip(
                  habitType: HabitType.jawGym,
                  habitLog: dayLog.jawGym,
                  onConfirm: (log) => _onHabitConfirm(HabitType.jawGym, log),
                ),
                MorphChip(
                  habitType: HabitType.chewQuest,
                  habitLog: dayLog.chewQuest,
                  onConfirm: (log) => _onHabitConfirm(HabitType.chewQuest, log),
                ),
                MorphChip(
                  habitType: HabitType.protein,
                  habitLog: dayLog.protein,
                  onConfirm: (log) => _onHabitConfirm(HabitType.protein, log),
                  proteinTarget: userPrefs.proteinTarget,
                ),
                MorphChip(
                  habitType: HabitType.study,
                  habitLog: dayLog.study,
                  onConfirm: (log) => _onHabitConfirm(HabitType.study, log),
                  defaultDuration: userPrefs.studyDefault,
                ),
                MorphChip(
                  habitType: HabitType.chess,
                  habitLog: dayLog.chess,
                  onConfirm: (log) => _onHabitConfirm(HabitType.chess, log),
                  defaultDuration: userPrefs.chessDefault,
                ),
                MorphChip(
                  habitType: HabitType.cycling,
                  habitLog: dayLog.cycling,
                  onConfirm: (log) => _onHabitConfirm(HabitType.cycling, log),
                  defaultDuration: userPrefs.cyclingDefault,
                ),
                MorphChip(
                  habitType: HabitType.buildStreak,
                  habitLog: dayLog.buildStreak,
                  onConfirm: (log) => _onHabitConfirm(HabitType.buildStreak, log),
                  availableProjects: activeProjectNames,
                ),
                MorphChip(
                  habitType: HabitType.madScientist,
                  habitLog: dayLog.madScientist,
                  onConfirm: (log) => _onHabitConfirm(HabitType.madScientist, log),
                ),
                // Custom Habits
                ...customHabits.map((customHabit) {
                  final habitLog = dayLog.customHabits?[customHabit.id] ?? HabitLog(logged: false);
                  return CustomHabitChip(
                    habit: customHabit,
                    habitLog: habitLog,
                    onConfirm: (log) async {
                      final notifier = ref.read(currentDayLogProvider.notifier);
                      final userPrefs = ref.read(userPrefsProvider);
                      final streakState = ref.read(streakProvider);
                      final oldStreak = streakState.currentStreak;

                      notifier.updateHabit(customHabit.id, log);

                      // Trigger confetti on first habit of the day
                      final currentCount = ref.read(currentDayLogProvider).totalHabitsLogged;
                      if (_lastHabitCount == 0 && currentCount == 1) {
                        _confettiController.play();
                      }
                      _lastHabitCount = currentCount;

                      // Check if streak should increment
                      await StreakService.checkTodayProgress(currentCount, userPrefs.strictStreakMode);

                      // Reload streak provider to reflect any changes
                      ref.read(streakProvider.notifier).reload();

                      // Check for milestone
                      final newStreakState = ref.read(streakProvider);
                      final milestone = StreakService.getMilestoneToShow(oldStreak, newStreakState.currentStreak);
                      if (milestone != null && mounted) {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) {
                            MilestoneModal.show(context, milestone);
                          }
                        });
                      }

                      // Check for achievement unlocks
                      final currentStats = ref.read(userStatsProvider);
                      AchievementService.checkAndUnlock(
                        context,
                        ref,
                        currentStats,
                        newStreakState.currentStreak,
                      );

                      // Update home screen widget
                      WidgetService.updateWidget();

                      // Show success toast
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${customHabit.name} logged! 🎯'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: customHabit.color,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  );
                }),
                // Add Custom Habit Button
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AddCustomHabitDialog(),
                    );
                  },
                  onLongPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageHabitsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D1E33),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFF6B35).withOpacity(0.3),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: const Color(0xFFFF6B35),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Add Custom Habit',
                          style: TextStyle(
                            color: Color(0xFFFF6B35),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 15,
              gravity: 0.3,
              shouldLoop: false,
              colors: const [
                Colors.amber,
                Colors.orange,
                Colors.pink,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/day_log_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/user_prefs_provider.dart';
import '../services/hive_service.dart';
import '../widgets/protein_gauge.dart';
import '../widgets/time_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayLog = ref.watch(currentDayLogProvider);
    final streakState = ref.watch(streakProvider);
    final userPrefs = ref.watch(userPrefsProvider);
    final streakNotifier = ref.read(streakProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak Stats Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.withOpacity(0.8), Colors.deepOrange.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Streak Stats',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Current', '${streakState.currentStreak}', '🔥'),
                      _buildStatColumn('Best', '${streakState.bestStreak}', '👑'),
                      _buildStatColumn('Grace', '${streakNotifier.gracePassesLeft}/1', '🛡️'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Time Tiles
            const Text(
              'Focus Time Today',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1E33),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer, color: Colors.orange, size: 32),
                      const SizedBox(width: 8),
                      Text(
                        '${dayLog.totalFocusMinutes} min',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TimeTile(
                        label: 'Meditation',
                        minutes: dayLog.meditation.seconds != null ? (dayLog.meditation.seconds! / 60).round() : 0,
                        icon: Icons.self_improvement,
                      ),
                      TimeTile(
                        label: 'Study',
                        minutes: dayLog.study.seconds != null ? (dayLog.study.seconds! / 60).round() : 0,
                        icon: Icons.menu_book,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TimeTile(
                        label: 'Chess',
                        minutes: dayLog.chess.seconds != null ? (dayLog.chess.seconds! / 60).round() : 0,
                        icon: Icons.psychology,
                      ),
                      TimeTile(
                        label: 'Cycling',
                        minutes: dayLog.cycling.seconds != null ? (dayLog.cycling.seconds! / 60).round() : 0,
                        icon: Icons.directions_bike,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Protein Gauge
            const Text(
              'Protein Intake',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            ProteinGauge(
              current: dayLog.protein.grams ?? 0,
              target: userPrefs.proteinTarget,
            ),
            const SizedBox(height: 24),

            // Today's Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1E33),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'Today\'s Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem('Habits Done', '${dayLog.totalHabitsLogged}/11', Icons.check_circle, Colors.green),
                      _buildSummaryItem('Focus Time', '${dayLog.totalFocusMinutes}m', Icons.access_time, Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}

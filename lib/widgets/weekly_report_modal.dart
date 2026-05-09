import 'package:flutter/material.dart';

class WeeklyReportModal extends StatelessWidget {
  final String grade;
  final double weeklySuccessRate;
  final int totalHabitsThisWeek;
  final int daysActiveThisWeek;
  final String bestDay;
  final String worstDay;
  final List<String> topHabits;

  const WeeklyReportModal({
    Key? key,
    required this.grade,
    required this.weeklySuccessRate,
    required this.totalHabitsThisWeek,
    required this.daysActiveThisWeek,
    required this.bestDay,
    required this.worstDay,
    required this.topHabits,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String grade,
    required double weeklySuccessRate,
    required int totalHabitsThisWeek,
    required int daysActiveThisWeek,
    required String bestDay,
    required String worstDay,
    required List<String> topHabits,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WeeklyReportModal(
        grade: grade,
        weeklySuccessRate: weeklySuccessRate,
        totalHabitsThisWeek: totalHabitsThisWeek,
        daysActiveThisWeek: daysActiveThisWeek,
        bestDay: bestDay,
        worstDay: worstDay,
        topHabits: topHabits,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = _getGradeColor();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0A0E21),
              gradeColor.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: gradeColor.withValues(alpha: 0.5), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.assessment, color: gradeColor, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'WEEKLY REPORT CARD',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Grade display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: gradeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: gradeColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'YOUR GRADE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: gradeColor,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    grade,
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: gradeColor,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${weeklySuccessRate.toStringAsFixed(1)}% Success Rate',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats summary
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    'Total Habits',
                    totalHabitsThisWeek.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBox(
                    'Days Active',
                    daysActiveThisWeek.toString(),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Best/Worst days
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1E33),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Best: $bestDay',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.trending_down, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Worst: $worstDay',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Top habits
            if (topHabits.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1E33),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.orange, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Top Habits',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...topHabits.take(3).map((habit) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '• $habit',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Motivational message
            Text(
              _getMotivationalMessage(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: gradeColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: gradeColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor() {
    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'B+':
      case 'B':
        return Colors.blue;
      case 'C+':
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getMotivationalMessage() {
    switch (grade) {
      case 'A+':
        return 'LEGENDARY! You\'re unstoppable! 🔥';
      case 'A':
        return 'Excellent work! Keep this momentum going!';
      case 'B+':
      case 'B':
        return 'Solid effort! You\'re on the right track.';
      case 'C+':
      case 'C':
        return 'Room for improvement. You got this!';
      case 'D':
        return 'Time to step it up! Push harder next week.';
      case 'F':
        return 'New week, new you. Let\'s rebuild!';
      default:
        return 'Keep pushing forward!';
    }
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

class StreakObituaryModal extends StatelessWidget {
  final int brokenStreak;
  final DateTime breakDate;
  final int daysToNextMilestone;
  final String nextMilestone;

  const StreakObituaryModal({
    Key? key,
    required this.brokenStreak,
    required this.breakDate,
    required this.daysToNextMilestone,
    required this.nextMilestone,
  }) : super(key: key);

  static void show(
    BuildContext context,
    int brokenStreak,
    DateTime breakDate,
    int daysToNextMilestone,
    String nextMilestone,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StreakObituaryModal(
        brokenStreak: brokenStreak,
        breakDate: breakDate,
        daysToNextMilestone: daysToNextMilestone,
        nextMilestone: nextMilestone,
      ),
    );
  }

  String _getEmotionalMessage() {
    if (brokenStreak >= 100) {
      return "A LEGEND HAS FALLEN 💔\n\nYour legendary ${brokenStreak}-day journey... ended.";
    } else if (brokenStreak >= 50) {
      return "DEVASTATING LOSS 😢\n\n${brokenStreak} days of discipline... gone.";
    } else if (brokenStreak >= 21) {
      return "HEARTBREAK 💔\n\nYou were building something special.";
    } else if (brokenStreak >= 7) {
      return "STREAK DOWN ⚠️\n\nA whole week... lost.";
    } else if (brokenStreak >= 3) {
      return "BROKEN 😔\n\nYou had momentum going.";
    } else {
      return "RESET ⚡\n\nBack to square one.";
    }
  }

  String _getShameMessage() {
    final messages = [
      "You were so close to greatness.",
      "Tomorrow becomes never.",
      "Your future self is disappointed.",
      "Excellence is not an act, but a habit.",
      "The only person you cheated was yourself.",
      "Discipline equals freedom. You chose chaos.",
      "Success is what happens after you've survived all your failures.",
    ];
    return messages[math.Random().nextInt(messages.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0000),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withValues(alpha: 0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Skull icon
            Icon(
              Icons.sentiment_very_dissatisfied,
              size: 80,
              color: Colors.red.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 16),

            // R.I.P Header
            Text(
              'R.I.P.',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red.withValues(alpha: 0.9),
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),

            // Streak days
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${brokenStreak} Days',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Death date
            Text(
              'Died: ${_formatDate(breakDate)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),

            // Emotional message
            Text(
              _getEmotionalMessage(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // What was lost
            if (daysToNextMilestone > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'YOU WERE SO CLOSE',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.withValues(alpha: 0.9),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Only $daysToNextMilestone days from\n"$nextMilestone"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Shame message
            Text(
              _getShameMessage(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            // Action button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.8),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'RISE AGAIN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

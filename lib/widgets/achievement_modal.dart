import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/achievement.dart';

class AchievementModal extends StatefulWidget {
  final Achievement achievement;

  const AchievementModal({
    Key? key,
    required this.achievement,
  }) : super(key: key);

  static void show(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AchievementModal(achievement: achievement),
    );
  }

  @override
  State<AchievementModal> createState() => _AchievementModalState();
}

class _AchievementModalState extends State<AchievementModal> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _confettiController.play();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.achievement.color.withValues(alpha: 0.3),
                  const Color(0xFF1D1E33),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.achievement.color.withValues(alpha: 0.6), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Achievement unlocked text
                Text(
                  'ACHIEVEMENT UNLOCKED!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.achievement.color,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),

                // Animated icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.achievement.color.withValues(alpha: 0.2),
                      border: Border.all(
                        color: widget.achievement.color.withValues(alpha: 0.6),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      widget.achievement.icon,
                      size: 60,
                      color: widget.achievement.color,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Achievement name
                Text(
                  widget.achievement.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  widget.achievement.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),

                // Reward box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.achievement.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.achievement.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'REWARD',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.achievement.color,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.achievement.reward,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Close button
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.achievement.color,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'AWESOME!',
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
        ),
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.3,
            shouldLoop: false,
            colors: [
              widget.achievement.color,
              Colors.amber,
              Colors.orange,
              Colors.pink,
            ],
          ),
        ),
      ],
    );
  }
}

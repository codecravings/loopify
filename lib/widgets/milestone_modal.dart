import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;
import '../constants/habits.dart';

class MilestoneModal extends StatefulWidget {
  final int streakDay;
  final VoidCallback onDismiss;

  const MilestoneModal({
    Key? key,
    required this.streakDay,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<MilestoneModal> createState() => _MilestoneModalState();

  static void show(BuildContext context, int streakDay) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MilestoneModal(
        streakDay: streakDay,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _MilestoneModalState extends State<MilestoneModal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));

    _controller.forward();
    _confettiController.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _getLabel() {
    return milestoneLabels[widget.streakDay] ?? 'Milestone!';
  }

  String _getQuip() {
    if (widget.streakDay >= 7) {
      return unstoppableQuips[math.Random().nextInt(unstoppableQuips.length)];
    } else {
      return keepGoingQuips[math.Random().nextInt(keepGoingQuips.length)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Stack(
        children: [
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withOpacity(0.9),
                      Colors.deepOrange.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '🔥 Day ${widget.streakDay}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getLabel(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getQuip(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: widget.onDismiss,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Keep Going',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 24,
              gravity: 0.3,
              shouldLoop: false,
              colors: const [
                Colors.amber,
                Colors.orange,
                Colors.pink,
                Colors.purple,
                Colors.red,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

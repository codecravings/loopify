import 'package:flutter/material.dart';
import 'dart:math' as math;

class Firebar extends StatefulWidget {
  final int streakCount;
  final String milestoneLabel;
  final int gracePassesUsed;
  final int totalGracePasses;

  const Firebar({
    Key? key,
    required this.streakCount,
    required this.milestoneLabel,
    this.gracePassesUsed = 0,
    this.totalGracePasses = 1,
  }) : super(key: key);

  @override
  State<Firebar> createState() => _FirebarState();
}

class _FirebarState extends State<Firebar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get brightness {
    // Increase brightness by 10% per 5 days, capped at 100%
    final brightnessFactor = 1.0 + (widget.streakCount ~/ 5) * 0.1;
    return brightnessFactor.clamp(1.0, 2.0);
  }

  @override
  Widget build(BuildContext context) {
    // Clamp opacity values to max 1.0
    final gradientOpacity = (0.8 * brightness).clamp(0.0, 1.0);
    final shadowOpacity = (0.5 * brightness).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(gradientOpacity),
            Colors.red.withOpacity(gradientOpacity),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(shadowOpacity),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 2 * math.sin(_controller.value * 2 * math.pi)),
                child: child,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.white, size: 32),
                const SizedBox(width: 8),
                Text(
                  '${widget.streakCount} days',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Day ${widget.streakCount} • ${widget.milestoneLabel}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          // Grace pass indicator
          if (widget.totalGracePasses > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Grace Pass: ${widget.totalGracePasses - widget.gracePassesUsed}/${widget.totalGracePasses}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                if (widget.gracePassesUsed > 0)
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber.withOpacity(0.9),
                    size: 14,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

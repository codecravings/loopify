import 'dart:async';
import 'package:flutter/material.dart';
import '../services/streak_service.dart';

class MidnightCountdown extends StatefulWidget {
  const MidnightCountdown({Key? key}) : super(key: key);

  @override
  State<MidnightCountdown> createState() => _MidnightCountdownState();
}

class _MidnightCountdownState extends State<MidnightCountdown> {
  late Timer _timer;
  String _countdown = '';

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final duration = StreakService.getTimeUntilMidnight();
    if (mounted) {
      setState(() {
        _countdown = StreakService.formatCountdown(duration);
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Only show countdown after 10 PM
    if (now.hour < 22) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.5), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Text(
            _countdown,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

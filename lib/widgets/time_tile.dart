import 'package:flutter/material.dart';

class TimeTile extends StatelessWidget {
  final String label;
  final int minutes;
  final IconData icon;

  const TimeTile({
    Key? key,
    required this.label,
    required this.minutes,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E21),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[850]!, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.orange, size: 20),
          const SizedBox(height: 4),
          Text(
            '${minutes}m',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

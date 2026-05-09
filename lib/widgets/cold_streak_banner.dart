import 'package:flutter/material.dart';

class ColdStreakBanner extends StatefulWidget {
  final int coldStreak;
  final VoidCallback onTap;

  const ColdStreakBanner({
    Key? key,
    required this.coldStreak,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ColdStreakBanner> createState() => _ColdStreakBannerState();
}

class _ColdStreakBannerState extends State<ColdStreakBanner> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _bannerColor {
    if (widget.coldStreak >= 3) return Colors.red;
    if (widget.coldStreak == 2) return Colors.orange;
    return Colors.amber;
  }

  IconData get _icon {
    if (widget.coldStreak >= 3) return Icons.warning_amber_rounded;
    if (widget.coldStreak == 2) return Icons.error_outline;
    return Icons.info_outline;
  }

  String get _message {
    if (widget.coldStreak >= 7) return '💀 ROCK BOTTOM - Act NOW!';
    if (widget.coldStreak >= 5) return '🚨 CRITICAL - ${widget.coldStreak} days failed!';
    if (widget.coldStreak >= 3) return '⚠️ EMERGENCY - Get back on track!';
    if (widget.coldStreak == 2) return '⚠️ WARNING - 2 days missed!';
    return '⚡ Missed yesterday - Don\'t make it 2!';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.coldStreak == 0) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _bannerColor.withValues(alpha: 0.3 + (_pulseController.value * 0.2)),
                  _bannerColor.withValues(alpha: 0.2 + (_pulseController.value * 0.1)),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _bannerColor.withValues(alpha: 0.6 + (_pulseController.value * 0.4)),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _bannerColor.withValues(alpha: 0.3),
                  blurRadius: 8 + (_pulseController.value * 4),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  _icon,
                  color: _bannerColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COLD STREAK: ${widget.coldStreak} ${widget.coldStreak == 1 ? 'DAY' : 'DAYS'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _bannerColor,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _message,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: _bannerColor,
                  size: 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

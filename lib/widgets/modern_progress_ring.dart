import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A stunning, modern progress ring with glow effects and animations
class ModernProgressRing extends StatefulWidget {
  final int current;
  final int total;
  final double size;

  const ModernProgressRing({
    Key? key,
    required this.current,
    required this.total,
    this.size = 220,
  }) : super(key: key);

  @override
  State<ModernProgressRing> createState() => _ModernProgressRingState();
}

class _ModernProgressRingState extends State<ModernProgressRing>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _glowController;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;
  int _previousCurrent = 0;

  @override
  void initState() {
    super.initState();
    _previousCurrent = widget.current;

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.current / widget.total,
    ).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _progressController.forward();

    // Glow pulse animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(ModernProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current != widget.current) {
      _progressController.reset();
      _progressAnimation = Tween<double>(
        begin: _previousCurrent / widget.total,
        end: widget.current / widget.total,
      ).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
      );
      _progressController.forward();
      _previousCurrent = widget.current;
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.current / widget.total * 100).round();

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_progressController, _glowController]),
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _ModernRingPainter(
              _progressAnimation.value,
              _glowAnimation.value,
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF1D1E33).withOpacity(0.8),
                      const Color(0xFF1D1E33).withOpacity(0.4),
                    ],
                    stops: const [0.7, 1.0],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Percentage
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        '$percentage%',
                        key: ValueKey(percentage),
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Current / Total
                    Text(
                      '${widget.current}/${widget.total}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Habits label with pill background
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getProgressColor(percentage).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getProgressColor(percentage).withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'habits done',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getProgressColor(percentage),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getProgressColor(int percentage) {
    if (percentage >= 80) return const Color(0xFF00E676); // Green
    if (percentage >= 50) return const Color(0xFFFFD700); // Gold
    if (percentage >= 30) return const Color(0xFFFFA726); // Orange
    return const Color(0xFFFF6B35); // Deep orange
  }
}

class _ModernRingPainter extends CustomPainter {
  final double progress;
  final double glowOpacity;

  _ModernRingPainter(this.progress, this.glowOpacity);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 30) / 2;
    const strokeWidth = 14.0;

    // Outer glow
    final glowPaint = Paint()
      ..color = _getGradientColor(progress).withOpacity(glowOpacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 20
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(center, radius, glowPaint);

    // Middle glow
    final middleGlowPaint = Paint()
      ..color = _getGradientColor(progress).withOpacity(glowOpacity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, radius, middleGlowPaint);

    // Background ring with gradient
    final backgroundPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF2A2D4A),
          const Color(0xFF1D1E33),
          const Color(0xFF2A2D4A),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Inner shadow for depth
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth - 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 4);

    canvas.drawCircle(center, radius, shadowPaint);

    // Progress arc with dynamic gradient
    if (progress > 0) {
      final progressColors = _getProgressGradient(progress);
      
      final progressPaint = Paint()
        ..shader = SweepGradient(
          colors: progressColors,
          stops: const [0.0, 0.5, 1.0],
          transform: GradientRotation(-math.pi / 2),
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // Glow at the end of progress
      if (progress > 0.05) {
        final endAngle = -math.pi / 2 + sweepAngle;
        final endX = center.dx + radius * math.cos(endAngle);
        final endY = center.dy + radius * math.sin(endAngle);
        
        final endGlowPaint = Paint()
          ..color = _getGradientColor(progress).withOpacity(glowOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

        canvas.drawCircle(Offset(endX, endY), 8, endGlowPaint);
      }
    }
  }

  List<Color> _getProgressGradient(double progress) {
    final percentage = (progress * 100).round();
    
    if (percentage >= 80) {
      return [
        const Color(0xFF00E676),
        const Color(0xFF69F0AE),
        const Color(0xFF00E676),
      ];
    }
    if (percentage >= 50) {
      return [
        const Color(0xFFFFD700),
        const Color(0xFFFFECB3),
        const Color(0xFFFFD700),
      ];
    }
    if (percentage >= 30) {
      return [
        const Color(0xFFFFA726),
        const Color(0xFFFFCC80),
        const Color(0xFFFFA726),
      ];
    }
    return [
      const Color(0xFFFF6B35),
      const Color(0xFFFFAB91),
      const Color(0xFFFF6B35),
    ];
  }

  Color _getGradientColor(double progress) {
    final percentage = (progress * 100).round();
    
    if (percentage >= 80) return const Color(0xFF00E676);
    if (percentage >= 50) return const Color(0xFFFFD700);
    if (percentage >= 30) return const Color(0xFFFFA726);
    return const Color(0xFFFF6B35);
  }

  @override
  bool shouldRepaint(_ModernRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.glowOpacity != glowOpacity;
  }
}

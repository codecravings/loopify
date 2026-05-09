import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProteinGauge extends StatefulWidget {
  final int current;
  final int target;

  const ProteinGauge({
    Key? key,
    required this.current,
    required this.target,
  }) : super(key: key);

  @override
  State<ProteinGauge> createState() => _ProteinGaugeState();
}

class _ProteinGaugeState extends State<ProteinGauge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.current / widget.target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(ProteinGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current != widget.current) {
      _controller.reset();
      _animation = Tween<double>(
        begin: oldWidget.current / widget.target,
        end: widget.current / widget.target,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!, width: 2),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 200),
                  painter: _GaugePainter(_animation.value, widget.current, widget.target),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.current}g / ${widget.target}g',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final int current;
  final int target;

  _GaugePainter(this.progress, this.current, this.target);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 20);
    final radius = size.width / 2.5;

    // Background arc
    final backgroundPaint = Paint()
      ..color = const Color(0xFF0A0E21)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    // Progress arc
    final progressColor = progress >= 1.0 ? Colors.green : (progress >= 0.6 ? Colors.orange : Colors.yellow);
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [progressColor, progressColor.withOpacity(0.6)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );

    // Needle
    final needleAngle = math.pi + (math.pi * progress.clamp(0.0, 1.0));
    final needleEnd = Offset(
      center.dx + radius * math.cos(needleAngle),
      center.dy + radius * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // Center dot
    final dotPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6, dotPaint);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

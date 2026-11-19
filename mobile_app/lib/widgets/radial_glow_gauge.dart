import 'dart:math' as math;
import 'package:flutter/material.dart';

class RadialGlowGauge extends StatelessWidget {
  final double percentage; // 0 to 100
  final String centerText;
  final String label;
  final String? subText;
  final String? statusText;
  final Color? statusColor;
  final Color primaryColor;
  final Color? secondaryColor;
  final double size;
  final double strokeWidth;
  final bool showPointer;
  final IconData? icon;

  const RadialGlowGauge({
    super.key,
    required this.percentage,
    required this.centerText,
    required this.label,
    this.subText,
    this.statusText,
    this.statusColor,
    required this.primaryColor,
    this.secondaryColor,
    this.size = 110,
    this.strokeWidth = 10,
    this.showPointer = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final endColor = secondaryColor ?? primaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Arc Circle with center text
        SizedBox(
          width: size,
          height: size,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: (percentage / 100.0).clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, animatedRatio, _) {
              return CustomPaint(
                painter: _RadialGlowPainter(
                  ratio: animatedRatio,
                  primaryColor: primaryColor,
                  secondaryColor: endColor,
                  strokeWidth: strokeWidth,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: size * 0.18, color: primaryColor),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        centerText,
                        style: TextStyle(
                          fontSize: size * 0.22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),

        // Indicator Tick Mark if requested
        if (showPointer)
          Container(
            width: 2,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        if (showPointer) const SizedBox(height: 4),

        // Label
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size * 0.11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // SubText (e.g., reset timer or temp)
        if (subText != null) ...[
          const SizedBox(height: 2),
          Text(
            subText!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size * 0.095,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.45),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        // Status Badge (e.g., "Plenty left" in emerald)
        if (statusText != null) ...[
          const SizedBox(height: 3),
          Text(
            statusText!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size * 0.095,
              fontWeight: FontWeight.w600,
              color: statusColor ?? const Color(0xFF30D158),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _RadialGlowPainter extends CustomPainter {
  final double ratio;
  final Color primaryColor;
  final Color secondaryColor;
  final double strokeWidth;

  _RadialGlowPainter({
    required this.ratio,
    required this.primaryColor,
    required this.secondaryColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth * 2) / 2;

    // Background track (dark circle)
    final bgPaint = Paint()
      ..color = const Color(0xFF26262E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (ratio <= 0.001) return;

    // Arc angles: starts at top (-pi/2)
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * ratio;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Glow effect (drawn behind active arc)
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4
      ..strokeCap = StrokeCap.round
      ..color = primaryColor.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);

    // Active Arc Gradient
    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * math.pi,
        colors: [primaryColor, secondaryColor],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);

    canvas.drawArc(rect, startAngle, sweepAngle, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _RadialGlowPainter oldDelegate) {
    return oldDelegate.ratio != ratio ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}

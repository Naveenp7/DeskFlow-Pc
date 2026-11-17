import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaveSparklineCard extends StatefulWidget {
  final String title;
  final String valueText;
  final String subText;
  final Color primaryColor;
  final Color? secondaryColor;
  final bool isNetworkDual;
  final String? networkSub;
  final VoidCallback? onTap;

  const WaveSparklineCard({
    super.key,
    required this.title,
    required this.valueText,
    required this.subText,
    required this.primaryColor,
    this.secondaryColor,
    this.isNetworkDual = false,
    this.networkSub,
    this.onTap,
  });

  @override
  State<WaveSparklineCard> createState() => _WaveSparklineCardState();
}

class _WaveSparklineCardState extends State<WaveSparklineCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF12141E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1E2232),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Animated Wave in bottom section
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 48,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _WavePainter(
                      phase: _controller.value * 2 * math.pi,
                      primaryColor: widget.primaryColor,
                      secondaryColor: widget.secondaryColor,
                      isDual: widget.isNetworkDual,
                    ),
                  );
                },
              ),
            ),

            // Card Text Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: widget.primaryColor,
                        ),
                      ),
                      if (widget.networkSub != null)
                        Text(
                          widget.networkSub!,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        widget.valueText,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double phase;
  final Color primaryColor;
  final Color? secondaryColor;
  final bool isDual;

  _WavePainter({
    required this.phase,
    required this.primaryColor,
    this.secondaryColor,
    required this.isDual,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw primary wave
    _drawSineWave(
      canvas: canvas,
      width: w,
      height: h,
      phase: phase,
      color: primaryColor,
      hasFill: true,
      amplitude: h * 0.38,
      frequency: 3.5,
      yOffset: h * 0.52,
    );

    // Draw secondary wave if dual (e.g. upload line in cyan)
    if (isDual) {
      _drawSineWave(
        canvas: canvas,
        width: w,
        height: h,
        phase: phase * 1.4 + 1.0,
        color: secondaryColor ?? const Color(0xFF00E5FF),
        hasFill: false,
        amplitude: h * 0.22,
        frequency: 5.0,
        yOffset: h * 0.72,
      );
    }
  }

  void _drawSineWave({
    required Canvas canvas,
    required double width,
    required double height,
    required double phase,
    required Color color,
    required bool hasFill,
    required double amplitude,
    required double frequency,
    required double yOffset,
  }) {
    final path = Path();
    final fillPath = Path();

    fillPath.moveTo(0, height);

    for (double x = 0; x <= width; x += 3) {
      final normalizedX = x / width;
      // Multi-frequency harmonic wave for realistic cyber look
      final y = yOffset +
          math.sin(normalizedX * 2 * math.pi * frequency + phase) * amplitude * 0.75 +
          math.cos(normalizedX * 4 * math.pi * frequency + phase * 0.5) * (amplitude * 0.25);

      if (x == 0) {
        path.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(width, height);
    fillPath.close();

    // Area fill with vertical gradient
    if (hasFill) {
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.28),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, width, height));

      canvas.drawPath(fillPath, fillPaint);
    }

    // Glow stroke
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(path, glowPaint);

    // Main sharp line
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.primaryColor != primaryColor;
  }
}

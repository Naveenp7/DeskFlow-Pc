import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedGauge extends StatelessWidget {
  final String label;
  final double percentage; // 0.0 to 100.0
  final String valueText;
  final String? subText;
  final IconData icon;
  final Color accentColor;

  const AnimatedGauge({
    super.key,
    required this.label,
    required this.percentage,
    required this.valueText,
    this.subText,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final clampedRatio = (percentage / 100.0).clamp(0.0, 1.0);

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.22),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Animated Circular Gauge
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: clampedRatio),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, _) {
                return SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: animatedValue,
                        strokeWidth: 4.0,
                        backgroundColor: Colors.white.withValues(alpha: 0.07),
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      ),
                      Icon(icon, size: 18, color: accentColor),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 12),

            // Text column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    valueText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subText != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subText!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

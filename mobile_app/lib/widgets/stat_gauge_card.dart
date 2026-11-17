import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class StatGaugeCard extends StatelessWidget {
  final String title;
  final String valueText;
  final String subText;
  final double progress; // 0.0 to 1.0
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const StatGaugeCard({
    super.key,
    required this.title,
    required this.valueText,
    required this.subText,
    required this.progress,
    required this.icon,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return GlassContainer(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      borderColor: accentColor.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 17),
              ),
              SizedBox(
                width: 34,
                height: 34,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: clampedProgress,
                      strokeWidth: 3.2,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                    Text(
                      '${(clampedProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valueText,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppTheme.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

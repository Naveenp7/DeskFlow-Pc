import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TactileTile extends StatefulWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isActive;
  final bool isDestructive;

  const TactileTile({
    super.key,
    required this.label,
    this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    this.isActive = false,
    this.isDestructive = false,
  });

  @override
  State<TactileTile> createState() => _TactileTileState();
}

class _TactileTileState extends State<TactileTile>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.94);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.isDestructive
        ? AppTheme.rose
        : widget.isActive
            ? widget.accentColor
            : widget.accentColor;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? effectiveColor.withValues(alpha: 0.18)
                : AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isActive
                  ? effectiveColor
                  : effectiveColor.withValues(alpha: 0.22),
              width: widget.isActive ? 1.5 : 1.0,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: effectiveColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: effectiveColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.icon,
                      color: effectiveColor,
                      size: 16,
                    ),
                  ),
                  if (widget.isActive)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: effectiveColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: effectiveColor.withValues(alpha: 0.8),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.subtitle != null) ...[
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: widget.isActive
                            ? effectiveColor
                            : AppTheme.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

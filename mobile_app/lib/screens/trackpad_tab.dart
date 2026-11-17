import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connection_service.dart';
import '../theme/app_theme.dart';

class TrackpadTab extends StatefulWidget {
  const TrackpadTab({super.key});

  @override
  State<TrackpadTab> createState() => _TrackpadTabState();
}

class _TrackpadTabState extends State<TrackpadTab> {
  double _sensitivity = 1.3;

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectionService>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Top Bar with Sensitivity Setting
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.mouse_rounded, color: AppTheme.cyan, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'REMOTE TRACKPAD',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Speed: ',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  DropdownButton<double>(
                    value: _sensitivity,
                    dropdownColor: AppTheme.surfaceCard,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 0.8, child: Text('0.8x')),
                      DropdownMenuItem(value: 1.3, child: Text('1.3x')),
                      DropdownMenuItem(value: 1.8, child: Text('1.8x')),
                      DropdownMenuItem(value: 2.5, child: Text('2.5x')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _sensitivity = val);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Main Trackpad and Scroll Strip Area
          Expanded(
            child: Row(
              children: [
                // Touchpad Main Surface
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanDown: (details) {
                      _lastPosition = details.localPosition;
                    },
                    onPanUpdate: (details) {
                      final dx = (details.delta.dx * _sensitivity).round();
                      final dy = (details.delta.dy * _sensitivity).round();
                      if (dx != 0 || dy != 0) {
                        conn.sendMouseMove(dx, dy);
                      }
                    },
                    onTap: () {
                      conn.sendMouseClick('left');
                    },
                    onDoubleTap: () {
                      conn.sendMouseClick('left');
                      conn.sendMouseClick('left');
                    },
                    onLongPress: () {
                      conn.sendMouseClick('right');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Subtle Trackpad Grid Indicator
                          Opacity(
                            opacity: 0.08,
                            child: Icon(
                              Icons.touch_app_rounded,
                              size: 100,
                              color: AppTheme.cyan,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Slide finger to move mouse',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tap: Left Click • Long Press: Right Click',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Vertical Scroll Rail
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (details) {
                    final dy = -(details.delta.dy * 12).round();
                    if (dy != 0) {
                      conn.sendMouseScroll(dy);
                    }
                  },
                  child: Container(
                    width: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Icon(Icons.arrow_drop_up_rounded, color: AppTheme.cyan),
                        RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            'SCROLL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down_rounded, color: AppTheme.cyan),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Bottom Left / Middle / Right Click Buttons
          SizedBox(
            height: 56,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _ClickButton(
                    label: 'Left Click',
                    icon: Icons.mouse_rounded,
                    onTap: () => conn.sendMouseClick('left'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _ClickButton(
                    label: 'Scroll Click',
                    icon: Icons.adjust_rounded,
                    onTap: () => conn.sendMouseClick('middle'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: _ClickButton(
                    label: 'Right Click',
                    icon: Icons.menu_rounded,
                    onTap: () => conn.sendMouseClick('right'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ClickButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ClickButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: AppTheme.cyan),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

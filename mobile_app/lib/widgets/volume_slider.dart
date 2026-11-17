import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class VolumeControlWidget extends StatelessWidget {
  final int volumeLevel;
  final bool isMuted;
  final ValueChanged<int> onVolumeChanged;
  final VoidCallback onToggleMute;

  const VolumeControlWidget({
    super.key,
    required this.volumeLevel,
    required this.isMuted,
    required this.onVolumeChanged,
    required this.onToggleMute,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveVolume = isMuted ? 0 : volumeLevel;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderColor: isMuted ? AppTheme.rose.withValues(alpha: 0.3) : AppTheme.cyan.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: onToggleMute,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isMuted
                            ? AppTheme.rose.withValues(alpha: 0.2)
                            : AppTheme.cyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isMuted
                            ? Icons.volume_off_rounded
                            : effectiveVolume > 50
                                ? Icons.volume_up_rounded
                                : Icons.volume_down_rounded,
                        color: isMuted ? AppTheme.rose : AppTheme.cyan,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Master Volume',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        isMuted ? 'Muted' : '$effectiveVolume%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isMuted ? AppTheme.rose : AppTheme.cyan,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Step down and up buttons
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                    color: AppTheme.textSecondary,
                    onPressed: () {
                      final next = (volumeLevel - 5).clamp(0, 100);
                      onVolumeChanged(next);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    color: AppTheme.textSecondary,
                    onPressed: () {
                      final next = (volumeLevel + 5).clamp(0, 100);
                      onVolumeChanged(next);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: isMuted ? AppTheme.rose : AppTheme.cyan,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              thumbColor: isMuted ? AppTheme.rose : AppTheme.cyan,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayColor: AppTheme.cyan.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: effectiveVolume.toDouble(),
              min: 0,
              max: 100,
              onChanged: (val) {
                onVolumeChanged(val.round());
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class VolumeControlWidget extends StatelessWidget {
  final int volumeLevel;
  final bool isMuted;
  final ValueChanged<int> onVolumeChanged;
  final VoidCallback onToggleMute;
  final bool compact;

  const VolumeControlWidget({
    super.key,
    required this.volumeLevel,
    required this.isMuted,
    required this.onVolumeChanged,
    required this.onToggleMute,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveVolume = isMuted ? 0 : volumeLevel;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderColor: isMuted
          ? AppTheme.rose.withValues(alpha: 0.3)
          : AppTheme.cyan.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onToggleMute,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isMuted
                        ? AppTheme.rose.withValues(alpha: 0.2)
                        : AppTheme.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isMuted
                        ? Icons.volume_off_rounded
                        : effectiveVolume > 50
                            ? Icons.volume_up_rounded
                            : Icons.volume_down_rounded,
                    color: isMuted ? AppTheme.rose : AppTheme.cyan,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Volume',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      isMuted ? 'Muted' : '$effectiveVolume%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isMuted ? AppTheme.rose : AppTheme.cyan,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  final next = (volumeLevel - 5).clamp(0, 100);
                  onVolumeChanged(next);
                },
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.remove_rounded, size: 16, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(width: 2),
              InkWell(
                onTap: () {
                  final next = (volumeLevel + 5).clamp(0, 100);
                  onVolumeChanged(next);
                },
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.add_rounded, size: 16, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: isMuted ? AppTheme.rose : AppTheme.cyan,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              thumbColor: isMuted ? AppTheme.rose : AppTheme.cyan,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
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

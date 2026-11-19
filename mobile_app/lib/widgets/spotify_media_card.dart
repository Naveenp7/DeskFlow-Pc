import 'package:flutter/material.dart';

/// Real PC media & volume remote. There is no reliable, zero-setup way for
/// the PC companion to know the title/artist of whatever is playing, so this
/// card only shows controls it can actually back with a real action: the
/// transport buttons send real media keys, and the volume slider reflects
/// the PC's real system volume.
class MediaControlsCard extends StatelessWidget {
  final bool compact;
  final int volumeLevel;
  final bool isMuted;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;
  final Function(int volume)? onVolumeChanged;

  const MediaControlsCard({
    super.key,
    this.compact = false,
    required this.volumeLevel,
    required this.isMuted,
    this.onPlayPause,
    this.onNext,
    this.onPrev,
    this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF26262E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 40 : 52,
                height: compact ? 40 : 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(compact ? 10 : 14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9F0A), Color(0xFFBF5AF2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.headphones_rounded,
                  color: Colors.white,
                  size: compact ? 20 : 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'PC MEDIA CONTROLS',
                      style: TextStyle(
                        fontSize: compact ? 10.5 : 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Play, pause & skip whatever is on your PC',
                      style: TextStyle(
                        fontSize: compact ? 9.5 : 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Controls Row: Prev, Play/Pause, Next, Volume
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, size: 20),
                color: Colors.white,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onPrev,
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onPlayPause,
                child: Container(
                  width: compact ? 34 : 40,
                  height: compact ? 34 : 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: compact ? 20 : 24,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, size: 20),
                color: Colors.white,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onNext,
              ),

              const Spacer(),

              Icon(
                isMuted || volumeLevel == 0
                    ? Icons.volume_off_rounded
                    : Icons.volume_down_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              SizedBox(
                width: compact ? 70 : 100,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4.5),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                    activeTrackColor: Colors.white.withValues(alpha: 0.7),
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: volumeLevel.toDouble().clamp(0.0, 100.0),
                    min: 0,
                    max: 100,
                    onChanged: (val) => onVolumeChanged?.call(val.toInt()),
                  ),
                ),
              ),
              Text(
                '$volumeLevel',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

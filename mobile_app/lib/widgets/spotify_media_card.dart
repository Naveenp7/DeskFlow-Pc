import 'package:flutter/material.dart';
import '../models/weather_media.dart';

class SpotifyMediaCard extends StatefulWidget {
  final MediaTrackInfo track;
  final bool compact;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;
  final Function(int volume)? onVolumeChanged;
  final Function(int position)? onSeek;

  const SpotifyMediaCard({
    super.key,
    required this.track,
    this.compact = false,
    this.onPlayPause,
    this.onNext,
    this.onPrev,
    this.onVolumeChanged,
    this.onSeek,
  });

  @override
  State<SpotifyMediaCard> createState() => _SpotifyMediaCardState();
}

class _SpotifyMediaCardState extends State<SpotifyMediaCard> {
  late bool _isPlaying;
  late int _currentSeconds;
  late int _volume;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.track.isPlaying;
    _currentSeconds = widget.track.currentSeconds;
    _volume = widget.track.volume;
  }

  @override
  void didUpdateWidget(covariant SpotifyMediaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.track != oldWidget.track) {
      _isPlaying = widget.track.isPlaying;
      _currentSeconds = widget.track.currentSeconds;
      _volume = widget.track.volume;
    }
  }

  @override
  Widget build(BuildContext context) {
    final track = widget.track;
    final posStr =
        '${_currentSeconds ~/ 60}:${(_currentSeconds % 60).toString().padLeft(2, '0')}';
    final totStr =
        '${track.totalSeconds ~/ 60}:${(track.totalSeconds % 60).toString().padLeft(2, '0')}';

    return Container(
      padding: EdgeInsets.all(widget.compact ? 10 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF12141E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E212E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top section: Album Art + Track Information
          Row(
            children: [
              // Custom-painted Synthwave retro album cover
              Container(
                width: widget.compact ? 48 : 72,
                height: widget.compact ? 48 : 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.compact ? 10 : 14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5252).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: CustomPaint(
                  painter: _SynthwaveArtPainter(),
                ),
              ),
              const SizedBox(width: 12),

              // Track details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      track.source.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: Color(0xFF1DB954),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      track.title,
                      style: TextStyle(
                        fontSize: widget.compact ? 13 : 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      track.artist,
                      style: TextStyle(
                        fontSize: widget.compact ? 10 : 11.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Seeker Slider with Progress
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: _currentSeconds.toDouble().clamp(0.0, track.totalSeconds.toDouble()),
                  min: 0,
                  max: track.totalSeconds.toDouble(),
                  onChanged: (val) {
                    setState(() => _currentSeconds = val.toInt());
                    widget.onSeek?.call(val.toInt());
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      posStr,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                    Text(
                      totStr,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Controls Row: Prev, Play/Pause, Next, Volume
          Row(
            children: [
              // Media buttons
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, size: 20),
                color: Colors.white,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: widget.onPrev,
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  setState(() => _isPlaying = !_isPlaying);
                  widget.onPlayPause?.call();
                },
                child: Container(
                  width: widget.compact ? 34 : 40,
                  height: widget.compact ? 34 : 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: widget.compact ? 20 : 24,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, size: 20),
                color: Colors.white,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: widget.onNext,
              ),

              const Spacer(),

              // Volume Icon & Slider
              Icon(
                _volume == 0 ? Icons.volume_off_rounded : Icons.volume_down_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              SizedBox(
                width: widget.compact ? 70 : 100,
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
                    value: _volume.toDouble(),
                    min: 0,
                    max: 100,
                    onChanged: (val) {
                      setState(() => _volume = val.toInt());
                      widget.onVolumeChanged?.call(val.toInt());
                    },
                  ),
                ),
              ),
              Text(
                '$_volume',
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

class _SynthwaveArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky gradient (purple to deep pink)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2C0B54), Color(0xFF6C1E7A), Color(0xFFC73E78)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // Glowing Retro Sun in center
    final sunCenter = Offset(w * 0.5, h * 0.45);
    final sunRadius = w * 0.28;
    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFF078), Color(0xFFFF7A00), Color(0xFFFF2E93)],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: sunRadius));

    canvas.drawCircle(sunCenter, sunRadius, sunPaint);

    // Dark grid horizon
    final horizonY = h * 0.65;
    final groundPaint = Paint()..color = const Color(0xFF0F051D);
    canvas.drawRect(Rect.fromLTWH(0, horizonY, w, h - horizonY), groundPaint);

    // Neon Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE040FB).withValues(alpha: 0.6)
      ..strokeWidth = 1.0;

    // Horizontal perspective lines
    for (double y = horizonY; y <= h; y += (y - horizonY + 3) * 0.4 + 2) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Converging perspective lines towards sun
    for (double x = -w * 0.5; x <= w * 1.5; x += w * 0.2) {
      canvas.drawLine(Offset(sunCenter.dx, horizonY), Offset(x, h), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

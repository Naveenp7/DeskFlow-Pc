import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StandbyClock extends StatefulWidget {
  final String hostname;
  final int pingMs;
  final bool isConnected;
  final String uptime;
  final VoidCallback? onConnectTap;

  const StandbyClock({
    super.key,
    required this.hostname,
    required this.pingMs,
    required this.isConnected,
    required this.uptime,
    this.onConnectTap,
  });

  @override
  State<StandbyClock> createState() => _StandbyClockState();
}

class _StandbyClockState extends State<StandbyClock> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hourStr = _now.hour.toString().padLeft(2, '0');
    final minStr = _now.minute.toString().padLeft(2, '0');
    final secStr = _now.second.toString().padLeft(2, '0');
    final weekdayStr = _weekdays[_now.weekday - 1];
    final monthStr = _months[_now.month - 1];
    final dateStr = '$weekdayStr, ${_now.day} $monthStr';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Connection status pill
        GestureDetector(
          onTap: widget.onConnectTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.isConnected
                  ? AppTheme.emerald.withValues(alpha: 0.12)
                  : AppTheme.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isConnected
                    ? AppTheme.emerald.withValues(alpha: 0.35)
                    : AppTheme.amber.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isConnected ? AppTheme.emerald : AppTheme.amber,
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    widget.isConnected
                        ? '${widget.hostname} • ${widget.pingMs}ms'
                        : 'Connecting...',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: widget.isConnected ? AppTheme.emerald : AppTheme.amber,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Standby Digital Clock Display (FittedBox ensures it scales to fit any width!)
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$hourStr:$minStr',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2.0,
                  height: 1.0,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                secStr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cyan,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // Date Display
        Text(
          dateStr.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: AppTheme.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        if (widget.isConnected && widget.uptime != '--') ...[
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_outlined, size: 11, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Uptime: ${widget.uptime}',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

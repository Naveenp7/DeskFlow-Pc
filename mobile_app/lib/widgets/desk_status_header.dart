import 'package:flutter/material.dart';

class DeskStatusHeader extends StatelessWidget {
  final String hostname;
  final bool isConnected;
  final bool hasBattery;
  final int batteryPercent;
  final bool isCharging;
  final double claudePct;
  final int activeSessionCount;
  final VoidCallback? onExit;
  final VoidCallback? onConnectTap;
  final VoidCallback? onActiveSessionsTap;

  const DeskStatusHeader({
    super.key,
    required this.hostname,
    required this.isConnected,
    this.hasBattery = false,
    this.batteryPercent = 0,
    this.isCharging = false,
    this.claudePct = 0.0,
    this.activeSessionCount = 0,
    this.onExit,
    this.onConnectTap,
    this.onActiveSessionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Hostname & Connection Pill
          GestureDetector(
            onTap: onConnectTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6.5,
                  height: 6.5,
                  decoration: BoxDecoration(
                    color: isConnected ? const Color(0xFF30D158) : const Color(0xFFFF453A),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isConnected ? const Color(0xFF30D158) : const Color(0xFFFF453A))
                            .withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'DESKFLOW',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '· ${hostname.toUpperCase()} · ${isConnected ? 'USB' : 'OFFLINE'}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),

          // Center: Battery + Claude + Codex + Waiting Badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Battery (only shown when the PC actually reports one)
              if (hasBattery) ...[
                Icon(
                  isCharging ? Icons.battery_charging_full_rounded : Icons.battery_std_rounded,
                  size: 13,
                  color: const Color(0xFFA78BFA),
                ),
                const SizedBox(width: 3),
                Text(
                  '$batteryPercent%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFA78BFA),
                  ),
                ),
                const SizedBox(width: 10),
              ],

              // Claude Quota Mini (real local usage estimate)
              Text(
                'Claude ${claudePct.toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 8),

              // Active Claude Code Sessions Badge
              if (activeSessionCount > 0)
                GestureDetector(
                  onTap: onActiveSessionsTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9F0A).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFFF9F0A).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      '$activeSessionCount active',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF9F0A),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Right: Exit Button
          IconButton(
            icon: const Icon(Icons.fullscreen_exit_rounded, size: 17),
            tooltip: 'Exit Standby',
            color: Colors.white.withValues(alpha: 0.5),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onExit,
          ),
        ],
      ),
    );
  }
}

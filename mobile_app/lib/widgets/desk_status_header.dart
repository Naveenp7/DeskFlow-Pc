import 'package:flutter/material.dart';

class DeskStatusHeader extends StatelessWidget {
  final String hostname;
  final bool isConnected;
  final int batteryPercent;
  final bool isCharging;
  final double claudePct;
  final double codexPct;
  final int waitingCount;
  final VoidCallback? onExit;
  final VoidCallback? onConnectTap;
  final VoidCallback? onWaitingTap;

  const DeskStatusHeader({
    super.key,
    required this.hostname,
    required this.isConnected,
    this.batteryPercent = 82,
    this.isCharging = true,
    this.claudePct = 34.0,
    this.codexPct = 12.0,
    this.waitingCount = 1,
    this.onExit,
    this.onConnectTap,
    this.onWaitingTap,
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
                    color: isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                            .withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'DeskFlow · ${hostname.toUpperCase()} · ${isConnected ? 'USB' : 'OFFLINE'}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
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
              // Battery
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

              // Claude Quota Mini
              Text(
                'Claude ${claudePct.toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 8),

              // Codex Quota Mini
              Text(
                'Codex ${codexPct.toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 8),

              // Waiting Badge
              if (waitingCount > 0)
                GestureDetector(
                  onTap: onWaitingTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFFF5252).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      '$waitingCount waiting',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF6E6E),
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

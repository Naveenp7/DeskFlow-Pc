import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connection_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gauge.dart';
import '../widgets/standby_clock.dart';
import '../widgets/tactile_tile.dart';
import '../widgets/volume_slider.dart';
import 'discovery_dialog.dart';

class StandbyScreen extends StatelessWidget {
  final VoidCallback onExitStandby;
  final VoidCallback onOpenTrackpad;
  final VoidCallback onOpenShare;

  const StandbyScreen({
    super.key,
    required this.onExitStandby,
    required this.onOpenTrackpad,
    required this.onOpenShare,
  });

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectionService>();
    final stats = conn.stats;
    final isConnected = conn.isConnected;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            children: [
              // Sleek Desk Top Status Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.cyan, AppTheme.purple],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.hub_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'DeskFlow',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppTheme.cyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'STANDBY DECK',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppTheme.cyan,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (stats.hasBattery) ...[
                        Icon(
                          stats.isCharging
                              ? Icons.battery_charging_full_rounded
                              : Icons.battery_std_rounded,
                          size: 13,
                          color: stats.batteryPercent > 20
                              ? AppTheme.emerald
                              : AppTheme.rose,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${stats.batteryPercent}%',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      IconButton(
                        icon: const Icon(Icons.fullscreen_exit_rounded, size: 18),
                        tooltip: 'Exit Standby',
                        color: AppTheme.textMuted,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: onExitStandby,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Main 3-Column Desk Grid
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ==========================================
                    // COLUMN 1: STANDBY CLOCK & MEDIA / AUDIO
                    // ==========================================
                    Expanded(
                      flex: 32,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Standby Clock & Status
                            StandbyClock(
                              hostname: stats.hostname,
                              pingMs: conn.pingMs,
                              isConnected: isConnected,
                              uptime: stats.uptime,
                              onConnectTap: () => _openDiscovery(context),
                            ),

                            // Volume Slider & Mute (Compact Mode)
                            VolumeControlWidget(
                              volumeLevel: stats.volumeLevel,
                              isMuted: stats.isMuted,
                              compact: true,
                              onVolumeChanged: (val) => conn.setVolume(val),
                              onToggleMute: () => conn.setMute(!stats.isMuted),
                            ),

                            // Compact Media Control Bar
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.skip_previous_rounded, size: 16),
                                    color: AppTheme.textPrimary,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    onPressed: () => conn.sendMediaAction('prev'),
                                    tooltip: 'Previous Track',
                                  ),
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [AppTheme.purple, AppTheme.cyan],
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                                      color: Colors.white,
                                      padding: EdgeInsets.zero,
                                      onPressed: () => conn.sendMediaAction('play_pause'),
                                      tooltip: 'Play / Pause',
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.skip_next_rounded, size: 16),
                                    color: AppTheme.textPrimary,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    onPressed: () => conn.sendMediaAction('next'),
                                    tooltip: 'Next Track',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // ==========================================
                    // COLUMN 2: HARDWARE TELEMETRY GAUGES
                    // ==========================================
                    Expanded(
                      flex: 38,
                      child: Column(
                        children: [
                          // 4 Performance Gauges (2x2 Grid)
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                              childAspectRatio: 1.85,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                AnimatedGauge(
                                  label: 'CPU Usage',
                                  percentage: stats.cpu,
                                  valueText: '${stats.cpu.toStringAsFixed(1)}%',
                                  subText: '${stats.cpuCores} Threads',
                                  icon: Icons.speed_rounded,
                                  accentColor: AppTheme.cyan,
                                ),
                                AnimatedGauge(
                                  label: 'RAM Memory',
                                  percentage: stats.ramPercent,
                                  valueText: '${stats.ramPercent.toStringAsFixed(0)}%',
                                  subText: '${stats.ramUsedGb.toStringAsFixed(1)} / ${stats.ramTotalGb.toStringAsFixed(0)} GB',
                                  icon: Icons.memory_rounded,
                                  accentColor: AppTheme.purple,
                                ),
                                AnimatedGauge(
                                  label: 'Disk (C:)',
                                  percentage: stats.diskPercent,
                                  valueText: '${stats.diskPercent.toStringAsFixed(0)}%',
                                  subText: '${stats.diskUsedGb.toStringAsFixed(0)} / ${stats.diskTotalGb.toStringAsFixed(0)} GB',
                                  icon: Icons.storage_rounded,
                                  accentColor: AppTheme.blue,
                                ),
                                AnimatedGauge(
                                  label: 'Network',
                                  percentage: (stats.downloadKbps / 10240 * 100).clamp(0.0, 100.0),
                                  valueText: stats.downloadKbps > 1024
                                      ? '${(stats.downloadKbps / 1024).toStringAsFixed(1)} MB/s'
                                      : '${stats.downloadKbps.toStringAsFixed(0)} KB/s',
                                  subText: 'Up: ${stats.uploadKbps.toStringAsFixed(0)} KB/s',
                                  icon: Icons.swap_vert_rounded,
                                  accentColor: AppTheme.emerald,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Quick Mode Utility Bar
                          Row(
                            children: [
                              Expanded(
                                child: _UtilityPill(
                                  icon: Icons.mouse_rounded,
                                  label: 'Trackpad',
                                  onTap: onOpenTrackpad,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: _UtilityPill(
                                  icon: Icons.share_rounded,
                                  label: 'Beam Link',
                                  onTap: onOpenShare,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: _UtilityPill(
                                  icon: Icons.screen_rotation_rounded,
                                  label: 'Standard',
                                  onTap: onExitStandby,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    // ==========================================
                    // COLUMN 3: TACTILE ACTION DECK & LAUNCHERS
                    // ==========================================
                    Expanded(
                      flex: 30,
                      child: Column(
                        children: [
                          // Stream-Deck Style 6-Tile Grid
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                              childAspectRatio: 1.85,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                TactileTile(
                                  label: stats.isMicMuted ? 'Muted' : 'Mic Live',
                                  subtitle: 'Toggle',
                                  icon: stats.isMicMuted
                                      ? Icons.mic_off_rounded
                                      : Icons.mic_rounded,
                                  accentColor: stats.isMicMuted
                                      ? AppTheme.rose
                                      : AppTheme.emerald,
                                  isActive: stats.isMicMuted,
                                  onTap: () => conn.toggleMic(),
                                ),
                                TactileTile(
                                  label: 'Lock PC',
                                  subtitle: 'Lock screen',
                                  icon: Icons.lock_outline_rounded,
                                  accentColor: AppTheme.amber,
                                  onTap: () => conn.sendSystemAction('lock_pc'),
                                ),
                                TactileTile(
                                  label: 'Snippet',
                                  subtitle: 'Win+Shift+S',
                                  icon: Icons.crop_free_rounded,
                                  accentColor: AppTheme.cyan,
                                  onTap: () => conn.sendSystemAction('screenshot'),
                                ),
                                TactileTile(
                                  label: 'Desktop',
                                  subtitle: 'Win + D',
                                  icon: Icons.desktop_windows_rounded,
                                  accentColor: AppTheme.blue,
                                  onTap: () => conn.sendSystemAction('show_desktop'),
                                ),
                                TactileTile(
                                  label: 'Task Mgr',
                                  subtitle: 'Ctrl+Shift+Esc',
                                  icon: Icons.analytics_outlined,
                                  accentColor: AppTheme.purple,
                                  onTap: () => conn.sendSystemAction('task_manager'),
                                ),
                                TactileTile(
                                  label: 'Sleep PC',
                                  subtitle: 'Standby',
                                  icon: Icons.nightlight_round,
                                  accentColor: AppTheme.rose,
                                  isDestructive: true,
                                  onTap: () => conn.sendSystemAction('sleep_pc'),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Quick App Launcher Bar
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _SmallAppIcon(
                                  icon: Icons.code_rounded,
                                  color: const Color(0xFF007ACC),
                                  tooltip: 'VS Code',
                                  onTap: () => conn.launchApp('vscode'),
                                ),
                                const SizedBox(width: 4),
                                _SmallAppIcon(
                                  icon: Icons.terminal_rounded,
                                  color: const Color(0xFF4E54C8),
                                  tooltip: 'Terminal',
                                  onTap: () => conn.launchApp('terminal'),
                                ),
                                const SizedBox(width: 4),
                                _SmallAppIcon(
                                  icon: Icons.language_rounded,
                                  color: const Color(0xFF4285F4),
                                  tooltip: 'Browser',
                                  onTap: () => conn.launchApp('browser'),
                                ),
                                const SizedBox(width: 4),
                                _SmallAppIcon(
                                  icon: Icons.album_rounded,
                                  color: const Color(0xFF1DB954),
                                  tooltip: 'Spotify',
                                  onTap: () => conn.launchApp('spotify'),
                                ),
                                const SizedBox(width: 4),
                                _SmallAppIcon(
                                  icon: Icons.calculate_rounded,
                                  color: const Color(0xFFFF9900),
                                  tooltip: 'Calculator',
                                  onTap: () => conn.launchApp('calculator'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDiscovery(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const DiscoveryDialog(),
    );
  }
}

class _UtilityPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UtilityPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: AppTheme.cyan),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallAppIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _SmallAppIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
        ),
      ),
    );
  }
}

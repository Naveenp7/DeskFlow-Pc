import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connection_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/stat_gauge_card.dart';
import '../widgets/volume_slider.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectionService>();
    final stats = conn.stats;
    final isConnected = conn.isConnected;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner notification if present
          if (conn.bannerNotification != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.emerald.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.emerald.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppTheme.emerald, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      conn.bannerNotification!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.emerald,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Quick PC Glance Card
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isConnected
                            ? AppTheme.emerald.withValues(alpha: 0.15)
                            : AppTheme.amber.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.computer_rounded,
                        color: isConnected ? AppTheme.emerald : AppTheme.amber,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isConnected ? stats.hostname : 'No PC Connected',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          isConnected
                              ? 'Uptime: ${stats.uptime} • ${stats.cpuCores} Cores'
                              : 'Open PC companion on same Wi-Fi',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (stats.hasBattery)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          stats.isCharging
                              ? Icons.battery_charging_full_rounded
                              : Icons.battery_std_rounded,
                          color: stats.batteryPercent > 20
                              ? AppTheme.emerald
                              : AppTheme.rose,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${stats.batteryPercent}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section Title
          const Text(
            'SYSTEM METRICS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 10),

          // 4-Card System Telemetry Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              StatGaugeCard(
                title: 'CPU Usage',
                valueText: '${stats.cpu.toStringAsFixed(1)}%',
                subText: '${stats.cpuCores} Logical Processors',
                progress: stats.cpu / 100.0,
                icon: Icons.speed_rounded,
                accentColor: AppTheme.cyan,
              ),
              StatGaugeCard(
                title: 'RAM Memory',
                valueText: '${stats.ramPercent.toStringAsFixed(1)}%',
                subText: '${stats.ramUsedGb.toStringAsFixed(1)} / ${stats.ramTotalGb.toStringAsFixed(0)} GB',
                progress: stats.ramPercent / 100.0,
                icon: Icons.memory_rounded,
                accentColor: AppTheme.purple,
              ),
              StatGaugeCard(
                title: 'Primary Drive C:',
                valueText: '${stats.diskPercent.toStringAsFixed(1)}%',
                subText: '${stats.diskUsedGb.toStringAsFixed(0)} / ${stats.diskTotalGb.toStringAsFixed(0)} GB',
                progress: stats.diskPercent / 100.0,
                icon: Icons.storage_rounded,
                accentColor: AppTheme.blue,
              ),
              StatGaugeCard(
                title: 'Network Traffic',
                valueText: stats.downloadKbps > 1024
                    ? '${(stats.downloadKbps / 1024).toStringAsFixed(1)} MB/s'
                    : '${stats.downloadKbps.toStringAsFixed(0)} KB/s',
                subText: 'Up: ${stats.uploadKbps.toStringAsFixed(0)} KB/s',
                progress: (stats.downloadKbps / 10240).clamp(0.0, 1.0),
                icon: Icons.swap_vert_rounded,
                accentColor: AppTheme.emerald,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Volume Control Section
          VolumeControlWidget(
            volumeLevel: stats.volumeLevel,
            isMuted: stats.isMuted,
            onVolumeChanged: (val) => conn.setVolume(val),
            onToggleMute: () => conn.setMute(!stats.isMuted),
          ),
          const SizedBox(height: 16),

          // Quick Media Player Controller
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.music_note_rounded, color: AppTheme.purple, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Media Playback Controls',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MediaButton(
                      icon: Icons.skip_previous_rounded,
                      label: 'Prev',
                      onTap: () => conn.sendMediaAction('prev'),
                    ),
                    _MediaButton(
                      icon: Icons.play_arrow_rounded,
                      label: 'Play / Pause',
                      isPrimary: true,
                      onTap: () => conn.sendMediaAction('play_pause'),
                    ),
                    _MediaButton(
                      icon: Icons.skip_next_rounded,
                      label: 'Next',
                      onTap: () => conn.sendMediaAction('next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isPrimary ? 54 : 46,
            height: isPrimary ? 54 : 46,
            decoration: BoxDecoration(
              gradient: isPrimary
                  ? const LinearGradient(
                      colors: [AppTheme.purple, AppTheme.cyan],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isPrimary ? null : AppTheme.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: isPrimary ? AppTheme.cyan : AppTheme.border,
                width: 1,
              ),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: AppTheme.purple.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isPrimary ? Colors.white : AppTheme.textPrimary,
              size: isPrimary ? 28 : 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

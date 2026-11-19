import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connection_service.dart';
import '../theme/app_theme.dart';
import '../widgets/claude_quota_view.dart';
import '../widgets/ai_sessions_card.dart';
import '../widgets/github_card.dart';
import '../widgets/spotify_media_card.dart';
import '../widgets/wave_sparkline.dart';
import '../widgets/processes_view.dart';
import '../widgets/radial_glow_gauge.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  int _activeSection = 0; // 0: All, 1: Claude & AI, 2: GitHub, 3: Hardware, 4: Processes

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectionService>();
    final stats = conn.stats;
    final claude = conn.claudeQuota;
    final sessions = conn.aiSessions;
    final github = conn.githubData;
    final processes = conn.processes;
    final gpu = stats.gpu;

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

          // Quick Filter Segment Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Full Deck',
                  isSelected: _activeSection == 0,
                  icon: Icons.dashboard_customize_rounded,
                  onTap: () => setState(() => _activeSection = 0),
                ),
                _FilterChip(
                  label: 'Claude & Sessions',
                  isSelected: _activeSection == 1,
                  icon: Icons.auto_awesome_rounded,
                  accentColor: const Color(0xFFFF9F0A),
                  onTap: () => setState(() => _activeSection = 1),
                ),
                _FilterChip(
                  label: 'GitHub PRs',
                  isSelected: _activeSection == 2,
                  icon: Icons.code_rounded,
                  accentColor: const Color(0xFFFFD60A),
                  onTap: () => setState(() => _activeSection = 2),
                ),
                _FilterChip(
                  label: 'Hardware & Waves',
                  isSelected: _activeSection == 3,
                  icon: Icons.monitor_heart_rounded,
                  accentColor: const Color(0xFF0A84FF),
                  onTap: () => setState(() => _activeSection = 3),
                ),
                _FilterChip(
                  label: 'Processes',
                  isSelected: _activeSection == 4,
                  icon: Icons.dns_rounded,
                  accentColor: const Color(0xFFF472B6),
                  onTap: () => setState(() => _activeSection = 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 1. CLAUDE CODE QUOTA & CREDITS VIEW
          if (_activeSection == 0 || _activeSection == 1) ...[
            SizedBox(
              height: 250,
              child: ClaudeQuotaView(
                quota: claude,
                onRefresh: () => conn.refreshClaudeQuota(),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // 2. AI SESSIONS CARD
          if (_activeSection == 0 || _activeSection == 1) ...[
            SizedBox(
              height: 260,
              child: AiSessionsCard(sessions: sessions),
            ),
            const SizedBox(height: 14),
          ],

          // 3. GITHUB REVIEWS & PRS
          if (_activeSection == 0 || _activeSection == 2) ...[
            SizedBox(
              height: 270,
              child: GitHubCard(
                data: github,
                onOpenUrl: (url) => conn.openUrlOnPc(url),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // 4. MEDIA CONTROLS CARD
          if (_activeSection == 0) ...[
            MediaControlsCard(
              compact: false,
              volumeLevel: stats.volumeLevel,
              isMuted: stats.isMuted,
              onPlayPause: () => conn.sendMediaAction('play_pause'),
              onNext: () => conn.sendMediaAction('next'),
              onPrev: () => conn.sendMediaAction('prev'),
              onVolumeChanged: (v) => conn.setVolume(v),
            ),
            const SizedBox(height: 14),
          ],

          // 5. HARDWARE WAVE GRAPHS & RADIAL GAUGES
          if (_activeSection == 0 || _activeSection == 3) ...[
            const Row(
              children: [
                Icon(Icons.speed_rounded, color: AppTheme.cyan, size: 16),
                SizedBox(width: 6),
                Text(
                  'TELEMETRY & HARDWARE WAVES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 4 Radial Arc Gauges Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF15151B),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF26262E), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RadialGlowGauge(
                    percentage: stats.cpu,
                    centerText: '${stats.cpu.toInt()}%',
                    label: 'CPU',
                    subText: '${stats.cpuCores} cores',
                    primaryColor: const Color(0xFF0A84FF),
                    size: 72,
                    strokeWidth: 6.5,
                    showPointer: false,
                  ),
                  RadialGlowGauge(
                    percentage: gpu?.percent ?? 0.0,
                    centerText: gpu != null ? '${gpu.percent.toInt()}%' : '--',
                    label: 'GPU',
                    subText: gpu != null ? '${gpu.tempC.toInt()}°C · ${gpu.powerW.toInt()} W' : 'none detected',
                    primaryColor: const Color(0xFF84CC16),
                    size: 72,
                    strokeWidth: 6.5,
                    showPointer: false,
                  ),
                  RadialGlowGauge(
                    percentage: stats.ramPercent,
                    centerText: stats.ramTotalGb > 0 ? '${stats.ramUsedGb.toStringAsFixed(1)} GB' : '--',
                    label: 'RAM',
                    subText: stats.ramTotalGb > 0
                        ? '${stats.ramUsedGb.toStringAsFixed(1)} / ${stats.ramTotalGb.toInt()} GB'
                        : 'no data',
                    primaryColor: const Color(0xFFBF5AF2),
                    size: 72,
                    strokeWidth: 6.5,
                    showPointer: false,
                  ),
                  RadialGlowGauge(
                    percentage: stats.diskPercent,
                    centerText: '${stats.diskPercent.toInt()}%',
                    label: 'DISK C:',
                    subText: '${stats.diskUsedGb.toStringAsFixed(0)} / ${stats.diskTotalGb.toInt()} GB',
                    primaryColor: const Color(0xFFFF9F0A),
                    size: 72,
                    strokeWidth: 6.5,
                    showPointer: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Waves 2x2 Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.6,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                WaveSparklineCard(
                  title: 'CPU Usage',
                  valueText: '${stats.cpu.toStringAsFixed(0)}%',
                  subText: '${stats.cpuCores} cores',
                  primaryColor: const Color(0xFF0A84FF),
                ),
                WaveSparklineCard(
                  title: gpu?.name ?? 'GPU',
                  valueText: gpu != null ? '${gpu.percent.toStringAsFixed(0)}%' : '--',
                  subText: gpu != null ? '${gpu.tempC.toStringAsFixed(0)}°C · ${gpu.powerW.toStringAsFixed(0)} W' : 'none detected',
                  primaryColor: const Color(0xFF84CC16),
                ),
                WaveSparklineCard(
                  title: 'RAM Memory',
                  valueText: '${stats.ramPercent.toStringAsFixed(0)}%',
                  subText: stats.ramTotalGb > 0
                      ? '${stats.ramUsedGb.toStringAsFixed(1)} / ${stats.ramTotalGb.toInt()} GB'
                      : '--',
                  primaryColor: const Color(0xFFBF5AF2),
                ),
                WaveSparklineCard(
                  title: 'Network',
                  valueText: '↓ ${(stats.downloadKbps / 1024).toStringAsFixed(1)} MB/s',
                  subText: '↑ ${stats.uploadKbps.toStringAsFixed(0)} KB/s',
                  primaryColor: const Color(0xFFFFD60A),
                  secondaryColor: const Color(0xFF0A84FF),
                  isNetworkDual: true,
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],

          // 6. PROCESSES & TASK MANAGER
          if (_activeSection == 0 || _activeSection == 4) ...[
            SizedBox(
              height: 380,
              child: ProcessesView(
                processes: processes,
                totalCpuPct: stats.cpu,
                onProcessAction: (item, action) {
                  if (action == 'kill') {
                    conn.killProcess(item.name);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData icon;
  final Color? accentColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.icon,
    this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppTheme.cyan;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.18) : const Color(0xFF1A1A20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.6) : const Color(0xFF26262E),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? color : Colors.white54,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

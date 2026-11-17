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
    final media = conn.mediaTrack;

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
                  accentColor: const Color(0xFFFF6E3A),
                  onTap: () => setState(() => _activeSection = 1),
                ),
                _FilterChip(
                  label: 'GitHub PRs',
                  isSelected: _activeSection == 2,
                  icon: Icons.code_rounded,
                  accentColor: const Color(0xFFFBBF24),
                  onTap: () => setState(() => _activeSection = 2),
                ),
                _FilterChip(
                  label: 'Hardware & Waves',
                  isSelected: _activeSection == 3,
                  icon: Icons.monitor_heart_rounded,
                  accentColor: const Color(0xFF00E5FF),
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
              child: AiSessionsCard(
                sessions: sessions,
                onPermissionResponse: (session, allow) {
                  conn.respondToSessionPermission(session.id, allow);
                },
              ),
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

          // 4. SPOTIFY MEDIA CARD
          if (_activeSection == 0) ...[
            SpotifyMediaCard(
              track: media,
              compact: false,
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
                color: const Color(0xFF10121A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1E212E), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RadialGlowGauge(
                    percentage: stats.cpu > 0 ? stats.cpu : 27.0,
                    centerText: '${(stats.cpu > 0 ? stats.cpu : 27.0).toInt()}%',
                    label: 'CPU',
                    subText: '68°C',
                    primaryColor: const Color(0xFF00E5FF),
                    size: 72,
                    strokeWidth: 6.5,
                    showPointer: false,
                  ),
                  const RadialGlowGauge(
                    percentage: 7.0,
                    centerText: '7%',
                    label: 'GPU',
                    subText: '60°C · 58 W',
                    primaryColor: Color(0xFF84CC16),
                    size: 72,
                    strokeWidth: 6.5,
                    showPointer: false,
                  ),
                  RadialGlowGauge(
                    percentage: (stats.ramUsedGb / (stats.ramTotalGb > 0 ? stats.ramTotalGb : 64) * 100).clamp(0.0, 100.0),
                    centerText: '${stats.ramUsedGb > 0 ? stats.ramUsedGb.toStringAsFixed(1) : '23.7'} GB',
                    label: 'RAM',
                    subText: '${stats.ramUsedGb > 0 ? stats.ramUsedGb.toStringAsFixed(1) : '23.7'} / ${stats.ramTotalGb > 0 ? stats.ramTotalGb.toInt() : 64} GB',
                    primaryColor: const Color(0xFFA855F7),
                    size: 72,
                    strokeWidth: 6.5,
                    showPointer: false,
                  ),
                  const RadialGlowGauge(
                    percentage: 60.0,
                    centerText: '60°C',
                    label: 'GPU TEMP',
                    subText: 'Fan 34%',
                    primaryColor: Color(0xFFFF6E3A),
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
                  valueText: '${(stats.cpu > 0 ? stats.cpu : 14.0).toStringAsFixed(0)}%',
                  subText: '54°C · ${stats.cpuCores} Cores',
                  primaryColor: const Color(0xFF00E5FF),
                ),
                const WaveSparklineCard(
                  title: 'GPU RTX 4080',
                  valueText: '7%',
                  subText: '53°C · 38 W',
                  primaryColor: Color(0xFF84CC16),
                ),
                WaveSparklineCard(
                  title: 'RAM Memory',
                  valueText: '${stats.ramPercent > 0 ? stats.ramPercent.toStringAsFixed(0) : '33'}%',
                  subText: '${stats.ramUsedGb > 0 ? stats.ramUsedGb.toStringAsFixed(1) : '21.2'} / ${stats.ramTotalGb > 0 ? stats.ramTotalGb.toInt() : 64} GB',
                  primaryColor: const Color(0xFFA855F7),
                ),
                WaveSparklineCard(
                  title: 'Network',
                  valueText: '↓ ${(stats.downloadKbps > 0 ? stats.downloadKbps / 1024 : 8.7).toStringAsFixed(1)} MB/s',
                  subText: '↑ ${(stats.uploadKbps > 0 ? stats.uploadKbps : 332).toStringAsFixed(0)} KB/s',
                  primaryColor: const Color(0xFFF59E0B),
                  secondaryColor: const Color(0xFF00E5FF),
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
          color: isSelected ? color.withValues(alpha: 0.18) : const Color(0xFF141724),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.6) : const Color(0xFF1F2336),
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

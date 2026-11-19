import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/ai_session.dart';
import '../models/claude_quota.dart';
import '../models/github_data.dart';
import '../models/system_process.dart';
import '../models/system_stats.dart';
import '../models/weather_media.dart';
import '../services/connection_service.dart';
import '../widgets/radial_glow_gauge.dart';
import '../widgets/claude_quota_view.dart';
import '../widgets/ai_sessions_card.dart';
import '../widgets/github_card.dart';
import '../widgets/processes_view.dart';
import '../widgets/hardware_waves_view.dart';
import '../widgets/spotify_media_card.dart';
import '../widgets/weather_forecast_card.dart';
import '../widgets/tactile_deck_grid.dart';
import '../widgets/docker_storage_card.dart';
import '../widgets/desk_status_header.dart';
import '../widgets/desk_pagination_bar.dart';
import 'discovery_dialog.dart';

class StandbyScreen extends StatefulWidget {
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
  State<StandbyScreen> createState() => _StandbyScreenState();
}

class _StandbyScreenState extends State<StandbyScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isAutoCycle = false;
  Timer? _cycleTimer;

  static const List<String> _pageTitles = [
    'Overview Deck',
    'Claude Quotas',
    'Sessions & GitHub',
    'Hardware Waves',
    'Task Manager',
    'Multi-Metric',
    'Media & Forecast',
    'Docker & Storage',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Desk Standby Dock is meant to sit on a desk like a screen — never sleep.
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _pageController.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  void _toggleAutoCycle() {
    setState(() {
      _isAutoCycle = !_isAutoCycle;
      if (_isAutoCycle) {
        _cycleTimer = Timer.periodic(const Duration(seconds: 12), (_) {
          if (!mounted) return;
          final nextPage = (_currentPage + 1) % _pageTitles.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeInOutCubic,
          );
        });
      } else {
        _cycleTimer?.cancel();
        _cycleTimer = null;
      }
    });
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _openDiscovery(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const DiscoveryDialog(),
    );
  }

  void _handleDeckAction(BuildContext context, ConnectionService conn, String action) {
    if (action == 'trackpad') {
      widget.onOpenTrackpad();
    } else if (action == 'share') {
      widget.onOpenShare();
    } else if (action == 'screen_off') {
      conn.sendSystemAction('screen_off');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turning off PC display...'),
          duration: Duration(seconds: 1),
          backgroundColor: Color(0xFF26262E),
        ),
      );
    } else if (action == 'mute') {
      conn.setMute(!conn.stats.isMuted);
    } else if (['lock_pc', 'screenshot', 'task_manager'].contains(action)) {
      conn.sendSystemAction(action);
    } else {
      conn.launchApp(action);
    }
  }

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectionService>();
    final stats = conn.stats;
    final isConnected = conn.isConnected;
    final claude = conn.claudeQuota;
    final sessions = conn.aiSessions;
    final github = conn.githubData;
    final processes = conn.processes;
    final weather = conn.weather;

    final workingCount = sessions.where((s) => s.status == AiSessionStatus.working).length;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Column(
            children: [
              // 1. Top Desk Status Bar
              DeskStatusHeader(
                hostname: stats.hostname.isNotEmpty ? stats.hostname : 'DESK-PC',
                isConnected: isConnected,
                hasBattery: stats.hasBattery,
                batteryPercent: stats.batteryPercent,
                isCharging: stats.isCharging,
                claudePct: claude.sessionPct,
                activeSessionCount: workingCount,
                onExit: widget.onExitStandby,
                onConnectTap: () => _openDiscovery(context),
                onActiveSessionsTap: () => _goToPage(2), // jump to Sessions & GitHub
              ),

              const SizedBox(height: 4),

              // 2. Main PageView Deck
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (idx) {
                    setState(() => _currentPage = idx);
                  },
                  children: [
                    // PAGE 0: OVERVIEW DECK
                    _buildOverviewDeck(context, conn, stats, weather),

                    // PAGE 1: CLAUDE CODE USAGE
                    ClaudeQuotaView(
                      quota: claude,
                      onRefresh: () => conn.refreshClaudeQuota(),
                    ),

                    // PAGE 2: AI SESSIONS & GITHUB
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 52,
                          child: AiSessionsCard(sessions: sessions),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 48,
                          child: GitHubCard(
                            data: github,
                            onOpenUrl: (url) => conn.openUrlOnPc(url),
                          ),
                        ),
                      ],
                    ),

                    // PAGE 3: HARDWARE WAVES
                    HardwareWavesView(
                      cpuPct: stats.cpu,
                      cpuCores: stats.cpuCores,
                      gpu: stats.gpu,
                      ramUsedGb: stats.ramUsedGb,
                      ramTotalGb: stats.ramTotalGb,
                      disks: stats.disks,
                      downMBs: stats.downloadKbps / 1024,
                      upKBs: stats.uploadKbps,
                      pingMs: conn.pingMs,
                      uptime: stats.uptime,
                    ),

                    // PAGE 4: PROCESSES & TASK MANAGER
                    ProcessesView(
                      processes: processes,
                      totalCpuPct: stats.cpu,
                      onProcessAction: (item, action) {
                        if (action == 'kill') {
                          conn.killProcess(item.name);
                        }
                      },
                    ),

                    // PAGE 5: MULTI-METRIC DECK
                    _buildMultiMetricDeck(conn, claude, stats, processes, sessions),

                    // PAGE 6: MEDIA CONTROLS & 7-DAY FORECAST
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 52,
                          child: MediaControlsCard(
                            compact: false,
                            volumeLevel: stats.volumeLevel,
                            isMuted: stats.isMuted,
                            onPlayPause: () => conn.sendMediaAction('play_pause'),
                            onNext: () => conn.sendMediaAction('next'),
                            onPrev: () => conn.sendMediaAction('prev'),
                            onVolumeChanged: (v) => conn.setVolume(v),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 48,
                          child: WeatherForecastCard(weather: weather),
                        ),
                      ],
                    ),

                    // PAGE 7: DOCKER & STORAGE DECK
                    _buildDockerStorageDeck(conn, stats, sessions, github),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // 3. Bottom Pagination Bar (Dots with Auto-Cycle)
              DeskPaginationBar(
                totalPages: _pageTitles.length,
                currentPage: _currentPage,
                pageTitle: _pageTitles[_currentPage],
                isAutoCycle: _isAutoCycle,
                onPageSelected: _goToPage,
                onToggleAutoCycle: _toggleAutoCycle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Page 0: Overview Deck with Clock, 4 Radial Gauges, Media & Tactile Action Deck
  Widget _buildOverviewDeck(
    BuildContext context,
    ConnectionService conn,
    SystemStats stats,
    WeatherData weather,
  ) {
    final ramRatio =
        stats.ramTotalGb > 0 ? (stats.ramUsedGb / stats.ramTotalGb * 100).clamp(0.0, 100.0) : 0.0;
    final gpu = stats.gpu;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column (flex: 38): Clock & Weather + Media Card
        Expanded(
          flex: 38,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Big Clock + Weather
              Expanded(
                flex: 48,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15151B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF26262E), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Clock with superscript seconds
                      _OverviewClockHeader(),
                      // Weather row -- real data, or a quiet placeholder.
                      Row(
                        children: [
                          const Icon(Icons.wb_cloudy_rounded,
                              size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              weather.available
                                  ? '${weather.temp}°  ${weather.city}'
                                  : 'Weather unavailable',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (weather.available) ...[
                            const SizedBox(width: 4),
                            Text(
                              '↑${weather.maxTemp}° ↓${weather.minTemp}° · Feels like ${weather.feelsLike}°',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Compact Media Controls
              Expanded(
                flex: 52,
                child: MediaControlsCard(
                  compact: true,
                  volumeLevel: stats.volumeLevel,
                  isMuted: stats.isMuted,
                  onPlayPause: () => conn.sendMediaAction('play_pause'),
                  onNext: () => conn.sendMediaAction('next'),
                  onPrev: () => conn.sendMediaAction('prev'),
                  onVolumeChanged: (v) => conn.setVolume(v),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Right Column (flex: 62): 4 Radial Gauges + 12 Action Buttons Deck
        Expanded(
          flex: 62,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top: 4 Radial Arc Gauges (CPU, GPU, RAM, Disk)
              Expanded(
                flex: 48,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15151B),
                    borderRadius: BorderRadius.circular(16),
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
                        secondaryColor: const Color(0xFF00B4D8),
                        size: 78,
                        strokeWidth: 7,
                        showPointer: false,
                      ),
                      RadialGlowGauge(
                        percentage: gpu?.percent ?? 0.0,
                        centerText: gpu != null ? '${gpu.percent.toInt()}%' : '--',
                        label: 'GPU',
                        subText: gpu != null ? '${gpu.tempC.toInt()}°C' : 'none detected',
                        primaryColor: const Color(0xFF84CC16),
                        secondaryColor: const Color(0xFF65A30D),
                        size: 78,
                        strokeWidth: 7,
                        showPointer: false,
                      ),
                      RadialGlowGauge(
                        percentage: ramRatio,
                        centerText: stats.ramTotalGb > 0 ? '${stats.ramUsedGb.toStringAsFixed(1)} GB' : '--',
                        label: 'RAM',
                        subText: stats.ramTotalGb > 0
                            ? '${stats.ramUsedGb.toStringAsFixed(1)} / ${stats.ramTotalGb.toInt()} GB'
                            : 'no data',
                        primaryColor: const Color(0xFFBF5AF2),
                        secondaryColor: const Color(0xFF9333EA),
                        size: 78,
                        strokeWidth: 7,
                        showPointer: false,
                      ),
                      RadialGlowGauge(
                        percentage: stats.diskPercent,
                        centerText: '${stats.diskPercent.toInt()}%',
                        label: 'DISK C:',
                        subText: '${stats.diskUsedGb.toStringAsFixed(0)} / ${stats.diskTotalGb.toInt()} GB',
                        primaryColor: const Color(0xFFFF9F0A),
                        secondaryColor: const Color(0xFFEA580C),
                        size: 78,
                        strokeWidth: 7,
                        showPointer: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Bottom: 12 Tactile Action Buttons
              Expanded(
                flex: 52,
                child: TactileDeckGrid(
                  isMuted: stats.isMuted,
                  onActionTriggered: (action) =>
                      _handleDeckAction(context, conn, action),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Page 5: Multi-Metric Deck
  Widget _buildMultiMetricDeck(
    ConnectionService conn,
    ClaudeQuota claude,
    SystemStats stats,
    List<SystemProcessItem> processes,
    List<AiSessionItem> sessions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top 4 Radial Gauges: Claude session, Claude weekly, CPU, Disk
        Expanded(
          flex: 48,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF15151B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF26262E), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RadialGlowGauge(
                  percentage: claude.sessionPct,
                  centerText: '${claude.sessionPct.toInt()}%',
                  label: 'Claude · 5-hour',
                  subText: claude.sessionReset,
                  primaryColor: const Color(0xFFFF9F0A),
                  size: 78,
                  strokeWidth: 7,
                  showPointer: false,
                ),
                RadialGlowGauge(
                  percentage: claude.weeklyPct,
                  centerText: '${claude.weeklyPct.toInt()}%',
                  label: 'Claude · Weekly',
                  subText: claude.weeklyReset,
                  primaryColor: const Color(0xFFFF9F0A),
                  size: 78,
                  strokeWidth: 7,
                  showPointer: false,
                ),
                RadialGlowGauge(
                  percentage: stats.cpu,
                  centerText: '${stats.cpu.toInt()}%',
                  label: 'CPU',
                  subText: '${stats.cpuCores} cores',
                  primaryColor: const Color(0xFF0A84FF),
                  size: 78,
                  strokeWidth: 7,
                  showPointer: false,
                ),
                RadialGlowGauge(
                  percentage: stats.diskPercent,
                  centerText: '${stats.diskPercent.toInt()}%',
                  label: 'DISK C:',
                  subText: '${stats.diskUsedGb.toStringAsFixed(0)} GB used',
                  primaryColor: const Color(0xFF30D158),
                  size: 78,
                  strokeWidth: 7,
                  showPointer: false,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Bottom 3 Panels: TOP CPU, Volume Capsule, Sessions List
        Expanded(
          flex: 52,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TOP CPU List
              Expanded(
                flex: 38,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15151B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF26262E), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOP CPU (${stats.cpu.toInt()}%)',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Color(0xFFF472B6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: processes.isEmpty
                            ? Center(
                                child: Text(
                                  'Waiting for data...',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.white.withValues(alpha: 0.35)),
                                ),
                              )
                            : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: processes.length.clamp(0, 4),
                          itemBuilder: (ctx, i) {
                            final p = processes[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.5),
                              child: Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: p.avatarColor.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      p.avatarLetter,
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        color: p.avatarColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      '${p.name} ×${p.count}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${p.cpuPct.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Volume Capsule Slider
              Expanded(
                flex: 18,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15151B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF26262E), width: 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        'VOLUME',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        '${stats.volumeLevel}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              stats.isMuted
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_mute_rounded,
                              size: 14,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            color: stats.isMuted ? Colors.red : Colors.white70,
                            onPressed: () => conn.setMute(!stats.isMuted),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.remove_rounded, size: 14),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            color: Colors.white70,
                            onPressed: () => conn.setVolume((stats.volumeLevel - 5).clamp(0, 100)),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.add_rounded, size: 14),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            color: Colors.white70,
                            onPressed: () => conn.setVolume((stats.volumeLevel + 5).clamp(0, 100)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Sessions Mini List
              Expanded(
                flex: 44,
                child: AiSessionsCard(sessions: sessions),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Page 7: Docker & Storage Deck
  Widget _buildDockerStorageDeck(
    ConnectionService conn,
    SystemStats stats,
    List<AiSessionItem> sessions,
    GitHubWorkspaceData github,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top: Docker & Drives cards + Radial Gauges
        Expanded(
          flex: 42,
          child: Row(
            children: [
              Expanded(
                flex: 55,
                child: DockerStorageCard(
                  dockerAvailable: conn.dockerAvailable,
                  containerCount: conn.containerCount,
                  freeDisksCount: conn.freeDisksCount,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 45,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15151B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF26262E), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RadialGlowGauge(
                        percentage: stats.cpu,
                        centerText: '${stats.cpu.toInt()}%',
                        label: 'CPU',
                        primaryColor: const Color(0xFF0A84FF),
                        size: 72,
                        strokeWidth: 6.5,
                        showPointer: false,
                      ),
                      RadialGlowGauge(
                        percentage: stats.ramPercent,
                        centerText: stats.ramTotalGb > 0 ? '${stats.ramUsedGb.toStringAsFixed(1)} GB' : '--',
                        label: 'RAM',
                        primaryColor: const Color(0xFFBF5AF2),
                        size: 72,
                        strokeWidth: 6.5,
                        showPointer: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Bottom: Sessions & GitHub side by side
        Expanded(
          flex: 58,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 50,
                child: AiSessionsCard(sessions: sessions),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 50,
                child: GitHubCard(
                  data: github,
                  onOpenUrl: (url) => conn.openUrlOnPc(url),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverviewClockHeader extends StatefulWidget {
  @override
  State<_OverviewClockHeader> createState() => _OverviewClockHeaderState();
}

class _OverviewClockHeaderState extends State<_OverviewClockHeader> {
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
      if (mounted) setState(() => _now = DateTime.now());
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
    final dateStr = '$weekdayStr ${_now.day} $monthStr';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$hourStr:$minStr',
              style: const TextStyle(
                fontSize: 38,
                height: 1.0,
                fontWeight: FontWeight.w200,
                letterSpacing: -1.5,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 3),
              child: Text(
                secStr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          dateStr,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

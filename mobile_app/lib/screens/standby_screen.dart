import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ai_session.dart';
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
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _pageController.dispose();
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
          backgroundColor: Color(0xFF1E2130),
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
    final media = conn.mediaTrack;

    final waitingCount =
        sessions.where((s) => s.status == AiSessionStatus.waiting).length;

    return Scaffold(
      backgroundColor: const Color(0xFF090A0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Column(
            children: [
              // 1. Top Desk Status Bar
              DeskStatusHeader(
                hostname: stats.hostname.isNotEmpty ? stats.hostname : 'DESK-PC',
                isConnected: isConnected,
                batteryPercent: stats.hasBattery ? stats.batteryPercent : 82,
                isCharging: stats.isCharging,
                claudePct: claude.sessionPct,
                codexPct: claude.codexSessionPct,
                waitingCount: waitingCount,
                onExit: widget.onExitStandby,
                onConnectTap: () => _openDiscovery(context),
                onWaitingTap: () => _goToPage(2), // jump to Sessions & GitHub
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
                    // ==========================================
                    // PAGE 0: OVERVIEW DECK (Screenshots 1 & 2)
                    // ==========================================
                    _buildOverviewDeck(context, conn, stats, weather, media),

                    // ==========================================
                    // PAGE 1: CLAUDE CODE QUOTAS (Screenshot 3)
                    // ==========================================
                    ClaudeQuotaView(
                      quota: claude,
                      onRefresh: () => conn.refreshClaudeQuota(),
                    ),

                    // ==========================================
                    // PAGE 2: AI SESSIONS & GITHUB (Screenshot 4)
                    // ==========================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 52,
                          child: AiSessionsCard(
                            sessions: sessions,
                            onPermissionResponse: (session, allow) {
                              conn.respondToSessionPermission(session.id, allow);
                            },
                          ),
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

                    // ==========================================
                    // PAGE 3: HARDWARE WAVES (Screenshot 5)
                    // ==========================================
                    HardwareWavesView(
                      cpuPct: stats.cpu > 0 ? stats.cpu : 10.0,
                      cpuTemp: '53°C',
                      gpuPct: 7.0,
                      gpuTemp: '53°C · 38 W',
                      ramUsedGb: stats.ramUsedGb > 0 ? stats.ramUsedGb : 21.2,
                      ramTotalGb: stats.ramTotalGb > 0 ? stats.ramTotalGb : 64.0,
                      vramUsedGb: 5.8,
                      vramTotalGb: 16.0,
                      downMBs: stats.downloadKbps > 0
                          ? stats.downloadKbps / 1024
                          : 8.7,
                      upKBs: stats.uploadKbps > 0 ? stats.uploadKbps : 332.0,
                      pingMs: conn.pingMs > 0 ? conn.pingMs : 9,
                      uptime: stats.uptime,
                    ),

                    // ==========================================
                    // PAGE 4: PROCESSES & TASK MANAGER (Screenshot 6)
                    // ==========================================
                    ProcessesView(
                      processes: processes,
                      onProcessAction: (item, action) {
                        if (action == 'kill') {
                          conn.killProcess(item.name);
                        }
                      },
                    ),

                    // ==========================================
                    // PAGE 5: MULTI-METRIC DECK (Screenshot 8)
                    // ==========================================
                    _buildMultiMetricDeck(conn, claude, stats, processes, sessions),

                    // ==========================================
                    // PAGE 6: MEDIA PLAYER & 7-DAY FORECAST (Screenshot 7)
                    // ==========================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 52,
                          child: SpotifyMediaCard(
                            track: media,
                            compact: false,
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

                    // ==========================================
                    // PAGE 7: DOCKER & STORAGE DECK (Screenshot 9)
                    // ==========================================
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
    dynamic stats,
    dynamic weather,
    dynamic media,
  ) {
    final cpuVal = stats.cpu > 0 ? stats.cpu : 27.0;
    final ramUsed = stats.ramUsedGb > 0 ? stats.ramUsedGb : 23.7;
    final ramTotal = stats.ramTotalGb > 0 ? stats.ramTotalGb : 64.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column (flex: 38): Clock & Weather + Media Card
        Expanded(
          flex: 38,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Big Clock + Tallinn Weather
              Expanded(
                flex: 48,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10121A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E212E), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Clock with superscript seconds
                      _OverviewClockHeader(),
                      // Weather row
                      Row(
                        children: [
                          const Icon(Icons.wb_cloudy_rounded,
                              size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          const Flexible(
                            child: Text(
                              '6°  Overcast · Tallinn',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '↑6° ↓3° · Feels like 2°',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Compact Spotify Media Player
              Expanded(
                flex: 52,
                child: SpotifyMediaCard(
                  track: media,
                  compact: true,
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
              // Top: 4 Radial Arc Gauges (CPU, GPU, RAM, GPU TEMP)
              Expanded(
                flex: 48,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10121A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E212E), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RadialGlowGauge(
                        percentage: cpuVal,
                        centerText: '${cpuVal.toInt()}%',
                        label: 'CPU',
                        subText: '68°C',
                        primaryColor: const Color(0xFF00E5FF),
                        secondaryColor: const Color(0xFF00B4D8),
                        size: 78,
                        strokeWidth: 7,
                        showPointer: false,
                      ),
                      const RadialGlowGauge(
                        percentage: 7.0,
                        centerText: '7%',
                        label: 'GPU',
                        subText: '60°C · 58 W',
                        primaryColor: Color(0xFF84CC16),
                        secondaryColor: Color(0xFF65A30D),
                        size: 78,
                        strokeWidth: 7,
                        showPointer: false,
                      ),
                      RadialGlowGauge(
                        percentage: (ramUsed / ramTotal * 100).clamp(0.0, 100.0),
                        centerText: '${ramUsed.toStringAsFixed(1)} GB',
                        label: 'RAM',
                        subText: '${ramUsed.toStringAsFixed(1)} / ${ramTotal.toInt()} GB',
                        primaryColor: const Color(0xFFA855F7),
                        secondaryColor: const Color(0xFF9333EA),
                        size: 78,
                        strokeWidth: 7,
                        showPointer: false,
                      ),
                      const RadialGlowGauge(
                        percentage: 60.0,
                        centerText: '60°C',
                        label: 'GPU TEMP',
                        subText: 'Fan 34% · 2520 MHz',
                        primaryColor: Color(0xFFFF6E3A),
                        secondaryColor: Color(0xFFEA580C),
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

  // Page 5: Multi-Metric Deck (Screenshot 8)
  Widget _buildMultiMetricDeck(
    ConnectionService conn,
    dynamic claude,
    dynamic stats,
    dynamic processes,
    dynamic sessions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top 4 Radial Gauges: Claude session, Claude weekly, Codex session, Phone
        Expanded(
          flex: 48,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10121A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E212E), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RadialGlowGauge(
                  percentage: claude.sessionPct,
                  centerText: '${claude.sessionPct.toInt()}%',
                  label: 'Claude · 5-hour',
                  subText: 'resets in 2 h 36 min',
                  primaryColor: const Color(0xFFFF6E3A),
                  size: 78,
                  strokeWidth: 7,
                  showPointer: false,
                ),
                RadialGlowGauge(
                  percentage: claude.weeklyPct,
                  centerText: '${claude.weeklyPct.toInt()}%',
                  label: 'Claude · Weekly',
                  subText: 'resets in 3 d 4 h',
                  primaryColor: const Color(0xFFFF6E3A),
                  size: 78,
                  strokeWidth: 7,
                  showPointer: false,
                ),
                RadialGlowGauge(
                  percentage: claude.codexSessionPct,
                  centerText: '${claude.codexSessionPct.toInt()}%',
                  label: 'Codex · 5-hour',
                  subText: 'resets in 4 h 6 min',
                  primaryColor: Colors.white,
                  size: 78,
                  strokeWidth: 7,
                  showPointer: false,
                ),
                RadialGlowGauge(
                  percentage: stats.hasBattery ? stats.batteryPercent.toDouble() : 82.0,
                  centerText: '${stats.hasBattery ? stats.batteryPercent : 82}%',
                  label: 'PHONE',
                  subText: '⚡ Charging · 30°C',
                  primaryColor: const Color(0xFF22C55E),
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
                    color: const Color(0xFF10121A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E212E), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOP CPU (10%)',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Color(0xFFF472B6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: 4,
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
                    color: const Color(0xFF10121A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E212E), width: 1),
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
                child: AiSessionsCard(
                  sessions: sessions,
                  onPermissionResponse: (session, allow) {
                    conn.respondToSessionPermission(session.id, allow);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Page 7: Docker & Storage Deck (Screenshot 9)
  Widget _buildDockerStorageDeck(
    ConnectionService conn,
    dynamic stats,
    dynamic sessions,
    dynamic github,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top: Docker & Free Disk cards + Radial Gauges
        Expanded(
          flex: 42,
          child: Row(
            children: [
              const Expanded(
                flex: 55,
                child: DockerStorageCard(
                  containerCount: 3,
                  freeDisksCount: 4,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 45,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10121A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E212E), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RadialGlowGauge(
                        percentage: 31.0,
                        centerText: '31%',
                        label: 'CPU',
                        primaryColor: const Color(0xFF00E5FF),
                        size: 72,
                        strokeWidth: 6.5,
                        showPointer: false,
                      ),
                      const RadialGlowGauge(
                        percentage: 33.0,
                        centerText: '21.1 GB',
                        label: 'RAM',
                        primaryColor: Color(0xFFA855F7),
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
                child: AiSessionsCard(
                  sessions: sessions,
                  onPermissionResponse: (session, allow) {
                    conn.respondToSessionPermission(session.id, allow);
                  },
                ),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/connection_service.dart';
import '../theme/app_theme.dart';
import 'dashboard_tab.dart';
import 'actions_tab.dart';
import 'trackpad_tab.dart';
import 'share_tab.dart';
import 'standby_screen.dart';
import 'discovery_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _forceStandby = false;

  final List<Widget> _tabs = const [
    DashboardTab(),
    ActionsTab(),
    TrackpadTab(),
    ShareTab(),
  ];

  void _toggleStandbyOrientation() {
    setState(() {
      _forceStandby = !_forceStandby;
    });

    if (_forceStandby) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // When physically in landscape or Standby Mode is triggered, render Standby Deck
    if (isLandscape || _forceStandby) {
      return StandbyScreen(
        onExitStandby: () {
          setState(() => _forceStandby = false);
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        },
        onOpenTrackpad: () {
          setState(() {
            _forceStandby = false;
            _currentIndex = 2; // Trackpad
          });
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        },
        onOpenShare: () {
          setState(() {
            _forceStandby = false;
            _currentIndex = 3; // Share
          });
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        },
      );
    }

    final conn = context.watch<ConnectionService>();
    final isConnected = conn.isConnected;
    final isConnecting = conn.status == DeviceConnectionStatus.connecting;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.cyan, AppTheme.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.hub_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'DeskFlow',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          // Standby Desk Mode Button
          IconButton(
            icon: const Icon(Icons.dock_rounded, size: 20),
            tooltip: 'Desk Standby Dock Mode',
            color: AppTheme.cyan,
            onPressed: _toggleStandbyOrientation,
          ),

          // Connection Status Pill
          GestureDetector(
            onTap: () => _openDiscoveryDialog(context),
            child: Container(
              margin: const EdgeInsets.only(right: 16, left: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isConnected
                    ? AppTheme.emerald.withValues(alpha: 0.15)
                    : isConnecting
                        ? AppTheme.cyan.withValues(alpha: 0.15)
                        : AppTheme.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isConnected
                      ? AppTheme.emerald.withValues(alpha: 0.4)
                      : isConnecting
                          ? AppTheme.cyan.withValues(alpha: 0.4)
                          : AppTheme.amber.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isConnected
                          ? AppTheme.emerald
                          : isConnecting
                              ? AppTheme.cyan
                              : AppTheme.amber,
                      boxShadow: [
                        BoxShadow(
                          color: (isConnected
                                  ? AppTheme.emerald
                                  : isConnecting
                                      ? AppTheme.cyan
                                      : AppTheme.amber)
                              .withValues(alpha: 0.8),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isConnected
                        ? '${conn.stats.hostname} (${conn.pingMs}ms)'
                        : isConnecting
                            ? 'Connecting...'
                            : 'Scan Wi-Fi',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isConnected
                          ? AppTheme.emerald
                          : isConnecting
                              ? AppTheme.cyan
                              : AppTheme.amber,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.radar_rounded,
                    size: 14,
                    color: isConnected
                        ? AppTheme.emerald
                        : isConnecting
                            ? AppTheme.cyan
                            : AppTheme.amber,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 6),
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.9),
          border: const Border(
            top: BorderSide(color: AppTheme.border, width: 0.8),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: NavigationBar(
            height: 60,
            backgroundColor: AppTheme.surfaceCard,
            indicatorColor: AppTheme.cyan.withValues(alpha: 0.2),
            selectedIndex: _currentIndex,
            onDestinationSelected: (idx) {
              setState(() => _currentIndex = idx);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, color: AppTheme.textSecondary),
                selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.cyan),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.touch_app_outlined, color: AppTheme.textSecondary),
                selectedIcon: Icon(Icons.touch_app_rounded, color: AppTheme.cyan),
                label: 'Actions',
              ),
              NavigationDestination(
                icon: Icon(Icons.mouse_outlined, color: AppTheme.textSecondary),
                selectedIcon: Icon(Icons.mouse_rounded, color: AppTheme.cyan),
                label: 'Trackpad',
              ),
              NavigationDestination(
                icon: Icon(Icons.share_outlined, color: AppTheme.textSecondary),
                selectedIcon: Icon(Icons.share_rounded, color: AppTheme.cyan),
                label: 'Share',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDiscoveryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const DiscoveryDialog(),
    );
  }
}

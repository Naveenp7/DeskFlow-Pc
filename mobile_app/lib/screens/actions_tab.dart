import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connection_service.dart';
import '../theme/app_theme.dart';
import '../widgets/tactile_tile.dart';

class ActionsTab extends StatelessWidget {
  const ActionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectionService>();
    final stats = conn.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Productivity Controls
          const Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppTheme.amber, size: 18),
              SizedBox(width: 8),
              Text(
                'QUICK PRODUCTIVITY ACTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              TactileTile(
                label: stats.isMicMuted ? 'Mic Muted' : 'Mic Live',
                subtitle: 'Tap to toggle mute',
                icon: stats.isMicMuted
                    ? Icons.mic_off_rounded
                    : Icons.mic_rounded,
                accentColor: stats.isMicMuted ? AppTheme.rose : AppTheme.emerald,
                isActive: stats.isMicMuted,
                onTap: () => conn.toggleMic(),
              ),
              TactileTile(
                label: 'Lock PC',
                subtitle: 'Lock workstation',
                icon: Icons.lock_outline_rounded,
                accentColor: AppTheme.amber,
                onTap: () => conn.sendSystemAction('lock_pc'),
              ),
              TactileTile(
                label: 'Show Desktop',
                subtitle: 'Win + D',
                icon: Icons.desktop_windows_rounded,
                accentColor: AppTheme.blue,
                onTap: () => conn.sendSystemAction('show_desktop'),
              ),
              TactileTile(
                label: 'Screenshot',
                subtitle: 'Snipping tool',
                icon: Icons.crop_free_rounded,
                accentColor: AppTheme.cyan,
                onTap: () => conn.sendSystemAction('screenshot'),
              ),
              TactileTile(
                label: 'Task Manager',
                subtitle: 'Ctrl+Shift+Esc',
                icon: Icons.analytics_outlined,
                accentColor: AppTheme.purple,
                onTap: () => conn.sendSystemAction('task_manager'),
              ),
              TactileTile(
                label: 'Sleep PC',
                subtitle: 'Standby mode',
                icon: Icons.nightlight_round,
                accentColor: AppTheme.rose,
                isDestructive: true,
                onTap: () => _confirmSleep(context, conn),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section: Quick App Launchers
          const Row(
            children: [
              Icon(Icons.rocket_launch_rounded, color: AppTheme.cyan, size: 18),
              SizedBox(width: 8),
              Text(
                'APP LAUNCHERS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0,
            children: [
              _AppLaunchTile(
                name: 'VS Code',
                icon: Icons.code_rounded,
                color: const Color(0xFF007ACC),
                onTap: () => conn.launchApp('vscode'),
              ),
              _AppLaunchTile(
                name: 'Terminal',
                icon: Icons.terminal_rounded,
                color: const Color(0xFF4E54C8),
                onTap: () => conn.launchApp('terminal'),
              ),
              _AppLaunchTile(
                name: 'Browser',
                icon: Icons.language_rounded,
                color: const Color(0xFF4285F4),
                onTap: () => conn.launchApp('browser'),
              ),
              _AppLaunchTile(
                name: 'Spotify',
                icon: Icons.album_rounded,
                color: const Color(0xFF1DB954),
                onTap: () => conn.launchApp('spotify'),
              ),
              _AppLaunchTile(
                name: 'Calculator',
                icon: Icons.calculate_rounded,
                color: const Color(0xFFFF9900),
                onTap: () => conn.launchApp('calculator'),
              ),
              _AppLaunchTile(
                name: 'Notepad',
                icon: Icons.edit_note_rounded,
                color: const Color(0xFF30D158),
                onTap: () => conn.launchApp('notepad'),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _confirmSleep(BuildContext context, ConnectionService conn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: const Text('Sleep PC?'),
        content: const Text(
          'This will put your computer into low-power sleep mode.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.rose,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              conn.sendSystemAction('sleep_pc');
            },
            child: const Text('Sleep'),
          ),
        ],
      ),
    );
  }
}

class _AppLaunchTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AppLaunchTile({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

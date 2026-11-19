import 'package:flutter/material.dart';

class TactileActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final String action;
  final bool hasDot;
  final bool isDotActive;

  const TactileActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.action,
    this.hasDot = false,
    this.isDotActive = false,
  });
}

class TactileDeckGrid extends StatelessWidget {
  final bool isMuted;
  final Function(String action)? onActionTriggered;

  const TactileDeckGrid({
    super.key,
    this.isMuted = false,
    this.onActionTriggered,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      const TactileActionItem(
        label: 'Terminal',
        icon: Icons.keyboard_rounded,
        color: Color(0xFFE2E8F0),
        action: 'terminal',
      ),
      const TactileActionItem(
        label: 'VS Code',
        icon: Icons.edit_note_rounded,
        color: Color(0xFF64D2FF),
        action: 'vscode',
      ),
      const TactileActionItem(
        label: 'Browser',
        icon: Icons.language_rounded,
        color: Color(0xFF0A84FF),
        action: 'browser',
      ),
      const TactileActionItem(
        label: 'Files',
        icon: Icons.folder_rounded,
        color: Color(0xFFFFD60A),
        action: 'files',
      ),
      const TactileActionItem(
        label: 'Spotify',
        icon: Icons.headphones_rounded,
        color: Color(0xFF22C55E),
        action: 'spotify',
      ),
      const TactileActionItem(
        label: 'Discord',
        icon: Icons.chat_bubble_rounded,
        color: Color(0xFFBF5AF2),
        action: 'discord',
      ),
      const TactileActionItem(
        label: 'Snip',
        icon: Icons.content_cut_rounded,
        color: Color(0xFF2DD4BF),
        action: 'screenshot',
      ),
      const TactileActionItem(
        label: 'Task Manager',
        icon: Icons.poll_rounded,
        color: Color(0xFF34D399),
        action: 'task_manager',
      ),
      TactileActionItem(
        label: isMuted ? 'Muted' : 'Mute',
        icon: isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
        color: const Color(0xFFFF453A),
        action: 'mute',
        hasDot: true,
        isDotActive: isMuted,
      ),
      const TactileActionItem(
        label: 'Screen Off',
        icon: Icons.nightlight_round,
        color: Color(0xFFFACC15),
        action: 'screen_off',
      ),
      const TactileActionItem(
        label: 'Lock',
        icon: Icons.lock_rounded,
        color: Color(0xFFFF453A),
        action: 'lock_pc',
      ),
      const TactileActionItem(
        label: 'Settings',
        icon: Icons.settings_rounded,
        color: Color(0xFFE2E8F0),
        action: 'settings',
      ),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 3.1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final item = actions[index];
        return _TactileDeckButton(
          item: item,
          onTap: () => onActionTriggered?.call(item.action),
        );
      },
    );
  }
}

class _TactileDeckButton extends StatefulWidget {
  final TactileActionItem item;
  final VoidCallback onTap;

  const _TactileDeckButton({
    required this.item,
    required this.onTap,
  });

  @override
  State<_TactileDeckButton> createState() => _TactileDeckButtonState();
}

class _TactileDeckButtonState extends State<_TactileDeckButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _isPressed
                ? item.color.withValues(alpha: 0.22)
                : const Color(0xFF1A1A20).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isPressed
                  ? item.color.withValues(alpha: 0.5)
                  : const Color(0xFF222638),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 13,
                color: item.color,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.hasDot) ...[
                const SizedBox(width: 4),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.isDotActive
                        ? const Color(0xFFFF453A)
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/ai_session.dart';

class AiSessionsCard extends StatefulWidget {
  final List<AiSessionItem> sessions;
  final Function(AiSessionItem session, bool allow)? onPermissionResponse;

  const AiSessionsCard({
    super.key,
    required this.sessions,
    this.onPermissionResponse,
  });

  @override
  State<AiSessionsCard> createState() => _AiSessionsCardState();
}

class _AiSessionsCardState extends State<AiSessionsCard> {
  late List<AiSessionItem> _currentSessions;

  @override
  void initState() {
    super.initState();
    _currentSessions = List.from(widget.sessions);
  }

  @override
  void didUpdateWidget(covariant AiSessionsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sessions != oldWidget.sessions) {
      _currentSessions = List.from(widget.sessions);
    }
  }

  void _showPermissionDialog(BuildContext context, AiSessionItem session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141622),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF282C40)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.security_rounded,
                color: Color(0xFFFF5252),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Permission Request: ${session.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session is requesting permission to execute terminal command:',
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0C0E14),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Text(
                session.pendingAction.isNotEmpty
                    ? session.pendingAction
                    : 'Bash: npm run test',
                style: const TextStyle(
                  fontFamily: 'Consolas',
                  fontSize: 12,
                  color: Color(0xFF00E5FF),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleResponse(session, false);
            },
            child: const Text(
              'Deny',
              style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _handleResponse(session, true);
            },
            child: const Text(
              'Allow',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _handleResponse(AiSessionItem session, bool allow) {
    widget.onPermissionResponse?.call(session, allow);
    setState(() {
      final index = _currentSessions.indexWhere((s) => s.id == session.id);
      if (index != -1) {
        _currentSessions[index] = AiSessionItem(
          id: session.id,
          name: session.name,
          provider: session.provider,
          status: allow ? AiSessionStatus.working : AiSessionStatus.idle,
          statusText: allow ? 'Working' : 'Denied / Idle',
          duration: 'just now',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final waitingCount =
        _currentSessions.where((s) => s.status == AiSessionStatus.waiting).length;
    final workingCount =
        _currentSessions.where((s) => s.status == AiSessionStatus.working).length;
    final idleCount =
        _currentSessions.where((s) => s.status == AiSessionStatus.idle).length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF11131B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF1E212E),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'SESSIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  color: Color(0xFFFF7A45),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$workingCount working · $waitingCount waiting · $idleCount idle',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2-Column Sessions Grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // If wide enough (in landscape panel), show 2 columns; else 1 column
                final isTwoColumn = constraints.maxWidth > 300;
                final crossAxisCount = isTwoColumn ? 2 : 1;

                return GridView.builder(
                  itemCount: _currentSessions.length,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: isTwoColumn ? 3.3 : 4.5,
                  ),
                  itemBuilder: (context, index) {
                    final item = _currentSessions[index];
                    return _SessionTile(
                      session: item,
                      onTap: () {
                        if (item.status == AiSessionStatus.waiting) {
                          _showPermissionDialog(context, item);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final AiSessionItem session;
  final VoidCallback onTap;

  const _SessionTile({
    required this.session,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    bool isGlowing = false;

    switch (session.status) {
      case AiSessionStatus.waiting:
        dotColor = const Color(0xFFFF4D4D);
        isGlowing = true;
        break;
      case AiSessionStatus.working:
        dotColor = const Color(0xFFFF9E0B);
        break;
      case AiSessionStatus.command:
        dotColor = const Color(0xFF38BDF8);
        break;
      case AiSessionStatus.idle:
        dotColor = Colors.white.withValues(alpha: 0.25);
        break;
    }

    final isWaiting = session.status == AiSessionStatus.waiting;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isWaiting
              ? const Color(0xFF261518)
              : const Color(0xFF161824).withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isWaiting
                ? const Color(0xFFFF4D4D).withValues(alpha: 0.45)
                : const Color(0xFF1E2130),
            width: isWaiting ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Status Dot
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: isGlowing
                    ? [
                        BoxShadow(
                          color: dotColor.withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 7),

            // Provider Icon (Claude sparkle or Codex target)
            Icon(
              session.provider == 'claude'
                  ? Icons.auto_awesome_rounded
                  : Icons.track_changes_rounded,
              size: 11,
              color: const Color(0xFFFF8A50).withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),

            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    session.name,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isWaiting ? const Color(0xFFFFD2D2) : Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    session.statusText,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: isWaiting
                          ? const Color(0xFFFF7A7A)
                          : Colors.white.withValues(alpha: 0.45),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Duration badge
            Text(
              session.duration,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isWaiting
                    ? const Color(0xFFFF5252)
                    : session.status == AiSessionStatus.working
                        ? const Color(0xFFFF9E0B)
                        : Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/ai_session.dart';

class AiSessionsCard extends StatelessWidget {
  final List<AiSessionItem> sessions;

  const AiSessionsCard({
    super.key,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final workingCount = sessions.where((s) => s.status == AiSessionStatus.working).length;
    final idleCount = sessions.where((s) => s.status == AiSessionStatus.idle).length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF26262E),
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
                'CLAUDE CODE SESSIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  color: Color(0xFFFF9F0A),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                sessions.isEmpty
                    ? 'none active on this PC'
                    : '$workingCount working · $idleCount idle',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2-Column Sessions Grid, or an honest empty state.
          Expanded(
            child: sessions.isEmpty
                ? Center(
                    child: Text(
                      'No recent Claude Code activity\nfound on this PC in the last 6h.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final isTwoColumn = constraints.maxWidth > 300;
                      final crossAxisCount = isTwoColumn ? 2 : 1;

                      return GridView.builder(
                        itemCount: sessions.length,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: isTwoColumn ? 3.3 : 4.5,
                        ),
                        itemBuilder: (context, index) {
                          return _SessionTile(session: sessions[index]);
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

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final isWorking = session.status == AiSessionStatus.working;
    final dotColor = isWorking ? const Color(0xFFFF9F0A) : Colors.white.withValues(alpha: 0.25);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A20).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF26262E)),
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
              boxShadow: isWorking
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
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  session.statusText,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.45),
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
              color: isWorking ? const Color(0xFFFF9F0A) : Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

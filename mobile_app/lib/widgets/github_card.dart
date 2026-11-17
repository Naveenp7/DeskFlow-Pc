import 'package:flutter/material.dart';
import '../models/github_data.dart';

class GitHubCard extends StatelessWidget {
  final GitHubWorkspaceData data;
  final Function(String url)? onOpenUrl;

  const GitHubCard({
    super.key,
    required this.data,
    this.onOpenUrl,
  });

  @override
  Widget build(BuildContext context) {
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
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'GITHUB',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data.username,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),

              // Notification Bell Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E2416),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF5E431E)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.notifications_rounded,
                      size: 11,
                      color: Color(0xFFFBBF24),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${data.notificationCount}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFBBF24),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Content Area (Scrollable if needed)
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: REVIEW REQUESTS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'REVIEW REQUESTS',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      Text(
                        '${data.reviewRequests.length}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  ...data.reviewRequests.map((rev) => _ReviewRow(
                        review: rev,
                        onTap: () => onOpenUrl?.call('https://github.com/pulls'),
                      )),

                  const SizedBox(height: 12),

                  // --- SECTION 2: MY PULL REQUESTS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MY PULL REQUESTS',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      Text(
                        '${data.pullRequests.length}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  ...data.pullRequests.map((pr) => _PullRequestRow(
                        pr: pr,
                        onTap: () => onOpenUrl?.call('https://github.com/pulls'),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final GitHubReviewRequest review;
  final VoidCallback onTap;

  const _ReviewRow({
    required this.review,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Diamond Icon
            Text(
              '◇',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(width: 8),

            // Repo#number
            Text(
              '${review.repo}#${review.number}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(width: 8),

            // Title
            Expanded(
              child: Text(
                review.title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PullRequestRow extends StatelessWidget {
  final GitHubPullRequest pr;
  final VoidCallback onTap;

  const _PullRequestRow({
    required this.pr,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget icon;
    switch (pr.status) {
      case PrStatus.approved:
        icon = const Icon(Icons.check_rounded, size: 12, color: Color(0xFF10B981));
        break;
      case PrStatus.inReview:
        icon = Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFFF59E0B),
            shape: BoxShape.circle,
          ),
        );
        break;
      case PrStatus.changes:
        icon = const Icon(Icons.close_rounded, size: 12, color: Color(0xFFEF4444));
        break;
      case PrStatus.draft:
        icon = Text(
          '—',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        );
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 14, child: Center(child: icon)),
            const SizedBox(width: 6),

            // Repo#number
            Text(
              '${pr.repo}#${pr.number}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(width: 8),

            // Title
            Expanded(
              child: Text(
                pr.title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  fontStyle:
                      pr.status == PrStatus.draft ? FontStyle.italic : FontStyle.normal,
                  color: pr.status == PrStatus.draft
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Status Pill (e.g. approved / changes)
            if (pr.statusLabel.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: pr.status == PrStatus.approved
                      ? const Color(0xFF132B22)
                      : const Color(0xFF331D1F),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: pr.status == PrStatus.approved
                        ? const Color(0xFF1E523C)
                        : const Color(0xFF662D32),
                  ),
                ),
                child: Text(
                  pr.statusLabel,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: pr.status == PrStatus.approved
                        ? const Color(0xFF34D399)
                        : const Color(0xFFF87171),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class GitHubReviewRequest {
  final String repo;
  final int number;
  final String title;

  const GitHubReviewRequest({
    required this.repo,
    required this.number,
    required this.title,
  });
}

enum PrStatus {
  approved,
  inReview,
  changes,
  draft,
}

class GitHubPullRequest {
  final String repo;
  final int number;
  final String title;
  final PrStatus status;
  final String statusLabel;

  const GitHubPullRequest({
    required this.repo,
    required this.number,
    required this.title,
    required this.status,
    required this.statusLabel,
  });
}

class GitHubWorkspaceData {
  final String username;
  final int notificationCount;
  final List<GitHubReviewRequest> reviewRequests;
  final List<GitHubPullRequest> pullRequests;

  const GitHubWorkspaceData({
    required this.username,
    required this.notificationCount,
    required this.reviewRequests,
    required this.pullRequests,
  });

  static GitHubWorkspaceData mock() {
    return const GitHubWorkspaceData(
      username: '@octocat',
      notificationCount: 7,
      reviewRequests: [
        GitHubReviewRequest(
          repo: 'api',
          number: 412,
          title: 'Rate limiter for public endpoints',
        ),
        GitHubReviewRequest(
          repo: 'web',
          number: 1288,
          title: 'Dark mode for the dashboard',
        ),
        GitHubReviewRequest(
          repo: 'infra',
          number: 77,
          title: 'Move staging to a new region',
        ),
      ],
      pullRequests: [
        GitHubPullRequest(
          repo: 'api',
          number: 409,
          title: 'Cache user sessions in Redis',
          status: PrStatus.approved,
          statusLabel: 'approved',
        ),
        GitHubPullRequest(
          repo: 'web',
          number: 1281,
          title: 'Faster image uploads',
          status: PrStatus.inReview,
          statusLabel: 'in review',
        ),
        GitHubPullRequest(
          repo: 'cli',
          number: 53,
          title: 'New "deploy" command',
          status: PrStatus.changes,
          statusLabel: 'changes',
        ),
        GitHubPullRequest(
          repo: 'docs',
          number: 210,
          title: 'Getting started rewrite',
          status: PrStatus.draft,
          statusLabel: '',
        ),
      ],
    );
  }
}

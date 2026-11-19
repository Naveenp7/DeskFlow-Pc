class GitHubReviewRequest {
  final String repo;
  final int number;
  final String title;
  final String url;

  const GitHubReviewRequest({
    required this.repo,
    required this.number,
    required this.title,
    this.url = '',
  });

  factory GitHubReviewRequest.fromJson(Map<String, dynamic> json) {
    return GitHubReviewRequest(
      repo: json['repo'] as String? ?? '?',
      number: (json['number'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
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
  final String url;

  const GitHubPullRequest({
    required this.repo,
    required this.number,
    required this.title,
    required this.status,
    required this.statusLabel,
    this.url = '',
  });

  factory GitHubPullRequest.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'inReview';
    final status = PrStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => PrStatus.inReview,
    );
    return GitHubPullRequest(
      repo: json['repo'] as String? ?? '?',
      number: (json['number'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      status: status,
      statusLabel: json['status_label'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}

class GitHubWorkspaceData {
  final bool configured;
  final String username;
  final int notificationCount;
  final List<GitHubReviewRequest> reviewRequests;
  final List<GitHubPullRequest> pullRequests;

  const GitHubWorkspaceData({
    required this.configured,
    required this.username,
    required this.notificationCount,
    required this.reviewRequests,
    required this.pullRequests,
  });

  factory GitHubWorkspaceData.initial() {
    return const GitHubWorkspaceData(
      configured: false,
      username: '',
      notificationCount: 0,
      reviewRequests: [],
      pullRequests: [],
    );
  }

  factory GitHubWorkspaceData.fromJson(Map<String, dynamic> json) {
    final reviews = (json['review_requests'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((r) => GitHubReviewRequest.fromJson(r))
        .toList();
    final prs = (json['pull_requests'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((p) => GitHubPullRequest.fromJson(p))
        .toList();
    return GitHubWorkspaceData(
      configured: json['configured'] as bool? ?? false,
      username: json['username'] as String? ?? '',
      notificationCount: (json['notification_count'] as num?)?.toInt() ?? 0,
      reviewRequests: reviews,
      pullRequests: prs,
    );
  }
}

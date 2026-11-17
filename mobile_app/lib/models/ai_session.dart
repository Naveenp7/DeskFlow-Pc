enum AiSessionStatus {
  waiting,
  working,
  command,
  idle,
}

class AiSessionItem {
  final String id;
  final String name;
  final String provider; // 'claude' or 'codex'
  final AiSessionStatus status;
  final String statusText;
  final String duration;
  final String pendingAction;

  const AiSessionItem({
    required this.id,
    required this.name,
    required this.provider,
    required this.status,
    required this.statusText,
    required this.duration,
    this.pendingAction = '',
  });

  static List<AiSessionItem> defaultList() {
    return const [
      AiSessionItem(
        id: 'docs-site',
        name: 'docs-site',
        provider: 'claude',
        status: AiSessionStatus.waiting,
        statusText: 'Waiting',
        duration: '2m',
        pendingAction: 'Bash run: npm test -- --coverage',
      ),
      AiSessionItem(
        id: 'mobile-app',
        name: 'mobile-app',
        provider: 'codex',
        status: AiSessionStatus.working,
        statusText: 'Demo coding model · h...',
        duration: '11m',
      ),
      AiSessionItem(
        id: 'api-gateway',
        name: 'api-gateway',
        provider: 'claude',
        status: AiSessionStatus.working,
        statusText: 'Working',
        duration: '4m',
      ),
      AiSessionItem(
        id: 'infra',
        name: 'infra',
        provider: 'claude',
        status: AiSessionStatus.command,
        statusText: 'Running a command',
        duration: '1m',
      ),
      AiSessionItem(
        id: 'blog-engine',
        name: 'blog-engine',
        provider: 'claude',
        status: AiSessionStatus.idle,
        statusText: 'Idle',
        duration: '38m',
      ),
      AiSessionItem(
        id: 'data-pipeline',
        name: 'data-pipeline',
        provider: 'codex',
        status: AiSessionStatus.working,
        statusText: 'Demo coding mode...',
        duration: '1h 14m',
      ),
      AiSessionItem(
        id: 'design-system',
        name: 'design-system',
        provider: 'claude',
        status: AiSessionStatus.idle,
        statusText: 'Idle',
        duration: '2h 5m',
      ),
    ];
  }
}

enum AiSessionStatus {
  working,
  idle,
}

class AiSessionItem {
  final String id;
  final String name;
  final String provider; // 'claude' or 'codex'
  final AiSessionStatus status;
  final String statusText;
  final String duration;

  const AiSessionItem({
    required this.id,
    required this.name,
    required this.provider,
    required this.status,
    required this.statusText,
    required this.duration,
  });

  factory AiSessionItem.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'idle';
    return AiSessionItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'session',
      provider: json['provider'] as String? ?? 'claude',
      status: statusStr == 'working' ? AiSessionStatus.working : AiSessionStatus.idle,
      statusText: json['status_text'] as String? ?? 'Idle',
      duration: json['duration'] as String? ?? '',
    );
  }
}

class ClaudeQuota {
  final double sessionPct;
  final String sessionReset;
  final String sessionStatus;
  final double weeklyPct;
  final String weeklyReset;
  final String weeklyStatus;
  final double weeklyFablePct;
  final String weeklyFableReset;
  final String weeklyFableStatus;
  final double codexSessionPct;
  final String codexReset;
  final String lastUpdated;
  final String tier;
  final String tokensUsed;
  final String tokensTotal;
  final String burnRate;

  const ClaudeQuota({
    required this.sessionPct,
    required this.sessionReset,
    required this.sessionStatus,
    required this.weeklyPct,
    required this.weeklyReset,
    required this.weeklyStatus,
    required this.weeklyFablePct,
    required this.weeklyFableReset,
    required this.weeklyFableStatus,
    required this.codexSessionPct,
    required this.codexReset,
    required this.lastUpdated,
    required this.tier,
    required this.tokensUsed,
    required this.tokensTotal,
    required this.burnRate,
  });

  factory ClaudeQuota.mock() {
    return const ClaudeQuota(
      sessionPct: 34.0,
      sessionReset: '21:57 · in 2 h 36 min',
      sessionStatus: 'Plenty left',
      weeklyPct: 52.0,
      weeklyReset: 'Sat 00:09 · in 3 d 4 h',
      weeklyStatus: 'On pace',
      weeklyFablePct: 9.0,
      weeklyFableReset: 'Sat 00:09 · in 3 d 4 h',
      weeklyFableStatus: 'Plenty left',
      codexSessionPct: 12.0,
      codexReset: 'resets in 4 h 6 min',
      lastUpdated: '2 min ago',
      tier: 'Max 5x',
      tokensUsed: '412K',
      tokensTotal: '1.2M',
      burnRate: '82K / hr',
    );
  }

  factory ClaudeQuota.fromJson(Map<String, dynamic> json) {
    return ClaudeQuota(
      sessionPct: (json['session_pct'] as num?)?.toDouble() ?? 34.0,
      sessionReset: json['session_reset'] as String? ?? '21:57 · in 2 h 36 min',
      sessionStatus: json['session_status'] as String? ?? 'Plenty left',
      weeklyPct: (json['weekly_pct'] as num?)?.toDouble() ?? 52.0,
      weeklyReset: json['weekly_reset'] as String? ?? 'Sat 00:09 · in 3 d 4 h',
      weeklyStatus: json['weekly_status'] as String? ?? 'On pace',
      weeklyFablePct: (json['weekly_fable_pct'] as num?)?.toDouble() ?? 9.0,
      weeklyFableReset: json['weekly_fable_reset'] as String? ?? 'Sat 00:09 · in 3 d 4 h',
      weeklyFableStatus: json['weekly_fable_status'] as String? ?? 'Plenty left',
      codexSessionPct: (json['codex_session_pct'] as num?)?.toDouble() ?? 12.0,
      codexReset: json['codex_reset'] as String? ?? 'resets in 4 h 6 min',
      lastUpdated: json['last_updated'] as String? ?? 'just now',
      tier: json['tier'] as String? ?? 'Max 5x',
      tokensUsed: json['tokens_used'] as String? ?? '412K',
      tokensTotal: json['tokens_total'] as String? ?? '1.2M',
      burnRate: json['burn_rate'] as String? ?? '82K / hr',
    );
  }
}

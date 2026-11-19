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

  /// Neutral placeholder before the PC companion has sent any real usage data.
  factory ClaudeQuota.initial() {
    return const ClaudeQuota(
      sessionPct: 0.0,
      sessionReset: 'Not connected',
      sessionStatus: '--',
      weeklyPct: 0.0,
      weeklyReset: 'Not connected',
      weeklyStatus: '--',
      weeklyFablePct: 0.0,
      weeklyFableReset: 'Not tracked',
      weeklyFableStatus: '--',
      codexSessionPct: 0.0,
      codexReset: 'Not tracked',
      lastUpdated: 'never',
      tier: 'Local estimate',
      tokensUsed: '0',
      tokensTotal: '0',
      burnRate: '0 / hr',
    );
  }

  factory ClaudeQuota.fromJson(Map<String, dynamic> json) {
    final fallback = ClaudeQuota.initial();
    return ClaudeQuota(
      sessionPct: (json['session_pct'] as num?)?.toDouble() ?? fallback.sessionPct,
      sessionReset: json['session_reset'] as String? ?? fallback.sessionReset,
      sessionStatus: json['session_status'] as String? ?? fallback.sessionStatus,
      weeklyPct: (json['weekly_pct'] as num?)?.toDouble() ?? fallback.weeklyPct,
      weeklyReset: json['weekly_reset'] as String? ?? fallback.weeklyReset,
      weeklyStatus: json['weekly_status'] as String? ?? fallback.weeklyStatus,
      weeklyFablePct: (json['weekly_fable_pct'] as num?)?.toDouble() ?? fallback.weeklyFablePct,
      weeklyFableReset: json['weekly_fable_reset'] as String? ?? fallback.weeklyFableReset,
      weeklyFableStatus: json['weekly_fable_status'] as String? ?? fallback.weeklyFableStatus,
      codexSessionPct: (json['codex_session_pct'] as num?)?.toDouble() ?? fallback.codexSessionPct,
      codexReset: json['codex_reset'] as String? ?? fallback.codexReset,
      lastUpdated: json['last_updated'] as String? ?? fallback.lastUpdated,
      tier: json['tier'] as String? ?? fallback.tier,
      tokensUsed: json['tokens_used'] as String? ?? fallback.tokensUsed,
      tokensTotal: json['tokens_total'] as String? ?? fallback.tokensTotal,
      burnRate: json['burn_rate'] as String? ?? fallback.burnRate,
    );
  }
}

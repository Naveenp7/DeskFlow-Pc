import 'package:flutter/material.dart';
import '../models/claude_quota.dart';
import 'radial_glow_gauge.dart';

class ClaudeQuotaView extends StatelessWidget {
  final ClaudeQuota quota;
  final VoidCallback? onRefresh;

  const ClaudeQuotaView({
    super.key,
    required this.quota,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    const claudeOrange = Color(0xFFFF9F0A);
    const claudeOrangeEnd = Color(0xFFFF9466);
    const badgeBg = Color(0xFF332018);
    const badgeText = Color(0xFFFF9055);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF26262E),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Claude Sparkle Icon
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: claudeOrange,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Claude',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Max 5x Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      quota.tier,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: badgeText,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onRefresh,
                child: Row(
                  children: [
                    Text(
                      quota.lastUpdated,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.refresh_rounded,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // 3 Glowing Radial Gauges in a Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1: 5-hour session
              Expanded(
                child: RadialGlowGauge(
                  percentage: quota.sessionPct,
                  centerText: '${quota.sessionPct.toInt()}%',
                  label: '5-hour session',
                  subText: quota.sessionReset,
                  statusText: quota.sessionStatus,
                  statusColor: const Color(0xFF30D158),
                  primaryColor: claudeOrange,
                  secondaryColor: claudeOrangeEnd,
                  size: 116,
                  strokeWidth: 10.5,
                ),
              ),

              // 2: Weekly
              Expanded(
                child: RadialGlowGauge(
                  percentage: quota.weeklyPct,
                  centerText: '${quota.weeklyPct.toInt()}%',
                  label: 'Weekly',
                  subText: quota.weeklyReset,
                  statusText: quota.weeklyStatus,
                  statusColor: Colors.white.withValues(alpha: 0.7),
                  primaryColor: claudeOrange,
                  secondaryColor: claudeOrangeEnd,
                  size: 116,
                  strokeWidth: 10.5,
                ),
              ),

              // 3: Weekly · Fable
              Expanded(
                child: RadialGlowGauge(
                  percentage: quota.weeklyFablePct,
                  centerText: '${quota.weeklyFablePct.toInt()}%',
                  label: 'Weekly · Fable',
                  subText: quota.weeklyFableReset,
                  statusText: quota.weeklyFableStatus,
                  statusColor: const Color(0xFF30D158),
                  primaryColor: claudeOrange,
                  secondaryColor: claudeOrangeEnd,
                  size: 116,
                  strokeWidth: 10.5,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Bottom Burn-Rate & Token Info Pill Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatDetail(
                  label: 'Burn Rate',
                  value: quota.burnRate,
                  color: claudeOrange,
                ),
                _StatDetail(
                  label: 'Tokens Used',
                  value: '${quota.tokensUsed} / ${quota.tokensTotal}',
                  color: Colors.white,
                ),
                _StatDetail(
                  label: 'Codex Session',
                  value: '${quota.codexSessionPct.toInt()}% left',
                  color: const Color(0xFF0A84FF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDetail extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatDetail({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

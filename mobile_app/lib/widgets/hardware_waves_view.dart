import 'package:flutter/material.dart';
import 'wave_sparkline.dart';

class HardwareWavesView extends StatelessWidget {
  final double cpuPct;
  final String cpuTemp;
  final double gpuPct;
  final String gpuTemp;
  final double ramUsedGb;
  final double ramTotalGb;
  final double vramUsedGb;
  final double vramTotalGb;
  final double downMBs;
  final double upKBs;
  final int pingMs;
  final String uptime;

  const HardwareWavesView({
    super.key,
    this.cpuPct = 10.0,
    this.cpuTemp = '53°C',
    this.gpuPct = 7.0,
    this.gpuTemp = '53°C · 38 W',
    this.ramUsedGb = 21.2,
    this.ramTotalGb = 64.0,
    this.vramUsedGb = 5.8,
    this.vramTotalGb = 16.0,
    this.downMBs = 8.7,
    this.upKBs = 332.0,
    this.pingMs = 9,
    this.uptime = 'Up 3 d 5 h',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Column (Processor on top, Memory on bottom)
            Expanded(
              flex: 50,
              child: Column(
                children: [
                  // PROCESSOR Card
                  Expanded(
                    flex: 48,
                    child: WaveSparklineCard(
                      title: 'Processor',
                      valueText: '${cpuPct.toStringAsFixed(0)}%',
                      subText: cpuTemp,
                      networkSub: 'AMD Ryzen 9 7950X 16-Core',
                      primaryColor: const Color(0xFF00E5FF),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // MEMORY Card with Multiple Bars
                  Expanded(
                    flex: 52,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12141E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1E2232)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'MEMORY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: Color(0xFFA855F7),
                                ),
                              ),
                              Text(
                                uptime,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.45),
                                ),
                              ),
                            ],
                          ),

                          // RAM Progress bar
                          _HardwareBarRow(
                            label: 'RAM',
                            valueStr:
                                '${ramUsedGb.toStringAsFixed(1)} / ${ramTotalGb.toStringAsFixed(0)} GB',
                            ratio: (ramUsedGb / ramTotalGb).clamp(0.0, 1.0),
                            color: const Color(0xFFA855F7),
                          ),

                          // VRAM RTX 4080
                          _HardwareBarRow(
                            label: 'VRAM · GeForce RTX 4080',
                            valueStr:
                                '${vramUsedGb.toStringAsFixed(1)} / ${vramTotalGb.toStringAsFixed(0)} GB',
                            ratio: (vramUsedGb / vramTotalGb).clamp(0.0, 1.0),
                            color: const Color(0xFF84CC16),
                          ),

                          // Disks Row
                          Row(
                            children: [
                              _MiniDiskBar(label: 'C:', pct: 61),
                              const SizedBox(width: 12),
                              _MiniDiskBar(label: 'D:', pct: 73),
                              const SizedBox(width: 12),
                              _MiniDiskBar(label: 'E:', pct: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right Column (Graphics on top, Network on bottom)
            Expanded(
              flex: 50,
              child: Column(
                children: [
                  // GRAPHICS Card
                  Expanded(
                    flex: 48,
                    child: WaveSparklineCard(
                      title: 'Graphics',
                      valueText: '${gpuPct.toStringAsFixed(0)}%',
                      subText: gpuTemp,
                      networkSub: 'NVIDIA GeForce RTX 4080',
                      primaryColor: const Color(0xFF84CC16),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // NETWORK Card with Dual Area Waves
                  Expanded(
                    flex: 52,
                    child: WaveSparklineCard(
                      title: 'Network',
                      valueText: '↓ ${downMBs.toStringAsFixed(1)} MB/s',
                      subText: '↑ ${upKBs.toStringAsFixed(0)} KB/s',
                      networkSub: 'Ping $pingMs ms · loss 0%',
                      primaryColor: const Color(0xFFF59E0B),
                      secondaryColor: const Color(0xFF00E5FF),
                      isNetworkDual: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HardwareBarRow extends StatelessWidget {
  final String label;
  final String valueStr;
  final double ratio;
  final Color color;

  const _HardwareBarRow({
    required this.label,
    required this.valueStr,
    required this.ratio,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            Text(
              valueStr,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Container(
          height: 4.5,
          decoration: BoxDecoration(
            color: const Color(0xFF1E2232),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ratio,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniDiskBar extends StatelessWidget {
  final String label;
  final int pct;

  const _MiniDiskBar({
    required this.label,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (pct / 100.0).clamp(0.0, 1.0);
    return Expanded(
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2232),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: ratio,
                child: Container(
                  decoration: BoxDecoration(
                    color: pct > 85
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF38BDF8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$pct%',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

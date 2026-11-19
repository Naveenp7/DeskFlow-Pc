import 'package:flutter/material.dart';
import '../models/system_stats.dart';
import 'wave_sparkline.dart';

class HardwareWavesView extends StatelessWidget {
  final double cpuPct;
  final GpuInfo? gpu;
  final double ramUsedGb;
  final double ramTotalGb;
  final List<DiskInfo> disks;
  final double downMBs;
  final double upKBs;
  final int pingMs;
  final String uptime;
  final int cpuCores;

  const HardwareWavesView({
    super.key,
    this.cpuPct = 0.0,
    this.gpu,
    this.ramUsedGb = 0.0,
    this.ramTotalGb = 0.0,
    this.disks = const [],
    this.downMBs = 0.0,
    this.upKBs = 0.0,
    this.pingMs = 0,
    this.uptime = '--',
    this.cpuCores = 0,
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
                      subText: cpuCores > 0 ? '$cpuCores logical cores' : '',
                      networkSub: 'Live from PC companion',
                      primaryColor: const Color(0xFF0A84FF),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // MEMORY Card with Multiple Bars
                  Expanded(
                    flex: 52,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF15151B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF26262E)),
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
                                  color: Color(0xFFBF5AF2),
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
                            valueStr: ramTotalGb > 0
                                ? '${ramUsedGb.toStringAsFixed(1)} / ${ramTotalGb.toStringAsFixed(0)} GB'
                                : '--',
                            ratio: ramTotalGb > 0 ? (ramUsedGb / ramTotalGb).clamp(0.0, 1.0) : 0.0,
                            color: const Color(0xFFBF5AF2),
                          ),

                          // VRAM (real NVIDIA GPU, if detected)
                          _HardwareBarRow(
                            label: gpu != null ? 'VRAM · ${gpu!.name}' : 'VRAM',
                            valueStr: gpu != null
                                ? '${gpu!.vramUsedGb.toStringAsFixed(1)} / ${gpu!.vramTotalGb.toStringAsFixed(0)} GB'
                                : 'No NVIDIA GPU detected',
                            ratio: gpu != null && gpu!.vramTotalGb > 0
                                ? (gpu!.vramUsedGb / gpu!.vramTotalGb).clamp(0.0, 1.0)
                                : 0.0,
                            color: const Color(0xFF84CC16),
                          ),

                          // Disks Row (real detected fixed drives)
                          if (disks.isEmpty)
                            Text(
                              'No drives reported',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.35),
                              ),
                            )
                          else
                            Row(
                              children: [
                                for (int i = 0; i < disks.length && i < 3; i++) ...[
                                  if (i > 0) const SizedBox(width: 12),
                                  _MiniDiskBar(label: disks[i].label, pct: disks[i].percent.round()),
                                ],
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
                      valueText: gpu != null ? '${gpu!.percent.toStringAsFixed(0)}%' : '--',
                      subText: gpu != null
                          ? '${gpu!.tempC.toStringAsFixed(0)}°C · ${gpu!.powerW.toStringAsFixed(0)} W'
                          : 'No dGPU detected',
                      networkSub: gpu?.name ?? 'Integrated / unknown GPU',
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
                      networkSub: pingMs > 0 ? 'Ping $pingMs ms' : 'Ping --',
                      primaryColor: const Color(0xFFFFD60A),
                      secondaryColor: const Color(0xFF0A84FF),
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
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
            color: const Color(0xFF26262E),
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
                color: const Color(0xFF26262E),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: ratio,
                child: Container(
                  decoration: BoxDecoration(
                    color: pct > 85
                        ? const Color(0xFFFF453A)
                        : const Color(0xFF64D2FF),
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

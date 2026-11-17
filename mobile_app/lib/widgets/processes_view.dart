import 'package:flutter/material.dart';
import '../models/system_process.dart';

class ProcessesView extends StatefulWidget {
  final List<SystemProcessItem> processes;
  final Function(SystemProcessItem item, String action)? onProcessAction;

  const ProcessesView({
    super.key,
    required this.processes,
    this.onProcessAction,
  });

  @override
  State<ProcessesView> createState() => _ProcessesViewState();
}

class _ProcessesViewState extends State<ProcessesView> {
  bool _sortByCpu = true;

  void _showProcessDetails(SystemProcessItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141624),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF23273A)),
        ),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: item.avatarColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                item.avatarLetter,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: item.avatarColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Instances: ${item.count}',
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 4),
            Text('CPU Utilization: ${item.cpuPct.toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 4),
            Text('Memory Allocated: ${item.ramDisplay}',
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            if (item.isProtected) ...[
              const SizedBox(height: 8),
              const Text(
                '🔒 System-critical process protected from termination.',
                style: TextStyle(color: Color(0xFFFBBF24), fontSize: 11.5),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          if (!item.isProtected)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                widget.onProcessAction?.call(item, 'kill');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Terminating ${item.name} (${item.count} tasks)...'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFF1E2130),
                  ),
                );
              },
              child: const Text('Kill Process'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = List<SystemProcessItem>.from(widget.processes);
    if (_sortByCpu) {
      list.sort((a, b) => b.cpuPct.compareTo(a.cpuPct));
    } else {
      list.sort((a, b) => b.ramMb.compareTo(a.ramMb));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF10121A),
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
                    'PROCESSES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                      color: Color(0xFFF472B6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total CPU 40% · 312 processes · 141 apps · tap one for details',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),

              // CPU / RAM Toggle Pills
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1E2B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _FilterPill(
                      label: 'CPU',
                      isSelected: _sortByCpu,
                      onTap: () => setState(() => _sortByCpu = true),
                    ),
                    _FilterPill(
                      label: 'RAM',
                      isSelected: !_sortByCpu,
                      onTap: () => setState(() => _sortByCpu = false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2-Column Process Grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTwoCol = constraints.maxWidth > 350;
                final cols = isTwoCol ? 2 : 1;

                return GridView.builder(
                  itemCount: list.length,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 6,
                    childAspectRatio: isTwoCol ? 5.6 : 6.0,
                  ),
                  itemBuilder: (context, index) {
                    final p = list[index];
                    return _ProcessTile(
                      process: p,
                      onTap: () => _showProcessDetails(p),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF33384C) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

class _ProcessTile extends StatelessWidget {
  final SystemProcessItem process;
  final VoidCallback onTap;

  const _ProcessTile({
    required this.process,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final maxRatio = (process.cpuPct / 10.0).clamp(0.05, 1.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF141722),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1E2232)),
        ),
        child: Row(
          children: [
            // Avatar badge
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: process.avatarColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.center,
              child: Text(
                process.avatarLetter,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: process.avatarColor,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Name + Instance count + Horizontal usage bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          process.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (process.count > 1) ...[
                        const SizedBox(width: 4),
                        Text(
                          '×${process.count}',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                      if (process.isProtected) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.lock_rounded,
                          size: 10,
                          color: Color(0xFFFBBF24),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Progress line
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: maxRatio,
                    child: Container(
                      height: 2.2,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF472B6),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF472B6).withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // CPU % & RAM
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${process.cpuPct.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  process.ramDisplay,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

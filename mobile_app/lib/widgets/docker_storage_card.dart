import 'package:flutter/material.dart';

class DockerStorageCard extends StatelessWidget {
  final int containerCount;
  final int freeDisksCount;

  const DockerStorageCard({
    super.key,
    this.containerCount = 3,
    this.freeDisksCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // DOCKER CONTAINERS
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF12141E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E212E), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DOCKER CONTAINERS',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Color(0xFF38BDF8),
                  ),
                ),
                Text(
                  '$containerCount',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'just now · 412 ms',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // FREE DISK SPACE
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF12141E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E212E), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'FREE DISK SPACE',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Color(0xFF38BDF8),
                  ),
                ),
                Text(
                  '$freeDisksCount',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'just now · 412 ms',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

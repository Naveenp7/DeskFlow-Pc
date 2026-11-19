import 'package:flutter/material.dart';

class DockerStorageCard extends StatelessWidget {
  final bool dockerAvailable;
  final int containerCount;
  final int freeDisksCount;

  const DockerStorageCard({
    super.key,
    this.dockerAvailable = false,
    this.containerCount = 0,
    this.freeDisksCount = 0,
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
              color: const Color(0xFF15151B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF26262E), width: 1),
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
                    color: Color(0xFF64D2FF),
                  ),
                ),
                Text(
                  dockerAvailable ? '$containerCount' : '--',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                Text(
                  dockerAvailable ? 'running now' : 'Docker not found on PC',
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

        // DRIVES DETECTED
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF15151B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF26262E), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DRIVES DETECTED',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Color(0xFF64D2FF),
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
                  'fixed local drives',
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

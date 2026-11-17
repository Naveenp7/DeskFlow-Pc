import 'package:flutter/material.dart';

class SystemProcessItem {
  final String name;
  final int count;
  final double cpuPct;
  final double ramMb;
  final String avatarLetter;
  final Color avatarColor;
  final bool isProtected;

  const SystemProcessItem({
    required this.name,
    required this.count,
    required this.cpuPct,
    required this.ramMb,
    required this.avatarLetter,
    required this.avatarColor,
    this.isProtected = false,
  });

  String get ramDisplay {
    if (ramMb >= 1024) {
      return '${(ramMb / 1024).toStringAsFixed(1)} GB';
    }
    return '${ramMb.toStringAsFixed(0)} MB';
  }

  static List<SystemProcessItem> defaultList() {
    return const [
      SystemProcessItem(
        name: 'Visual Studio Code',
        count: 9,
        cpuPct: 5.8,
        ramMb: 2150,
        avatarLetter: 'V',
        avatarColor: Color(0xFF8B5CF6),
      ),
      SystemProcessItem(
        name: 'Google Chrome',
        count: 14,
        cpuPct: 4.7,
        ramMb: 3379,
        avatarLetter: 'G',
        avatarColor: Color(0xFF10B981),
      ),
      SystemProcessItem(
        name: 'Node.js',
        count: 6,
        cpuPct: 3.2,
        ramMb: 1228,
        avatarLetter: 'N',
        avatarColor: Color(0xFFF97316),
      ),
      SystemProcessItem(
        name: 'Claude',
        count: 7,
        cpuPct: 2.7,
        ramMb: 1843,
        avatarLetter: 'C',
        avatarColor: Color(0xFFF59E0B),
      ),
      SystemProcessItem(
        name: 'Docker Desktop',
        count: 4,
        cpuPct: 2.0,
        ramMb: 2560,
        avatarLetter: 'D',
        avatarColor: Color(0xFF06B6D4),
      ),
      SystemProcessItem(
        name: 'Spotify',
        count: 5,
        cpuPct: 1.5,
        ramMb: 420,
        avatarLetter: 'S',
        avatarColor: Color(0xFF22C55E),
      ),
      SystemProcessItem(
        name: 'Discord',
        count: 6,
        cpuPct: 1.1,
        ramMb: 610,
        avatarLetter: 'D',
        avatarColor: Color(0xFFEC4899),
      ),
      SystemProcessItem(
        name: 'Windows Explorer',
        count: 3,
        cpuPct: 0.8,
        ramMb: 380,
        avatarLetter: 'W',
        avatarColor: Color(0xFF84CC16),
        isProtected: true,
      ),
      SystemProcessItem(
        name: 'OBS Studio',
        count: 1,
        cpuPct: 0.7,
        ramMb: 520,
        avatarLetter: 'O',
        avatarColor: Color(0xFFA855F7),
      ),
      SystemProcessItem(
        name: 'Slack',
        count: 5,
        cpuPct: 0.6,
        ramMb: 700,
        avatarLetter: 'S',
        avatarColor: Color(0xFF6366F1),
      ),
      SystemProcessItem(
        name: 'Steam',
        count: 3,
        cpuPct: 0.4,
        ramMb: 340,
        avatarLetter: 'S',
        avatarColor: Color(0xFF14B8A6),
      ),
      SystemProcessItem(
        name: 'Python',
        count: 2,
        cpuPct: 0.3,
        ramMb: 160,
        avatarLetter: 'P',
        avatarColor: Color(0xFF0EA5E9),
      ),
      SystemProcessItem(
        name: 'Microsoft OneDrive',
        count: 1,
        cpuPct: 0.3,
        ramMb: 120,
        avatarLetter: 'M',
        avatarColor: Color(0xFF10B981),
      ),
      SystemProcessItem(
        name: 'Figma',
        count: 3,
        cpuPct: 0.2,
        ramMb: 640,
        avatarLetter: 'F',
        avatarColor: Color(0xFFEF4444),
      ),
    ];
  }
}

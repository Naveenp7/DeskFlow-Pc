import 'package:flutter/material.dart';

const List<Color> _avatarPalette = [
  Color(0xFFBF5AF2),
  Color(0xFF30D158),
  Color(0xFFFF9F0A),
  Color(0xFFFFD60A),
  Color(0xFF0A84FF),
  Color(0xFF64D2FF),
  Color(0xFFF472B6),
  Color(0xFF84CC16),
];

const Set<String> _protectedNames = {
  'system',
  'system idle process',
  'registry',
  'svchost',
  'csrss',
  'wininit',
  'winlogon',
  'smss',
  'lsass',
  'explorer',
  'dwm',
};

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

  factory SystemProcessItem.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'Unknown';
    final colorIndex = name.toLowerCase().hashCode.abs() % _avatarPalette.length;
    return SystemProcessItem(
      name: name,
      count: (json['count'] as num?)?.toInt() ?? 1,
      cpuPct: (json['cpu_pct'] as num?)?.toDouble() ?? 0.0,
      ramMb: (json['ram_mb'] as num?)?.toDouble() ?? 0.0,
      avatarLetter: name.isNotEmpty ? name[0].toUpperCase() : '?',
      avatarColor: _avatarPalette[colorIndex],
      isProtected: _protectedNames.contains(name.toLowerCase()),
    );
  }
}

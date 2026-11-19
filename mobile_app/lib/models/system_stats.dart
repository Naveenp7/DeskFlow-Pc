class DiskInfo {
  final String label;
  final double percent;
  final double usedGb;
  final double totalGb;

  const DiskInfo({
    required this.label,
    required this.percent,
    required this.usedGb,
    required this.totalGb,
  });

  factory DiskInfo.fromJson(Map<String, dynamic> json) {
    return DiskInfo(
      label: json['label'] as String? ?? '?',
      percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
      usedGb: (json['used_gb'] as num?)?.toDouble() ?? 0.0,
      totalGb: (json['total_gb'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class GpuInfo {
  final String name;
  final double percent;
  final double tempC;
  final double vramUsedGb;
  final double vramTotalGb;
  final double powerW;

  const GpuInfo({
    required this.name,
    required this.percent,
    required this.tempC,
    required this.vramUsedGb,
    required this.vramTotalGb,
    required this.powerW,
  });

  factory GpuInfo.fromJson(Map<String, dynamic> json) {
    return GpuInfo(
      name: json['name'] as String? ?? 'GPU',
      percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
      tempC: (json['temp_c'] as num?)?.toDouble() ?? 0.0,
      vramUsedGb: (json['vram_used_gb'] as num?)?.toDouble() ?? 0.0,
      vramTotalGb: (json['vram_total_gb'] as num?)?.toDouble() ?? 0.0,
      powerW: (json['power_w'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SystemStats {
  final double cpu;
  final int cpuCores;
  final double ramUsedGb;
  final double ramTotalGb;
  final double ramPercent;
  final double diskUsedGb;
  final double diskTotalGb;
  final double diskPercent;
  final bool hasBattery;
  final int batteryPercent;
  final bool isCharging;
  final double uploadKbps;
  final double downloadKbps;
  final int volumeLevel;
  final bool isMuted;
  final bool isMicMuted;
  final String uptime;
  final String hostname;
  final List<DiskInfo> disks;
  final GpuInfo? gpu;
  final DateTime receivedAt;

  SystemStats({
    required this.cpu,
    required this.cpuCores,
    required this.ramUsedGb,
    required this.ramTotalGb,
    required this.ramPercent,
    required this.diskUsedGb,
    required this.diskTotalGb,
    required this.diskPercent,
    required this.hasBattery,
    required this.batteryPercent,
    required this.isCharging,
    required this.uploadKbps,
    required this.downloadKbps,
    required this.volumeLevel,
    required this.isMuted,
    required this.isMicMuted,
    required this.uptime,
    required this.hostname,
    this.disks = const [],
    this.gpu,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  factory SystemStats.initial() {
    return SystemStats(
      cpu: 0.0,
      cpuCores: 4,
      ramUsedGb: 0.0,
      ramTotalGb: 0.0,
      ramPercent: 0.0,
      diskUsedGb: 0.0,
      diskTotalGb: 0.0,
      diskPercent: 0.0,
      hasBattery: false,
      batteryPercent: 0,
      isCharging: false,
      uploadKbps: 0.0,
      downloadKbps: 0.0,
      volumeLevel: 0,
      isMuted: false,
      isMicMuted: false,
      uptime: '--',
      hostname: '',
    );
  }

  factory SystemStats.fromJson(Map<String, dynamic> json) {
    final ram = json['ram'] as Map<String, dynamic>? ?? {};
    final disk = json['disk'] as Map<String, dynamic>? ?? {};
    final battery = json['battery'] as Map<String, dynamic>? ?? {};
    final net = json['network'] as Map<String, dynamic>? ?? {};
    final vol = json['volume'] as Map<String, dynamic>? ?? {};
    final disksJson = json['disks'] as List<dynamic>? ?? const [];
    final gpuJson = json['gpu'] as Map<String, dynamic>?;

    return SystemStats(
      cpu: (json['cpu'] as num?)?.toDouble() ?? 0.0,
      cpuCores: json['cpu_cores'] as int? ?? 4,
      ramUsedGb: (ram['used_gb'] as num?)?.toDouble() ?? 0.0,
      ramTotalGb: (ram['total_gb'] as num?)?.toDouble() ?? 0.0,
      ramPercent: (ram['percent'] as num?)?.toDouble() ?? 0.0,
      diskUsedGb: (disk['used_gb'] as num?)?.toDouble() ?? 0.0,
      diskTotalGb: (disk['total_gb'] as num?)?.toDouble() ?? 0.0,
      diskPercent: (disk['percent'] as num?)?.toDouble() ?? 0.0,
      hasBattery: battery['has_battery'] as bool? ?? false,
      batteryPercent: (battery['percent'] as num?)?.toInt() ?? 100,
      isCharging: battery['is_charging'] as bool? ?? true,
      uploadKbps: (net['up_kbps'] as num?)?.toDouble() ?? 0.0,
      downloadKbps: (net['down_kbps'] as num?)?.toDouble() ?? 0.0,
      volumeLevel: (vol['level'] as num?)?.toInt() ?? 50,
      isMuted: vol['muted'] as bool? ?? false,
      isMicMuted: json['mic_muted'] as bool? ?? false,
      uptime: json['uptime'] as String? ?? '--',
      hostname: json['hostname'] as String? ?? 'PC',
      disks: disksJson
          .whereType<Map<String, dynamic>>()
          .map((d) => DiskInfo.fromJson(d))
          .toList(),
      gpu: gpuJson != null ? GpuInfo.fromJson(gpuJson) : null,
    );
  }
}

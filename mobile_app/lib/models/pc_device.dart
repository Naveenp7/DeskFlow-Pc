class PcDevice {
  final String hostname;
  final String ip;
  final int wsPort;
  final String os;
  final String version;
  final DateTime discoveredAt;

  PcDevice({
    required this.hostname,
    required this.ip,
    required this.wsPort,
    required this.os,
    required this.version,
    DateTime? discoveredAt,
  }) : discoveredAt = discoveredAt ?? DateTime.now();

  factory PcDevice.fromJson(Map<String, dynamic> json, String remoteIp) {
    return PcDevice(
      hostname: json['hostname'] as String? ?? 'Windows PC',
      ip: (json['ip'] as String?)?.isNotEmpty == true
          ? json['ip'] as String
          : remoteIp,
      wsPort: json['ws_port'] as int? ?? 41533,
      os: json['os'] as String? ?? 'Windows',
      version: json['version'] as String? ?? '1.0.0',
    );
  }

  String get wsUrl => 'ws://$ip:$wsPort';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PcDevice &&
          runtimeType == other.runtimeType &&
          ip == other.ip &&
          wsPort == other.wsPort;

  @override
  int get hashCode => ip.hashCode ^ wsPort.hashCode;
}

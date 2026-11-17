import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/pc_device.dart';
import '../models/system_stats.dart';

enum DeviceConnectionStatus {
  disconnected,
  connecting,
  connected,
}

class ConnectionService extends ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  DeviceConnectionStatus _status = DeviceConnectionStatus.disconnected;
  PcDevice? _currentDevice;
  SystemStats _stats = SystemStats.initial();
  int _pingMs = 0;
  String? _lastError;
  String? _clipboardContent;
  String? _bannerNotification;

  Timer? _reconnectTimer;
  final bool _autoReconnect = true;

  DeviceConnectionStatus get status => _status;
  bool get isConnected => _status == DeviceConnectionStatus.connected;
  PcDevice? get currentDevice => _currentDevice;
  SystemStats get stats => _stats;
  int get pingMs => _pingMs;
  String? get lastError => _lastError;
  String? get clipboardContent => _clipboardContent;
  String? get bannerNotification => _bannerNotification;

  ConnectionService() {
    _loadLastDeviceAndConnect();
  }

  Future<void> _loadLastDeviceAndConnect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastIp = prefs.getString('last_pc_ip');
      final lastPort = prefs.getInt('last_pc_port') ?? 41533;
      final lastName = prefs.getString('last_pc_name') ?? 'My PC';

      if (lastIp != null && lastIp.isNotEmpty) {
        final device = PcDevice(
          hostname: lastName,
          ip: lastIp,
          wsPort: lastPort,
          os: 'Windows',
          version: '1.0.0',
        );
        connect(device);
      }
    } catch (e) {
      debugPrint("[Prefs Load Error] $e");
    }
  }

  Future<void> connect(PcDevice device) async {
    if (_status == DeviceConnectionStatus.connecting) return;

    disconnect(clearSaved: false);

    _status = DeviceConnectionStatus.connecting;
    _currentDevice = device;
    _lastError = null;
    notifyListeners();

    try {
      final uri = Uri.parse(device.wsUrl);
      debugPrint("[Connecting] $uri");

      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;

      _status = DeviceConnectionStatus.connected;
      _saveLastDevice(device);
      notifyListeners();

      _subscription = _channel!.stream.listen(
        _onMessageReceived,
        onError: (err) {
          debugPrint("[WS Error] $err");
          _handleDisconnect(err.toString());
        },
        onDone: () {
          debugPrint("[WS Done] Connection closed.");
          _handleDisconnect("Connection closed.");
        },
      );
    } catch (e) {
      debugPrint("[Connection Failed] $e");
      _handleDisconnect(e.toString());
    }
  }

  void _onMessageReceived(dynamic message) {
    try {
      final json = jsonDecode(message as String) as Map<String, dynamic>;
      final type = json['type'] as String?;

      if (type == 'stats') {
        _stats = SystemStats.fromJson(json);
        final sentTime = json['timestamp'] as num?;
        if (sentTime != null) {
          final now = DateTime.now().millisecondsSinceEpoch;
          final diff = now - sentTime.toInt();
          _pingMs = diff > 0 && diff < 500 ? diff : 3;
        }
        notifyListeners();
      } else if (type == 'mic_state') {
        // Updated mic state
        final isMuted = json['mic_muted'] as bool? ?? false;
        _stats = SystemStats(
          cpu: _stats.cpu,
          cpuCores: _stats.cpuCores,
          ramUsedGb: _stats.ramUsedGb,
          ramTotalGb: _stats.ramTotalGb,
          ramPercent: _stats.ramPercent,
          diskUsedGb: _stats.diskUsedGb,
          diskTotalGb: _stats.diskTotalGb,
          diskPercent: _stats.diskPercent,
          hasBattery: _stats.hasBattery,
          batteryPercent: _stats.batteryPercent,
          isCharging: _stats.isCharging,
          uploadKbps: _stats.uploadKbps,
          downloadKbps: _stats.downloadKbps,
          volumeLevel: _stats.volumeLevel,
          isMuted: _stats.isMuted,
          isMicMuted: isMuted,
          uptime: _stats.uptime,
          hostname: _stats.hostname,
        );
        notifyListeners();
      } else if (type == 'clipboard_content') {
        _clipboardContent = json['text'] as String? ?? '';
        notifyListeners();
      } else if (type == 'notify') {
        _bannerNotification = json['message'] as String?;
        notifyListeners();
        // Clear banner after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (_bannerNotification != null) {
            _bannerNotification = null;
            notifyListeners();
          }
        });
      }
    } catch (e) {
      debugPrint("[Parse Error] $e");
    }
  }

  void _handleDisconnect(String reason) {
    _status = DeviceConnectionStatus.disconnected;
    _lastError = reason;
    _channel = null;
    _subscription?.cancel();
    _subscription = null;
    notifyListeners();

    if (_autoReconnect && _currentDevice != null) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 4), () {
        if (_status == DeviceConnectionStatus.disconnected && _currentDevice != null) {
          connect(_currentDevice!);
        }
      });
    }
  }

  void disconnect({bool clearSaved = false}) {
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _status = DeviceConnectionStatus.disconnected;

    if (clearSaved) {
      _currentDevice = null;
      _clearSavedDevice();
    }
    notifyListeners();
  }

  Future<void> _saveLastDevice(PcDevice device) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_pc_ip', device.ip);
      await prefs.setInt('last_pc_port', device.wsPort);
      await prefs.setString('last_pc_name', device.hostname);
    } catch (e) {
      debugPrint("[Save Device Error] $e");
    }
  }

  Future<void> _clearSavedDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_pc_ip');
      await prefs.remove('last_pc_port');
      await prefs.remove('last_pc_name');
    } catch (_) {}
  }

  // --- COMMAND SENDERS ---

  void sendCommand(String type, [Map<String, dynamic>? payload]) {
    if (!isConnected || _channel == null) return;
    try {
      final data = jsonEncode({
        'type': type,
        'payload': payload ?? {},
      });
      _channel!.sink.add(data);
    } catch (e) {
      debugPrint("[Send Error] $e");
    }
  }

  void sendMediaAction(String action) {
    sendCommand('media', {'action': action});
  }

  void setVolume(int level) {
    sendCommand('set_volume', {'level': level});
  }

  void setMute(bool muted) {
    sendCommand('set_mute', {'muted': muted});
  }

  void toggleMic() {
    sendCommand('toggle_mic');
  }

  void sendSystemAction(String action) {
    sendCommand('action', {'action': action});
  }

  void launchApp(String app) {
    sendCommand('launch', {'app': app});
  }

  void sendClipboardToPc(String text) {
    sendCommand('clipboard_send', {'text': text});
  }

  void requestPcClipboard() {
    sendCommand('clipboard_get');
  }

  void openUrlOnPc(String url) {
    sendCommand('open_url', {'url': url});
  }

  void sendMouseMove(int dx, int dy) {
    sendCommand('mouse_move', {'dx': dx, 'dy': dy});
  }

  void sendMouseClick(String button) {
    sendCommand('mouse_click', {'button': button});
  }

  void sendMouseScroll(int dy) {
    sendCommand('mouse_scroll', {'dy': dy});
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/pc_device.dart';

class DiscoveryService extends ChangeNotifier {
  static const int discoveryPort = 41532;
  static const String pingMessage = "DESKFLOW_DISCOVERY_PING";

  RawDatagramSocket? _socket;
  Timer? _broadcastTimer;
  bool _isSearching = false;
  final Map<String, PcDevice> _discoveredDevices = {};

  bool get isSearching => _isSearching;
  List<PcDevice> get devices => _discoveredDevices.values.toList();

  Future<void> startDiscovery() async {
    if (_isSearching) return;
    _isSearching = true;
    _discoveredDevices.clear();
    notifyListeners();

    try {
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0,
        reuseAddress: true,
        reusePort: false,
      );
      _socket!.broadcastEnabled = true;

      _socket!.listen(
        (RawSocketEvent event) {
          if (event == RawSocketEvent.read) {
            final datagram = _socket?.receive();
            if (datagram != null) {
              _handleDatagram(datagram);
            }
          }
        },
        onError: (err) {
          debugPrint("[Discovery Error] $err");
        },
      );

      // Broadcast immediately and then periodically
      _sendPing();
      _broadcastTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
        _sendPing();
      });
    } catch (e) {
      debugPrint("[Discovery Bind Error] $e");
    }
  }

  void _sendPing() {
    if (_socket == null) return;
    try {
      final data = utf8.encode(pingMessage);
      _socket!.send(
        data,
        InternetAddress('255.255.255.255'),
        discoveryPort,
      );
    } catch (e) {
      debugPrint("[Send Ping Error] $e");
    }
  }

  void _handleDatagram(Datagram datagram) {
    try {
      final text = utf8.decode(datagram.data);
      final json = jsonDecode(text) as Map<String, dynamic>;

      if (json['service'] == 'deskflow') {
        final senderIp = datagram.address.address;
        final device = PcDevice.fromJson(json, senderIp);

        final key = '${device.ip}:${device.wsPort}';
        if (!_discoveredDevices.containsKey(key)) {
          _discoveredDevices[key] = device;
          notifyListeners();
          debugPrint("[Discovered PC] ${device.hostname} at ${device.ip}");
        }
      }
    } catch (e) {
      // Ignore malformed packets from other network services
    }
  }

  void stopDiscovery() {
    _broadcastTimer?.cancel();
    _broadcastTimer = null;
    _socket?.close();
    _socket = null;
    _isSearching = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopDiscovery();
    super.dispose();
  }
}

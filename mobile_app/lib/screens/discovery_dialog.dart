import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pc_device.dart';
import '../services/connection_service.dart';
import '../services/discovery_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class DiscoveryDialog extends StatefulWidget {
  const DiscoveryDialog({super.key});

  @override
  State<DiscoveryDialog> createState() => _DiscoveryDialogState();
}

class _DiscoveryDialogState extends State<DiscoveryDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController =
      TextEditingController(text: '41533');
  bool _showManual = false;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Start discovery scan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoveryService>().startDiscovery();
    });
  }

  @override
  void dispose() {
    // Stop the UDP broadcast scan once the radar is closed, in keeping with
    // the companion's zero-idle-CPU design -- no point scanning in the background.
    context.read<DiscoveryService>().stopDiscovery();
    _radarController.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final discovery = context.watch<DiscoveryService>();
    final conn = context.watch<ConnectionService>();
    final devices = discovery.devices;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    RotationTransition(
                      turns: _radarController,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.cyan.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.radar_rounded,
                          color: AppTheme.cyan,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Wi-Fi Device Radar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Looking for PCs running DeskFlow on your local Wi-Fi...',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Discovered Devices List
            if (devices.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: const [
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.cyan),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Scanning local network...',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ensure run_pc_companion.bat is running on your PC',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: devices.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final device = devices[i];
                    final isCurrent = conn.isConnected &&
                        conn.currentDevice?.ip == device.ip;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppTheme.emerald.withValues(alpha: 0.15)
                            : AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent
                              ? AppTheme.emerald
                              : AppTheme.cyan.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.laptop_windows_rounded,
                                color: isCurrent
                                    ? AppTheme.emerald
                                    : AppTheme.cyan,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.hostname,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${device.ip}:${device.wsPort} • ${device.os}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCurrent
                                  ? AppTheme.emerald
                                  : AppTheme.cyan,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              conn.connect(device);
                              Navigator.pop(context);
                            },
                            child: Text(
                              isCurrent ? 'Connected' : 'Connect',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Toggle Manual IP
            InkWell(
              onTap: () => setState(() => _showManual = !_showManual),
              child: Row(
                children: [
                  Icon(
                    _showManual
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.cyan,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Manual IP Connection',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cyan,
                    ),
                  ),
                ],
              ),
            ),

            if (_showManual) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _ipController,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'e.g. 192.168.1.15',
                        hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        filled: true,
                        fillColor: AppTheme.surfaceElevated,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _portController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Port',
                        hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        filled: true,
                        fillColor: AppTheme.surfaceElevated,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final ip = _ipController.text.trim();
                      final port = int.tryParse(_portController.text.trim()) ?? 41533;
                      if (ip.isNotEmpty) {
                        final customDevice = PcDevice(
                          hostname: 'PC ($ip)',
                          ip: ip,
                          wsPort: port,
                          os: 'Windows',
                          version: '1.0.0',
                        );
                        conn.connect(customDevice);
                        Navigator.pop(context);
                      }
                    },
                    child: const Icon(Icons.arrow_forward_rounded, size: 16),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

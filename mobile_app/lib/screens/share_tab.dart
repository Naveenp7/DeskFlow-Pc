import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/connection_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class ShareTab extends StatefulWidget {
  const ShareTab({super.key});

  @override
  State<ShareTab> createState() => _ShareTabState();
}

class _ShareTabState extends State<ShareTab> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectionService>();
    final clipboardContent = conn.clipboardContent;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Send to PC
          const Row(
            children: [
              Icon(Icons.send_rounded, color: AppTheme.cyan, size: 18),
              SizedBox(width: 8),
              Text(
                'BEAM TO PC',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _textController,
                  maxLines: 4,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type or paste a note, message, or web link...',
                    hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.paste_rounded, size: 20, color: AppTheme.cyan),
                      tooltip: 'Paste from phone',
                      onPressed: () async {
                        final data = await Clipboard.getData(Clipboard.kTextPlain);
                        if (data?.text != null) {
                          _textController.text = data!.text!;
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.surfaceElevated,
                          foregroundColor: AppTheme.cyan,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppTheme.cyan, width: 0.8),
                          ),
                        ),
                        icon: const Icon(Icons.content_copy_rounded, size: 16),
                        label: const Text('Send to Clipboard', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        onPressed: () {
                          final text = _textController.text.trim();
                          if (text.isNotEmpty) {
                            conn.sendClipboardToPc(text);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to PC Clipboard!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cyan,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                        label: const Text('Open on PC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        onPressed: () {
                          final text = _textController.text.trim();
                          if (text.isNotEmpty) {
                            conn.openUrlOnPc(text);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Opening link in PC browser!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section: Pull from PC
          const Row(
            children: [
              Icon(Icons.download_rounded, color: AppTheme.purple, size: 18),
              SizedBox(width: 8),
              Text(
                'GRAB FROM PC CLIPBOARD',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderColor: AppTheme.purple.withValues(alpha: 0.25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PC Active Clipboard',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.purple.withValues(alpha: 0.2),
                        foregroundColor: AppTheme.purple,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: AppTheme.purple, width: 0.8),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Fetch Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      onPressed: () {
                        conn.requestPcClipboard();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 80, maxHeight: 160),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      (clipboardContent != null && clipboardContent.isNotEmpty)
                          ? clipboardContent
                          : 'Tap "Fetch Now" to pull whatever is currently copied on your PC.',
                      style: TextStyle(
                        fontSize: 13,
                        color: (clipboardContent != null && clipboardContent.isNotEmpty)
                            ? AppTheme.textPrimary
                            : AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
                if (clipboardContent != null && clipboardContent.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.copy_all_rounded, size: 16, color: AppTheme.cyan),
                      label: const Text(
                        'Copy to Phone',
                        style: TextStyle(color: AppTheme.cyan, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: clipboardContent));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to phone clipboard!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

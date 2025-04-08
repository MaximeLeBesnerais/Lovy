import 'package:flutter/material.dart';
import 'package:werapp/services/profile_manager.dart';
import 'package:werapp/services/qr_service.dart';

class ConnectionSettingsCard extends StatelessWidget {
  final String? userId;

  const ConnectionSettingsCard({super.key, required this.userId});

  Future<void> _showQrCodeModal(BuildContext context) async {
    if (!context.mounted) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final String qrData = await ProfileManager.getQrData();

      if (!context.mounted) return;
      Navigator.pop(context);

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: const Text('Your QR Code')),
            alignment: Alignment.center,
            content: SizedBox(
              width: 250,
              height: 250,
              child: QrService.generateQrCodeWidget(qrData),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating QR code: $e')));
    }
  }

  void _scanQrCode(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR scanner feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Connection Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (userId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withAlpha(77),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.vpn_key_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your User ID',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            SelectableText(
                              userId!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (userId == null)
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text("Loading User ID..."),
                  ],
                ),
              ),
            ElevatedButton.icon(
              onPressed:
                  userId != null ? () => _showQrCodeModal(context) : null,
              icon: const Icon(Icons.qr_code_2_outlined),
              label: const Text('Show Your QR Code'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _scanQrCode(context),
              icon: const Icon(Icons.qr_code_scanner_outlined),
              label: const Text('Scan Partner\'s QR Code'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

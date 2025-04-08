import 'package:flutter/material.dart';
import 'package:werapp/services/profile_manager.dart';
import 'package:werapp/services/qr_service.dart'; // For QR generation

/// A card widget for displaying connection settings (User ID, QR actions).
class ConnectionSettingsCard extends StatelessWidget {
  /// The current user's unique ID. Can be null if not loaded yet.
  final String? userId;

  const ConnectionSettingsCard({super.key, required this.userId});

  /// Shows a dialog displaying the user's QR code.
  Future<void> _showQrCodeModal(BuildContext context) async {
    if (!context.mounted) return; // Check if widget is still in the tree

    try {
      // Show loading indicator while fetching QR data
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent closing while loading
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final String qrData = await ProfileManager.getQrData(); // Fetch data

      if (!context.mounted) return; // Check again after async operation
      Navigator.pop(context); // Close loading indicator

      // Show the QR code dialog
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Your Connection QR Code'),
            alignment: Alignment.center, // Center the dialog content
            content: SizedBox(
              width: 250, // Fixed size for the QR code
              height: 250,
              // Generate the QR code widget using the service
              child: QrService.generateQrCodeWidget(qrData),
            ),
            actions: [
              // Close button
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
      Navigator.pop(context); // Close loading indicator on error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating QR code: $e')));
    }
  }

  /// Placeholder for the QR scanner functionality.
  void _scanQrCode(BuildContext context) {
    // TO-DO: Implement actual QR scanner logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR scanner feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Rounded corners
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card Title
            Text(
              'Connection Settings',
              style: Theme.of(context).textTheme.titleLarge, // Prominent title
            ),
            const SizedBox(height: 16), // Spacing
            // --- User ID Display ---
            // Show User ID section only if userId is available
            if (userId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  // Styling similar to the view-only name field
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.5),
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
                        Icons.vpn_key_outlined, // Key icon
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.primary, // Use primary color
                      ),
                      const SizedBox(width: 12), // Spacing
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your User ID', // Label
                              style:
                                  Theme.of(
                                    context,
                                  ).textTheme.labelSmall, // Smaller label style
                            ),
                            // Display the actual user ID
                            SelectableText(
                              // Allow copying the ID
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
            // Show loading indicator if userId is not yet available
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

            // --- Action Buttons ---
            // Button to show the user's QR code
            ElevatedButton.icon(
              onPressed:
                  userId != null
                      ? () => _showQrCodeModal(context)
                      : null, // Disable if no user ID
              icon: const Icon(Icons.qr_code_2_outlined), // QR code icon
              label: const Text('Show Your QR Code'),
              // Style for full width and consistent height
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12), // Spacing between buttons
            // Button to scan a partner's QR code
            OutlinedButton.icon(
              onPressed: () => _scanQrCode(context), // Trigger scan function
              icon: const Icon(Icons.qr_code_scanner_outlined), // Scanner icon
              label: const Text('Scan Partner\'s QR Code'),
              // Style for full width and consistent height
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

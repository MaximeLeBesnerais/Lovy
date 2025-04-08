import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/user_profile.dart';
import 'encryption_service.dart';

class QrService {
  // Generate QR code data from user profile and encryption key
  static Future<String> generateQrData(UserProfile profile) async {
    // Get the current key
    String? key = await EncryptionService.getCurrentKey();

    // Generate a new key if none exists
    key ??= await EncryptionService.generateKey();

    return key;
  }

  // Create a QR code widget from the data
  static Widget generateQrCodeWidget(String qrData, {double size = 250}) {
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
    );
  }

  // Parse QR code data from scan result
  static String? parseQrData(String data) {
    try {
      return data;
    } catch (e) {
      return null;
    }
  }
}

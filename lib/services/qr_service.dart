import 'dart:convert';
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

    // Compress the profile image if it exists
    String base64Image = '';
    if (profile.profileImagePath != null) {
      base64Image = await EncryptionService.compressProfileImage(
        profile.profileImagePath!,
      );
    }

    // Create the data object
    final Map<String, dynamic> qrData = {
      'name': profile.name ?? 'User',
      'picture': base64Image,
      'key': key,
    };

    // Convert to JSON string
    return jsonEncode(qrData);
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
  static Map<String, dynamic>? parseQrData(String data) {
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}

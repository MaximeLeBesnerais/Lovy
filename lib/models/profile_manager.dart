import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../models/user_profile.dart';
import '../services/qr_service.dart';

class ProfileManager {
  static const String _profileKey = 'user_profile';

  // Save user profile to SharedPreferences
  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = jsonEncode(profile.toJson());
    await prefs.setString(_profileKey, profileJson);
  }

  // Load user profile from SharedPreferences
  static Future<UserProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);

    if (profileJson != null) {
      final Map<String, dynamic> profileMap = jsonDecode(profileJson);
      return UserProfile.fromJson(profileMap);
    }

    // Return empty profile if none exists
    return UserProfile();
  }

  // Update just the name
  static Future<void> updateName(String name) async {
    final profile = await loadProfile();
    profile.name = name;

    // Regenerate QR data since the name changed
    profile.cachedQrData = await QrService.generateQrData(profile);
    await saveProfile(profile);
  }

  // Update just the profile image path
  static Future<void> updateProfileImage(String imagePath) async {
    // First resize the image to 512x512
    final String resizedImagePath = await _resizeImage(imagePath, 512, 512);

    final profile = await loadProfile();
    profile.profileImagePath = resizedImagePath;

    // Regenerate QR data since the image changed
    profile.cachedQrData = await QrService.generateQrData(profile);
    await saveProfile(profile);
  }

  // Get cached QR data or generate new if needed
  static Future<String> getQrData() async {
    final profile = await loadProfile();
    print('Profile loaded: ${profile.toJson()}');

    if (profile.cachedQrData != null && profile.cachedQrData!.isNotEmpty) {
      return profile.cachedQrData!;
    }

    // Generate and cache if not available
    final qrData = await QrService.generateQrData(profile);
    profile.cachedQrData = qrData;
    await saveProfile(profile);

    return qrData;
  }

  // Helper method to resize image
  static Future<String> _resizeImage(
    String imagePath,
    int targetWidth,
    int targetHeight,
  ) async {
    try {
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return imagePath; // Return original if file doesn't exist
      }

      // Read image bytes
      final List<int> imageBytes = await imageFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(
        Uint8List.fromList(imageBytes),
      );

      if (originalImage == null) {
        return imagePath; // Return original if can't decode
      }

      // Resize image
      img.Image resizedImage = img.copyResize(
        originalImage,
        width: targetWidth,
        height: targetHeight,
      );

      // Create a file path for the resized image
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String resizedFileName =
          'resized_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String resizedFilePath = '${appDir.path}/$resizedFileName';

      // Save the resized image
      File(resizedFilePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 85));

      return resizedFilePath;
    } catch (e) {
      print('Error resizing image: $e');
      return imagePath; // Return original if error
    }
  }
}

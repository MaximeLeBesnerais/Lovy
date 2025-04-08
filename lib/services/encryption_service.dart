import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image/image.dart' as img;

class EncryptionService {
  static const String _keyStorageKey = 'encryption_key';
  static const String _userIdStorageKey = 'user_id';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  // Generate a new encryption key
  static Future<String> generateKey() async {
    final Random random = Random.secure();
    final List<int> values = List<int>.generate(32, (i) => random.nextInt(256));
    final String key = base64Url.encode(values);
    
    // Save the key to secure storage
    await _secureStorage.write(key: _keyStorageKey, value: key);
    
    // Generate and save user ID from key hash
    final String userId = generateUserIdFromKey(key);
    await _secureStorage.write(key: _userIdStorageKey, value: userId);
    
    return key;
  }
  
  // Get the current user's encryption key
  static Future<String?> getCurrentKey() async {
    return await _secureStorage.read(key: _keyStorageKey);
  }
  
  // Generate a user ID by hashing the encryption key
  static String generateUserIdFromKey(String key) {
    final bytes = utf8.encode(key);
    final digest = sha256.convert(bytes);
    // Use first 16 characters of the hash as the user ID
    return digest.toString().substring(0, 16);
  }
  
  // Get the current user's ID
  static Future<String?> getCurrentUserId() async {
    return await _secureStorage.read(key: _userIdStorageKey);
  }
  
  // Encrypt a message with the specified key
  static String encryptMessage(String message, String key) {
    final keyBytes = base64Url.decode(key);
    final encryptKey = encrypt.Key(Uint8List.fromList(keyBytes));
    final iv = encrypt.IV.fromLength(16);
    
    final encrypter = encrypt.Encrypter(encrypt.AES(encryptKey));
    final encrypted = encrypter.encrypt(message, iv: iv);
    
    return encrypted.base64;
  }
  
  // Decrypt a message with the specified key
  static String decryptMessage(String encryptedMessage, String key) {
    try {
      final keyBytes = base64Url.decode(key);
      final encryptKey = encrypt.Key(Uint8List.fromList(keyBytes));
      final iv = encrypt.IV.fromLength(16);
      
      final encrypter = encrypt.Encrypter(encrypt.AES(encryptKey));
      final decrypted = encrypter.decrypt64(encryptedMessage, iv: iv);
      
      return decrypted;
    } catch (e) {
      // If decryption fails, it might be encrypted with another key
      return '';
    }
  }
  
  // Process and compress an image for QR code sharing
  static Future<String> compressProfileImage(String imagePath, {int maxWidth = 150, int maxHeight = 150, int quality = 70}) async {
    final File imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      return '';
    }
    
    final List<int> imageBytes = await imageFile.readAsBytes();
    final img.Image? originalImage = img.decodeImage(Uint8List.fromList(imageBytes));
    
    if (originalImage == null) {
      return '';
    }
    
    // Resize the image to reduce size
    final img.Image resizedImage = img.copyResize(
      originalImage,
      width: maxWidth,
      height: maxHeight,
    );
    
    // Encode image to JPEG with the specified quality
    final List<int> compressedBytes = img.encodeJpg(resizedImage, quality: quality);
    
    // Convert to base64
    final String base64Image = base64Encode(compressedBytes);
    
    return base64Image;
  }
}

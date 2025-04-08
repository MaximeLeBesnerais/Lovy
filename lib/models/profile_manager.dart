import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

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
    await saveProfile(profile);
  }

  // Update just the profile image path
  static Future<void> updateProfileImage(String imagePath) async {
    final profile = await loadProfile();
    profile.profileImagePath = imagePath;
    await saveProfile(profile);
  }
}

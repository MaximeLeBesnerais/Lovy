class UserProfile {
  String? name;
  String? profileImagePath;
  String? cachedQrData; // Added for QR code caching

  UserProfile({this.name, this.profileImagePath, this.cachedQrData});

  // Convert to JSON Map for storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'profileImagePath': profileImagePath,
      'cachedQrData': cachedQrData,
    };
  }

  // Create from JSON Map when loading from storage
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      profileImagePath: json['profileImagePath'],
      cachedQrData: json['cachedQrData'],
    );
  }
}

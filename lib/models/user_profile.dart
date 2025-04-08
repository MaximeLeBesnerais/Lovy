class UserProfile {
  String? name;
  String? profileImagePath;

  UserProfile({this.name, this.profileImagePath});

  // Convert to JSON Map for storage
  Map<String, dynamic> toJson() {
    return {'name': name, 'profileImagePath': profileImagePath};
  }

  // Create from JSON Map when loading from storage
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      profileImagePath: json['profileImagePath'],
    );
  }
}

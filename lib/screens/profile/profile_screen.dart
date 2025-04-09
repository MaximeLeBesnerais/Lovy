import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lovy/services/profile_manager.dart';
import 'package:lovy/services/encryption_service.dart';
import 'widgets/profile_header.dart';
import 'widgets/theme_settings_card.dart';
import 'widgets/connection_settings_card.dart';
import '../../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  final Function(Color) setThemeColor;
  final Color currentThemeColor;
  final ThemeMode currentThemeMode;

  const ProfileScreen({
    super.key,
    required this.setThemeMode,
    required this.setThemeColor,
    required this.currentThemeColor,
    required this.currentThemeMode,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isEditMode = false;
  String? _userId;
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        ProfileManager.loadProfile(),
        _loadOrCreateUserId(),
      ]);

      final profile = results[0] as UserProfile;
      final userId = results[1] as String?;

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _nameController.text = profile.name ?? '';
          _userId = userId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile data: $e')),
        );
      }
    }
  }

  Future<String?> _loadOrCreateUserId() async {
    String? userId = await EncryptionService.getCurrentUserId();
    if (userId == null) {
      await EncryptionService.generateKey();
      userId = await EncryptionService.getCurrentUserId();
    }
    return userId;
  }

  Future<void> _updateName() async {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty && newName != _userProfile?.name) {
      try {
        await ProfileManager.updateName(newName);
        if (mounted) {
          setState(() {
            _userProfile?.name = newName;
            _isEditMode = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Profile name updated')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to update name: $e')));
        }
      }
    } else if (newName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
    } else {
      if (mounted) {
        setState(() => _isEditMode = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (image != null && mounted) {
        await ProfileManager.updateProfileImage(image.path);
        setState(() {
          _userProfile?.profileImagePath = image.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick or update image: $e')),
        );
      }
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (_isEditMode) {
        _nameController.text = _userProfile?.name ?? '';
      }
    });
  }

  void _cancelEdit() {
    setState(() {
      _nameController.text = _userProfile?.name ?? '';
      _isEditMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        actions: [
          if (!_isLoading && !_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _toggleEditMode,
              tooltip: 'Edit Profile',
            ),
        ],
        elevation: 1,
        shadowColor: Theme.of(context).shadowColor.withAlpha(77),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    ProfileHeader(
                      userProfile: _userProfile,
                      nameController: _nameController,
                      isEditMode: _isEditMode,
                      onPickImage: _pickImage,
                      onSaveChanges: _updateName,
                      onCancelEdit: _cancelEdit,
                    ),
                    const SizedBox(height: 24),
                    ThemeSettingsCard(
                      setThemeMode: widget.setThemeMode,
                      setThemeColor: widget.setThemeColor,
                      currentThemeColor: widget.currentThemeColor,
                      currentThemeMode: widget.currentThemeMode,
                    ),
                    const SizedBox(height: 24),
                    ConnectionSettingsCard(userId: _userId),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

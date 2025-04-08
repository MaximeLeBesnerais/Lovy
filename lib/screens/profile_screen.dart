import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:werapp/models/profile_manager.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  final Function(ThemeMode) setTheme;
  final Function(Color) setThemeColor;
  final Color currentThemeColor;

  const ProfileScreen({
    super.key,
    required this.setTheme,
    required this.setThemeColor,
    required this.currentThemeColor,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isEditMode = false; // Added to track edit mode
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    final profile = await ProfileManager.loadProfile();

    setState(() {
      _userProfile = profile;
      _nameController.text = profile.name ?? '';
      _isLoading = false;
    });
  }

  Future<void> _updateName() async {
    if (_nameController.text.trim().isNotEmpty) {
      await ProfileManager.updateName(_nameController.text.trim());
      setState(() {
        _userProfile?.name = _nameController.text.trim();
        _isEditMode = false; // Exit edit mode after saving
      });

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile updated')));
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await ProfileManager.updateProfileImage(image.path);
      setState(() {
        _userProfile?.profileImagePath = image.path;
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      // Reset name field to current value when entering edit mode
      if (_isEditMode) {
        _nameController.text = _userProfile?.name ?? '';
      }
    });
  }

  // Cancel changes and exit edit mode
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
        title: const Text('Profile'),
        actions: [
          if (!_isLoading && !_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditMode,
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Card
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Profile Picture
                              _isEditMode
                                  ? _buildEditableProfileImage()
                                  : _buildViewOnlyProfileImage(),
                              const SizedBox(height: 16),

                              // Name Field or Display
                              _isEditMode
                                  ? _buildEditableNameField()
                                  : _buildViewOnlyNameField(),
                              const SizedBox(height: 16),

                              // Action Buttons - only show in edit mode
                              if (_isEditMode) _buildActionButtons(),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Theme Settings Card
                      _buildThemeSettingsCard(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildEditableProfileImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.2),
            backgroundImage:
                _userProfile?.profileImagePath != null
                    ? FileImage(File(_userProfile!.profileImagePath!))
                    : null,
            child:
                _userProfile?.profileImagePath == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildViewOnlyProfileImage() {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      backgroundImage:
          _userProfile?.profileImagePath != null
              ? FileImage(File(_userProfile!.profileImagePath!))
              : null,
      child:
          _userProfile?.profileImagePath == null
              ? const Icon(Icons.person, size: 50)
              : null,
    );
  }

  Widget _buildEditableNameField() {
    return TextField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Your Name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person_outline),
      ),
    );
  }

  Widget _buildViewOnlyNameField() {
    final name =
        _userProfile?.name?.isNotEmpty == true
            ? _userProfile!.name!
            : 'No name set';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline),
          const SizedBox(width: 12),
          Text(name, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _cancelEdit,
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _updateName,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 50)),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSettingsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Theme Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),

            // Theme mode section
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Theme.of(context).brightness == Brightness.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  Theme.of(context).brightness == Brightness.dark
                      ? 'Dark Mode Active'
                      : 'Light Mode Active',
                ),
                const SizedBox(width: 12),
                DropdownButton<ThemeMode>(
                  value:
                      Theme.of(context).brightness == Brightness.dark
                          ? ThemeMode.dark
                          : ThemeMode.light,
                  onChanged: (ThemeMode? newThemeMode) {
                    if (newThemeMode != null) {
                      widget.setTheme(newThemeMode);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 30),

            // Theme color section
            Text(
              'Theme Color',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildColorOption(
                  context,
                  const Color.fromARGB(255, 255, 11, 153),
                  'Pink',
                ),
                _buildColorOption(
                  context,
                  const Color.fromARGB(255, 26, 152, 255),
                  'Blue',
                ),
                _buildColorOption(
                  context,
                  const Color.fromARGB(255, 27, 255, 34),
                  'Green',
                ),
                _buildColorOption(
                  context,
                  const Color.fromARGB(255, 255, 198, 111),
                  'Orange',
                ),
                _buildColorOption(
                  context,
                  const Color.fromARGB(255, 222, 36, 255),
                  'Purple',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(BuildContext context, Color color, String label) {
    final isSelected = widget.currentThemeColor == color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          InkWell(
            onTap: () => widget.setThemeColor(color),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ]
                        : null,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

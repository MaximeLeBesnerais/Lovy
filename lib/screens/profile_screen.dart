import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:werapp/models/profile_manager.dart';
import 'package:werapp/services/encryption_service.dart';
import 'package:werapp/services/qr_service.dart';
import '../models/user_profile.dart';

// Profile Screen
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
  bool _isEditMode = false;
  String? _userId;
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final userId = await EncryptionService.getCurrentUserId();
    if (userId == null) {
      // No encryption key exists yet, generate one
      await EncryptionService.generateKey();
      final newUserId = await EncryptionService.getCurrentUserId();
      setState(() {
        _userId = newUserId;
      });
    } else {
      setState(() {
        _userId = userId;
      });
    }
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

  Future<void> _showQrCodeModal() async {
    if (_userProfile == null) return;

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the cached QR data or generate new if needed
      final String qrData = await ProfileManager.getQrData();

      if (!context.mounted) return;

      // Show the QR code in a modal
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Share Your Profile Key'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Let your partner scan this QR code to connect with you securely.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrService.generateQrCodeWidget(qrData, size: 250),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your ID: $_userId',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
      );
    } finally {
      // Reset loading state if still mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

                      const SizedBox(height: 24),

                      // Connection Settings Card
                      _buildConnectionSettingsCard(),
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
            ).colorScheme.primary.withValues(alpha: 0.2),
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
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.2),
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
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
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

  Widget _buildConnectionSettingsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Connection Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (_userId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.vpn_key_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your User ID',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              _userId!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ElevatedButton.icon(
              onPressed: _showQrCodeModal,
              icon: const Icon(Icons.qr_code),
              label: const Text('Show Your QR Code'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                // TO-DO: Implement QR scanner
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('QR scanner coming soon')),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan Partner\'s QR Code'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
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
                            color: Colors.black.withValues(alpha: 0.3),
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

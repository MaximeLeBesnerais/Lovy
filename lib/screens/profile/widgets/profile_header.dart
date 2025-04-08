import 'dart:io';
import 'package:flutter/material.dart';
import 'package:werapp/models/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile? userProfile;
  final TextEditingController nameController;
  final bool isEditMode;
  final VoidCallback onPickImage;
  final VoidCallback onSaveChanges;
  final VoidCallback onCancelEdit;

  const ProfileHeader({
    super.key,
    required this.userProfile,
    required this.nameController,
    required this.isEditMode,
    required this.onPickImage,
    required this.onSaveChanges,
    required this.onCancelEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            isEditMode
                ? _buildEditableProfileImage(context)
                : _buildViewOnlyProfileImage(context),
            const SizedBox(height: 16),
            isEditMode
                ? _buildEditableNameField(context)
                : _buildViewOnlyNameField(context),
            const SizedBox(height: 16),
            if (isEditMode) _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableProfileImage(BuildContext context) {
    return GestureDetector(
      onTap: onPickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          _buildBaseProfileImage(context),
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildViewOnlyProfileImage(BuildContext context) {
    return _buildBaseProfileImage(context);
  }

  Widget _buildBaseProfileImage(BuildContext context) {
    final ImageProvider? backgroundImage =
        userProfile?.profileImagePath != null
            ? FileImage(File(userProfile!.profileImagePath!))
            : null;

    return CircleAvatar(
      radius: 50,
      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(51),
      backgroundImage: backgroundImage,
      child:
          backgroundImage == null
              ? Icon(
                Icons.person,
                size: 50,
                color: Theme.of(context).colorScheme.onPrimary.withAlpha(150),
              )
              : null,
    );
  }

  Widget _buildEditableNameField(BuildContext context) {
    return TextField(
      controller: nameController,
      decoration: const InputDecoration(
        labelText: 'Your Name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person_outline),
      ),
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onSaveChanges(),
    );
  }

  Widget _buildViewOnlyNameField(BuildContext context) {
    final String name =
        userProfile?.name?.isNotEmpty == true
            ? userProfile!.name!
            : 'No name set';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(77),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_outline,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCancelEdit,
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onSaveChanges,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 50)),
          ),
        ),
      ],
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/features/user/profile_controller.dart';
import 'package:bike_renting_app/features/user/user_models.dart';
import 'package:bike_renting_app/data/models/database_models.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.profileCTRL,
  });

  final ProfileController profileCTRL;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;

  late final TextEditingController _displayNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _icController;

  @override
  void initState() {
    super.initState();

    _displayNameController = TextEditingController();
    _phoneController = TextEditingController();
    _icController = TextEditingController();

    _loadProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _icController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    await widget.profileCTRL.loadProfile();
  }

  void _startEditing(UserProfileRecord profile) {
    _displayNameController.text = profile.displayName;
    _phoneController.text = profile.phone ?? '';

    // IC number is currently not stored in the profile model.
    _icController.clear();

    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _saveProfile() async {
    final profile = widget.profileCTRL.profile;

    await widget.profileCTRL.updateProfile(
      displayName: _displayNameController.text,
      phone: _phoneController.text,
      avatarUrl: profile?.avatarUrl,
    );

    if (!mounted) return;

    if (widget.profileCTRL.error == null) {
      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully.'),
        ),
      );
    }
  }

  Future<void> _pickAvatar() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image == null || !mounted) return;

    final profile = widget.profileCTRL.profile;

    if (profile == null) return;

    await widget.profileCTRL.uploadAvatar(
      userId: profile.id,
      image: File(image.path),
    );

    if (!mounted) return;

    if (widget.profileCTRL.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: widget.profileCTRL,
      builder: (context, child) {
        final profile = widget.profileCTRL.profile;
        final error = widget.profileCTRL.error;

        if (widget.profileCTRL.isBusy && profile == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (error != null && profile == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage(error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProfile,
                    child: Text(context.l10n.retry),
                  ),
                ],
              ),
            ),
          );
        }

        if (profile == null) {
          return const Center(
            child: Text('Profile not found'),
          );
        }

        return _buildProfile(
          context,
          profile,
          theme,
          scheme,
        );
      },
    );
  }

  Widget _buildProfile(
      BuildContext context,
      UserProfileRecord profile,
      ThemeData theme,
      ColorScheme scheme,
      ) {
    final email =
        Supabase.instance.client.auth.currentUser?.email ?? 'No email';

    return ListView(
      key: const ValueKey<String>('profile-page'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.profile,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            if (!_isEditing)
              IconButton(
                onPressed: () => _startEditing(profile),
                tooltip: 'Edit profile',
                icon: const Icon(
                  Icons.edit_rounded,
                ),
              ),
          ],
        ),

        const SizedBox(height: 28),

        // Avatar
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 62,
                backgroundColor: scheme.surfaceContainerHighest,
                backgroundImage:
                profile.avatarUrl != null &&
                    profile.avatarUrl!.isNotEmpty
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child:
                profile.avatarUrl == null ||
                    profile.avatarUrl!.isEmpty
                    ? Icon(
                  Icons.person_rounded,
                  size: 62,
                  color: scheme.onSurfaceVariant,
                )
                    : null,
              ),

              if (_isEditing)
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Material(
                    color: scheme.primary,
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: widget.profileCTRL.isBusy
                          ? null
                          : _pickAvatar,
                      tooltip: 'Change profile picture',
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 42,
                        minHeight: 42,
                        maxWidth: 42,
                        maxHeight: 42,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Display name
        if (!_isEditing)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  profile.displayName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          )
        else
          TextField(
            controller: _displayNameController,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),

        const SizedBox(height: 6),

        Text(
          email,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 32),

        const Divider(),

        const SizedBox(height: 12),

        // Phone
        if (_isEditing)
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          )
        else
          _profileItem(
            context,
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: _formatValue(profile.phone),
          ),

        if (_isEditing) ...[
          const SizedBox(height: 16),

          // IC Number
          TextField(
            controller: _icController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'IC Number',
              hintText: 'Enter your IC number',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
        ],

        const SizedBox(height: 16),

        _profileItem(
          context,
          icon: Icons.badge_outlined,
          label: 'Role',
          value: _formatValue(profile.role),
        ),

        const SizedBox(height: 16),

        _profileItem(
          context,
          icon: Icons.verified_user_outlined,
          label: 'Status',
          value: _formatValue(profile.accountStatus),
        ),

        if (_isEditing) ...[
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.profileCTRL.isBusy
                      ? null
                      : _cancelEditing,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: widget.profileCTRL.isBusy
                      ? null
                      : _saveProfile,
                  child: widget.profileCTRL.isBusy
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _profileItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatValue(Object? value) {
    if (value == null) return 'Not set';

    if (value is Enum) {
      final raw = value.name;

      return raw
          .split('_')
          .map(
            (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
          .join(' ');
    }

    final text = value.toString().trim();

    if (text.isEmpty) return 'Not set';

    return text;
  }

  String _errorMessage(UserError error) {
    switch (error) {
      case UserError.displayNameRequired:
        return 'Display name is required.';
      case UserError.profileLoadFailed:
        return 'Unable to load your profile.';
      case UserError.profileUpdateFailed:
        return 'Unable to update your profile.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
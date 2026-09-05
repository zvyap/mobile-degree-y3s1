import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/features/user/profile_controller.dart';
import 'package:bike_renting_app/features/user/user_models.dart';
import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

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
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await widget.profileCTRL.loadProfile();
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
          return Center(
            child: Text("Profile not found"),
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
        Supabase.instance.client.auth.currentUser?.email ??
            'No email';

    return ListView(
      key: const ValueKey<String>('profile-page'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          context.l10n.profile,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 28),

        // Avatar
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: scheme.surfaceContainerHighest,
                backgroundImage: profile.avatarUrl != null &&
                    profile.avatarUrl!.isNotEmpty
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: profile.avatarUrl == null ||
                    profile.avatarUrl!.isEmpty
                    ? Icon(
                  Icons.person_rounded,
                  size: 52,
                  color: scheme.onSurfaceVariant,
                )
                    : null,
              ),

              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Display name + edit icon
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
            const SizedBox(width: 6),
            Icon(
              Icons.edit_rounded,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Email
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
        _profileItem(
          theme: theme,
          scheme: scheme,
          icon: Icons.phone_outlined,
          label: "Phone",
          value: profile.phone?.isNotEmpty == true
              ? profile.phone!
              : "-",
        ),

        // Role
        _profileItem(
          theme: theme,
          scheme: scheme,
          icon: Icons.badge_outlined,
          label: "Role",
          value: _formatValue(profile.role),
        ),

        // Account status
        _profileItem(
          theme: theme,
          scheme: scheme,
          icon: Icons.verified_user_outlined,
          label: "Status",
          value: _formatValue(profile.accountStatus),
        ),
      ],
    );
  }

  Widget _profileItem({
    required ThemeData theme,
    required ColorScheme scheme,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatValue(Object value) {
    final text = value.toString();

    if (text.contains('.')) {
      return text
          .split('.')
          .last
          .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
            (match) => '${match.group(1)} ${match.group(2)}',
      )
          .replaceFirstMapped(
        RegExp(r'^.'),
            (match) => match.group(0)!.toUpperCase(),
      );
    }

    return text;
  }

  String _errorMessage(UserError error) {
    switch (error) {
      case UserError.profileLoadFailed:
        return 'Unable to load your profile.';

      case UserError.notAuthenticated:
        return 'You are not logged in.';

      case UserError.connectionFailed:
        return 'Unable to connect. Please try again.';

      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
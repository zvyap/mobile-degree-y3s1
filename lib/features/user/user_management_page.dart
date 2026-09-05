import 'package:flutter/material.dart';

import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/features/user/user_controller.dart';
import 'package:bike_renting_app/features/user/user_models.dart';
import 'package:bike_renting_app/shared/ui_components.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({
    super.key,
    required this.userCTRL,
    required this.onEditUser,
    required this.onAddUser,
  });

  final UserController userCTRL;
  final ValueChanged<String> onEditUser;
  final VoidCallback onAddUser;

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    await widget.userCTRL.loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: widget.userCTRL,
      builder: (context, child) {
        final users = _filteredUsers(widget.userCTRL.users);
        final isLoading =
            widget.userCTRL.isBusy && widget.userCTRL.users.isEmpty;
        final error = widget.userCTRL.error;

        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (error == UserError.usersLoadFailed &&
            widget.userCTRL.users.isEmpty) {
          return _buildErrorState(context);
        }

        return Entrance(
          child: ListView(
            key: const ValueKey<String>('user-management-page'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Text(
                'User Management',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Manage registered users and their account status.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.68),
                ),
              ),

              const SizedBox(height: 16),

              // Search
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: _searchController.clear,
                  )
                      : null,
                  filled: true,
                  fillColor: scheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: scheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: scheme.outline,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // User count
              Row(
                children: [
                  Text(
                    '${users.length} ${users.length == 1 ? 'User' : 'Users'}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (users.isEmpty)
                _buildEmptyState(context)
              else
                ...users.map(
                      (user) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _UserListItem(
                      user: user,
                      onEdit: () => _editUser(user),
                      onVerifyIc: () => _verifyIc(user),
                      onToggleStatus: () => _toggleStatus(user),
                      onDelete: () => _confirmDelete(user),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<UserProfileRecord> _filteredUsers(
      List<UserProfileRecord> users,
      ) {
    if (_searchQuery.isEmpty) {
      return users;
    }

    return users.where((user) {
      final name = user.displayName.toLowerCase();
      final phone = user.phone?.toLowerCase() ?? '';
      final role = _formatValue(user.role).toLowerCase();
      final status = _formatValue(user.accountStatus).toLowerCase();

      return name.contains(_searchQuery) ||
          phone.contains(_searchQuery) ||
          role.contains(_searchQuery) ||
          status.contains(_searchQuery);
    }).toList();
  }

  Widget _buildErrorState(BuildContext context) {
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
            const Text(
              'Unable to load users.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SurfacePanel(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 48,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isEmpty
                  ? 'No users found.'
                  : 'No matching users found.',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editUser(UserProfileRecord user) async {
    // TODO: Navigate to AdminEditUserPage.
    //
    // Example:
    // await Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (_) => AdminEditUserPage(
    //       userCTRL: widget.userCTRL,
    //       user: user,
    //     ),
    //   ),
    // );
  }

  Future<void> _verifyIc(UserProfileRecord user) async {
    // TODO: Implement once IC image upload and face detection
    // have been added.
    //
    // await widget.userCTRL.verifyIc(
    //   userId: user.id,
    // );
  }

  Future<void> _toggleStatus(UserProfileRecord user) async {
    final newStatus = user.accountStatus == AccountStatus.active
        ? AccountStatus.suspended
        : AccountStatus.active;

    await widget.userCTRL.updateUser(
      userId: user.id,
      displayName: user.displayName,
      phone: user.phone,
      avatarUrl: user.avatarUrl,
      role: user.role,
      accountStatus: newStatus,
    );
  }

  Future<void> _confirmDelete(UserProfileRecord user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text(
            'Are you sure you want to delete ${user.displayName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await widget.userCTRL.deleteUser(user.id);

    if (!mounted) return;

    if (widget.userCTRL.error == UserError.userDeleteFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to delete user.'),
        ),
      );
    }
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
}

class _UserListItem extends StatelessWidget {
  const _UserListItem({
    required this.user,
    required this.onEdit,
    required this.onVerifyIc,
    required this.onToggleStatus,
    required this.onDelete,
  });

  final UserProfileRecord user;
  final VoidCallback onEdit;
  final VoidCallback onVerifyIc;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final isActive = user.accountStatus == AccountStatus.active;
    final role = _formatValue(user.role);
    final status = _formatValue(user.accountStatus);

    return SurfacePanel(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 4, 8),

        leading: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
            ? CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage(user.avatarUrl!),
        )
            : const IconTile(
          icon: Icons.person_rounded,
          color: Colors.blue,
          size: 44,
        ),

        title: Text(
          user.displayName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            [
              if (user.phone?.isNotEmpty == true) user.phone!,
              '$role • $status',
            ].join(' • '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),

        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;

              case 'verify_ic':
                onVerifyIc();
                break;

              case 'toggle_status':
                onToggleStatus();
                break;

              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_rounded),
                title: Text('Edit User'),
              ),
            ),
            const PopupMenuItem(
              value: 'verify_ic',
              child: ListTile(
                leading: Icon(Icons.badge_rounded),
                title: Text('Verify IC'),
              ),
            ),
            PopupMenuItem(
              value: 'toggle_status',
              child: ListTile(
                leading: Icon(
                  isActive
                      ? Icons.block_rounded
                      : Icons.check_circle_rounded,
                ),
                title: Text(
                  isActive ? 'Suspend User' : 'Activate User',
                ),
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline_rounded),
                title: Text('Delete User'),
              ),
            ),
          ],
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
}
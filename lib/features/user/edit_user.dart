import 'package:flutter/material.dart';
import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/features/user/user_controller.dart';
import 'package:bike_renting_app/shared/ui_components.dart';

class EditUserPage extends StatefulWidget {
  const EditUserPage({
    super.key,
    required this.userCTRL,
    required this.userId,
  });

  final UserController userCTRL;
  final String userId;

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _displayNameController;
  late final TextEditingController _phoneController;

  AppUserRole? _selectedRole;
  AccountStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();

    final user = widget.userCTRL.users.cast<UserProfileRecord?>().firstWhere(
          (user) => user?.id == widget.userId,
      orElse: () => null,
    );

    _displayNameController = TextEditingController(
      text: user?.displayName ?? '',
    );
    _phoneController = TextEditingController(
      text: user?.phone ?? '',
    );

    _selectedRole = user?.role;
    _selectedStatus = user?.accountStatus;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user == null) {
        _loadUser();
      }
    });
  }

  Future<void> _loadUser() async {
    // The current controller does not expose a getUserById() method.
    // Since the user normally comes from the management list,
    // this should rarely be needed.
    //
    // TODO: Add UserController.loadUser(userId) if direct loading
    // is required for this page.
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.userCTRL.updateUser(
      userId: widget.userId,
      displayName: _displayNameController.text,
      phone: _phoneController.text,
      role: _selectedRole,
      accountStatus: _selectedStatus,
    );

    if (!mounted) return;

    if (widget.userCTRL.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User updated successfully.'),
        ),
      );

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update user.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      body: AnimatedBuilder(
        animation: widget.userCTRL,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              SectionHeader(
                title: 'Edit User',
                subtitle: 'Update the selected user account details.',
              ),
              const SizedBox(height: 20),

              SurfacePanel(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _displayNameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Display Name',
                          hintText: 'Enter display name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Display name is required.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          hintText: 'Enter phone number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Account Settings',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<AppUserRole>(
                        initialValue: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          prefixIcon: Icon(Icons.manage_accounts_outlined),
                        ),
                        items: AppUserRole.values.map((role) {
                          return DropdownMenuItem<AppUserRole>(
                            value: role,
                            child: Text(_roleLabel(role)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value;
                          });
                        },
                      ),

                      const SizedBox(height: 14),

                      DropdownButtonFormField<AccountStatus>(
                        initialValue: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Account Status',
                          prefixIcon: Icon(Icons.verified_user_outlined),
                        ),
                        items: AccountStatus.values.map((status) {
                          return DropdownMenuItem<AccountStatus>(
                            value: status,
                            child: Text(_statusLabel(status)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // TODO: Add IC number and verification controls
                      // after the database migration.
                      //
                      // TextFormField(
                      //   controller: _icNumberController,
                      //   ...
                      // ),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed:
                          widget.userCTRL.isBusy ? null : _saveUser,
                          icon: widget.userCTRL.isBusy
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(Icons.save_rounded),
                          label: Text(
                            widget.userCTRL.isBusy
                                ? 'Saving...'
                                : 'Save Changes',
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: widget.userCTRL.isBusy
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _roleLabel(AppUserRole role) {
    switch (role) {
      case AppUserRole.rider:
        return 'Rider';
      case AppUserRole.admin:
        return 'Administrator';
    }
  }

  String _statusLabel(AccountStatus status) {
    switch (status) {
      case AccountStatus.active:
        return 'Active';
      case AccountStatus.suspended:
        return 'Suspended';
    }
  }
}
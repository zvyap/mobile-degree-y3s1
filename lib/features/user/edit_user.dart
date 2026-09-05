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
  late final TextEditingController _icNumberController;



  AppUserRole? _selectedRole;
  AccountStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();

    _displayNameController = TextEditingController();
    _phoneController = TextEditingController();
    _icNumberController = TextEditingController();

    _loadUser();
  }

  Future<void> _loadUser() async {
    await widget.userCTRL.loadUser(widget.userId);

    if (!mounted) return;

    final user = widget.userCTRL.selectedUser;

    if (user == null) return;

    _displayNameController.text = user.displayName;
    _phoneController.text = user.phone ?? '';
    _icNumberController.text = user.icNumber ?? '';

    setState(() {
      _selectedRole = user.role;
      _selectedStatus = user.accountStatus;
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _icNumberController.dispose();
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
      icNumber: _icNumberController.text,
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
        SnackBar(
          content: Text(
            widget.userCTRL.debugError ?? 'Failed to update user.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
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

                      TextFormField(
                        controller: _icNumberController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'IC Number',
                          hintText: 'Enter IC number',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),

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
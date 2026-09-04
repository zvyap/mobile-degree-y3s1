import 'package:flutter/material.dart';
import 'package:bike_renting_app/data/repositories/auth_repository.dart';
import 'package:bike_renting_app/features/user/auth_controller.dart';
import 'package:bike_renting_app/features/user/forgot_password_page.dart';
import 'package:bike_renting_app/features/user/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AuthController _authController;

  @override
  void initState() {
    super.initState();

    _authController = AuthController(
      AuthRepository(),
    );

    _authController.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authController
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _login() async {
    await _authController.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (_authController.error == null) {
      // Login succeeded.
    }
  }

  static const List<_TestAccount> _testAccounts = [
    _TestAccount(
      name: 'punly day',
      email: 'punlyhayday@gmail.com',
      password: 'test1234',
      role: 'Admin',
      icon: Icons.admin_panel_settings_outlined,
    ),
    _TestAccount(
      name: 'Renting Test User 1',
      email: 'renting.demo.01@example.com',
      password: 'BikeRenting-Demo-01!2026',
      role: 'Rider',
      icon: Icons.directions_bike_outlined,
    ),
  ];

  void _showTestAccountPicker(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  'Select Test Account',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Choose an account to autofill credentials',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ..._testAccounts.map((account) {
                final isAdmin = account.role.toLowerCase() == 'admin';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isAdmin
                        ? scheme.primaryContainer
                        : scheme.secondaryContainer,
                    foregroundColor: isAdmin
                        ? scheme.onPrimaryContainer
                        : scheme.onSecondaryContainer,
                    child: Icon(account.icon),
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          account.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? scheme.primary.withValues(alpha: 0.12)
                              : scheme.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          account.role,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isAdmin ? scheme.primary : scheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    account.email,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                  ),
                  minTileHeight: 48,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _emailController.text = account.email;
                    _passwordController.text = account.password;
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 72,
                    height: 72,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'BikeRent',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 32),

                // Email Input
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: scheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: scheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: scheme.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Input
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: scheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: scheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: scheme.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Quick test account selector
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _authController.isBusy
                        ? null
                        : () => _showTestAccountPicker(context),
                    icon: const Icon(Icons.arrow_drop_down_rounded, size: 18),
                    label: const Text('Use Test Account'),
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.onSurface.withValues(alpha: 0.7),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Primary Action Button
                FilledButton(
                  onPressed: _authController.isBusy ? null : _login,
                  child: _authController.isBusy
                      ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onPrimary,
                    ),
                  )
                      : const Text('Login'),
                ),

                if (_authController.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _authController.error.toString(),
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 16),

                // Forgot Password
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ForgotPasswordPage(
                            onBack: () => Navigator.of(context).pop(),
                            authController: _authController,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: scheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sign Up Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.7)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RegisterPage(
                              authController: _authController,
                              onBackToLogin: () => Navigator.of(context).pop(),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TestAccount {
  const _TestAccount({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.icon,
  });

  final String name;
  final String email;
  final String password;
  final String role;
  final IconData icon;
}
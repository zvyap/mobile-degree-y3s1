import 'package:flutter/material.dart';
import 'package:bike_renting_app/data/repositories/auth_repository.dart';
import 'package:bike_renting_app/data/repositories/profile_repository.dart';
import 'package:bike_renting_app/data/database/database_data_source.dart';
import 'package:bike_renting_app/features/user/auth_controller.dart';
import 'package:bike_renting_app/features/user/forgot_password_page.dart';
import 'package:bike_renting_app/features/user/register_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    final client = Supabase.instance.client;
    final dataSource = SupabaseDatabaseDataSource(client);

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
                    hintStyle: TextStyle(color: scheme.onSurface.withOpacity(0.5)),
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
                    hintStyle: TextStyle(color: scheme.onSurface.withOpacity(0.5)),
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

                // Quick test account quick-fill
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _authController.isBusy
                        ? null
                        : () {
                      _emailController.text = 'punlyhayday@gmail.com';
                      _passwordController.text = 'test1234';
                    },
                    child: Text(
                      'Use Test Account',
                      style: TextStyle(color: scheme.onSurface.withOpacity(0.6), fontSize: 12),
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
                      style: TextStyle(color: scheme.onSurface.withOpacity(0.7)),
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
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
      // The AuthGate will eventually handle navigation/session state.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B2D),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icon/app_icon.png',
                  width: 90, height: 90,
                ),

                const SizedBox(height: 12),

                const Text(
                  'BikeRent',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 45),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                // remove this before submit
                TextButton(
                  onPressed: _authController.isBusy
                      ? null
                      : () {
                    _emailController.text = 'punlyhayday@gmail.com';
                    _passwordController.text = 'test1234';
                  },
                  child: const Text(
                    'Use Test Account',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ),

                const SizedBox(height: 8),


                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _authController.isBusy ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF023E8A),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF023E8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _authController.isBusy
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                if (_authController.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _authController.error.toString(),
                    style: const TextStyle(
                      color: Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 18),

                TextButton(
                  onPressed: () {
                    // TODO: Navigate to forgot password page.
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ForgotPasswordPage(
                          onBack: () => Navigator.of(context).pop(), authController: _authController,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
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
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
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
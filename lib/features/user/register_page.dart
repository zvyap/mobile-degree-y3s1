import 'package:flutter/material.dart';
import 'package:bike_renting_app/features/user/auth_controller.dart';
import 'package:bike_renting_app/features/user/user_models.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.authController,
    required this.onBackToLogin,
  });

  final AuthController authController;
  final VoidCallback onBackToLogin;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    await widget.authController.register(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (widget.authController.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully. Please log in.',
          ),
        ),
      );

      widget.onBackToLogin();
    }
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: scheme.onSurface.withOpacity(0.5)),
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBackToLogin,
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.authController,
          builder: (context, child) {
            final error = widget.authController.error;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // First Name Input
                    TextField(
                      controller: _firstNameController,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: _inputDecoration(context, 'First Name'),
                    ),
                    const SizedBox(height: 14),

                    // Last Name Input
                    TextField(
                      controller: _lastNameController,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: _inputDecoration(context, 'Last Name'),
                    ),
                    const SizedBox(height: 14),

                    // Email Input
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: _inputDecoration(context, 'Email'),
                    ),
                    const SizedBox(height: 14),

                    // Password Input
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: _inputDecoration(context, 'Password').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: scheme.onSurface.withOpacity(0.6),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Confirm Password Input
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: _inputDecoration(context, 'Confirm Password').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: scheme.onSurface.withOpacity(0.6),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    if (error != null) ...[
                      Text(
                        _errorMessage(error),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: scheme.error,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Primary Submit Button
                    FilledButton(
                      onPressed: widget.authController.isBusy
                          ? null
                          : _register,
                      child: widget.authController.isBusy
                          ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.onPrimary,
                        ),
                      )
                          : const Text('Register'),
                    ),
                    const SizedBox(height: 16),

                    // Back to Login Link
                    Center(
                      child: TextButton(
                        onPressed: widget.authController.isBusy
                            ? null
                            : widget.onBackToLogin,
                        child: Text(
                          'Already have an account? Log In',
                          style: TextStyle(
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _errorMessage(UserError error) {
    switch (error) {
      case UserError.emailRequired:
        return 'Email is required.';

      case UserError.invalidEmail:
        return 'Please enter a valid email address.';

      case UserError.passwordRequired:
        return 'Password is required.';

      case UserError.weakPassword:
        return 'Password must be at least 8 characters long.';

      case UserError.emailAlreadyRegistered:
        return 'An account with this email already exists.';

      case UserError.displayNameRequired:
        return 'First and last name are required.';

      case UserError.registrationFailed:
        return 'Registration failed. Please try again.';

      case UserError.connectionFailed:
        return 'Unable to connect. Please try again.';

      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
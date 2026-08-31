import 'package:flutter/material.dart';
import 'package:bike_renting_app/features/user/auth_controller.dart';
import 'package:bike_renting_app/features/user/user_models.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    super.key,
    required this.onBack,
    required this.authController,
  });

  final VoidCallback onBack;
  final AuthController authController;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  bool _isSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    setState(() {
      _isSent = false;
    });

    await widget.authController.forgotPassword(
      email: _emailController.text,
    );

    if (!mounted) return;

    if (widget.authController.error == null) {
      setState(() {
        _isSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Forgot Password',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Email Input Field
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
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
                          borderSide: BorderSide(
                            color: scheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Action Button
                    FilledButton(
                      onPressed: widget.authController.isBusy
                          ? null
                          : _sendResetEmail,
                      child: widget.authController.isBusy
                          ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.onPrimary,
                        ),
                      )
                          : const Text('Send Reset Email'),
                    ),

                    if (_isSent) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Reset email sent! Check your inbox.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: scheme.secondary,
                          fontSize: 14,
                        ),
                      ),
                    ],

                    if (error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage(error),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: scheme.error,
                          fontSize: 14,
                        ),
                      ),
                    ],
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
        return 'Please enter your email address.';
      case UserError.passwordResetFailed:
        return 'Unable to send the reset email. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
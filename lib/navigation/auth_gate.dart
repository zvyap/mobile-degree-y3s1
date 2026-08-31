import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bike_renting_app/features/user/login_page.dart';
import 'package:bike_renting_app/shell/bike_shell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.onToggleTheme,
  });

  final ValueChanged<Brightness> onToggleTheme;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<AuthState> _authSubscription;

  Session? _session;

  @override
  void initState() {
    super.initState();

    final client = Supabase.instance.client;

    // Get the session that already exists when the app starts.
    _session = client.auth.currentSession;

    // Listen for future login/logout changes.
    _authSubscription = client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;

      setState(() {
        _session = data.session;
      });
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_session != null) {
      return BikeShell(
        onToggleTheme: widget.onToggleTheme,
      );
    }
    return const LoginPage();
  }
}
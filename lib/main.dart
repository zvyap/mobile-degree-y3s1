import 'dart:io';
import 'package:bike_renting_app/app/bike_renting_app.dart';
import 'package:bike_renting_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = 'https://xlekizcdmynrngilkjoy.supabase.co';
const String supabasePublishableKey =
    'sb_publishable_JZzEqgEg8mOGEsZA8PzlNw_yhvdK-sn';

enum ConnectionFailureReason {
  noInternet,
  noSupabase,
}

/// Tests whether the device has a working internet connection.
Future<bool> testInternetConnection({
  Duration timeout = const Duration(seconds: 4),
  http.Client? httpClient,
}) async {
  try {
    final lookup = await InternetAddress.lookup('google.com').timeout(timeout);
    if (lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty) {
      debugPrint('[ConnectionTest] Internet DNS check: PASSED');
      return true;
    }
  } catch (e) {
    debugPrint('[ConnectionTest] Internet DNS check failed: $e');
  }

  final client = httpClient ?? http.Client();
  try {
    final response = await client
        .get(Uri.parse('https://clients3.google.com/generate_204'))
        .timeout(timeout);
    final isSuccess = response.statusCode == 204 || response.statusCode == 200;
    debugPrint(
      '[ConnectionTest] Internet HTTP check: ${isSuccess ? "PASSED" : "FAILED"}',
    );
    return isSuccess;
  } catch (e) {
    debugPrint('[ConnectionTest] Internet HTTP check failed: $e');
    return false;
  } finally {
    if (httpClient == null) {
      client.close();
    }
  }
}

/// Tests whether the Supabase backend service is reachable and healthy.
Future<bool> testSupabaseConnection({
  Duration timeout = const Duration(seconds: 4),
  http.Client? httpClient,
  String url = supabaseUrl,
  String apiKey = supabasePublishableKey,
}) async {
  final client = httpClient ?? http.Client();
  try {
    final response = await client.get(
      Uri.parse('$url/auth/v1/health'),
      headers: {
        'apikey': apiKey,
      },
    ).timeout(timeout);
    final isSuccess = response.statusCode == 200;
    debugPrint(
      '[ConnectionTest] Supabase health check: ${isSuccess ? "PASSED" : "FAILED (${response.statusCode})"}',
    );
    return isSuccess;
  } catch (e) {
    debugPrint('[ConnectionTest] Supabase health check failed: $e');
    return false;
  } finally {
    if (httpClient == null) {
      client.close();
    }
  }
}

/// Ensures Supabase is initialized safely without duplicate initialization.
Future<void> ensureSupabaseInitialized() async {
  try {
    Supabase.instance.client;
  } catch (_) {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hasInternet = await testInternetConnection();
  if (!hasInternet) {
    runApp(const ConnectionBlockedApp(
      reason: ConnectionFailureReason.noInternet,
    ));
    return;
  }

  final hasSupabase = await testSupabaseConnection();
  if (!hasSupabase) {
    runApp(const ConnectionBlockedApp(
      reason: ConnectionFailureReason.noSupabase,
    ));
    return;
  }

  await ensureSupabaseInitialized();
  runApp(const BikeRentingApp());
}

/// Blocking app UI displayed when internet or Supabase is unavailable.
/// Stops the user from accessing any app features until connection is verified.
class ConnectionBlockedApp extends StatelessWidget {
  const ConnectionBlockedApp({
    super.key,
    required this.reason,
    this.testInternet = testInternetConnection,
    this.testSupabase = testSupabaseConnection,
    this.onRetrySuccess,
  });

  final ConnectionFailureReason reason;
  final Future<bool> Function() testInternet;
  final Future<bool> Function() testSupabase;
  final Future<void> Function()? onRetrySuccess;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Connection Error',
      themeMode: ThemeMode.system,
      theme: AppTheme.build(Brightness.light),
      darkTheme: AppTheme.build(Brightness.dark),
      home: ConnectionBlockedScreen(
        initialReason: reason,
        testInternet: testInternet,
        testSupabase: testSupabase,
        onRetrySuccess: onRetrySuccess,
      ),
    );
  }
}

class ConnectionBlockedScreen extends StatefulWidget {
  const ConnectionBlockedScreen({
    super.key,
    required this.initialReason,
    required this.testInternet,
    required this.testSupabase,
    this.onRetrySuccess,
  });

  final ConnectionFailureReason initialReason;
  final Future<bool> Function() testInternet;
  final Future<bool> Function() testSupabase;
  final Future<void> Function()? onRetrySuccess;

  @override
  State<ConnectionBlockedScreen> createState() =>
      _ConnectionBlockedScreenState();
}

class _ConnectionBlockedScreenState extends State<ConnectionBlockedScreen> {
  late ConnectionFailureReason _reason;
  bool _isRetrying = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _reason = widget.initialReason;
  }

  Future<void> _handleRetry() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
      _statusMessage = 'Checking internet connection...';
    });

    try {
      final hasInternet = await widget.testInternet();
      if (!hasInternet) {
        if (mounted) {
          setState(() {
            _reason = ConnectionFailureReason.noInternet;
            _isRetrying = false;
            _statusMessage = 'No internet connection. Please check network.';
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _statusMessage = 'Checking Supabase connection...';
        });
      }

      final hasSupabase = await widget.testSupabase();
      if (!hasSupabase) {
        if (mounted) {
          setState(() {
            _reason = ConnectionFailureReason.noSupabase;
            _isRetrying = false;
            _statusMessage = 'Unable to reach Supabase backend service.';
          });
        }
        return;
      }

      if (!mounted) return;

      setState(() {
        _isRetrying = false;
        _statusMessage = 'Connection restored! Starting app...';
      });

      if (widget.onRetrySuccess != null) {
        await widget.onRetrySuccess!();
      } else {
        await ensureSupabaseInitialized();
        runApp(const BikeRentingApp());
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isRetrying = false;
          _statusMessage = 'Failed to verify connection. Please retry.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isNoInternet = _reason == ConnectionFailureReason.noInternet;

    final iconData = isNoInternet
        ? Icons.wifi_off_rounded
        : Icons.cloud_off_rounded;

    final title = isNoInternet
        ? 'No Internet Connection'
        : 'Service Unavailable';

    final message = isNoInternet
        ? 'BikeRent requires an active internet connection to operate. Please check your cellular data or Wi-Fi settings and try again.'
        : 'Unable to connect to the Supabase backend service. Please check your network connection or try again later.';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconData,
                      size: 48,
                      color: colorScheme.error,
                      semanticLabel: title,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 16),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _isRetrying
                              ? colorScheme.primary
                              : colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _isRetrying ? null : _handleRetry,
                      icon: _isRetrying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.refresh_rounded),
                      label: Text(
                        _isRetrying ? 'Checking...' : 'Retry Connection',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

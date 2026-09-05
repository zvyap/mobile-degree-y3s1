import 'package:bike_renting_app/app/bike_renting_app.dart';
import 'package:bike_renting_app/shared/connection_service.dart';
import 'package:flutter/material.dart';

/// Screen displayed when internet or Supabase is unavailable.
/// Provides retry mechanism to verify connection before continuing.
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

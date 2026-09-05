import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

enum GpsIssueType {
  serviceDisabled,
  permissionDenied,
}

/// Safeguard widget that wraps the application and enforces that device GPS
/// is enabled and location permission is granted.
/// If either condition fails, it displays a non-dismissible modal and prevents
/// access to the app, with an option to open settings or quit the app.
class LocationSafeguard extends StatefulWidget {
  const LocationSafeguard({
    super.key,
    required this.child,
    this.isServiceEnabledChecker,
    this.permissionChecker,
    this.permissionRequester,
    this.onOpenSettings,
    this.onQuit,
    this.autoCheck = true,
  });

  final Widget child;
  final Future<bool> Function()? isServiceEnabledChecker;
  final Future<LocationPermission> Function()? permissionChecker;
  final Future<LocationPermission> Function()? permissionRequester;
  final Future<void> Function(GpsIssueType issue)? onOpenSettings;
  final VoidCallback? onQuit;
  final bool autoCheck;

  @override
  State<LocationSafeguard> createState() => _LocationSafeguardState();
}

class _LocationSafeguardState extends State<LocationSafeguard>
    with WidgetsBindingObserver {
  GpsIssueType? _activeIssue;
  bool _isChecking = false;
  late final bool _isTest;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isTest = Platform.environment.containsKey('FLUTTER_TEST');

    if (widget.autoCheck && !_isTest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        checkStatus();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When returning to app after changing settings, re-check GPS status.
    if (state == AppLifecycleState.resumed && widget.autoCheck && !_isTest) {
      checkStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Checks location service availability and permissions.
  Future<void> checkStatus() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    try {
      final serviceEnabled = widget.isServiceEnabledChecker != null
          ? await widget.isServiceEnabledChecker!()
          : await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _activeIssue = GpsIssueType.serviceDisabled;
            _isChecking = false;
          });
        }
        return;
      }

      var permission = widget.permissionChecker != null
          ? await widget.permissionChecker!()
          : await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = widget.permissionRequester != null
            ? await widget.permissionRequester!()
            : await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _activeIssue = GpsIssueType.permissionDenied;
            _isChecking = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _activeIssue = null;
          _isChecking = false;
        });
      }
    } catch (e) {
      debugPrint('LocationSafeguard check error: $e');
      if (mounted) {
        setState(() {
          _activeIssue = GpsIssueType.serviceDisabled;
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _handleOpenSettings() async {
    final issue = _activeIssue ?? GpsIssueType.serviceDisabled;
    if (widget.onOpenSettings != null) {
      await widget.onOpenSettings!(issue);
      return;
    }

    if (issue == GpsIssueType.serviceDisabled) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }

  void _handleQuit() {
    if (widget.onQuit != null) {
      widget.onQuit!();
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final issue = _activeIssue;

    return Stack(
      fit: StackFit.expand,
      children: [
        // App child underneath is disabled while GPS is not granted/usable
        IgnorePointer(
          ignoring: issue != null,
          child: widget.child,
        ),

        // Modal blocker barrier
        if (issue != null)
          _GpsBlockedModal(
            issue: issue,
            isChecking: _isChecking,
            onOpenSettings: _handleOpenSettings,
            onCheckAgain: checkStatus,
            onQuit: _handleQuit,
          ),
      ],
    );
  }
}

class _GpsBlockedModal extends StatelessWidget {
  const _GpsBlockedModal({
    required this.issue,
    required this.isChecking,
    required this.onOpenSettings,
    required this.onCheckAgain,
    required this.onQuit,
  });

  final GpsIssueType issue;
  final bool isChecking;
  final VoidCallback onOpenSettings;
  final VoidCallback onCheckAgain;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final isServiceDisabled = issue == GpsIssueType.serviceDisabled;
    final title = isServiceDisabled
        ? 'GPS Location Disabled'
        : 'Location Permission Required';
    final message = isServiceDisabled
        ? 'Device GPS is turned off. This bike renting app requires GPS to find stations, track active rides, and load live weather conditions.\n\nPlease turn on location services to continue.'
        : 'Location access was not granted. This bike renting app requires GPS permission to find stations, track active rides, and load live weather conditions.\n\nPlease grant location permission in Settings to continue.';

    return PopScope(
      canPop: false,
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.72),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Material(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon header
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: scheme.errorContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_off_rounded,
                            size: 32,
                            color: scheme.onErrorContainer,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Title
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Explanation message
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.78),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Primary Action: Open Settings
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton.icon(
                            key: const ValueKey<String>('gps-open-settings'),
                            onPressed: isChecking ? null : onOpenSettings,
                            icon: const Icon(Icons.settings_outlined, size: 20),
                            label: Text(
                              isServiceDisabled
                                  ? 'Open Location Settings'
                                  : 'Open App Settings',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Secondary Action: Check Again
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            key: const ValueKey<String>('gps-check-again'),
                            onPressed: isChecking ? null : onCheckAgain,
                            icon: isChecking
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: scheme.primary,
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded, size: 20),
                            label: Text(
                              isChecking ? 'Checking...' : 'Check Again',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Tertiary Action: Quit App
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: TextButton.icon(
                            key: const ValueKey<String>('gps-quit-app'),
                            onPressed: onQuit,
                            icon: Icon(
                              Icons.power_settings_new_rounded,
                              size: 20,
                              color: scheme.error,
                            ),
                            label: Text(
                              'Quit App',
                              style: TextStyle(
                                color: scheme.error,
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
          ),
        ),
      ),
    );
  }
}

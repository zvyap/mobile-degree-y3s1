import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:bike_renting_app/features/user/reset_password_page.dart';
import 'package:flutter/material.dart';

class AppDeepLinkManager {
  AppDeepLinkManager._();

  static final AppDeepLinkManager instance = AppDeepLinkManager._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  final _bikeQrController = StreamController<String>.broadcast();
  Stream<String> get onBikeQr => _bikeQrController.stream;

  String? _pendingBikeQrToken;
  String? get pendingBikeQrToken => _pendingBikeQrToken;

  bool _pendingResetPassword = false;
  String? _lastHandledUri;
  DateTime? _lastHandledTime;

  bool _initialized = false;

  void initialize() {
    if (_initialized) return;
    _initialized = true;

    // Listen for deep links when app is running or resumed
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (err) {
        debugPrint('[AppDeepLinkManager] Link stream error: $err');
      },
    );

    // Check initial deep link on cold start
    unawaited(_checkInitialLink());
  }

  Future<void> _checkInitialLink() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (err) {
      debugPrint('[AppDeepLinkManager] Initial link error: $err');
    }
  }

  void _handleUri(Uri uri) {
    if (uri.scheme.toLowerCase() != 'bike-renting') {
      return;
    }

    final uriStr = uri.toString();
    final now = DateTime.now();
    if (_lastHandledUri == uriStr &&
        _lastHandledTime != null &&
        now.difference(_lastHandledTime!).inMilliseconds < 1500) {
      return;
    }
    _lastHandledUri = uriStr;
    _lastHandledTime = now;

    debugPrint('[AppDeepLinkManager] Handling deep link: $uri');

    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();

    // 1. Reset password route
    if (host == 'reset-password' || path.contains('reset-password')) {
      openResetPassword();
      return;
    }

    // 2. Bike QR route
    final token = uri.queryParameters['qr'] ??
        uri.queryParameters['token'] ??
        uri.queryParameters['qr_token'] ??
        uri.queryParameters['code'] ??
        (uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null) ??
        (host.isNotEmpty && host != 'bike' && host != 'rent' ? host : null);

    if (token != null && token.isNotEmpty) {
      _pendingBikeQrToken = token;
      _bikeQrController.add(token);
    }
  }

  void openResetPassword() {
    final nav = rootNavigatorKey.currentState;
    if (nav == null) {
      _pendingResetPassword = true;
      return;
    }

    _pendingResetPassword = false;
    nav.push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/reset-password'),
        builder: (_) => const ResetPasswordPage(),
      ),
    );
  }

  String? consumePendingBikeQrToken() {
    final token = _pendingBikeQrToken;
    _pendingBikeQrToken = null;
    return token;
  }

  void onNavigatorReady() {
    if (_pendingResetPassword) {
      _pendingResetPassword = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        openResetPassword();
      });
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
    _bikeQrController.close();
    _initialized = false;
  }
}

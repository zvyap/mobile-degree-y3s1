import 'dart:convert';
import 'dart:math';

import 'package:bike_renting_app/constants.dart';
import 'package:http/http.dart' as http;

enum PayPalFailureType {
  configuration,
  network,
  authentication,
  declined,
  invalidResponse,
  captureFailed,
  voidFailed,
}

class PayPalException implements Exception {
  const PayPalException({
    required this.type,
    required this.message,
    this.statusCode,
    this.debugId,
  });

  final PayPalFailureType type;
  final String message;
  final int? statusCode;
  final String? debugId;

  @override
  String toString() => 'PayPalException($type, $message)';
}

class PayPalAuthorizationOrder {
  const PayPalAuthorizationOrder({
    required this.orderId,
    required this.approvalUrl,
  });

  final String orderId;
  final Uri approvalUrl;
}

class PayPalAuthorizationResult {
  const PayPalAuthorizationResult({
    required this.orderId,
    required this.authorizationId,
  });

  final String orderId;
  final String authorizationId;
}

class PayPalCaptureResult {
  const PayPalCaptureResult({required this.captureId});

  final String captureId;
}

abstract interface class PayPalPaymentGateway {
  Future<PayPalAuthorizationOrder> createAuthorizationOrder(double amount);

  Future<PayPalAuthorizationResult> authorizeOrder(String orderId);

  Future<PayPalCaptureResult> captureAuthorization(
    String authorizationId,
    double amount,
  );

  Future<void> voidAuthorization(String authorizationId);

  void close();
}

class PayPalGateway implements PayPalPaymentGateway {
  PayPalGateway({
    http.Client? client,
    this.clientId = PayPalSandboxConstants.clientId,
    this.clientSecret = PayPalSandboxConstants.clientSecret,
    this.apiBaseUrl = PayPalSandboxConstants.apiBaseUrl,
    this.currencyCode = PayPalSandboxConstants.currencyCode,
    this.returnUrl = PayPalSandboxConstants.returnUrl,
    this.cancelUrl = PayPalSandboxConstants.cancelUrl,
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;
  final String clientId;
  final String clientSecret;
  final String apiBaseUrl;
  final String currencyCode;
  final String returnUrl;
  final String cancelUrl;

  String? _accessToken;
  DateTime? _accessTokenExpiresAt;
  String? _pendingCreateRequestId;

  @override
  Future<PayPalAuthorizationOrder> createAuthorizationOrder(
    double amount,
  ) async {
    _validateConfiguration();
    final token = await _getAccessToken();
    final requestId = _pendingCreateRequestId ??= _newRequestId('order');
    final response = await _send(
      () => _client.post(
        _uri('/v2/checkout/orders'),
        headers: _jsonHeaders(token, requestId: requestId),
        body: jsonEncode({
          'intent': 'AUTHORIZE',
          'purchase_units': [
            {
              'reference_id': 'bike-rental',
              'description': 'BikeRent temporary rental hold',
              'amount': {
                'currency_code': currencyCode,
                'value': _money(amount),
              },
            },
          ],
          'application_context': {
            'brand_name': 'BikeRent',
            'locale': 'en-MY',
            'landing_page': 'NO_PREFERENCE',
            'shipping_preference': 'NO_SHIPPING',
            'user_action': 'PAY_NOW',
            'return_url': returnUrl,
            'cancel_url': cancelUrl,
          },
        }),
      ),
    );
    final payload = _decodeSuccess(response, expectedStatuses: const {201});
    final orderId = _requiredString(payload, 'id');
    final approvalUrl = _approvalUrl(payload);
    _pendingCreateRequestId = null;
    return PayPalAuthorizationOrder(orderId: orderId, approvalUrl: approvalUrl);
  }

  @override
  Future<PayPalAuthorizationResult> authorizeOrder(String orderId) async {
    final token = await _getAccessToken();
    final response = await _send(
      () => _client.post(
        _uri('/v2/checkout/orders/$orderId/authorize'),
        headers: _jsonHeaders(
          token,
          requestId: _stableRequestId('authorize', orderId),
        ),
      ),
    );
    final payload = _decodeSuccess(response, expectedStatuses: const {201});
    final authorization = _firstAuthorization(payload);
    final status = authorization['status'];
    if (status != 'CREATED') {
      throw PayPalException(
        type: PayPalFailureType.declined,
        message: 'paypal_authorization_$status',
        statusCode: response.statusCode,
      );
    }
    return PayPalAuthorizationResult(
      orderId: orderId,
      authorizationId: _requiredString(authorization, 'id'),
    );
  }

  @override
  Future<PayPalCaptureResult> captureAuthorization(
    String authorizationId,
    double amount,
  ) async {
    final token = await _getAccessToken();
    final response = await _send(
      () => _client.post(
        _uri('/v2/payments/authorizations/$authorizationId/capture'),
        headers: _jsonHeaders(
          token,
          requestId: _stableRequestId('capture', authorizationId),
        ),
        body: jsonEncode({
          'amount': {'currency_code': currencyCode, 'value': _money(amount)},
          'final_capture': true,
          'note_to_payer': 'Final BikeRent ride fare',
        }),
      ),
    );
    final payload = _decodeSuccess(
      response,
      expectedStatuses: const {200, 201},
      failureType: PayPalFailureType.captureFailed,
    );
    if (payload['status'] != 'COMPLETED') {
      throw PayPalException(
        type: PayPalFailureType.captureFailed,
        message: 'paypal_capture_${payload['status']}',
        statusCode: response.statusCode,
      );
    }
    return PayPalCaptureResult(captureId: _requiredString(payload, 'id'));
  }

  @override
  Future<void> voidAuthorization(String authorizationId) async {
    final token = await _getAccessToken();
    final response = await _send(
      () => _client.post(
        _uri('/v2/payments/authorizations/$authorizationId/void'),
        headers: _jsonHeaders(
          token,
          requestId: _stableRequestId('void', authorizationId),
        ),
      ),
    );
    _decodeSuccess(
      response,
      expectedStatuses: const {204},
      failureType: PayPalFailureType.voidFailed,
      allowEmptyBody: true,
    );
  }

  Future<String> _getAccessToken() async {
    _validateConfiguration();
    final expiresAt = _accessTokenExpiresAt;
    if (_accessToken != null &&
        expiresAt != null &&
        DateTime.now().isBefore(expiresAt)) {
      return _accessToken!;
    }

    final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));
    final response = await _send(
      () => _client.post(
        _uri('/v1/oauth2/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials',
      ),
    );
    final payload = _decodeSuccess(
      response,
      expectedStatuses: const {200},
      failureType: PayPalFailureType.authentication,
    );
    final token = _requiredString(payload, 'access_token');
    final expiresIn = payload['expires_in'];
    if (expiresIn is! num) {
      throw const PayPalException(
        type: PayPalFailureType.invalidResponse,
        message: 'paypal_missing_token_expiry',
      );
    }
    _accessToken = token;
    _accessTokenExpiresAt = DateTime.now().add(
      Duration(seconds: max(0, expiresIn.toInt() - 60)),
    );
    return token;
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request();
    } on PayPalException {
      rethrow;
    } catch (error) {
      throw PayPalException(
        type: PayPalFailureType.network,
        message: 'paypal_network_error',
      );
    }
  }

  Map<String, dynamic> _decodeSuccess(
    http.Response response, {
    required Set<int> expectedStatuses,
    PayPalFailureType failureType = PayPalFailureType.declined,
    bool allowEmptyBody = false,
  }) {
    Map<String, dynamic>? payload;
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) payload = decoded;
      } on FormatException {
        if (expectedStatuses.contains(response.statusCode)) {
          throw const PayPalException(
            type: PayPalFailureType.invalidResponse,
            message: 'paypal_invalid_json',
          );
        }
      }
    }

    if (!expectedStatuses.contains(response.statusCode)) {
      final type = response.statusCode == 401
          ? PayPalFailureType.authentication
          : failureType;
      throw PayPalException(
        type: type,
        message: payload?['message'] as String? ?? 'paypal_request_failed',
        statusCode: response.statusCode,
        debugId: payload?['debug_id'] as String?,
      );
    }
    if (allowEmptyBody && response.body.isEmpty) return const {};
    if (payload == null) {
      throw const PayPalException(
        type: PayPalFailureType.invalidResponse,
        message: 'paypal_invalid_response',
      );
    }
    return payload;
  }

  Uri _approvalUrl(Map<String, dynamic> payload) {
    final links = payload['links'];
    if (links is List) {
      for (final link in links) {
        if (link is! Map) continue;
        final relation = link['rel'];
        if (relation != 'payer-action' && relation != 'approve') continue;
        final href = link['href'];
        if (href is String) {
          final uri = Uri.tryParse(href);
          if (uri != null &&
              uri.scheme == 'https' &&
              (uri.host == 'paypal.com' || uri.host.endsWith('.paypal.com'))) {
            return uri;
          }
        }
      }
    }
    throw const PayPalException(
      type: PayPalFailureType.invalidResponse,
      message: 'paypal_missing_approval_url',
    );
  }

  Map<String, dynamic> _firstAuthorization(Map<String, dynamic> payload) {
    final purchaseUnits = payload['purchase_units'];
    if (purchaseUnits is List && purchaseUnits.isNotEmpty) {
      final purchaseUnit = purchaseUnits.first;
      if (purchaseUnit is Map) {
        final payments = purchaseUnit['payments'];
        if (payments is Map) {
          final authorizations = payments['authorizations'];
          if (authorizations is List && authorizations.isNotEmpty) {
            final authorization = authorizations.first;
            if (authorization is Map) {
              return Map<String, dynamic>.from(authorization);
            }
          }
        }
      }
    }
    throw const PayPalException(
      type: PayPalFailureType.invalidResponse,
      message: 'paypal_missing_authorization',
    );
  }

  String _requiredString(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is String && value.isNotEmpty) return value;
    throw PayPalException(
      type: PayPalFailureType.invalidResponse,
      message: 'paypal_missing_$key',
    );
  }

  Map<String, String> _jsonHeaders(String token, {String? requestId}) => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
    'PayPal-Request-Id': ?requestId,
  };

  Uri _uri(String path) => Uri.parse('$apiBaseUrl$path');

  String _money(double amount) {
    if (!amount.isFinite || amount <= 0) {
      throw const PayPalException(
        type: PayPalFailureType.configuration,
        message: 'paypal_invalid_amount',
      );
    }
    return amount.toStringAsFixed(2);
  }

  void _validateConfiguration() {
    if (clientId.isEmpty ||
        clientSecret.isEmpty ||
        clientId.startsWith('YOUR_') ||
        clientSecret.startsWith('YOUR_')) {
      throw const PayPalException(
        type: PayPalFailureType.configuration,
        message: 'paypal_sandbox_not_configured',
      );
    }
  }

  String _newRequestId(String operation) {
    final random = Random.secure();
    final suffix = List.generate(
      16,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
    return 'bike-$operation-$suffix';
  }

  String _stableRequestId(String operation, String providerId) {
    final safeId = providerId.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    return 'bike-$operation-$safeId';
  }

  @override
  void close() {
    if (_ownsClient) _client.close();
  }
}

const appCurrencyCode = 'MYR';

abstract final class PayPalSandboxConstants {
  // Sandbox-only prototype. Anything in lib/ is recoverable from the APK.
  // Never place production PayPal credentials in this file.
  static const clientId = 'Af5DjATo63xumm2FtjmtEiVVIGJx7hA1XpnPFWZUqb3VFIKzob2Xqlpo-Jw0U5TafCatk04lK7_5vMtQ';
  static const clientSecret = 'YOUR_PAYPAL_SANDBOX_CLIENT_SECRET';

  static const apiBaseUrl = 'https://api-m.sandbox.paypal.com';
  static const currencyCode = 'MYR';
  static const returnUrl = 'https://bike-renting-app.invalid/paypal/approved';
  static const cancelUrl = 'https://bike-renting-app.invalid/paypal/cancelled';

  static bool get isConfigured =>
      clientId.isNotEmpty &&
      clientSecret.isNotEmpty &&
      !clientId.startsWith('YOUR_') &&
      !clientSecret.startsWith('YOUR_');
}

import 'package:bike_renting_app/data/paypal/paypal_locale.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum PayPalCheckoutResult { approved, cancelled }

PayPalCheckoutResult? paypalCheckoutResultForUrl(
  Uri url, {
  String returnUrl = PayPalSandboxConstants.returnUrl,
  String cancelUrl = PayPalSandboxConstants.cancelUrl,
}) {
  bool matches(String target) {
    final targetUri = Uri.parse(target);
    return url.scheme == targetUri.scheme &&
        url.host == targetUri.host &&
        url.path == targetUri.path;
  }

  if (matches(returnUrl)) return PayPalCheckoutResult.approved;
  if (matches(cancelUrl)) return PayPalCheckoutResult.cancelled;
  return null;
}

class PayPalCheckoutPage extends StatefulWidget {
  const PayPalCheckoutPage({
    super.key,
    required this.approvalUrl,
    this.initialLocale,
    @visibleForTesting this.customWebView,
  });

  final Uri approvalUrl;
  final PayPalLocale? initialLocale;
  final Widget? customWebView;

  @override
  State<PayPalCheckoutPage> createState() => _PayPalCheckoutPageState();
}

class _PayPalCheckoutPageState extends State<PayPalCheckoutPage> {
  late final WebViewController _webViewController;
  late PayPalLocale _currentLocale;
  int _progress = 0;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _currentLocale =
        widget.initialLocale ?? PayPalLocaleService.resolveClientLocale();
    final localizedUrl = PayPalLocaleService.applyLocaleToUrl(
      widget.approvalUrl,
      _currentLocale.webCode,
    );
    if (widget.customWebView == null) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (progress) {
              if (mounted) setState(() => _progress = progress);
            },
            onUrlChange: (change) => _checkUrl(change.url),
            onPageStarted: (url) => _checkUrl(url),
            onNavigationRequest: (request) {
              final url = Uri.tryParse(request.url);
              if (url == null) return NavigationDecision.prevent;
              final result = paypalCheckoutResultForUrl(url);
              if (result != null) {
                _finish(result);
                return NavigationDecision.prevent;
              }
              return url.scheme == 'https'
                  ? NavigationDecision.navigate
                  : NavigationDecision.prevent;
            },
          ),
        )
        ..loadRequest(
          localizedUrl,
          headers: PayPalLocaleService.buildHeaders(_currentLocale.bcp47),
        );
    }
  }

  void _checkUrl(String? urlString) {
    if (urlString == null) return;
    final url = Uri.tryParse(urlString);
    if (url == null) return;
    final result = paypalCheckoutResultForUrl(url);
    if (result != null) {
      _finish(result);
    }
  }

  void _finish(PayPalCheckoutResult result) {
    if (_completed || !mounted) return;
    _completed = true;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish(PayPalCheckoutResult.cancelled);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: context.l10n.cancelRental,
            onPressed: () => _finish(PayPalCheckoutResult.cancelled),
            icon: const Icon(Icons.close_rounded),
          ),
          title: Text(context.l10n.paypalCheckoutTitle),
          actions: [
            if (kDebugMode)
              TextButton.icon(
                key: const ValueKey('debug-paypal-approve-button'),
                onPressed: () => _finish(PayPalCheckoutResult.approved),
                icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                label: const Text('Approve', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
          ],
          bottom: _progress < 100
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: LinearProgressIndicator(
                    value: _progress == 0 ? null : _progress / 100,
                    minHeight: 3,
                  ),
                )
              : null,
        ),
        body: SafeArea(
          child: ColoredBox(
            color: scheme.surface,
            child: Semantics(
              label: context.l10n.paypalCheckoutSemantics,
              container: true,
              child: widget.customWebView ??
                  WebViewWidget(controller: _webViewController),
            ),
          ),
        ),
      ),
    );
  }
}

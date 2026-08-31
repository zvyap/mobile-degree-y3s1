import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/paypal_sandbox_constants.dart';
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
  const PayPalCheckoutPage({super.key, required this.approvalUrl});

  final Uri approvalUrl;

  @override
  State<PayPalCheckoutPage> createState() => _PayPalCheckoutPageState();
}

class _PayPalCheckoutPageState extends State<PayPalCheckoutPage> {
  late final WebViewController _webViewController;
  int _progress = 0;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
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
      ..loadRequest(widget.approvalUrl);
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
              child: WebViewWidget(controller: _webViewController),
            ),
          ),
        ),
      ),
    );
  }
}

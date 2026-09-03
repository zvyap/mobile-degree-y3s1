import 'package:bike_renting_app/features/legal/legal_content.dart';
import 'package:bike_renting_app/features/legal/legal_document_page.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({
    super.key,
    this.showAgreeButton = false,
    this.agreeButtonText = 'Agree',
    this.onAgree,
    this.onBack,
  });

  final bool showAgreeButton;
  final String agreeButtonText;
  final VoidCallback? onAgree;
  final VoidCallback? onBack;

  static Future<bool?> open(
    BuildContext context, {
    bool showAgreeButton = false,
    String agreeButtonText = 'Agree',
    VoidCallback? onAgree,
    VoidCallback? onBack,
    bool rootNavigator = true,
  }) {
    return Navigator.of(context, rootNavigator: rootNavigator).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PrivacyPolicyPage(
          showAgreeButton: showAgreeButton,
          agreeButtonText: agreeButtonText,
          onAgree: onAgree,
          onBack: onBack,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LegalDocumentPage(
      documentData: LegalContent.privacyPolicy,
      showAgreeButton: showAgreeButton,
      agreeButtonText: agreeButtonText,
      onAgree: onAgree,
      onBack: onBack,
    );
  }
}

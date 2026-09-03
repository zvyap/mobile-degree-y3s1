import 'package:bike_renting_app/features/legal/legal_content.dart';
import 'package:bike_renting_app/shared/ui_components.dart';
import 'package:flutter/material.dart';

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({
    super.key,
    required this.documentData,
    this.showAgreeButton = false,
    this.agreeButtonText = 'Agree',
    this.onAgree,
    this.onBack,
  });

  final LegalDocumentData documentData;
  final bool showAgreeButton;
  final String agreeButtonText;
  final VoidCallback? onAgree;
  final VoidCallback? onBack;

  void _handleAgree(BuildContext context) {
    if (onAgree != null) {
      onAgree!();
    } else {
      Navigator.of(context).pop(true);
    }
  }

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
    } else {
      Navigator.of(context).maybePop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      key: ValueKey<String>('legal-doc-${documentData.title.toLowerCase().replaceAll(' ', '-')}'),
      appBar: AppBar(
        leading: IconButton(
          key: const ValueKey<String>('legal-back-button'),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () => _handleBack(context),
        ),
        title: Text(
          documentData.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (showAgreeButton)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: FilledButton(
                  key: const ValueKey<String>('legal-agree-button'),
                  onPressed: () => _handleAgree(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(64, 40),
                    tapTargetSize: MaterialTapTargetSize.padded,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    agreeButtonText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: ListView(
          key: const ValueKey<String>('legal-document-list'),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // Header Hero Box
            _HeaderHero(
              data: documentData,
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // Document Sections
            ...documentData.sections.asMap().entries.map((entry) {
              final section = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _SectionCard(
                  section: section,
                  isDark: isDark,
                ),
              );
            }),

            const SizedBox(height: 8),

            // Footer / Agreement Notice
            if (showAgreeButton)
              _AgreementFooter(
                title: documentData.title,
                agreeButtonText: agreeButtonText,
                onAgree: () => _handleAgree(context),
              )
            else
              _InformationalFooter(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

class _HeaderHero extends StatelessWidget {
  const _HeaderHero({
    required this.data,
    required this.isDark,
  });

  final LegalDocumentData data;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: isDark ? 0.3 : 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  data.badgeText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                data.icon,
                color: scheme.primary,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 14,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  data.lastUpdated,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.overview,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.82),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.isDark,
  });

  final LegalSection section;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SurfacePanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            section.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),

          // Paragraphs
          for (final paragraph in section.paragraphs) ...[
            Text(
              paragraph,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.85),
                height: 1.55,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Bullet Points
          if (section.bulletPoints.isNotEmpty) ...[
            const SizedBox(height: 4),
            for (final bullet in section.bulletPoints)
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 8),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        bullet,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.85),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],

          // Callout Banner
          if (section.calloutText != null) ...[
            const SizedBox(height: 8),
            _CalloutBox(
              text: section.calloutText!,
              icon: section.calloutIcon ?? Icons.info_outline_rounded,
              type: section.calloutType,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }
}

class _CalloutBox extends StatelessWidget {
  const _CalloutBox({
    required this.text,
    required this.icon,
    required this.type,
    required this.isDark,
  });

  final String text;
  final IconData icon;
  final LegalCalloutType type;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final Color tintColor = switch (type) {
      LegalCalloutType.warning => Colors.amber.shade700,
      LegalCalloutType.info => scheme.primary,
      LegalCalloutType.note => scheme.secondary,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tintColor.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: tintColor.withValues(alpha: isDark ? 0.35 : 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: tintColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.9),
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgreementFooter extends StatelessWidget {
  const _AgreementFooter({
    required this.title,
    required this.agreeButtonText,
    required this.onAgree,
  });

  final String title;
  final String agreeButtonText;
  final VoidCallback onAgree;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: scheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Agreement Confirmation',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'By tapping "$agreeButtonText" above or below, you acknowledge that you have reviewed and accept these $title.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              key: const ValueKey<String>('legal-bottom-agree-button'),
              onPressed: onAgree,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(
                '$agreeButtonText & Continue',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationalFooter extends StatelessWidget {
  const _InformationalFooter({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail_outline_rounded,
              size: 16,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
            const SizedBox(width: 6),
            Text(
              'Questions? Contact support@bikerent.app',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:bike_renting_app/features/renting/renting_models.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class RideWarningBanner extends StatelessWidget {
  const RideWarningBanner({
    super.key,
    required this.warning,
    this.onTap,
  });

  final ActiveRideWarning warning;
  final VoidCallback? onTap;

  String _title(BuildContext context) {
    final l10n = context.l10n;
    return switch (warning.type) {
      RideWarningType.depositExceeded => l10n.rideWarningDepositExceededTitle,
      RideWarningType.doubleDepositLegalAction =>
        l10n.rideWarningLegalActionTitle,
      RideWarningType.suspiciousActivity =>
        l10n.rideWarningSuspiciousActivityTitle,
      RideWarningType.suspiciousLegalAction =>
        l10n.rideWarningSuspiciousLegalTitle,
    };
  }

  String _message(BuildContext context) {
    final l10n = context.l10n;
    return switch (warning.type) {
      RideWarningType.depositExceeded => l10n.rideWarningDepositExceededBody,
      RideWarningType.doubleDepositLegalAction =>
        l10n.rideWarningLegalActionBody,
      RideWarningType.suspiciousActivity =>
        l10n.rideWarningSuspiciousActivityBody,
      RideWarningType.suspiciousLegalAction =>
        l10n.rideWarningSuspiciousLegalBody,
    };
  }

  IconData _icon() => switch (warning.type) {
    RideWarningType.depositExceeded => Icons.warning_amber_rounded,
    RideWarningType.doubleDepositLegalAction => Icons.gavel_rounded,
    RideWarningType.suspiciousActivity => Icons.warning_amber_rounded,
    RideWarningType.suspiciousLegalAction => Icons.gavel_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCritical = warning.severity == RideWarningSeverity.critical;

    final Color backgroundColor;
    final Color borderColor;
    final Color accentColor;
    final Color textColor;
    final Color subtitleColor;

    if (isCritical) {
      // Red: Legal action / severe violation
      final scheme = theme.colorScheme;
      backgroundColor = isDark
          ? scheme.errorContainer.withValues(alpha: 0.40)
          : scheme.errorContainer.withValues(alpha: 0.70);
      borderColor = scheme.error;
      accentColor = scheme.error;
      textColor = scheme.onErrorContainer;
      subtitleColor = scheme.onErrorContainer.withValues(alpha: 0.88);
    } else {
      // Orange: Warning / Deposit exceeded / Suspicious activity
      backgroundColor = isDark
          ? const Color(0xFF431407).withValues(alpha: 0.60)
          : const Color(0xFFFFF7ED);
      borderColor = isDark ? const Color(0xFFFB923C) : const Color(0xFFF97316);
      accentColor = isDark ? const Color(0xFFFDBA74) : const Color(0xFFC2410C);
      textColor = isDark ? const Color(0xFFFED7AA) : const Color(0xFF7C2D12);
      subtitleColor = isDark
          ? const Color(0xFFFED7AA).withValues(alpha: 0.85)
          : const Color(0xFF9A3412);
    }

    final title = _title(context);
    final message = _message(context);

    final bannerContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              _icon(),
              size: 22,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  key: const ValueKey<String>('ride-warning-title'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  key: const ValueKey<String>('ride-warning-message'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: subtitleColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: accentColor.withValues(alpha: 0.8),
            ),
          ],
        ],
      ),
    );

    return Semantics(
      liveRegion: true,
      container: true,
      label: '$title. $message',
      button: onTap != null,
      child: Material(
        color: Colors.transparent,
        child: onTap != null
            ? InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onTap,
                child: bannerContent,
              )
            : bannerContent,
      ),
    );
  }
}

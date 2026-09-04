part of '../renting_flow_page.dart';

class _BikeCheckStage extends StatelessWidget {
  const _BikeCheckStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      children: [
        SurfacePanel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StageTitle(
                icon: Icons.verified_rounded,
                title: context.l10n.bikeReady,
                subtitle: context.l10n.bikeReadyDescription,
              ),
              const SizedBox(height: 12),
              _ReservationTimerBadge(controller: controller),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.secondary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    IconTile(
                      icon: Icons.electric_bike_rounded,
                      color: scheme.secondary,
                      size: 44,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.bike!.id,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            context.l10n.bikeBatteryLocation(
                              controller.bike!.batteryPercent,
                              controller.startStation!.name,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      key: const ValueKey<String>('rent-bike-view'),
                      style: _secondaryTextButtonStyle(context),
                      onPressed: () {
                        final bikeCode = controller.bike?.id;
                        if (bikeCode != null) {
                          Navigator.of(context).pushNamed(
                            AppPage.bikeDetail.routeName,
                            arguments: bikeCode,
                          );
                        }
                      },
                      child: Text(context.l10n.view),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _CheckRow(label: context.l10n.brakesSafe),
              _CheckRow(label: context.l10n.frameSafe),
              _CheckRow(label: context.l10n.lightsSafe),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  key: const ValueKey<String>('rent-report-issue-bike-check'),
                  style: _dangerTextButtonStyle(context),
                  onPressed: () {
                    final bikeCode = controller.bike?.id;
                    if (bikeCode != null) {
                      Navigator.of(context).pushNamed(
                        AppPage.bikeReport.routeName,
                        arguments: bikeCode,
                      );
                    }
                  },
                  icon: const Icon(Icons.report_problem_outlined),
                  label: Text(context.l10n.reportBikeIssue),
                ),
              ),
              const SizedBox(height: 12),
              _FareCalculationPanel(controller: controller),
              const SizedBox(height: 12),
              _DepositSummaryTile(controller: controller),
              const SizedBox(height: 14),
              const _TermsAndPrivacyNotice(),
              const SizedBox(height: 14),
              _ActionButton(
                key: const ValueKey('rent-review-hold'),
                label: context.l10n.reviewHold(
                  context.formats.currency(controller.holdAmount),
                ),
                icon: Icons.account_balance_wallet_rounded,
                onPressed: controller.reviewAuthorization,
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  key: const ValueKey('rent-cancel'),
                  style: _secondaryTextButtonStyle(context),
                  onPressed: controller.reset,
                  icon: const Icon(Icons.close_rounded),
                  label: Text(context.l10n.cancelRental),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TermsAndPrivacyNotice extends StatefulWidget {
  const _TermsAndPrivacyNotice();

  @override
  State<_TermsAndPrivacyNotice> createState() => _TermsAndPrivacyNoticeState();
}

class _TermsAndPrivacyNoticeState extends State<_TermsAndPrivacyNotice> {
  late final TapGestureRecognizer _tosRecognizer;
  late final TapGestureRecognizer _ppRecognizer;

  @override
  void initState() {
    super.initState();
    _tosRecognizer = TapGestureRecognizer()
      ..onTap = () {
        TermsOfServicePage.open(context);
      };
    _ppRecognizer = TapGestureRecognizer()
      ..onTap = () {
        PrivacyPolicyPage.open(context);
      };
  }

  @override
  void dispose() {
    _tosRecognizer.dispose();
    _ppRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final linkStyle = textTheme.bodySmall?.copyWith(
      color: colorScheme.primary,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
      decorationColor: colorScheme.primary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text.rich(
        TextSpan(
          text:
              'By proceeding with the renting process, you are considered to accept and clear the ',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
          children: [
            TextSpan(
              text: 'Terms & Condition',
              style: linkStyle,
              recognizer: _tosRecognizer,
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: linkStyle,
              recognizer: _ppRecognizer,
            ),
            const TextSpan(text: ' of the app.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

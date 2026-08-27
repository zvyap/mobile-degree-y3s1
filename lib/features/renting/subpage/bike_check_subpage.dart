part of '../renting_flow_page.dart';

class _BikeCheckStage extends StatelessWidget {
  const _BikeCheckStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final method = controller.selectedPaymentMethod!;

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
                            controller.bike.id,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            context.l10n.bikeBatteryLocation(
                              controller.bike.batteryPercent,
                              _stationName(
                                context.l10n,
                                controller.stations[0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      key: const ValueKey<String>('rent-bike-view'),
                      style: _secondaryTextButtonStyle(context),
                      onPressed: () {},
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
                  onPressed: () {},
                  icon: const Icon(Icons.report_problem_outlined),
                  label: Text(context.l10n.reportBikeIssue),
                ),
              ),
              const SizedBox(height: 12),
              const _FareCalculationPanel(),
              const SizedBox(height: 12),
              _PaymentMethodTile(method: method),
              const SizedBox(height: 18),
              _ActionButton(
                key: const ValueKey('rent-review-hold'),
                label: context.l10n.reviewHold(
                  context.formats.currency(RentingController.holdAmount),
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
        const SizedBox(height: 8),
        Text(
          context.l10n.holdExplanation,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

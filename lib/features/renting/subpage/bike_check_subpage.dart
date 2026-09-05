part of '../renting_flow_page.dart';

class _BikeCheckStage extends StatefulWidget {
  const _BikeCheckStage({required this.controller});

  final RentingController controller;

  @override
  State<_BikeCheckStage> createState() => _BikeCheckStageState();
}

class _BikeCheckStageState extends State<_BikeCheckStage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.fetchBikeReports();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _BikeCheckStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller.sessionBikeId != widget.controller.sessionBikeId) {
      widget.controller.fetchBikeReports();
    }
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'chain_gears':
        return 'Chain & gears';
      case 'qr_lock':
        return 'QR & lock';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final activeReports =
        controller.bikeReports.where((r) => r.isActive).toList();
    final brakesReports = activeReports
        .where((r) => r.category == 'brakes' || r.category == 'tyres')
        .toList();
    final frameReports =
        activeReports.where((r) => r.category == 'seat_frame').toList();
    final lightsReports =
        activeReports.where((r) => r.category == 'bell_lights').toList();

    // Group remaining categories (e.g. chain_gears, qr_lock, other)
    final otherReportsByCategory = <String, List<BikeReport>>{};
    for (final report in activeReports) {
      if (report.category != 'brakes' &&
          report.category != 'tyres' &&
          report.category != 'seat_frame' &&
          report.category != 'bell_lights') {
        otherReportsByCategory
            .putIfAbsent(report.category, () => [])
            .add(report);
      }
    }

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
                          if (controller.startStation?.isUnderMaintenance == true) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF97316).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFF97316),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.build_circle_outlined,
                                    size: 14,
                                    color: Color(0xFFF97316),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      context.l10n.stationUnderMaintenance,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: const Color(0xFFF97316),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (controller.isLoadingBikeReports) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.checkingBikeCondition,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
              ],
              _ConditionCheckRow(
                key: const ValueKey('rent-check-brakes'),
                isSafe: brakesReports.isEmpty,
                safeLabel: context.l10n.brakesSafe,
                issueLabel: context.l10n.brakesIssueReported(brakesReports.length),
                issueReports: brakesReports,
              ),
              _ConditionCheckRow(
                key: const ValueKey('rent-check-frame'),
                isSafe: frameReports.isEmpty,
                safeLabel: context.l10n.frameSafe,
                issueLabel: context.l10n.frameIssueReported(frameReports.length),
                issueReports: frameReports,
              ),
              _ConditionCheckRow(
                key: const ValueKey('rent-check-lights'),
                isSafe: lightsReports.isEmpty,
                safeLabel: context.l10n.lightsSafe,
                issueLabel: context.l10n.lightsIssueReported(lightsReports.length),
                issueReports: lightsReports,
              ),
              for (final entry in otherReportsByCategory.entries) ...[
                _ConditionCheckRow(
                  key: ValueKey('rent-check-issue-${entry.key}'),
                  isSafe: false,
                  safeLabel: '',
                  issueLabel: '${_categoryLabel(entry.key)}: ${entry.value.length == 1 ? "1 issue reported" : "${entry.value.length} issues reported"}',
                  issueReports: entry.value,
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  key: const ValueKey<String>('rent-report-issue-bike-check'),
                  style: _dangerTextButtonStyle(context),
                  onPressed: () async {
                    await Navigator.of(context).pushNamed(
                      AppPage.reportForm.routeName,
                      arguments: controller.sessionBikeId,
                    );
                    if (context.mounted) {
                      controller.fetchBikeReports();
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
              if (controller.error != null) ...[
                const SizedBox(height: 14),
                _ErrorPanel(message: _rentalError(context, controller)),
              ] else if (controller.startStation?.isUnderMaintenance == true ||
                  controller.startStation?.isTerminated == true) ...[
                const SizedBox(height: 14),
                _ErrorPanel(
                  message: controller.startStation?.isUnderMaintenance == true
                      ? context.l10n.errorStationMaintenance(
                          controller.startStation?.name ?? '',
                        )
                      : context.l10n.errorStationTerminated(
                          controller.startStation?.name ?? '',
                        ),
                ),
              ] else if (BikeBatteryGuard.isTooLow(controller.bike?.batteryPercent)) ...[
                const SizedBox(height: 14),
                _ErrorPanel(
                  message: context.l10n.errorBikeLowBattery(
                    controller.bikeCode,
                    controller.bike?.batteryPercent ?? 0,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              const _TermsAndPrivacyNotice(),
              const SizedBox(height: 14),
              _ActionButton(
                key: const ValueKey('rent-review-hold'),
                label: context.l10n.reviewHold(
                  context.formats.currency(controller.holdAmount),
                ),
                icon: Icons.account_balance_wallet_rounded,
                onPressed: (controller.startStation?.isUnderMaintenance == true ||
                        controller.startStation?.isTerminated == true ||
                        BikeBatteryGuard.isTooLow(controller.bike?.batteryPercent) ||
                        controller.error != null)
                    ? null
                    : () async {
                        final canProceed = await guardBikeBattery(
                          context,
                          controller: controller,
                          batteryPercent: controller.bike?.batteryPercent,
                          bikeCode: controller.bike?.id,
                        );
                        if (canProceed) {
                          controller.reviewAuthorization();
                        }
                      },
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
          text: context.l10n.termsNoticePrefix,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
          children: [
            TextSpan(
              text: context.l10n.termsOfService,
              style: linkStyle,
              recognizer: _tosRecognizer,
            ),
            TextSpan(text: context.l10n.termsNoticeMiddle),
            TextSpan(
              text: context.l10n.privacyPolicy,
              style: linkStyle,
              recognizer: _ppRecognizer,
            ),
            TextSpan(text: context.l10n.termsNoticeSuffix),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ConditionCheckRow extends StatelessWidget {
  const _ConditionCheckRow({
    super.key,
    required this.isSafe,
    required this.safeLabel,
    required this.issueLabel,
    this.issueReports = const [],
  });

  final bool isSafe;
  final String safeLabel;
  final String issueLabel;
  final List<BikeReport> issueReports;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (isSafe) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 21,
              color: scheme.secondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                safeLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    const warningColor = Color(0xFFEA580C);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: warningColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: warningColor.withValues(alpha: 0.40),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 20,
              color: warningColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issueLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: warningColor,
                  ),
                ),
                for (final report in issueReports) ...[
                  const SizedBox(height: 2),
                  Text(
                    report.description.trim().isNotEmpty
                        ? report.description.trim()
                        : (report.status == 'approved'
                            ? 'Confirmed issue'
                            : 'Pending review'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}


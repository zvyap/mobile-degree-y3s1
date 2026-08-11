import 'package:bike_renting_app/features/history/ride_history_models.dart';
import 'package:bike_renting_app/l10n/app_formats.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/shared/ui_components.dart';
import 'package:flutter/material.dart';

class RideDetailsPage extends StatelessWidget {
  const RideDetailsPage({super.key, required this.ride});

  final RideHistoryEntry ride;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalInset = constraints.maxWidth > 920
            ? (constraints.maxWidth - 860) / 2
            : 16.0;

        return ListView(
          key: const ValueKey<String>('ride-details-page'),
          padding: EdgeInsets.fromLTRB(horizontalInset, 8, horizontalInset, 24),
          children: [
            _CompletionSummary(ride: ride),
            const SizedBox(height: 16),
            _SectionTitle(title: context.l10n.journeyDetails),
            const SizedBox(height: 8),
            _JourneyPanel(ride: ride),
            const SizedBox(height: 16),
            _SectionTitle(title: context.l10n.rideSummary),
            const SizedBox(height: 8),
            _RideSummaryPanel(ride: ride),
            const SizedBox(height: 16),
            _SectionTitle(title: context.l10n.paymentDetails),
            const SizedBox(height: 8),
            _PaymentPanel(
              key: const ValueKey<String>('ride-detail-payment-panel'),
              ride: ride,
            ),
          ],
        );
      },
    );
  }
}

class _CompletionSummary extends StatelessWidget {
  const _CompletionSummary({required this.ride});

  final RideHistoryEntry ride;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SurfacePanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: scheme.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.check_rounded,
                color: scheme.secondary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.rideCompleted,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${context.formats.date(ride.startedAt)} · '
                  '${context.formats.time(ride.startedAt)}',
                  softWrap: true,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.68),
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  ride.rideId,
                  key: const ValueKey<String>('ride-detail-id'),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _JourneyPanel extends StatelessWidget {
  const _JourneyPanel({required this.ride});

  final RideHistoryEntry ride;

  @override
  Widget build(BuildContext context) {
    return SurfacePanel(
      child: Column(
        children: [
          _DetailRow(
            key: const ValueKey<String>('ride-detail-from'),
            icon: Icons.trip_origin_rounded,
            label: context.l10n.from,
            value: ride.startStation.label(context.l10n),
            supporting: context.l10n.departedAt(
              context.formats.time(ride.startedAt),
            ),
          ),
          const Divider(height: 20),
          _DetailRow(
            key: const ValueKey<String>('ride-detail-to'),
            icon: Icons.location_on_rounded,
            label: context.l10n.to,
            value: ride.endStation.label(context.l10n),
            supporting: context.l10n.arrivedAt(
              context.formats.time(ride.endedAt),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.supporting,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? supporting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconTile(icon: icon, color: scheme.primary, size: 40),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                softWrap: true,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (supporting != null) ...[
                const SizedBox(height: 2),
                Text(
                  supporting!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.68),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RideSummaryPanel extends StatelessWidget {
  const _RideSummaryPanel({required this.ride});

  final RideHistoryEntry ride;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _Metric(
        icon: Icons.timer_outlined,
        label: context.l10n.duration,
        value: context.formats.duration(ride.durationSeconds),
      ),
      _Metric(
        icon: Icons.straighten_rounded,
        label: context.l10n.distance,
        value: context.l10n.distanceKm(
          context.formats.decimal(ride.distanceKm, decimalDigits: 1),
        ),
      ),
      _Metric(
        icon: Icons.pedal_bike_rounded,
        label: context.l10n.bikeId,
        value: ride.bikeId,
      ),
    ];

    return SurfacePanel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          if (constraints.maxWidth < 320 || textScale > 1.3) {
            return Column(
              children: [
                for (var index = 0; index < metrics.length; index++) ...[
                  metrics[index],
                  if (index < metrics.length - 1) const Divider(height: 16),
                ],
              ],
            );
          }

          return IntrinsicHeight(
            child: Row(
              children: [
                for (var index = 0; index < metrics.length; index++) ...[
                  Expanded(child: metrics[index]),
                  if (index < metrics.length - 1)
                    const VerticalDivider(width: 1),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: scheme.primary, size: 19),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.68),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentPanel extends StatelessWidget {
  const _PaymentPanel({super.key, required this.ride});

  final RideHistoryEntry ride;

  @override
  Widget build(BuildContext context) {
    final payment = ride.payment;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SurfacePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.22)),
            ),
            child: Column(
              children: [
                _PaymentFlowRow(
                  label: context.l10n.depositHeld,
                  value: context.formats.currency(payment.deposit),
                ),
                const Divider(height: 18),
                _PaymentFlowRow(
                  label: context.l10n.rideFareFromDeposit,
                  value: context.formats.currency(payment.finalFare),
                ),
                const Divider(height: 18),
                _PaymentFlowRow(
                  label: context.l10n.depositRefunded,
                  value: context.formats.currency(payment.refundedDeposit),
                  valueColor: scheme.secondary,
                  strong: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _PriceRow(
            label: context.l10n.unlockFee,
            value: context.formats.currency(payment.unlockFee),
          ),
          const SizedBox(height: 10),
          _PriceRow(
            label: context.l10n.startedMinutes(payment.startedMinutes),
            value: context.formats.currency(payment.minuteCharge),
          ),
          const Divider(height: 24),
          _PriceRow(
            key: const ValueKey<String>('ride-detail-total-paid'),
            label: context.l10n.totalPaid,
            value: context.formats.currency(payment.finalFare),
            strong: true,
          ),
          const SizedBox(height: 10),
          _PriceRow(
            key: const ValueKey<String>('ride-detail-refund'),
            label: context.l10n.depositRefund,
            value: context.formats.currency(payment.refundedDeposit),
          ),
          const SizedBox(height: 10),
          _PriceRow(
            key: const ValueKey<String>('ride-detail-payment-method'),
            label: context.l10n.paymentMethod,
            value: payment.maskedPaymentMethod,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.depositPaymentExplanation,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.68),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentFlowRow extends StatelessWidget {
  const _PaymentFlowRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.strong = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, softWrap: true)),
        const SizedBox(width: 12),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: valueColor,
            fontWeight: strong ? FontWeight.w900 : FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    super.key,
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, softWrap: true, style: style)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            softWrap: true,
            style: style,
          ),
        ),
      ],
    );
  }
}

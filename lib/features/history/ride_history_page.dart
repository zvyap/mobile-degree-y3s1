import 'package:bike_renting_app/data/database/database_data_source.dart';
import 'package:bike_renting_app/data/repositories/rental_repository.dart';
import 'package:bike_renting_app/features/history/ride_history_models.dart';
import 'package:bike_renting_app/l10n/app_formats.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/shared/ui_components.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RideHistoryPage extends StatefulWidget {
  const RideHistoryPage({super.key, required this.onRideSelected});

  final ValueChanged<RideHistoryEntry> onRideSelected;

  @override
  State<RideHistoryPage> createState() => _RideHistoryPageState();
}

class _RideHistoryPageState extends State<RideHistoryPage> {
  late Future<List<RideHistoryEntry>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  Future<List<RideHistoryEntry>> _loadHistory() async {
    final client = Supabase.instance.client;
    final repository = RentalRepository(SupabaseDatabaseDataSource(client));
    final records = await repository.listHistory();
    return records.map(RideHistoryEntry.fromDatabase).toList(growable: false);
  }

  Future<void> _refresh() async {
    final nextHistory = _loadHistory();
    setState(() => _historyFuture = nextHistory);
    await nextHistory;
  }

  void _retry() {
    setState(() => _historyFuture = _loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RideHistoryEntry>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final horizontalInset = constraints.maxWidth > 920
                ? (constraints.maxWidth - 860) / 2
                : 16.0;

            if (snapshot.connectionState != ConnectionState.done) {
              return _HistoryStatusView(
                horizontalInset: horizontalInset,
                child: const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (snapshot.hasError) {
              return _HistoryStatusView(
                horizontalInset: horizontalInset,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 38,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Ride history could not be loaded.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _retry,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return _buildHistory(
              context,
              horizontalInset,
              snapshot.data ?? const [],
            );
          },
        );
      },
    );
  }

  Widget _buildHistory(
    BuildContext context,
    double horizontalInset,
    List<RideHistoryEntry> rides,
  ) {
    final totalDistance = rides.fold<double>(
      0,
      (total, ride) => total + ride.distanceKm,
    );
    final totalSpent = rides.fold<double>(
      0,
      (total, ride) => total + ride.payment.finalFare,
    );

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        key: const ValueKey<String>('ride-history-page'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(horizontalInset, 8, horizontalInset, 24),
        children: [
          SectionHeader(
            title: context.l10n.rideHistory,
            subtitle: context.l10n.rideHistoryDescription,
          ),
          const SizedBox(height: 14),
          _HistorySummary(
            rideCount: rides.length,
            totalDistance: totalDistance,
            totalSpent: totalSpent,
          ),
          const SizedBox(height: 18),
          Text(
            context.l10n.pastRides,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          SurfacePanel(
            padding: EdgeInsets.zero,
            child: rides.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No completed rides yet.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Column(
                    key: const ValueKey<String>('ride-history-list'),
                    children: [
                      for (var index = 0; index < rides.length; index++) ...[
                        _RideHistoryRow(
                          ride: rides[index],
                          onTap: () => widget.onRideSelected(rides[index]),
                        ),
                        if (index < rides.length - 1)
                          Divider(
                            height: 1,
                            color: Theme.of(context).colorScheme.outline,
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

class _HistoryStatusView extends StatelessWidget {
  const _HistoryStatusView({
    required this.horizontalInset,
    required this.child,
  });

  final double horizontalInset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey<String>('ride-history-page'),
      padding: EdgeInsets.fromLTRB(horizontalInset, 8, horizontalInset, 24),
      children: [
        SectionHeader(
          title: context.l10n.rideHistory,
          subtitle: context.l10n.rideHistoryDescription,
        ),
        const SizedBox(height: 18),
        Text(
          context.l10n.pastRides,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        SurfacePanel(child: child),
      ],
    );
  }
}

class _HistorySummary extends StatelessWidget {
  const _HistorySummary({
    required this.rideCount,
    required this.totalDistance,
    required this.totalSpent,
  });

  final int rideCount;
  final double totalDistance;
  final double totalSpent;

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryMetric(
        icon: Icons.directions_bike_rounded,
        value: rideCount.toString(),
        label: context.l10n.totalRides,
      ),
      _SummaryMetric(
        icon: Icons.straighten_rounded,
        value: context.l10n.distanceKm(
          context.formats.decimal(totalDistance, decimalDigits: 1),
        ),
        label: context.l10n.totalDistance,
      ),
      _SummaryMetric(
        icon: Icons.account_balance_wallet_rounded,
        value: context.formats.currency(totalSpent),
        label: context.l10n.totalSpent,
      ),
    ];

    return SurfacePanel(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          if (constraints.maxWidth < 320 || textScale > 1.3) {
            return Column(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  items[index],
                  if (index < items.length - 1) const Divider(height: 16),
                ],
              ],
            );
          }

          return IntrinsicHeight(
            child: Row(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  Expanded(child: items[index]),
                  if (index < items.length - 1) const VerticalDivider(width: 1),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: scheme.primary),
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RideHistoryRow extends StatelessWidget {
  const _RideHistoryRow({required this.ride, required this.onTap});

  final RideHistoryEntry ride;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final date = context.formats.date(ride.startedAt);
    final time = context.formats.time(ride.startedAt);
    final duration = context.formats.duration(ride.durationSeconds);
    final distance = context.l10n.distanceKm(
      context.formats.decimal(ride.distanceKm, decimalDigits: 1),
    );
    final fare = context.formats.currency(ride.payment.finalFare);
    final from = ride.startStation;
    final to = ride.endStation;

    return Semantics(
      button: true,
      label: context.l10n.rideHistoryEntrySemantics(
        date,
        time,
        from,
        to,
        duration,
        distance,
        fare,
      ),
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey<String>('ride-history-${ride.rideId}'),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 116),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '$date · $time',
                          softWrap: true,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.70),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        fare,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: scheme.onSurface.withValues(alpha: 0.56),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _StationLine(label: context.l10n.from, station: from),
                  const SizedBox(height: 4),
                  _StationLine(label: context.l10n.to, station: to),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 12,
                    runSpacing: 5,
                    children: [
                      _RideMeta(icon: Icons.timer_outlined, label: duration),
                      _RideMeta(
                        icon: Icons.straighten_rounded,
                        label: distance,
                      ),
                      _RideMeta(
                        icon: Icons.pedal_bike_rounded,
                        label: ride.bikeId,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StationLine extends StatelessWidget {
  const _StationLine({required this.label, required this.station});

  final String label;
  final String station;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 42,
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.62),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            station,
            softWrap: true,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _RideMeta extends StatelessWidget {
  const _RideMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: scheme.onSurface.withValues(alpha: 0.62)),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.72),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

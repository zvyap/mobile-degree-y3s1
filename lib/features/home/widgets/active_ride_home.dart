import 'package:bike_renting_app/features/renting/renting_controller.dart';
import 'package:bike_renting_app/features/renting/renting_models.dart';
import 'package:bike_renting_app/l10n/app_formats.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/navigation/app_page.dart';
import 'package:bike_renting_app/shared/ui_components.dart';
import 'package:flutter/material.dart';

class ActiveRideHome extends StatefulWidget {
  const ActiveRideHome({
    super.key,
    required this.controller,
    required this.onOpenRide,
  });

  final RentingController controller;
  final VoidCallback onOpenRide;

  @override
  State<ActiveRideHome> createState() => _ActiveRideHomeState();
}

class _ActiveRideHomeState extends State<ActiveRideHome> {
  @override
  void initState() {
    super.initState();
    widget.controller.resumeTracking();
  }

  @override
  void didUpdateWidget(covariant ActiveRideHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller.resumeTracking();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final largeText = MediaQuery.textScalerOf(context).scale(14) > 18;

        return SurfacePanel(
          key: const ValueKey<String>('home-active-ride'),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (largeText)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RideIdentity(controller: controller),
                    const SizedBox(height: 8),
                    _GpsStatus(available: controller.gpsAvailable),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _RideIdentity(controller: controller)),
                    const SizedBox(width: 10),
                    _GpsStatus(available: controller.gpsAvailable),
                  ],
                ),
              const SizedBox(height: 12),
              _RideMetrics(controller: controller, stacked: largeText),
              const SizedBox(height: 12),
              if (largeText)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CurrentRideButton(onPressed: widget.onOpenRide),
                    const SizedBox(height: 8),
                    _ReportIssueButton(controller: controller),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(child: _CurrentRideButton(onPressed: widget.onOpenRide)),
                    const SizedBox(width: 8),
                    Expanded(child: _ReportIssueButton(controller: controller)),
                  ],
                ),
              const SizedBox(height: 9),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.health_and_safety_outlined,
                    size: 16,
                    color: scheme.onSurface.withValues(alpha: 0.58),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      context.l10n.phoneSafety,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.62),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RideIdentity extends StatelessWidget {
  const _RideIdentity({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: scheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                context.l10n.rideActive.toUpperCase(),
                softWrap: true,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.secondary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          controller.bikeCode,
          key: const ValueKey<String>('home-active-bike-code'),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          context.l10n.rideInProgress,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.66),
          ),
        ),
      ],
    );
  }
}

class _GpsStatus extends StatelessWidget {
  const _GpsStatus({required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = available ? scheme.secondary : scheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            available ? Icons.gps_fixed_rounded : Icons.gps_off_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            available ? context.l10n.gpsActive : context.l10n.gpsLost,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RideMetrics extends StatelessWidget {
  const _RideMetrics({required this.controller, required this.stacked});

  final RentingController controller;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _RideMetric(
        label: context.l10n.time,
        value: context.formats.duration(controller.metrics.elapsedSeconds),
      ),
      _RideMetric(
        label: context.l10n.distance,
        value: context.l10n.distanceKm(
          context.formats.decimal(controller.metrics.distanceKm),
        ),
      ),
      _RideMetric(
        label: context.l10n.estimated,
        value: context.formats.currency(controller.estimatedFare),
      ),
    ];

    if (stacked) {
      return Column(
        children: [
          for (var index = 0; index < metrics.length; index++) ...[
            metrics[index],
            if (index < metrics.length - 1) const SizedBox(height: 7),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var index = 0; index < metrics.length; index++) ...[
          Expanded(child: metrics[index]),
          if (index < metrics.length - 1) const SizedBox(width: 7),
        ],
      ],
    );
  }
}

class _RideMetric extends StatelessWidget {
  const _RideMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.62),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentRideButton extends StatelessWidget {
  const _CurrentRideButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      key: const ValueKey<String>('home-current-ride'),
      onPressed: onPressed,
      icon: const Icon(Icons.directions_bike_rounded),
      label: Text(context.l10n.currentRide),
    );
  }
}

class _ReportIssueButton extends StatelessWidget {
  const _ReportIssueButton({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      key: const ValueKey<String>('home-report-issue'),
      style: OutlinedButton.styleFrom(foregroundColor: scheme.error),
      onPressed: () => Navigator.of(context).pushNamed(
        AppPage.reportForm.routeName,
        arguments: controller.sessionBikeId,
      ),
      icon: const Icon(Icons.report_problem_outlined),
      label: Text(context.l10n.reportBikeIssue),
    );
  }
}

class ActiveReturnStationPreview extends StatelessWidget {
  const ActiveReturnStationPreview({
    super.key,
    required this.stations,
    required this.onViewAll,
  });

  final List<ReturnStation> stations;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final station = _nearestAvailableStation();

    return Column(
      key: const ValueKey<String>('home-active-return-station'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.nearestReturnStation,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(onPressed: onViewAll, child: Text(context.l10n.viewAll)),
          ],
        ),
        Divider(height: 1, color: scheme.outline.withValues(alpha: 0.76)),
        if (station == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              context.l10n.returnStationUnavailable,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.66),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
              children: [
                Icon(Icons.location_on_rounded, color: scheme.secondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        station.distanceMeters == null
                            ? ''
                            : context.l10n.stationDistance(station.distanceMeters!),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.dockCount(station.availableDocks),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  ReturnStation? _nearestAvailableStation() {
    ReturnStation? nearest;
    for (final station in stations) {
      if (station.availableDocks <= 0) continue;
      final distance = station.distanceMeters;
      if (nearest == null ||
          (distance != null &&
              (nearest.distanceMeters == null ||
                  distance < nearest.distanceMeters!))) {
        nearest = station;
      }
    }
    return nearest;
  }
}

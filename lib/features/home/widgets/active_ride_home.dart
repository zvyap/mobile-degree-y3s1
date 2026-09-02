import 'package:bike_renting_app/features/renting/renting_controller.dart';
import 'package:bike_renting_app/features/renting/renting_models.dart';
import 'package:bike_renting_app/l10n/app_formats.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/shared/app_toast.dart';
import 'package:bike_renting_app/shared/ui_components.dart';
import 'package:flutter/material.dart';

class ActiveRideHome extends StatelessWidget {
  const ActiveRideHome({
    super.key,
    required this.controller,
    required this.onOpenRide,
  });

  final RentingController controller;
  final VoidCallback onOpenRide;

  @override
  Widget build(BuildContext context) {
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
                _CurrentRideButton(onPressed: onOpenRide),
                const SizedBox(height: 8),
                _ReportIssueButton(controller: controller),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _CurrentRideButton(onPressed: onOpenRide)),
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
      onPressed: () => showRideIssueSheet(
        context,
        bikeCode: controller.bikeCode,
        onSubmit: controller.noteRideIssue,
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
                        context.l10n.stationDistance(station.distanceMeters),
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
      if (nearest == null || station.distanceMeters < nearest.distanceMeters) {
        nearest = station;
      }
    }
    return nearest;
  }
}

Future<void> showRideIssueSheet(
  BuildContext context, {
  required String bikeCode,
  required void Function(RentalIssueType type, String note) onSubmit,
}) async {
  final result = await showModalBottomSheet<_RideIssueResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => _RideIssueSheet(bikeCode: bikeCode),
  );

  if (result != null && context.mounted) {
    onSubmit(result.type, result.note);
    AppToast.show(
      context,
      title: context.l10n.issueNoted,
      message: context.l10n.issueNotSent,
      variant: AppToastVariant.warning,
    );
  }
}

class _RideIssueSheet extends StatefulWidget {
  const _RideIssueSheet({required this.bikeCode});

  final String bikeCode;

  @override
  State<_RideIssueSheet> createState() => _RideIssueSheetState();
}

class _RideIssueSheetState extends State<_RideIssueSheet> {
  final _noteController = TextEditingController();
  RentalIssueType? _selectedIssue;
  bool _showValidation = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final labels = {
      RentalIssueType.brakes: context.l10n.issueBrakes,
      RentalIssueType.tyres: context.l10n.issueTyres,
      RentalIssueType.lights: context.l10n.issueLights,
      RentalIssueType.lock: context.l10n.issueLock,
      RentalIssueType.other: context.l10n.issueOther,
    };

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        18,
        0,
        18,
        18 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        key: const ValueKey<String>('ride-issue-sheet'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.reportBikeIssue,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.reportingBike(widget.bikeCode),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.66),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            context.l10n.chooseIssueType,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in labels.entries)
                ChoiceChip(
                  key: ValueKey<String>('ride-issue-${entry.key.name}'),
                  label: Text(entry.value),
                  selected: _selectedIssue == entry.key,
                  onSelected: (_) => setState(() {
                    _selectedIssue = entry.key;
                    _showValidation = false;
                  }),
                ),
            ],
          ),
          if (_showValidation) ...[
            const SizedBox(height: 8),
            Text(
              context.l10n.chooseIssueTypeError,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            key: const ValueKey<String>('ride-issue-note'),
            controller: _noteController,
            minLines: 2,
            maxLines: 4,
            maxLength: 240,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: context.l10n.issueNoteOptional,
              hintText: context.l10n.issueNoteHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.tertiary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 19,
                  color: scheme.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.issueSessionOnly,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const ValueKey<String>('ride-issue-submit'),
              onPressed: _submit,
              icon: const Icon(Icons.check_rounded),
              label: Text(context.l10n.noteIssue),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_selectedIssue == null) {
      setState(() => _showValidation = true);
      return;
    }
    Navigator.of(
      context,
    ).pop(_RideIssueResult(type: _selectedIssue!, note: _noteController.text));
  }
}

class _RideIssueResult {
  const _RideIssueResult({required this.type, required this.note});

  final RentalIssueType type;
  final String note;
}

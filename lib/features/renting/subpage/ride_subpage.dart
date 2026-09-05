part of '../renting_flow_page.dart';

class _RideStage extends StatelessWidget {
  const _RideStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final availableStations =
        controller.stations.where((station) => station.canAcceptReturn);
    final nearestStation = availableStations.firstOrNull ??
        controller.stations.where((s) => !s.isUnderMaintenance).firstOrNull ??
        controller.stations.firstOrNull;
    final otherNearbyStations = nearestStation == null
        ? const <ReturnStation>[]
        : controller.stations
            .where((station) => station.id != nearestStation.id)
            .take(3)
            .toList(growable: false);
    return Column(
      children: [
        SurfacePanel(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StageTitle(
                      icon: Icons.navigation_rounded,
                      title: context.l10n.rideActive,
                      subtitle: context.l10n.rideActiveDescription,
                    ),
                  ),
                  _StatusPill(
                    label: controller.gpsAvailable
                        ? context.l10n.gpsActive
                        : context.l10n.gpsLost,
                    icon: controller.gpsAvailable
                        ? Icons.gps_fixed_rounded
                        : Icons.gps_off_rounded,
                    color: controller.gpsAvailable
                        ? scheme.secondary
                        : scheme.error,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _RideSessionMap(
                stations: controller.stations,
                riderLocation: controller.riderLatLng,
                riderHeading: controller.riderHeading,
                routePoints: controller.rideRoutePoints,
                nearestStation: nearestStation,
              ),
              if (controller.isOverdue ||
                  (controller.timeUntilDeadline != null &&
                      controller.timeUntilDeadline! <=
                          const Duration(minutes: 30))) ...[
                const SizedBox(height: 10),
                _RideDeadlineBanner(controller: controller),
              ],
              if (controller.error != null) ...[
                const SizedBox(height: 10),
                _ErrorPanel(
                  message: _rentalError(context, controller),
                  actionLabel: context.l10n.restoreGps,
                  onAction: () => controller.setGpsAvailable(true),
                ),
              ],
              const SizedBox(height: 10),
              _MetricGrid(
                children: [
                  _MetricValue(
                    label: context.l10n.time,
                    value: context.formats.duration(
                      controller.metrics.elapsedSeconds,
                    ),
                  ),
                  _MetricValue(
                    label: context.l10n.distance,
                    value: context.l10n.distanceKm(
                      context.formats.decimal(controller.metrics.distanceKm),
                    ),
                  ),
                  _MetricValue(
                    label: context.l10n.estimated,
                    value: context.formats.currency(controller.estimatedFare),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _ActionButton(
                key: const ValueKey('rent-find-station'),
                label: context.l10n.returnBike,
                icon: Icons.assignment_return_rounded,
                onPressed: controller.findReturnStation,
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  key: const ValueKey<String>('rent-report-issue-active'),
                  style: _dangerTextButtonStyle(context),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppPage.reportForm.routeName,
                      arguments: controller.sessionBikeId,
                    );
                  },
                  icon: const Icon(Icons.report_problem_outlined),
                  label: Text(context.l10n.reportBikeIssue),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (controller.startStation != null) ...[
          StationPlaceholderRow(
            station: <String, dynamic>{
              'id': controller.startStation!.id,
              'name': _stationName(context.l10n, controller.startStation!),
              'address': controller.startStation!.distanceMeters == null
                  ? ''
                  : context.l10n.stationDistance(
                      controller.startStation!.distanceMeters!,
                    ),
              'status': controller.startStation!.status,
            },
            isOrigin: true,
            showEdit: false,
            defaultTitle: context.l10n.originStation,
            defaultSubtitle: context.l10n.tripStartedHere,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 4.0, bottom: 4.0),
            child: Icon(
              Icons.arrow_downward_rounded,
              color: scheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
          ),
        ],
        StationPlaceholderRow(
          key: const ValueKey<String>('rent-nearest-station'),
          station: nearestStation != null
              ? <String, dynamic>{
                  'id': nearestStation.id,
                  'name': _stationName(context.l10n, nearestStation),
                  'address': nearestStation.distanceMeters == null
                      ? ''
                      : context.l10n.stationDistance(
                          nearestStation.distanceMeters!,
                        ),
                  'status': nearestStation.status,
                }
              : null,
          isOrigin: false,
          showEdit: false,
          defaultTitle: context.l10n.nearestReturnStation,
          defaultSubtitle: context.l10n.chooseReturnStationDescription,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            context.l10n.otherNearbyStations,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 6),
        for (final station in otherNearbyStations) ...[
          _NearbyStationRow(station: station),
          const SizedBox(height: 6),
        ],
        Text(
          context.l10n.phoneSafety,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _RideDeadlineBanner extends StatelessWidget {
  const _RideDeadlineBanner({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final overdue = controller.isOverdue;
    final remaining = controller.timeUntilDeadline;
    final headline = overdue
        ? context.l10n.rideOverdueTitle
        : context.l10n.rideDeadlineCountdown(
            remaining == null ? 0 : remaining.inMinutes.clamp(0, 1 << 31),
          );
    final contentColor = overdue ? scheme.onErrorContainer : scheme.secondary;
    final canExtend = controller.extensionsRemaining > 0;

    return Container(
      key: const ValueKey<String>('rent-deadline-banner'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: overdue ? scheme.errorContainer : scheme.secondary.withValues(alpha: 0.08),
        border: Border.all(
          color: overdue ? scheme.error : scheme.secondary.withValues(alpha: 0.72),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                overdue ? Icons.warning_amber_rounded : Icons.schedule_rounded,
                color: contentColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  headline,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: overdue ? scheme.onErrorContainer : null,
                  ),
                ),
              ),
            ],
          ),
          if (overdue) ...[
            const SizedBox(height: 6),
            Text(
              context.l10n.rideOverdueBody,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              key: const ValueKey<String>('rent-extend-ride'),
              onPressed: canExtend && !controller.isBusy
                  ? controller.extendRide
                  : null,
              icon: const Icon(Icons.more_time_rounded),
              label: Text(
                canExtend
                    ? context.l10n.extendRide(controller.extensionsRemaining)
                    : context.l10n.noExtensionsLeft,
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NearbyStationRow extends StatelessWidget {
  const _NearbyStationRow({required this.station});

  final ReturnStation station;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isMaintenance = station.isUnderMaintenance;
    final available = station.canAcceptReturn;
    final statusColor = isMaintenance
        ? const Color(0xFFF97316)
        : (available ? scheme.secondary : scheme.error);

    return Container(
      key: ValueKey<String>('rent-nearby-station-${station.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isMaintenance
            ? const Color(0xFFF97316).withValues(alpha: 0.08)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.36),
        border: Border.all(
          color: isMaintenance
              ? const Color(0xFFF97316)
              : scheme.outline.withValues(alpha: 0.6),
          width: isMaintenance ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            isMaintenance
                ? Icons.build_circle_outlined
                : (available ? Icons.local_parking_rounded : Icons.block_rounded),
            color: statusColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _stationName(context.l10n, station),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (isMaintenance) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFFF97316),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          context.l10n.stationUnderMaintenance,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFFF97316),
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (station.distanceMeters != null) ...[
                  Text(
                    context.l10n.stationDistance(station.distanceMeters!),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isMaintenance
                ? context.l10n.stationUnderMaintenance
                : (available
                    ? context.l10n.dockCount(station.availableDocks)
                    : context.l10n.full),
            style: theme.textTheme.labelMedium?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

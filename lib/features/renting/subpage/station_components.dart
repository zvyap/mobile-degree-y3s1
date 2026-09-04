part of '../renting_flow_page.dart';

class _StationTile extends StatelessWidget {
  const _StationTile({
    required this.station,
    required this.selected,
    required this.onTap,
  });

  final ReturnStation station;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final available = station.availableDocks > 0;
    final selectable = available;
    final highlighted = selected || selectable;
    final selectionLabel = selected
        ? context.l10n.selected
        : selectable
        ? context.l10n.selectable
        : null;
    final badgeColor = available ? scheme.secondary : scheme.error;

    Widget buildBadge(String label, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return Semantics(
      selected: selected,
      button: true,
      enabled: available,
      child: Material(
        color: selected
            ? scheme.secondary.withValues(alpha: 0.09)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          key: ValueKey<String>('rent-station-${station.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: highlighted
                    ? scheme.secondary
                    : scheme.outline.withValues(alpha: 0.6),
                width: highlighted ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Icon(
                  available ? Icons.local_parking_rounded : Icons.block_rounded,
                  color: available ? scheme.primary : scheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _stationName(context.l10n, station),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        context.l10n.stationDistance(station.distanceMeters),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (selectionLabel != null) ...[
                      buildBadge(selectionLabel, badgeColor),
                      const SizedBox(height: 4),
                    ],
                    buildBadge(
                      available
                          ? context.l10n.dockCount(station.availableDocks)
                          : context.l10n.full,
                      badgeColor,
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                  tooltip: 'Station details',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StationDetailScreen(
                          stationData: {
                            'id': station.backendId,
                            'name': station.name,
                            'address': station.name,
                            'latitude': station.latitude,
                            'longitude': station.longitude,
                            'available_bikes': 0,
                            'capacity': station.availableDocks,
                            'status': 'Normal',
                          },
                          isViewOnly: true,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReturnStationMap extends BaseStationMapView {
  _ReturnStationMap({
    required this.stations,
    required this.selectedStation,
    required this.onSelectStation,
    required this.isAtStation,
  }) : super(
          isEmbedded: true,
          height: 200,
          selectedStationId: selectedStation?.id,
          geofenceRadiusMeters: 250,
          initialCenter: selectedStation != null
              ? LatLng(selectedStation.latitude, selectedStation.longitude)
              : null,
          showHeader: false,
          showRecenterButton: true,
        );

  final List<ReturnStation> stations;
  final ReturnStation? selectedStation;
  final ValueChanged<ReturnStation> onSelectStation;
  final bool isAtStation;

  @override
  BaseStationMapViewState<_ReturnStationMap> createState() =>
      _ReturnStationMapState();
}

class _ReturnStationMapState
    extends BaseStationMapViewState<_ReturnStationMap> {
  @override
  void initState() {
    super.initState();
    _syncReturnStations();
  }

  @override
  void didUpdateWidget(covariant _ReturnStationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stations != oldWidget.stations ||
        widget.selectedStation != oldWidget.selectedStation) {
      _syncReturnStations();
    }
  }

  void _syncReturnStations() {
    setState(() {
      stations = widget.stations
          .map((s) => {
                'id': s.id,
                'backendId': s.backendId,
                'name': s.name,
                'latitude': s.latitude,
                'longitude': s.longitude,
                'status': s.availableDocks > 0 ? 'Normal' : 'Under Maintenance',
                'available_bikes': 0,
                'capacity': s.availableDocks,
                'distance_meters': s.distanceMeters,
              })
          .toList(growable: false);
      selectedStation = widget.selectedStation != null
          ? stations.firstWhere(
              (s) => s['id'] == widget.selectedStation!.id,
              orElse: () => {},
            )
          : null;
    });
  }

  @override
  void handleStationTap(String stationId) {
    final matched = widget.stations.cast<ReturnStation?>().firstWhere(
          (s) => s?.id == stationId,
          orElse: () => null,
        );
    if (matched != null) {
      widget.onSelectStation(matched);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.cityMapSemantics,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: double.infinity,
          height: widget.height ?? 200,
          child: Stack(
            children: [
              Positioned.fill(child: buildMapLayer(context)),
              if (widget.showRecenterButton)
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: buildRecenterButton(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityMap extends StatelessWidget {
  const _CityMap({
    required this.routeProgress,
    required this.selectedStation,
    required this.atStation,
  });

  final double routeProgress;
  final ReturnStation? selectedStation;
  final bool atStation;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: context.l10n.cityMapSemantics,
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: _CityMapPainter(
            background: scheme.surfaceContainerHighest,
            road: scheme.outline.withValues(alpha: 0.65),
            route: scheme.primary,
            station: scheme.secondary,
            rider: scheme.tertiary,
            progress: routeProgress,
            selectedStationId: selectedStation?.id,
            atStation: atStation,
          ),
          child: const SizedBox(width: double.infinity, height: 180),
        ),
      ),
    );
  }
}

class _CityMapPainter extends CustomPainter {
  const _CityMapPainter({
    required this.background,
    required this.road,
    required this.route,
    required this.station,
    required this.rider,
    required this.progress,
    required this.selectedStationId,
    required this.atStation,
  });

  final Color background;
  final Color road;
  final Color route;
  final Color station;
  final Color rider;
  final double progress;
  final String? selectedStationId;
  final bool atStation;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    final roadPaint = Paint()
      ..color = road
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final y in [0.22, 0.52, 0.82]) {
      canvas.drawLine(
        Offset(0, size.height * y),
        Offset(size.width, size.height * y),
        roadPaint,
      );
    }
    for (final x in [0.18, 0.48, 0.78]) {
      canvas.drawLine(
        Offset(size.width * x, 0),
        Offset(size.width * x, size.height),
        roadPaint,
      );
    }

    final routePath = Path()
      ..moveTo(size.width * 0.08, size.height * 0.80)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.62,
        size.width * 0.34,
        size.height * 0.30,
        size.width * 0.55,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.63,
        size.width * 0.80,
        size.height * 0.27,
        size.width * 0.92,
        size.height * 0.18,
      );
    canvas.drawPath(
      routePath,
      Paint()
        ..color = route.withValues(alpha: 0.30)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      routePath,
      Paint()
        ..color = route
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final metrics = routePath.computeMetrics().first;
    final riderOffset = metrics
        .getTangentForOffset(metrics.length * progress.clamp(0, 1))!
        .position;
    canvas.drawCircle(
      riderOffset,
      12,
      Paint()..color = rider.withValues(alpha: 0.22),
    );
    canvas.drawCircle(riderOffset, 6, Paint()..color = rider);
    canvas.drawCircle(riderOffset, 3, Paint()..color = Colors.white);

    final stationPoints = <String, Offset>{
      'central': Offset(size.width * 0.92, size.height * 0.18),
      'riverside': Offset(size.width * 0.50, size.height * 0.82),
      'market': Offset(size.width * 0.78, size.height * 0.52),
      'university': Offset(size.width * 0.20, size.height * 0.36),
    };
    for (final entry in stationPoints.entries) {
      final selected = entry.key == selectedStationId;
      canvas.drawCircle(
        entry.value,
        selected ? 12 : 9,
        Paint()..color = station.withValues(alpha: selected ? 0.25 : 0.16),
      );
      canvas.drawCircle(
        entry.value,
        selected ? 7 : 5,
        Paint()..color = station,
      );
    }

    if (atStation && selectedStationId != null) {
      final point = stationPoints[selectedStationId];
      if (point != null) {
        canvas.drawCircle(
          point,
          18,
          Paint()
            ..color = station
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CityMapPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedStationId != selectedStationId ||
        oldDelegate.atStation != atStation ||
        oldDelegate.background != background;
  }
}

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
    final isMaintenance = station.isUnderMaintenance;
    final available = station.canAcceptReturn;
    final selectable = available;
    final highlighted = selected || (selectable && !isMaintenance);
    final selectionLabel = isMaintenance
        ? context.l10n.stationUnderMaintenance
        : (selected
            ? context.l10n.selected
            : selectable
                ? context.l10n.selectable
                : null);
    final badgeColor = isMaintenance
        ? const Color(0xFFF97316)
        : (available ? scheme.secondary : scheme.error);

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
      enabled: available && !isMaintenance,
      child: Material(
        color: isMaintenance
            ? const Color(0xFFF97316).withValues(alpha: 0.08)
            : (selected
                ? scheme.secondary.withValues(alpha: 0.09)
                : scheme.surfaceContainerHighest.withValues(alpha: 0.36)),
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
                color: isMaintenance
                    ? const Color(0xFFF97316)
                    : (highlighted
                        ? scheme.secondary
                        : scheme.outline.withValues(alpha: 0.6)),
                width: isMaintenance ? 2 : (highlighted ? 2 : 1),
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Icon(
                  isMaintenance
                      ? Icons.build_circle_outlined
                      : (available ? Icons.local_parking_rounded : Icons.block_rounded),
                  color: isMaintenance
                      ? const Color(0xFFF97316)
                      : (available ? scheme.primary : scheme.error),
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
                      isMaintenance
                          ? context.l10n.stationUnderMaintenance
                          : (available
                              ? context.l10n.dockCount(station.availableDocks)
                              : context.l10n.full),
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
                            'available_bikes': station.availableBikes,
                            'capacity': station.capacity,
                            'status': station.status,
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
    super.riderLocation,
    super.riderHeading,
  }) : super(
          isEmbedded: true,
          height: 200,
          trackLiveLocation: true,
          showDirectionIndicator: true,
          selectedStationId: selectedStation?.id,
          geofenceRadiusMeters: 250,
          initialCenter: selectedStation != null
              ? LatLng(selectedStation.latitude, selectedStation.longitude)
              : riderLocation,
          showHeader: false,
          showRecenterButton: true,
          initialStations: stations
              .where((s) => !s.isTerminated)
              .map<Map<String, dynamic>>((s) => <String, dynamic>{
                    'id': s.id,
                    'backendId': s.backendId,
                    'name': s.name,
                    'latitude': s.latitude,
                    'longitude': s.longitude,
                    'status': s.isUnderMaintenance
                        ? 'Under Maintenance'
                        : 'Normal',
                    'available_bikes': s.availableBikes,
                    'capacity': s.capacity,
                    'distance_meters': s.distanceMeters,
                  })
              .toList(growable: false),
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
  final GlobalKey<SharedBikeMapState> _mapTileKey =
      GlobalKey<SharedBikeMapState>();
  OsrmRouteResult? routeResult;
  bool isCalculating = false;
  bool isRouteTooFar = false;

  @override
  void initState() {
    super.initState();
    _syncReturnStations();
    if (widget.selectedStation != null) {
      _calculateRoute();
    }
  }

  @override
  void didUpdateWidget(covariant _ReturnStationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stations != oldWidget.stations ||
        widget.selectedStation != oldWidget.selectedStation) {
      _syncReturnStations();
    }
    if (widget.selectedStation != oldWidget.selectedStation ||
        widget.riderLocation != oldWidget.riderLocation) {
      _calculateRoute();
    }
  }

  void _syncReturnStations() {
    setState(() {
      stations = widget.stations
          .where((s) => !s.isTerminated)
          .map<Map<String, dynamic>>((s) => <String, dynamic>{
                'id': s.id,
                'backendId': s.backendId,
                'name': s.name,
                'latitude': s.latitude,
                'longitude': s.longitude,
                'status': s.isUnderMaintenance
                    ? 'Under Maintenance'
                    : 'Normal',
                'available_bikes': s.availableBikes,
                'capacity': s.capacity,
                'distance_meters': s.distanceMeters,
              })
          .toList(growable: false);
      selectedStation = widget.selectedStation != null
          ? stations
              .where((s) => s['id'] == widget.selectedStation!.id)
              .firstOrNull
          : null;
    });
  }

  Future<void> _calculateRoute() async {
    final target = widget.selectedStation;
    if (target == null) {
      if (mounted) {
        setState(() {
          routeResult = null;
          isCalculating = false;
          isRouteTooFar = false;
        });
      }
      return;
    }

    final LatLng? start = widget.riderLocation ?? userLocation;
    if (start == null) return;

    if (mounted) {
      setState(() {
        isCalculating = true;
        isRouteTooFar = false;
      });
    }

    final end = LatLng(target.latitude, target.longitude);
    OsrmRouteResult? result = await OsrmService.fetchBikingRoute(start, end);

    if (!mounted) return;

    // Fallback to direct path calculation if offline or OSRM route is unavailable
    if (result == null) {
      final directDist = Geolocator.distanceBetween(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );
      final estSeconds = directDist / 4.16; // ~15 km/h biking estimate
      result = OsrmRouteResult(
        polylinePoints: [start, end],
        distanceMeters: directDist,
        durationSeconds: estSeconds,
      );
    }

    bool checkTooFar = false;
    if (result.distanceKm > 80.0 || result.durationMinutes > (24 * 60)) {
      checkTooFar = true;
    }

    setState(() {
      routeResult = result;
      isRouteTooFar = checkTooFar;
      isCalculating = false;
    });

    if (!checkTooFar && result.polylinePoints.isNotEmpty) {
      _mapTileKey.currentState?.fitBounds(
        result.polylinePoints,
        padding: const EdgeInsets.all(28.0),
      );
    }
  }

  @override
  void handleStationTap(String stationId) {
    final matched = widget.stations
        .where((s) => s.id == stationId)
        .firstOrNull;
    if (matched != null) {
      widget.onSelectStation(matched);
      _calculateRoute();
    }
  }

  @override
  Widget buildMapLayer(BuildContext context) {
    return SharedBikeMap(
      key: _mapTileKey,
      stations: stations,
      riderLocation: widget.riderLocation ?? userLocation,
      riderHeading: widget.riderHeading ?? userHeading,
      showDirectionIndicator: widget.showDirectionIndicator,
      trackLiveLocation: widget.trackLiveLocation,
      selectedStationId: widget.selectedStation?.id ??
          widget.selectedStationId ??
          selectedStation?['id']?.toString(),
      isAdminMode: widget.isAdminMode,
      geofenceRadiusMeters: widget.geofenceRadiusMeters,
      routePoints: isRouteTooFar
          ? null
          : routeResult?.polylinePoints ?? widget.routePoints,
      initialCenter: widget.initialCenter,
      initialZoom: widget.initialZoom,
      onStationTap: handleStationTap,
      onMapLongPress: widget.onMapLongPress,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selectedStationMap = widget.selectedStation != null
        ? <String, dynamic>{
            'id': widget.selectedStation!.id,
            'name': _stationName(context.l10n, widget.selectedStation!),
            'address': context.l10n.stationDistance(widget.selectedStation!.distanceMeters),
            'status': widget.selectedStation!.status,
          }
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
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
        ),
        const SizedBox(height: 10),
        StationPlaceholderRow(
          station: null,
          isOrigin: true,
          defaultTitle: 'Current Location',
          defaultSubtitle: 'Your GPS position',
          onEdit: recenterToGps,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 4.0, bottom: 4.0),
          child: Icon(
            Icons.arrow_downward_rounded,
            color: scheme.onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
        ),
        StationPlaceholderRow(
          key: const ValueKey<String>('rent-return-station-placeholder'),
          station: selectedStationMap,
          isOrigin: false,
          defaultTitle: context.l10n.nearestReturnStation,
          defaultSubtitle: context.l10n.chooseReturnStationDescription,
          onEdit: () {},
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.36),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.4)),
          ),
          child: StationRouteDisplay(
            isCalculating: isCalculating,
            isRouteTooFar: isRouteTooFar,
            routeResult: routeResult,
          ),
        ),
      ],
    );
  }
}


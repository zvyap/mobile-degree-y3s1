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


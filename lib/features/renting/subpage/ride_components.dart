part of '../renting_flow_page.dart';

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 300 || textScale > 1.3) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index < children.length - 1) const SizedBox(height: 8),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              Expanded(child: children[index]),
              if (index < children.length - 1) const SizedBox(width: 8),
            ],
          ],
        );
      },
    );
  }
}

class _MetricValue extends StatelessWidget {
  const _MetricValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _RideSessionMap extends BaseStationMapView {
  _RideSessionMap({
    required List<ReturnStation> stations,
    super.riderLocation,
    super.routePoints,
    ReturnStation? nearestStation,
  }) : super(
          isEmbedded: true,
          height: 200,
          initialCenter: riderLocation ??
              (stations.isNotEmpty
                  ? LatLng(stations.first.latitude, stations.first.longitude)
                  : null),
          selectedStationId: nearestStation?.id,
          geofenceRadiusMeters: nearestStation != null ? 250 : null,
          showHeader: false,
          showRecenterButton: true,
          initialStations: stations
              .map<Map<String, dynamic>>((s) => <String, dynamic>{
                    'id': s.id,
                    'backendId': s.backendId,
                    'name': s.name,
                    'latitude': s.latitude,
                    'longitude': s.longitude,
                    'status': s.availableDocks > 0
                        ? 'Normal'
                        : 'Under Maintenance',
                    'available_bikes': 0,
                    'capacity': s.availableDocks,
                    'distance_meters': s.distanceMeters,
                  })
              .toList(growable: false),
        );

  @override
  BaseStationMapViewState<_RideSessionMap> createState() =>
      _RideSessionMapState();
}

class _RideSessionMapState extends BaseStationMapViewState<_RideSessionMap> {
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

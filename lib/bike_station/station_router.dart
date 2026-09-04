import 'package:bike_renting_app/bike_station/osrm_service.dart';
import 'package:bike_renting_app/bike_station/shared_map.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class StationRoutePlannerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stations;
  final Map<String, dynamic>? initialOrigin;
  final Map<String, dynamic>? initialDestination;

  const StationRoutePlannerScreen({
    super.key,
    required this.stations,
    this.initialOrigin,
    this.initialDestination,
  });

  @override
  State<StationRoutePlannerScreen> createState() => _StationRoutePlannerScreenState();
}

class _StationRoutePlannerScreenState extends State<StationRoutePlannerScreen> {
  Map<String, dynamic>? originStation;
  Map<String, dynamic>? destinationStation;

  OsrmRouteResult? routeResult;
  bool isCalculating = false;

  @override
  void initState() {
    super.initState();
    if (widget.stations.isNotEmpty) {
      originStation = widget.initialOrigin ?? widget.stations.first;
      if (widget.stations.length > 1) {
        destinationStation = widget.initialDestination ?? widget.stations[1];
      }
    }
    _calculateRoute();
  }

  Future<void> _calculateRoute() async {
    if (originStation == null || destinationStation == null) return;

    final double? startLat = _toDouble(originStation!['latitude'] ?? originStation!['lat']);
    final double? startLng = _toDouble(originStation!['longitude'] ?? originStation!['lng']);
    final double? endLat = _toDouble(destinationStation!['latitude'] ?? destinationStation!['lat']);
    final double? endLng = _toDouble(destinationStation!['longitude'] ?? destinationStation!['lng']);

    if (startLat == null || startLng == null || endLat == null || endLng == null) return;

    setState(() => isCalculating = true);

    final start = LatLng(startLat, startLng);
    final end = LatLng(endLat, endLng);

    final result = await OsrmService.fetchBikingRoute(start, end);

    if (mounted) {
      setState(() {
        routeResult = result;
        isCalculating = false;
      });
    }
  }

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  String _formatEtaRange(int durationMinutes) {
    final now = DateTime.now();
    final arrival = now.add(Duration(minutes: durationMinutes));
    final timeFormat = DateFormat('h:mm');
    final amPmFormat = DateFormat('a');
    return "${timeFormat.format(now)} - ${timeFormat.format(arrival)} ${amPmFormat.format(arrival)}";
  }

  void _showStationPickerDialog(bool isOrigin) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: widget.stations.length,
          itemBuilder: (context, index) {
            final station = widget.stations[index];
            return ListTile(
              leading: Icon(Icons.location_on_outlined, color: colorScheme.primary),
              title: Text(
                station['name'] ?? 'Unnamed Station',
                style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                station['address'] ?? '',
                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  if (isOrigin) {
                    originStation = station;
                  } else {
                    destinationStation = station;
                  }
                });
                _calculateRoute();
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. MAP LAYER WITH OSRM POLYLINE ROUTE
          Positioned.fill(
            child: SharedBikeMap(
              stations: widget.stations,
              routePoints: routeResult?.polylinePoints,
            ),
          ),

          // 2. SEARCH BAR & BACK BUTTON
          Positioned(
            top: 50.0,
            left: 16.0,
            right: 16.0,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                        const SizedBox(width: 8),
                        Text(
                          "Search stations",
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. RECENTER FAB
          Positioned(
            right: 16.0,
            bottom: MediaQuery.of(context).size.height * 0.42 + 16.0,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2))
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.my_location, color: colorScheme.onSurface),
                onPressed: _calculateRoute,
              ),
            ),
          ),

          // 4. ROUTE INFORMATION BOTTOM SHEET
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.42,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, -4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle indicator bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // ORIGIN STATION ROW
                  _buildStationRow(
                    context: context,
                    station: originStation,
                    isOrigin: true,
                    onEdit: () => _showStationPickerDialog(true),
                  ),

                  // DOWNWARD CONNECTING ARROW
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 4.0, bottom: 4.0),
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),

                  // DESTINATION STATION ROW
                  _buildStationRow(
                    context: context,
                    station: destinationStation,
                    isOrigin: false,
                    onEdit: () => _showStationPickerDialog(false),
                  ),

                  const SizedBox(height: 16),
                  Divider(color: colorScheme.outline.withValues(alpha: 0.5), height: 1),
                  const SizedBox(height: 16),

                  // ETA AND DISTANCE METRICS
                  if (isCalculating)
                    const Center(child: CircularProgressIndicator.adaptive())
                  else if (routeResult != null) ...[
                    Text(
                      "Estimated Arrival Time (ETA)",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatEtaRange(routeResult!.durationMinutes),
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "${routeResult!.durationMinutes} minutes",
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Total Distance: ${routeResult!.distanceKm.toStringAsFixed(2)} km",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ] else
                    Text(
                      "Select two stations to calculate route.",
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationRow({
    required BuildContext context,
    required Map<String, dynamic>? station,
    required bool isOrigin,
    required VoidCallback onEdit,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.onSurface, width: 2),
          ),
          child: Icon(
            Icons.location_on,
            size: 20,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                station?['name'] ?? (isOrigin ? "Select Origin" : "Select Destination"),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                station?['address'] ?? "Tap edit to choose station",
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit_square, color: colorScheme.onSurface.withValues(alpha: 0.7)),
          onPressed: onEdit,
        ),
      ],
    );
  }
}
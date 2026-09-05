import 'dart:async';
import 'package:bike_renting_app/bike_station/base_station_map.dart';
import 'package:bike_renting_app/bike_station/shared_map.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  final GlobalKey<SharedBikeMapState> _mapTileKey = GlobalKey<SharedBikeMapState>();

  Map<String, dynamic>? originStation;
  Map<String, dynamic>? destinationStation;

  Position? userPosition;
  StreamSubscription<Position>? _positionSubscription;
  OsrmRouteResult? routeResult;
  bool isCalculating = false;
  bool isRouteTooFar = false;

  static const double _initialSheetExtent = 0.38;
  double _currentSheetExtent = _initialSheetExtent;

  @override
  void initState() {
    super.initState();
    originStation = widget.initialOrigin;
    destinationStation = widget.initialDestination;

    _getUserLocation();

    if (originStation != null && destinationStation != null) {
      _calculateRoute();
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (mounted) {
        setState(() {
          userPosition = pos;
        });
      }

      _positionSubscription?.cancel();
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 2,
        ),
      ).listen(
        (pos) {
          if (!mounted) return;
          setState(() {
            userPosition = pos;
          });
        },
        onError: (_) {},
      );
    } catch (e) {
      debugPrint("Error fetching user position: $e");
    }
  }

  Future<void> _calculateRoute() async {
    if (originStation == null || destinationStation == null) return;

    final double? startLat = _toDouble(originStation!['latitude'] ?? originStation!['lat']);
    final double? startLng = _toDouble(originStation!['longitude'] ?? originStation!['lng']);
    final double? endLat = _toDouble(destinationStation!['latitude'] ?? destinationStation!['lat']);
    final double? endLng = _toDouble(destinationStation!['longitude'] ?? destinationStation!['lng']);

    if (startLat == null || startLng == null || endLat == null || endLng == null) return;

    setState(() {
      isCalculating = true;
      isRouteTooFar = false;
    });

    final start = LatLng(startLat, startLng);
    final end = LatLng(endLat, endLng);

    final result = await OsrmService.fetchBikingRoute(start, end);

    if (mounted) {
      bool checkTooFar = false;

      if (result != null) {
        if (result.distanceKm > 80.0 || result.durationMinutes > (24 * 60)) {
          checkTooFar = true;
        }
      }

      setState(() {
        routeResult = result;
        isRouteTooFar = checkTooFar;
        isCalculating = false;
      });

      if (!checkTooFar && result != null && result.polylinePoints.isNotEmpty) {
        _mapTileKey.currentState?.fitBounds(
          result.polylinePoints,
          padding: const EdgeInsets.only(
            top: 120.0,
            bottom: 300.0,
            left: 60.0,
            right: 60.0,
          ),
        );
      }
    }
  }

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  void _showStationPickerDialog(bool isOrigin) {
    final colorScheme = Theme.of(context).colorScheme;

    String? excludedId;
    if (isOrigin) {
      if (destinationStation != null && destinationStation!['id'] != null) {
        excludedId = destinationStation!['id'].toString();
      }
    } else {
      if (originStation != null && originStation!['id'] != null) {
        excludedId = originStation!['id'].toString();
      }
    }

    final List<Map<String, dynamic>> eligibleStations = widget.stations.where((s) {
      final String? sId = s['id']?.toString();
      if (sId == null) return false;
      if (excludedId != null && sId == excludedId) return false;
      return true;
    }).toList();

    if (isOrigin) {
      if (userPosition != null) {
        eligibleStations.sort((a, b) {
          final double latA = _toDouble(a['latitude'] ?? a['lat']) ?? 0.0;
          final double lngA = _toDouble(a['longitude'] ?? a['lng']) ?? 0.0;
          final double distA = Geolocator.distanceBetween(
              userPosition!.latitude, userPosition!.longitude, latA, lngA);

          final double latB = _toDouble(b['latitude'] ?? b['lat']) ?? 0.0;
          final double lngB = _toDouble(b['longitude'] ?? b['lng']) ?? 0.0;
          final double distB = Geolocator.distanceBetween(
              userPosition!.latitude, userPosition!.longitude, latB, lngB);

          return distA.compareTo(distB);
        });
      }
    } else {
      if (originStation != null) {
        final double? oLat = _toDouble(originStation!['latitude'] ?? originStation!['lat']);
        final double? oLng = _toDouble(originStation!['longitude'] ?? originStation!['lng']);

        if (oLat != null && oLng != null) {
          eligibleStations.sort((a, b) {
            final double latA = _toDouble(a['latitude'] ?? a['lat']) ?? 0.0;
            final double lngA = _toDouble(a['longitude'] ?? a['lng']) ?? 0.0;
            final double distA = Geolocator.distanceBetween(oLat, oLng, latA, lngA);

            final double latB = _toDouble(b['latitude'] ?? b['lat']) ?? 0.0;
            final double lngB = _toDouble(b['longitude'] ?? b['lng']) ?? 0.0;
            final double distB = Geolocator.distanceBetween(oLat, oLng, latB, lngB);

            return distA.compareTo(distB);
          });
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _StationPickerBottomSheet(
          stations: eligibleStations,
          isOrigin: isOrigin,
          userPosition: userPosition,
          originStation: originStation,
          onSelected: (station) {
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double availableHeight = constraints.maxHeight;
          final double buttonBottom = (availableHeight * _currentSheetExtent) + 12.0;

          return Stack(
            children: [
              Positioned.fill(
                child: SharedBikeMap(
                  key: _mapTileKey,
                  stations: widget.stations,
                  riderLocation: userPosition != null ? LatLng(userPosition!.latitude, userPosition!.longitude) : null,
                  riderHeading: userPosition?.heading,
                  trackLiveLocation: true,
                  showDirectionIndicator: true,
                  routePoints: isRouteTooFar ? null : routeResult?.polylinePoints,
                  originStationId: originStation?['id']?.toString(),
                  destinationStationId: destinationStation?['id']?.toString(),
                ),
              ),
              Positioned(
                top: 50.0,
                left: 16.0,
                right: 16.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      Icon(Icons.alt_route_rounded, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Select origin & destination below to plan route",
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 16.0,
                bottom: buttonBottom,
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
              NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  setState(() {
                    _currentSheetExtent = notification.extent;
                  });
                  return true;
                },
                child: DraggableScrollableSheet(
                  initialChildSize: _initialSheetExtent,
                  minChildSize: 0.12,
                  maxChildSize: _initialSheetExtent,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, -4))
                        ],
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        physics: const ClampingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 5,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                StationPlaceholderRow(
                                  station: originStation,
                                  isOrigin: true,
                                  onEdit: () => _showStationPickerDialog(true),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0, top: 4.0, bottom: 4.0),
                                  child: Icon(
                                    Icons.arrow_downward_rounded,
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    size: 20,
                                  ),
                                ),
                                StationPlaceholderRow(
                                  station: destinationStation,
                                  isOrigin: false,
                                  onEdit: () => _showStationPickerDialog(false),
                                ),
                                const SizedBox(height: 16),
                                Divider(color: colorScheme.outline.withValues(alpha: 0.5), height: 1),
                                const SizedBox(height: 16),
                                StationRouteDisplay(
                                  isCalculating: isCalculating,
                                  isRouteTooFar: isRouteTooFar,
                                  routeResult: routeResult,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StationPickerBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> stations;
  final bool isOrigin;
  final Position? userPosition;
  final Map<String, dynamic>? originStation;
  final Function(Map<String, dynamic>) onSelected;

  const _StationPickerBottomSheet({
    required this.stations,
    required this.isOrigin,
    this.userPosition,
    this.originStation,
    required this.onSelected,
  });

  @override
  State<_StationPickerBottomSheet> createState() => _StationPickerBottomSheetState();
}

class _StationPickerBottomSheetState extends State<_StationPickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredStations = [];

  @override
  void initState() {
    super.initState();
    _filteredStations = widget.stations;
  }

  void _filter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredStations = widget.stations;
      } else {
        _filteredStations = widget.stations.where((s) {
          final name = (s['name'] ?? '').toString().toLowerCase();
          final address = (s['address'] ?? '').toString().toLowerCase();
          final code = (s['code'] ?? '').toString().toLowerCase();
          return name.contains(q) || address.contains(q) || code.contains(q);
        }).toList();
      }
    });
  }

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.88,
      builder: (context, scrollController) {
        return Column(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filter,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search station code, name or address...',
                  hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: colorScheme.primary, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                ),
              ),
            ),
            Expanded(
              child: _filteredStations.isEmpty
                  ? Center(
                child: Text(
                  "No matching stations found.",
                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
              )
                  : ListView.builder(
                controller: scrollController,
                itemCount: _filteredStations.length,
                itemBuilder: (context, index) {
                  final station = _filteredStations[index];
                  final lat = _toDouble(station['latitude'] ?? station['lat']);
                  final lng = _toDouble(station['longitude'] ?? station['lng']);

                  String distStr = '0.0 km';

                  if (widget.isOrigin) {
                    if (widget.userPosition != null && lat != null && lng != null) {
                      final meters = Geolocator.distanceBetween(
                        widget.userPosition!.latitude,
                        widget.userPosition!.longitude,
                        lat,
                        lng,
                      );
                      distStr = meters >= 1000
                          ? '${(meters / 1000).toStringAsFixed(1)} km away'
                          : '${meters.round()} m away';
                    }
                  } else {
                    if (widget.originStation != null) {
                      final oLat = _toDouble(widget.originStation!['latitude'] ?? widget.originStation!['lat']);
                      final oLng = _toDouble(widget.originStation!['longitude'] ?? widget.originStation!['lng']);

                      if (oLat != null && oLng != null && lat != null && lng != null) {
                        final meters = Geolocator.distanceBetween(
                          oLat,
                          oLng,
                          lat,
                          lng,
                        );
                        distStr = meters >= 1000
                            ? '${(meters / 1000).toStringAsFixed(1)} km away'
                            : '${meters.round()} m away';
                      }
                    }
                  }

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
                    trailing: Text(
                      distStr,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => widget.onSelected(station),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
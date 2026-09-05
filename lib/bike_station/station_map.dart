import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:bike_renting_app/bike_station/base_station_map.dart';
import 'package:bike_renting_app/bike_station/shared_map.dart';
import 'package:bike_renting_app/bike_station/station_details.dart';

export 'package:bike_renting_app/bike_station/base_station_map.dart';

class RefinedUserBikeView extends BaseStationMapView {
  final bool isAdminDeleteMode;
  final Function(Map<String, dynamic> station)? onRemoveStation;

  const RefinedUserBikeView({
    super.key,
    this.isAdminDeleteMode = false,
    this.onRemoveStation,
  }) : super(
    isAdminMode: isAdminDeleteMode,
    isEmbedded: false,
  );

  @override
  State<RefinedUserBikeView> createState() => _RefinedUserBikeViewState();
}

class _RefinedUserBikeViewState extends BaseStationMapViewState<RefinedUserBikeView> {
  final GlobalKey<SharedBikeMapState> _mapTileKey = GlobalKey<SharedBikeMapState>();
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  // 🟢 Increased minimum bounds to ensure contents fit without overflowing
  static const double _minSheetSize = 0.32;
  static const double _initialSheetSize = 0.38;
  static const double _maxSheetSize = 0.70;

  double _currentSheetExtent = _initialSheetSize;

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'under maintenance':
        return const Color(0xFFF97316); // Light Orange
      case 'terminated':
        return const Color(0xFFDC2626); // Red
      case 'normal':
      default:
        return const Color(0xFF10B981); // Green
    }
  }

  void _selectStation(Map<String, dynamic> station) {
    searchFocusNode.unfocus();
    setState(() {
      selectedStation = station;
      isSearching = false;
    });

    final double? lat = BaseStationMapViewState.toDouble(station['latitude'] ?? station['lat']);
    final double? lng = BaseStationMapViewState.toDouble(station['longitude'] ?? station['lng']);

    if (lat != null && lng != null) {
      _mapTileKey.currentState?.moveCameraToLocation(LatLng(lat, lng));
    }
  }

  Future<void> _deleteStation(Map<String, dynamic> station) async {
    try {
      final stationId = station['id'];

      final client = supabase;
      if (client != null) {
        await client.from('stations').update({
          'is_active': false,
          'status': 'Terminated',
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', stationId);
      }

      setState(() {
        if (selectedStation?['id'] == stationId) {
          selectedStation = null;
        }
        stations.removeWhere((s) => s['id'] == stationId);
        filteredStations.removeWhere((s) => s['id'] == stationId);
      });

      if (widget.onRemoveStation != null) {
        widget.onRemoveStation!(station);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${station['name']} deactivated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove station: $e')),
        );
      }
    }
  }

  void _openStationDetail(Map<String, dynamic> station) {
    searchFocusNode.unfocus();
    setState(() => isSearching = false);

    if (widget.isAdminDeleteMode) {
      _showDeleteConfirmationDialog(context, station, Theme.of(context), Theme.of(context).colorScheme, const Color(0xFFDC2626));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StationDetailScreen(
            stationData: station,
            isViewOnly: true,
          ),
        ),
      );
    }
  }

  @override
  void handleStationTap(String stationId) {
    final station = stations.firstWhere(
          (s) => s['id']?.toString() == stationId,
      orElse: () => {},
    );
    if (station.isNotEmpty) {
      _selectStation(station);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const destructiveColor = Color(0xFFDC2626);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: () {
          searchFocusNode.unfocus();
          setState(() => isSearching = false);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final double buttonBottom = (availableHeight * _currentSheetExtent) + 12.0;

            return Stack(
              children: [
                // 1. MAP LAYER
                Positioned.fill(
                  child: SharedBikeMap(
                    key: _mapTileKey,
                    stations: stations,
                    riderLocation: widget.riderLocation ?? userLocation,
                    selectedStationId: widget.selectedStationId ?? selectedStation?['id']?.toString(),
                    isAdminMode: widget.isAdminMode,
                    geofenceRadiusMeters: widget.geofenceRadiusMeters,
                    routePoints: widget.routePoints,
                    initialCenter: widget.initialCenter,
                    initialZoom: widget.initialZoom,
                    onStationTap: handleStationTap,
                    onMapLongPress: widget.onMapLongPress,
                  ),
                ),

                // 2. SEARCH BAR HEADER
                Positioned(
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      onChanged: filterStations,
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: widget.isAdminDeleteMode ? 'Search station to remove...' : 'Search station name or address...',
                        hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                        prefixIcon: Icon(Icons.search, color: colorScheme.primary, size: 20),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear, color: colorScheme.onSurface.withValues(alpha: 0.5), size: 18),
                          onPressed: () {
                            searchController.clear();
                            filterStations('');
                          },
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

                // 3. SEARCH RESULTS OVERLAY
                if (isSearching && searchController.text.trim().isNotEmpty)
                  Positioned(
                    top: 72.0,
                    left: 16.0,
                    right: 16.0,
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: availableHeight * 0.4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 6))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: filteredStations.isEmpty
                            ? Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            "No stations found.",
                            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        )
                            : ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: filteredStations.length,
                          separatorBuilder: (context, index) => Divider(color: colorScheme.outline.withValues(alpha: 0.2), height: 1),
                          itemBuilder: (context, index) {
                            final station = filteredStations[index];
                            final dist = formatDistance(station['distance_meters']);
                            final statusColor = _getStatusColor(station['status']?.toString());

                            return ListTile(
                              leading: Icon(Icons.location_on, color: statusColor),
                              title: Text(
                                station['name'] ?? 'Unnamed Station',
                                style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              subtitle: Text(
                                station['address'] ?? 'No address',
                                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("${station['available_bikes'] ?? 0} bikes", style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                                  if (dist.isNotEmpty)
                                    Text(dist, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11)),
                                ],
                              ),
                              onTap: () => _selectStation(station),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                // 4. GPS BUTTON
                Positioned(
                  right: 16.0,
                  bottom: buttonBottom,
                  child: buildRecenterButton(context),
                ),

                // 5. DRAGGABLE BOTTOM SHEET
                NotificationListener<DraggableScrollableNotification>(
                  onNotification: (notification) {
                    setState(() {
                      _currentSheetExtent = notification.extent;
                    });
                    return true;
                  },
                  child: DraggableScrollableSheet(
                    controller: _sheetController,
                    initialChildSize: _initialSheetSize,
                    minChildSize: _minSheetSize,
                    maxChildSize: _maxSheetSize,
                    builder: (context, sheetScrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, -4))],
                        ),
                        child: Column(
                          children: [
                            // TOP DRAG HANDLE HEADER
                            SingleChildScrollView(
                              controller: sheetScrollController,
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Center(
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: colorScheme.onSurface.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          selectedStation != null
                                              ? "Currently Selected"
                                              : (widget.isAdminDeleteMode ? "Target Station to Remove" : "Closest to you"),
                                          style: TextStyle(
                                            color: selectedStation != null ? colorScheme.secondary : colorScheme.onSurface.withValues(alpha: 0.7),
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (selectedStation != null)
                                          InkWell(
                                            onTap: () => setState(() => selectedStation = null),
                                            child: Text(
                                              "Reset",
                                              style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: _buildFeaturedStationCard(theme, colorScheme, destructiveColor),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                    child: Divider(color: colorScheme.outline.withValues(alpha: 0.5), height: 1),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Text(
                                      widget.isAdminDeleteMode ? "All Active Stations" : "Nearby Stations",
                                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),

                            // INNER STATION LIST
                            Expanded(
                              child: _buildStationList(theme, colorScheme, destructiveColor),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedStationCard(ThemeData theme, ColorScheme colorScheme, Color destructiveColor) {
    if (isLoading) {
      return Container(height: 60, alignment: Alignment.center, child: const CircularProgressIndicator.adaptive());
    }

    if (stations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: colorScheme.outline)),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: colorScheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 10),
            Text("No stations available", style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13)),
          ],
        ),
      );
    }

    final isCurrentlySelected = selectedStation != null;
    final displayStation = selectedStation ?? stations.first;
    final String statusStr = displayStation['status']?.toString() ?? 'Normal';
    final Color statusColor = _getStatusColor(statusStr);

    final availableBikes = displayStation['available_bikes'] ?? 0;
    final distStr = formatDistance(displayStation['distance_meters']);
    final distDisplay = distStr.isNotEmpty ? " • $distStr away" : "";

    return InkWell(
      onTap: () {
        if (isCurrentlySelected) {
          _openStationDetail(displayStation);
        } else {
          _selectStation(displayStation);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isAdminDeleteMode
              ? destructiveColor.withValues(alpha: 0.15)
              : statusColor.withValues(alpha: 0.12),
          border: Border.all(
            color: widget.isAdminDeleteMode
                ? destructiveColor.withValues(alpha: 0.5)
                : statusColor,
            width: isCurrentlySelected ? 1.8 : 1.0,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.isAdminDeleteMode ? destructiveColor : statusColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCurrentlySelected ? Icons.check_circle_outline : Icons.directions_bike,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayStation["name"] ?? "Unnamed Station",
                          style: TextStyle(color: colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor, width: 1.0),
                        ),
                        child: Text(
                          statusStr,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${displayStation["address"] ?? "No address"} • $availableBikes Bikes$distDisplay",
                    style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurface.withValues(alpha: 0.4), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStationList(ThemeData theme, ColorScheme colorScheme, Color destructiveColor) {
    if (isLoading) return const Center(child: CircularProgressIndicator.adaptive());

    if (filteredStations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("No matching stations found.", style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13)),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: filteredStations.length,
      itemBuilder: (context, index) {
        final station = filteredStations[index];
        final distStr = formatDistance(station['distance_meters']);
        final isSelected = selectedStation?['id'] == station['id'];
        final statusColor = _getStatusColor(station['status']?.toString());

        return InkWell(
          onTap: () => _selectStation(station),
          child: Container(
            color: isSelected ? statusColor.withValues(alpha: 0.08) : Colors.transparent,
            child: _StandardStationTile(
              name: station["name"] ?? "Unnamed Station",
              address: station["address"] ?? "",
              bikes: station["available_bikes"] ?? 0,
              distance: distStr,
              statusColor: statusColor,
              isSelected: isSelected,
              theme: theme,
              colorScheme: colorScheme,
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, Map<String, dynamic> station, ThemeData theme, ColorScheme colorScheme, Color destructiveColor) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Are you sure to remove\n${station["name"]}?", textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text("This action is irreversible, are you sure to continue?", textAlign: TextAlign.center, style: TextStyle(color: destructiveColor, fontSize: 12, fontStyle: FontStyle.italic)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: destructiveColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteStation(station);
                  },
                  child: const Text("Remove Location", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: colorScheme.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StandardStationTile extends StatelessWidget {
  final String name;
  final String address;
  final int bikes;
  final String distance;
  final Color statusColor;
  final bool isSelected;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _StandardStationTile({
    required this.name,
    required this.address,
    required this.bikes,
    this.distance = '',
    required this.statusColor,
    this.isSelected = false,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isSelected ? Icons.location_on : Icons.location_on_outlined,
            color: statusColor,
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isSelected ? statusColor : colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(address, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(Icons.directions_bike, color: colorScheme.secondary, size: 13),
                    const SizedBox(width: 4),
                    Text("$bikes", style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
              if (distance.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  distance,
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
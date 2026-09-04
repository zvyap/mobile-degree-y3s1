import 'package:flutter/material.dart';

import 'package:bike_renting_app/bike_station/base_station_map.dart';
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
      setState(() => selectedStation = station);
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
    final station = stations
        .where((s) => s['id']?.toString() == stationId)
        .firstOrNull;
    if (station != null) {
      _openStationDetail(station);
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
        child: Stack(
          children: [
            // 1. MAP LAYER (Inherited from BaseStationMapViewState)
            Positioned.fill(
              child: buildMapLayer(context),
            ),

            // 2. SEARCH BAR HEADER
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
                      onPressed: () {
                        if (isSearching || searchController.text.isNotEmpty) {
                          searchController.clear();
                          filterStations('');
                          searchFocusNode.unfocus();
                          setState(() => isSearching = false);
                        } else if (selectedStation != null) {
                          setState(() => selectedStation = null);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
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
                ],
              ),
            ),

            // 3. SEARCH RESULTS LIST OVERLAY WITH DISTANCES
            if (isSearching && searchController.text.trim().isNotEmpty)
              Positioned(
                top: 110.0,
                left: 16.0,
                right: 16.0,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
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

                        return ListTile(
                          leading: Icon(Icons.location_on, color: colorScheme.primary),
                          title: Text(station['name'] ?? 'Unnamed Station', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(station['address'] ?? 'No address', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("${station['available_bikes'] ?? 0} bikes", style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                              if (dist.isNotEmpty)
                                Text(dist, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11)),
                            ],
                          ),
                          onTap: () => _openStationDetail(station),
                        );
                      },
                    ),
                  ),
                ),
              ),

            // RECENTER GPS BUTTON (Inherited from BaseStationMapViewState)
            Positioned(
              right: 16.0,
              bottom: MediaQuery.of(context).size.height * 0.55 + 16.0,
              child: buildRecenterButton(context),
            ),

            // DYNAMIC BOTTOM SHEET
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.55,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, -4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 16),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        widget.isAdminDeleteMode ? "Target Station to Remove" : "Closest to you",
                        style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: _buildFeaturedStationCard(theme, colorScheme, destructiveColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Divider(color: colorScheme.outline, height: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        widget.isAdminDeleteMode ? "All Active Stations" : "Nearby Stations",
                        style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _buildStationList(theme, colorScheme, destructiveColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ABSOLUTE NEAREST FEATURED STATION CARD ---
  Widget _buildFeaturedStationCard(ThemeData theme, ColorScheme colorScheme, Color destructiveColor) {
    if (isLoading) {
      return Container(height: 70, alignment: Alignment.center, child: const CircularProgressIndicator.adaptive());
    }

    if (stations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: colorScheme.outline)),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: colorScheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 12),
            Text("No stations available", style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14)),
          ],
        ),
      );
    }

    final topStation = stations.first; // Nearest station after sorting
    final availableBikes = topStation['available_bikes'] ?? 0;
    final distStr = formatDistance(topStation['distance_meters']);
    final distDisplay = distStr.isNotEmpty ? " • $distStr away" : "";

    return InkWell(
      onTap: () => _openStationDetail(topStation),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isAdminDeleteMode ? destructiveColor.withValues(alpha: 0.15) : colorScheme.primary.withValues(alpha: 0.15),
          border: Border.all(color: widget.isAdminDeleteMode ? destructiveColor.withValues(alpha: 0.5) : colorScheme.primary.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: widget.isAdminDeleteMode ? destructiveColor : colorScheme.primary, shape: BoxShape.circle),
              child: const Icon(Icons.directions_bike, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topStation["name"] ?? "Unnamed Station", style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    "${topStation["address"] ?? "No address"} • $availableBikes Bikes$distDisplay",
                    style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SORTED STATION LIST ---
  Widget _buildStationList(ThemeData theme, ColorScheme colorScheme, Color destructiveColor) {
    if (isLoading) return const Center(child: CircularProgressIndicator.adaptive());

    if (filteredStations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("No matching stations found.", style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14)),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: filteredStations.length,
      itemBuilder: (context, index) {
        final station = filteredStations[index];
        final distStr = formatDistance(station['distance_meters']);

        return InkWell(
          onTap: () => _openStationDetail(station),
          child: _StandardStationTile(
            name: station["name"] ?? "Unnamed Station",
            address: station["address"] ?? "",
            bikes: station["available_bikes"] ?? 0,
            distance: distStr,
            theme: theme,
            colorScheme: colorScheme,
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
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _StandardStationTile({
    required this.name,
    required this.address,
    required this.bikes,
    this.distance = '',
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.location_on_outlined, color: colorScheme.onSurface.withValues(alpha: 0.6), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(address, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.directions_bike, color: colorScheme.secondary, size: 14),
                    const SizedBox(width: 4),
                    Text("$bikes", style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              if (distance.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  distance,
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 11,
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
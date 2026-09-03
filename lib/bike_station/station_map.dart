import 'package:bike_renting_app/bike_station/shared_map.dart';
import 'package:bike_renting_app/bike_station/station_details.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RefinedUserBikeView extends StatefulWidget {
  final bool isAdminDeleteMode; // Toggle between User Mode & Admin Delete Mode
  final Function(Map<String, dynamic> station)? onRemoveStation; // Callback when station is deleted

  const RefinedUserBikeView({
    super.key,
    this.isAdminDeleteMode = false,
    this.onRemoveStation,
  });

  @override
  State<RefinedUserBikeView> createState() => _RefinedUserBikeViewState();
}

class _RefinedUserBikeViewState extends State<RefinedUserBikeView> {
  final SupabaseClient supabase = Supabase.instance.client;

  Map<String, dynamic>? selectedStation;
  List<Map<String, dynamic>> stations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  // 1. FETCH ONLY ACTIVE STATIONS FROM SUPABASE
  Future<void> _fetchStations() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('stations')
          .select()
          .eq('is_active', true) // Filter out soft-deleted/inactive stations
          .order('id', ascending: true);

      setState(() {
        stations = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stations: $e')),
        );
      }
    }
  }

  // 2. SOFT DELETE STATION (Set is_active = false)
  Future<void> _deleteStation(Map<String, dynamic> station) async {
    try {
      final stationId = station['id'];

      // Perform update instead of hard deletion
      await supabase.from('stations').update({
        'is_active': false,
        'status': 'Terminated',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', stationId);

      setState(() {
        stations.removeWhere((s) => s['id'] == stationId);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final destructiveColor = const Color(0xFFDC2626);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // BACKGROUND MAP
          Positioned.fill(
            child: SharedBikeMap(
              stations: stations,
              selectedStationId: selectedStation?['id']?.toString(),
              isAdminMode: widget.isAdminDeleteMode,
              onStationTap: (stationId) {
                final station = stations.firstWhere(
                  (s) => s['id']?.toString() == stationId,
                  orElse: () => {},
                );
                if (station.isNotEmpty) {
                  setState(() => selectedStation = station);
                  if (!widget.isAdminDeleteMode) {
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
              },
            ),
          ),

          // MIDDLE LOCATION MARKER (Admin Delete Mode crosshair)
          if (widget.isAdminDeleteMode)
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 200.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Selected Location",
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      Icons.location_on,
                      color: destructiveColor,
                      size: 42,
                    ),
                  ],
                ),
              ),
            ),

          // TOP SEARCH BAR
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
                      if (selectedStation != null) {
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.isAdminDeleteMode ? 'Search location...' : 'Search destination...',
                        style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // RECENTER BUTTON
          Positioned(
            right: 16.0,
            bottom: MediaQuery.of(context).size.height * 0.55 + 16.0,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.my_location, color: colorScheme.onSurface),
                onPressed: _fetchStations,
              ),
            ),
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
                  // Drag Handle
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

                  // === SECTION 1: Absolute Nearest Station ===
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

                  // === SECTION 2: Station List ===
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      widget.isAdminDeleteMode ? "All Active Stations" : "Top 3 Nearby Stations",
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: _buildStationList(theme, colorScheme, destructiveColor),
                  ),

                  // === SECTION 3: Admin Mode Remove Button ===
                  if (widget.isAdminDeleteMode && stations.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: destructiveColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, stations.first, theme, colorScheme, destructiveColor);
                          },
                          child: const Text("Remove Location", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- FEATURED CARD WIDGET ---
  Widget _buildFeaturedStationCard(ThemeData theme, ColorScheme colorScheme, Color destructiveColor) {
    if (isLoading) {
      return Container(
        height: 70,
        alignment: Alignment.center,
        child: const CircularProgressIndicator.adaptive(),
      );
    }

    if (stations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: colorScheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 12),
            Text(
              "No stations available",
              style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
            ),
          ],
        ),
      );
    }

    final topStation = stations.first;
    final availableBikes = topStation['available_bikes'] ?? 0;

    return InkWell(
      onTap: () {
        if (widget.isAdminDeleteMode) {
          _showDeleteConfirmationDialog(context, topStation, theme, colorScheme, destructiveColor);
        } else {
          setState(() => selectedStation = topStation);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StationDetailScreen(
                stationData: topStation,
                isViewOnly: true,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isAdminDeleteMode
              ? destructiveColor.withValues(alpha: 0.15)
              : colorScheme.primary.withValues(alpha: 0.15),
          border: Border.all(
            color: widget.isAdminDeleteMode
                ? destructiveColor.withValues(alpha: 0.5)
                : colorScheme.primary.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.isAdminDeleteMode ? destructiveColor : colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_bike, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topStation["name"] ?? "Unnamed Station",
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${topStation["address"] ?? "No address"} • $availableBikes Bikes available",
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

  // --- LIST WIDGET ---
  Widget _buildStationList(ThemeData theme, ColorScheme colorScheme, Color destructiveColor) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (stations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "No stations available in this area.",
            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: stations.length,
      itemBuilder: (context, index) {
        final station = stations[index];
        return InkWell(
          onTap: () {
            if (widget.isAdminDeleteMode) {
              _showDeleteConfirmationDialog(context, station, theme, colorScheme, destructiveColor);
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
          },
          child: _StandardStationTile(
            name: station["name"] ?? "Unnamed Station",
            address: station["address"] ?? "",
            bikes: station["available_bikes"] ?? 0,
            theme: theme,
            colorScheme: colorScheme,
          ),
        );
      },
    );
  }

  // CONFIRMATION MODAL DIALOG
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
              Text(
                "Are you sure to remove\n${station["name"]}?",
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "This action is irreversible, are you sure to continue?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: destructiveColor,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),

              // Confirm Delete Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: destructiveColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteStation(station); // Triggers soft delete in Supabase
                  },
                  child: const Text("Remove Location", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
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
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _StandardStationTile({
    required this.name,
    required this.address,
    required this.bikes,
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
                Text(
                  address,
                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.directions_bike, color: colorScheme.secondary, size: 14),
                const SizedBox(width: 4),
                Text("$bikes", style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
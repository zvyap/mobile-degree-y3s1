import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bike_renting_app/navigation/app_page.dart';
import 'package:bike_renting_app/l10n/l10n.dart';

// 🟢 Correct import path for BikeDetailsPage
import '../features/bike/pages/bike_details.dart';

class StationBikesScreen extends StatefulWidget {
  final Map<String, dynamic>? stationData;
  const StationBikesScreen({super.key, this.stationData});

  @override
  State<StationBikesScreen> createState() => _StationBikesScreenState();
}

class _StationBikesScreenState extends State<StationBikesScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> allBikes = [];
  List<Map<String, dynamic>> filteredBikes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBikes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBikes() async {
    final rawStationId = widget.stationData?['id'];

    if (rawStationId == null) {
      setState(() => isLoading = false);
      return;
    }

    final stationId = int.tryParse(rawStationId.toString()) ?? rawStationId;

    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('bikes')
          .select()
          .eq('current_station_id', stationId)
          .order('code', ascending: true);

      final fetchedBikes = List<Map<String, dynamic>>.from(response);

      if (mounted) {
        setState(() {
          allBikes = fetchedBikes;
          filteredBikes = fetchedBikes;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.failedToLoadBikes(e.toString()))),
        );
      }
    }
  }

  void _filterBikes(String query) {
    final trimmedQuery = query.trim().toLowerCase();
    setState(() {
      if (trimmedQuery.isEmpty) {
        filteredBikes = allBikes;
      } else {
        filteredBikes = allBikes.where((bike) {
          final code = (bike['code'] ?? '').toString().toLowerCase();
          final id = (bike['id'] ?? '').toString().toLowerCase();
          return code.contains(trimmedQuery) || id.contains(trimmedQuery);
        }).toList();
      }
    });
  }

  void _navigateToBikeDetails(Map<String, dynamic> bike) {
    final dynamic rawId = bike['id'];
    final int? bikeId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');

    if (bikeId == null || bikeId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.invalidBikeIdError)),
      );
      return;
    }

    final String bikeCode = bike['code']?.toString() ?? 'BR-$bikeId';

    // 🟢 Opens BikeDetailsPage inside a full Scaffold so it displays reliably
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(bikeCode, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: BikeDetailsPage(
            bikeId: bikeId,
            onEditBike: () {
              Navigator.pushNamed(
                context,
                AppPage.editBike.routeName,
                arguments: bikeId,
              );
            },
            onTransferBike: () {
              Navigator.pushNamed(
                context,
                AppPage.transferBike.routeName,
                arguments: bikeId,
              );
            },
            onServiceBike: () {
              Navigator.pushNamed(
                context,
                AppPage.serviceBike.routeName,
                arguments: bikeId,
              );
            },
            onMakeReport: () {
              Navigator.pushNamed(
                context,
                AppPage.reportForm.routeName,
                arguments: bikeId,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP HEADER SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.stationData?['name']?.toString() ?? context.l10n.stationBikes,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.stationData?['address']?.toString() ?? context.l10n.locationCoordinatesNotProvided,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(color: colorScheme.outline, height: 24),
            ),

            // 2. SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterBikes,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                    hintText: context.l10n.searchBikesCodeOrId,
                    hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3. MAIN CONTENT BODY
            Expanded(
              child: Builder(
                builder: (context) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (allBikes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_bike,
                            size: 64,
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            context.l10n.noBikesInStationYet,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (filteredBikes.isEmpty) {
                    return Center(
                      child: Text(
                        context.l10n.noBikesMatchSearch,
                        style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredBikes.length,
                    itemBuilder: (context, index) {
                      final bike = filteredBikes[index];
                      final String bikeCode = bike["code"] ?? "BR-${bike["id"]}";
                      final String status = bike["status"] ?? context.l10n.unknownStatus;
                      final int battery = (bike["battery_percent"] as num?)?.toInt() ?? 0;
                      final bool isAvailable = status.toLowerCase() == "available";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.outline),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.directions_bike,
                                color: colorScheme.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bikeCode,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        context.l10n.bikeStatus(status),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: isAvailable
                                              ? colorScheme.secondary
                                              : colorScheme.tertiary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.battery_charging_full,
                                        size: 14,
                                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        "$battery%",
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              icon: Icon(Icons.visibility_outlined, color: colorScheme.onSurface),
                              onPressed: () => _navigateToBikeDetails(bike),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
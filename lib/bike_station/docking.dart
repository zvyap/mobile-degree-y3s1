import 'package:flutter/material.dart';

class StationBikesScreen extends StatefulWidget {
  const StationBikesScreen({super.key});

  @override
  State<StationBikesScreen> createState() => _StationBikesScreenState();
}

class _StationBikesScreenState extends State<StationBikesScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> allBikes = [
    {"id": "BR-1028", "status": "Available", "battery": "85%"},
    {"id": "BR-1029", "status": "Available", "battery": "92%"},
    {"id": "BR-1030", "status": "Maintenance", "battery": "15%"},
    {"id": "BR-1031", "status": "Available", "battery": "60%"},
  ];

  List<Map<String, String>> filteredBikes = [];

  @override
  void initState() {
    super.initState();
    filteredBikes = allBikes;
  }

  void _filterBikes(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredBikes = allBikes;
      } else {
        filteredBikes = allBikes
            .where((bike) => bike["id"]!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. ACCESS GLOBAL THEME VARIABLES FROM app_theme.dart
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Uses AppTheme's scaffoldBackgroundColor (Dark: #0B1117 / Light: #F8FAFC)
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. TOP HEADER SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circular Back Button using surfaceContainerHighest background
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
                  const SizedBox(height: 16),
                  Text(
                    "Jalan Sungai Kelian Station",
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
                          "Tanjung Bungah, Penang",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
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

            // 3. SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterBikes,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.6)),
                    hintText: "Search bikes",
                    hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 4. BICYCLE CARDS LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filteredBikes.length,
                itemBuilder: (context, index) {
                  final bike = filteredBikes[index];
                  final bool isAvailable = bike["status"] == "Available";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      // Uses surfaceContainerHighest (Dark: #1F2937 / Light: #E8ECF1)
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      // Uses AppTheme outline (Dark: #334155 / Light: #E2E8F0)
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: Row(
                      children: [
                        // Bike Icon Container using surface background
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.directions_bike,
                            color: colorScheme.primary, // #0369A1
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Bike ID & Status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bike["id"]!,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Status: ${bike["status"]}",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  // Uses AppTheme secondary (#0E9F6E Green) or tertiary (#F59E0B Amber)
                                  color: isAvailable
                                      ? colorScheme.secondary
                                      : colorScheme.tertiary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action Buttons
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.visibility_outlined, color: colorScheme.onSurface),
                              onPressed: () {
                                // TODO: View details
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: colorScheme.onSurface.withOpacity(0.5)),
                              onPressed: () {
                                setState(() {
                                  allBikes.removeWhere((item) => item["id"] == bike["id"]);
                                  _filterBikes(_searchController.text);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
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
import 'package:flutter/material.dart';

class UserBikeStationView extends StatelessWidget {
  const UserBikeStationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Defines the dark theme color used in the image
    const Color darkSurfaceColor = Color(0xFF151821);

    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND MAP LAYER
          // Replace this Container with your actual flutter_map or GoogleMap widget
          Positioned.fill(
            child: Container(
              color: const Color(0xFFEAF5EB), // Light map-like background color
              child: const Center(
                child: Text(
                  'Map Implementation Here\n(e.g., flutter_map with OSRM)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),

          // 2. TOP NAVIGATION ROW (Back Button & Search)
          Positioned(
            top: 50.0, // Safe area padding
            left: 16.0,
            right: 16.0,
            child: Row(
              children: [
                // Back Button
                Container(
                  decoration: const BoxDecoration(
                    color: darkSurfaceColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Search Bar
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: darkSurfaceColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Search stations',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. RECENTER FLOATING ACTION BUTTON
          Positioned(
            right: 16.0,
            bottom: MediaQuery.of(context).size.height * 0.45 + 16.0,
            child: Container(
              decoration: const BoxDecoration(
                color: darkSurfaceColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.my_location, color: Colors.white),
                onPressed: () {
                  // TODO: Add map recentering logic here
                },
              ),
            ),
          ),

          // 4. BOTTOM STATION LIST (Dark Mode Bottom Sheet)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                color: darkSurfaceColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Drag Handle / Indicator
                  const SizedBox(height: 12),
                  Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Scrollable List of Stations
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: const [
                        StationListTile(
                          address: 'Jalan Sungai Kelian, Tanjung Bungah',
                          distance: '1.2 km',
                        ),
                        StationListTile(
                          address: 'Pearl Hill, Tanjung Bungah',
                          distance: '2.4 km',
                        ),
                        StationListTile(
                          address: 'Pepper Estate, Penang',
                          distance: '3.1 km',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Widget for the Station Items to match the design
class StationListTile extends StatelessWidget {
  final String address;
  final String distance;

  const StationListTile({
    super.key,
    required this.address,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Outline Location Icon
          const Icon(
            Icons.location_on_outlined,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 16),

          // Text Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  distance,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class RefinedUserBikeView extends StatelessWidget {
  const RefinedUserBikeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    const Color bgColor = Color(0xFF10141D);
    const Color cardColor = Color(0xFF19202E);
    const Color primaryBlue = Color(0xFF4358F5);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. BACKGROUND MAP
          Positioned.fill(
            child: Container(
              color: const Color(0xFFEAF5EB),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 200.0),
                  child: Text(
                    'Interactive Map Layer Here\n(Pans underneath the center marker)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),

          // 2. THE MIDDLE MARKER (Changed to a normal map pin)
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
                      "Your Location",
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Updated to standard map marker
                  const Icon(
                    Icons.location_on,
                    color: primaryBlue,
                    size: 42,
                  ),
                ],
              ),
            ),
          ),

          // 3. TOP SEARCH BAR
          Positioned(
            top: 50.0,
            left: 16.0,
            right: 16.0,
            child: Row(
              children: [
                Container(
                  decoration: const BoxDecoration(color: bgColor, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
                        ]
                    ),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Search destination...', style: TextStyle(color: Colors.white54, fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. RECENTER / MY LOCATION BUTTON
          // Positioned dynamically just above the bottom sheet
          Positioned(
            right: 16.0,
            bottom: MediaQuery.of(context).size.height * 0.55 + 16.0,
            child: Container(
              decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
              ),
              child: IconButton(
                icon: const Icon(Icons.my_location, color: Colors.white),
                onPressed: () {
                  // TODO: Trigger map controller to jump to GPS coordinates
                },
              ),
            ),
          ),

          // 5. BOTTOM SHEET OVERLAY
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: const BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, -4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 20),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  // === SECTION 1: Absolute Nearest Station ===
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text("Closest to you", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.15),
                        border: Border.all(color: primaryBlue.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
                            child: const Icon(Icons.directions_bike, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Jalan Sungai Kelian Station", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text("0.2 km away • 12 Bikes available", style: TextStyle(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Divider(color: Colors.white12, height: 1),
                  ),

                  // === SECTION 2: Top 3 Nearest Stations ===
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text("Top 3 Nearby Stations", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: const [
                        _StandardStationTile(name: "Jalan Sungai Kelian Station", distance: "0.2 km", bikes: 12),
                        _StandardStationTile(name: "Pearl Hill Park", distance: "1.2 km", bikes: 8),
                        _StandardStationTile(name: "Tanjung Bungah Market", distance: "2.4 km", bikes: 15),
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

class _StandardStationTile extends StatelessWidget {
  final String name;
  final String distance;
  final int bikes;

  const _StandardStationTile({
    required this.name,
    required this.distance,
    required this.bikes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.location_on_outlined, color: Colors.white54, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(distance, style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF19202E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.directions_bike, color: Colors.green, size: 14),
                const SizedBox(width: 4),
                Text("$bikes", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
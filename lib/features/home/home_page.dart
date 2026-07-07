import 'package:bike_renting_app/features/home/widgets/hero_panel.dart';
import 'package:bike_renting_app/features/home/widgets/home_cards.dart';
import 'package:bike_renting_app/features/home/widgets/station_preview.dart';
import 'package:bike_renting_app/shared/ui_components.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalInset = width > 920 ? (width - 860) / 2 : 20.0;

        return ListView(
          padding: EdgeInsets.fromLTRB(horizontalInset, 8, horizontalInset, 28),
          children: const [
            Entrance(child: HeroPanel()),
            SizedBox(height: 24),
            SectionHeader(
              title: 'Today overview',
              subtitle: 'Live status across renting, stations, and bikes.',
            ),
            SizedBox(height: 12),
            ResponsiveWrap(
              children: [
                MetricCard(
                  title: 'Available bikes',
                  value: '128',
                  caption: '18 near campus gate',
                  icon: Icons.directions_bike_rounded,
                ),
                MetricCard(
                  title: 'Active rides',
                  value: '42',
                  caption: '6 ending soon',
                  icon: Icons.timer_rounded,
                ),
                MetricCard(
                  title: 'Open docks',
                  value: '73',
                  caption: 'Across 9 stations',
                  icon: Icons.local_parking_rounded,
                ),
              ],
            ),
            SizedBox(height: 24),
            SectionHeader(
              title: 'Modules',
              subtitle: 'Core areas for user, renting, station, and bike work.',
            ),
            SizedBox(height: 12),
            ResponsiveWrap(
              children: [
                ModuleCard(
                  title: 'User',
                  caption: 'Profile, wallet, ride history',
                  icon: Icons.person_rounded,
                  accent: Color(0xFF7C3AED),
                ),
                ModuleCard(
                  title: 'Renting',
                  caption: 'Scan, unlock, ride, return',
                  icon: Icons.qr_code_scanner_rounded,
                  accent: Color(0xFF0369A1),
                ),
                ModuleCard(
                  title: 'Station and Bike',
                  caption: 'Docks, bikes, maintenance',
                  icon: Icons.warehouse_rounded,
                  accent: Color(0xFF0E9F6E),
                ),
              ],
            ),
            SizedBox(height: 24),
            StationPreview(),
          ],
        );
      },
    );
  }
}

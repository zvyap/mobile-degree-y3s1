import 'package:bike_renting_app/features/home/widgets/hero_panel.dart';
import 'package:bike_renting_app/features/home/widgets/home_cards.dart';
import 'package:bike_renting_app/features/home/widgets/ride_conditions_panel.dart';
import 'package:bike_renting_app/features/home/widgets/station_preview.dart';
import 'package:bike_renting_app/shared/ui_components.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalInset = width > 920 ? (width - 860) / 2 : 16.0;

        return ListView(
          key: const ValueKey<String>('home-content'),
          padding: EdgeInsets.fromLTRB(horizontalInset, 4, horizontalInset, 20),
          children: [
            Entrance(
              child: HeroPanel(
                onScan: () => onNavigate(2),
                onFindStation: () => onNavigate(1),
              ),
            ),
            const SizedBox(height: 18),
            const NetworkSummary(),
            const SizedBox(height: 18),
            const RideConditionsPanel(),
            const SizedBox(height: 18),
            StationPreview(onViewAll: () => onNavigate(1)),
          ],
        );
      },
    );
  }
}

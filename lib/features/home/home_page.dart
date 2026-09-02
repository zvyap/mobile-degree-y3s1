import 'package:bike_renting_app/features/home/widgets/active_ride_home.dart';
import 'package:bike_renting_app/features/home/widgets/hero_panel.dart';
import 'package:bike_renting_app/features/home/widgets/home_cards.dart';
import 'package:bike_renting_app/features/home/widgets/ride_conditions_panel.dart';
import 'package:bike_renting_app/features/home/widgets/station_preview.dart';
import 'package:bike_renting_app/features/renting/renting_controller.dart';
import 'package:bike_renting_app/navigation/app_page.dart';
import 'package:bike_renting_app/shared/ui_components.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.rentingController,
    required this.onNavigate,
  });

  final RentingController rentingController;
  final ValueChanged<AppPage> onNavigate;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: rentingController,
      builder: (context, child) => LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalInset = width > 920 ? (width - 860) / 2 : 16.0;
          final rideActive = rentingController.isRideActive;

          return ListView(
            key: ValueKey<String>(
              rideActive ? 'home-active-content' : 'home-idle-content',
            ),
            padding: EdgeInsets.fromLTRB(
              horizontalInset,
              4,
              horizontalInset,
              20,
            ),
            children: [
              Entrance(
                child: rideActive
                    ? ActiveRideHome(
                        controller: rentingController,
                        onOpenRide: () => onNavigate(AppPage.scan),
                      )
                    : HeroPanel(
                        onScan: () => onNavigate(AppPage.scan),
                        onFindStation: () => onNavigate(AppPage.stations),
                        onViewHistory: () => onNavigate(AppPage.history),
                      ),
              ),
              if (!rideActive) ...[
                const SizedBox(height: 18),
                const NetworkSummary(),
              ],
              const SizedBox(height: 18),
              const RideConditionsPanel(),
              const SizedBox(height: 18),
              if (rideActive)
                ActiveReturnStationPreview(
                  stations: rentingController.stations,
                  onViewAll: () => onNavigate(AppPage.stations),
                )
              else
                StationPreview(onViewAll: () => onNavigate(AppPage.stations)),
            ],
          );
        },
      ),
    );
  }
}

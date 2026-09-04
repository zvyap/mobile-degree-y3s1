import 'package:bike_renting_app/features/home/widgets/active_ride_home.dart';
import 'package:bike_renting_app/features/home/widgets/hero_panel.dart';
import 'package:bike_renting_app/features/home/widgets/home_cards.dart';
import 'package:bike_renting_app/features/home/widgets/ride_conditions_panel.dart';
import 'package:bike_renting_app/features/home/widgets/station_preview.dart';
import 'package:bike_renting_app/features/renting/renting_controller.dart';
import 'package:bike_renting_app/navigation/app_page.dart';
import 'package:bike_renting_app/shared/ui_components.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.rentingController,
    required this.onNavigate,
    this.onRefresh,
  });

  final RentingController rentingController;
  final ValueChanged<AppPage> onNavigate;
  final Future<void> Function()? onRefresh;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<RideConditionsPanelState> _weatherPanelKey =
      GlobalKey<RideConditionsPanelState>();

  Future<void> _handleRefresh() async {
    await Future.wait([
      if (widget.onRefresh != null) widget.onRefresh!(),
      _weatherPanelKey.currentState?.refresh(forceRefresh: true) ?? Future.value(),
      widget.rentingController.reinitialize(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: widget.rentingController,
      builder: (context, child) => LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalInset = width > 920 ? (width - 860) / 2 : 16.0;
          final rideActive = widget.rentingController.isRideActive;

          return RefreshIndicator(
            key: const ValueKey<String>('home-refresh-indicator'),
            color: scheme.primary,
            backgroundColor: scheme.surfaceContainerHighest,
            displacement: 32,
            edgeOffset: 0,
            onRefresh: _handleRefresh,
            child: ListView(
              key: ValueKey<String>(
                rideActive ? 'home-active-content' : 'home-idle-content',
              ),
              physics: const AlwaysScrollableScrollPhysics(),
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
                          controller: widget.rentingController,
                          onOpenRide: () => widget.onNavigate(AppPage.scan),
                        )
                      : HeroPanel(
                          onScan: () => widget.onNavigate(AppPage.scan),
                          onFindStation: () => widget.onNavigate(AppPage.stations),
                          onViewHistory: () => widget.onNavigate(AppPage.history),
                        ),
                ),
                if (!rideActive) ...[
                  const SizedBox(height: 18),
                  const NetworkSummary(),
                ],
                const SizedBox(height: 18),
                RideConditionsPanel(key: _weatherPanelKey),
                const SizedBox(height: 18),
                if (rideActive)
                  ActiveReturnStationPreview(
                    stations: widget.rentingController.stations,
                    onViewAll: () => widget.onNavigate(AppPage.stations),
                  )
                else
                  StationPreview(
                    onViewAll: () => widget.onNavigate(AppPage.stations),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

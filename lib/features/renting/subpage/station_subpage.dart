part of '../renting_flow_page.dart';

class _StationStage extends StatelessWidget {
  const _StationStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SurfacePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: context.l10n.continueRide,
                onPressed: controller.resumeRide,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _StageTitle(
                  icon: Icons.location_on_rounded,
                  title: context.l10n.chooseReturnStation,
                  subtitle: context.l10n.chooseReturnStationDescription,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _CityMap(
            routeProgress: controller.isAtStation ? 1 : 0.72,
            selectedStation: controller.selectedStation,
            atStation: controller.isAtStation,
          ),
          const SizedBox(height: 10),
          for (final station in controller.stations) ...[
            _StationTile(
              station: station,
              selected: controller.selectedStation?.id == station.id,
              onTap: station.availableDocks == 0
                  ? () => controller.selectStation(station)
                  : () => controller.selectStation(station),
            ),
            const SizedBox(height: 8),
          ],
          if (controller.error != null) ...[
            const SizedBox(height: 4),
            _ErrorPanel(message: _rentalError(context, controller)),
          ],
          if (controller.selectedStation != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const ValueKey('rent-confirm-arrival'),
              onPressed: controller.confirmArrival,
              icon: Icon(
                controller.isAtStation
                    ? Icons.check_rounded
                    : Icons.near_me_rounded,
              ),
              label: Text(
                controller.isAtStation
                    ? context.l10n.withinReturnZone
                    : context.l10n.confirmArrival,
              ),
              style: controller.isAtStation
                  ? OutlinedButton.styleFrom(foregroundColor: scheme.secondary)
                  : null,
            ),
          ],
          const SizedBox(height: 12),
          _ActionButton(
            key: const ValueKey('rent-begin-return'),
            label: context.l10n.continueToDock,
            icon: Icons.keyboard_double_arrow_down_rounded,
            onPressed: controller.beginReturn,
          ),
        ],
      ),
    );
  }
}

part of '../renting_flow_page.dart';

class _StationStage extends StatelessWidget {
  const _StationStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final cannotReturnHere =
        controller.selectedStation?.isUnderMaintenance == true ||
            controller.selectedStation?.isTerminated == true;
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
          _ReturnStationMap(
            stations: controller.stations,
            selectedStation: controller.selectedStation,
            riderLocation: controller.riderLatLng,
            riderHeading: controller.riderHeading,
            onSelectStation: controller.selectStation,
            isAtStation: controller.isAtStation,
          ),
          const SizedBox(height: 10),
          for (final station in controller.stations) ...[
            _StationTile(
              station: station,
              selected: controller.selectedStation?.id == station.id,
              onTap: () => controller.selectStation(station),
            ),
            const SizedBox(height: 8),
          ],
          if (controller.error != null) ...[
            const SizedBox(height: 4),
            _ErrorPanel(message: _rentalError(context, controller)),
          ],
          if (controller.selectedStation != null) ...[
            if (cannotReturnHere) ...[
              const SizedBox(height: 8),
              _ErrorPanel(
                message: controller.selectedStation?.isUnderMaintenance == true
                    ? context.l10n.stationCannotReturnMaintenance
                    : context.l10n.errorStationTerminated(
                        controller.selectedStation!.name,
                      ),
              ),
            ],
            if (!controller.isAtStation) ...[
              const SizedBox(height: 8),
              _ErrorPanel(
                message: controller.stationDistanceMeters != null
                    ? '${context.l10n.errorOutsideReturnZone} (${context.l10n.stationDistance(controller.stationDistanceMeters!)})'
                    : context.l10n.errorOutsideReturnZone,
              ),
            ],
            const SizedBox(height: 12),
            _ActionButton(
              key: const ValueKey('rent-begin-return'),
              label: controller.isAtStation
                  ? context.l10n.continueToDock
                  : context.l10n.returnAtStation(controller.selectedStation!.name),
              icon: Icons.keyboard_double_arrow_down_rounded,
              busy: controller.isBusy,
              onPressed: (controller.isBusy || cannotReturnHere || !controller.isAtStation)
                  ? null
                  : () => controller.beginReturn(),
            ),
          ],
        ],
      ),
    );
  }
}

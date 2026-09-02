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
              onPressed: controller.isBusy ? null : controller.checkArrival,
              icon: controller.isBusy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
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
                  ? OutlinedButton.styleFrom(
                      foregroundColor: scheme.secondary,
                      minimumSize: const Size(double.infinity, 48),
                    )
                  : OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
            ),
            if (controller.stationDistanceMeters != null &&
                !controller.isAtStation) ...[
              const SizedBox(height: 6),
              Text(
                context.l10n.stationDistance(controller.stationDistanceMeters!),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
          const SizedBox(height: 8),
          _ActionButton(
            key: const ValueKey('rent-scan-station-qr'),
            label: context.l10n.scanStationQr,
            icon: Icons.qr_code_scanner_rounded,
            onPressed: () => _handleStationScan(context, controller),
          ),
          if (controller.selectedStation != null &&
              controller.stationQrToken != null) ...[
            const SizedBox(height: 12),
            _ActionButton(
              key: const ValueKey('rent-begin-return'),
              label: context.l10n.continueToDock,
              icon: Icons.keyboard_double_arrow_down_rounded,
              onPressed: controller.beginReturn,
            ),
          ],
        ],
      ),
    );
  }
}

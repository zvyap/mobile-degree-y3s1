part of '../renting_flow_page.dart';

class _ReturnStage extends StatelessWidget {
  const _ReturnStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
          final cannotReturnHere =
              controller.selectedStation?.isUnderMaintenance == true ||
                  controller.selectedStation?.isTerminated == true;
          return SurfacePanel(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _StageTitle(
                  icon: Icons.keyboard_double_arrow_down_rounded,
                  title: context.l10n.secureBike,
                  subtitle: context.l10n.secureBikeDescription,
                ),
                const SizedBox(height: 18),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: (cannotReturnHere
                            ? const Color(0xFFF97316)
                            : scheme.secondary)
                        .withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: controller.isBusy
                      ? Padding(
                          padding: const EdgeInsets.all(28),
                          child: CircularProgressIndicator(
                            color: cannotReturnHere
                                ? const Color(0xFFF97316)
                                : scheme.secondary,
                          ),
                        )
                      : Icon(
                          cannotReturnHere
                              ? Icons.build_circle_outlined
                              : Icons.pedal_bike_rounded,
                          size: 48,
                          color: cannotReturnHere
                              ? const Color(0xFFF97316)
                              : scheme.secondary,
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  _stationName(context.l10n, controller.selectedStation!),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (controller.selectedStation?.isUnderMaintenance == true) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFF97316),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.build_circle_outlined,
                          size: 14,
                          color: Color(0xFFF97316),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.l10n.stationUnderMaintenance,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFFF97316),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Text(
                    context.l10n.docksAvailable(
                      controller.selectedStation!.availableDocks,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                _ReturnStationMap(
                  stations: controller.stations,
                  selectedStation: controller.selectedStation,
                  riderLocation: controller.riderLatLng,
                  riderHeading: controller.riderHeading,
                  onSelectStation: controller.selectStation,
                  isAtStation: controller.isAtStation,
                ),
                if (controller.error != null) ...[
                  const SizedBox(height: 18),
                  _ErrorPanel(message: _rentalError(context, controller)),
                ] else if (cannotReturnHere) ...[
                  const SizedBox(height: 18),
                  _ErrorPanel(
                    message: controller.selectedStation?.isUnderMaintenance ==
                            true
                        ? context.l10n.stationCannotReturnMaintenance
                        : context.l10n.errorStationTerminated(
                            controller.selectedStation!.name,
                          ),
                  ),
                ] else if (!controller.isAtStation) ...[
                  const SizedBox(height: 18),
                  _ErrorPanel(
                    message: controller.stationDistanceMeters != null
                        ? '${context.l10n.errorOutsideReturnZone} (${context.l10n.stationDistance(controller.stationDistanceMeters!)})'
                        : context.l10n.errorOutsideReturnZone,
                  ),
                ],
                const SizedBox(height: 16),
                _ActionButton(
                  key: const ValueKey('rent-confirm-dock'),
                  label: context.l10n.confirmBikeDocked,
                  icon: Icons.lock_rounded,
                  busy: controller.isBusy,
                  onPressed: (cannotReturnHere || controller.isBusy || !controller.isAtStation)
                      ? null
                      : () => controller.confirmDock(),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  key: const ValueKey('rent-change-station'),
                  style: _secondaryTextButtonStyle(context),
                  onPressed: controller.isBusy ? null : controller.resumeRide,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(context.l10n.continueRide),
                ),
              ],
            ),
          );
  }
}

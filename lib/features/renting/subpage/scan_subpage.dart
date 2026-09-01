part of '../renting_flow_page.dart';

class _ScanStage extends StatelessWidget {
  const _ScanStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 0.82,
          child: Semantics(
            button: true,
            label: context.l10n.cameraPreviewSemantics,
            child: GestureDetector(
              key: const ValueKey<String>('rent-camera-preview'),
              behavior: HitTestBehavior.opaque,
              onTap: () => _handleCameraTap(context, controller),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF111827),
                      scheme.primary.withValues(alpha: 0.30),
                      const Color(0xFF071018),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.46),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              context.l10n.cameraReady,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox.square(
                        dimension: 252,
                        child: Stack(
                          children: [
                            for (final alignment in const [
                              Alignment.topLeft,
                              Alignment.topRight,
                              Alignment.bottomLeft,
                              Alignment.bottomRight,
                            ])
                              _ScannerCorner(alignment: alignment),
                            Center(
                              child: Icon(
                                Icons.qr_code_2_rounded,
                                size: 92,
                                color: Colors.white.withValues(alpha: 0.34),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          context.l10n.pointCamera,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (controller.error != null) ...[
          const SizedBox(height: 10),
          _ErrorPanel(message: _rentalError(context, controller)),
        ],
        const SizedBox(height: 8),
        Text(
          context.l10n.scanInstructions,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.64),
          ),
        ),
      ],
    );
  }
}

/// DEBUG ONLY: camera scanning is not wired up yet, so debug builds pick a
/// bike from a sheet instead. Release builds keep the placeholder demo scan.
Future<void> _handleCameraTap(
  BuildContext context,
  RentingController controller,
) async {
  if (!kDebugMode) {
    await controller.scanBike();
    return;
  }
  final bike = await showModalBottomSheet<BikeDatabaseRecord>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => _DebugBikePickerSheet(controller: controller),
  );
  if (bike == null || bike.qrToken.isEmpty) return;
  await controller.scanBike(bike.qrToken);
}

class _DebugBikePickerSheet extends StatelessWidget {
  const _DebugBikePickerSheet({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: FutureBuilder<List<BikeDatabaseRecord>>(
        future: controller.listDebugBikes(),
        builder: (context, snapshot) {
          Widget body;
          if (snapshot.connectionState != ConnectionState.done) {
            body = const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            body = SizedBox(
              height: 160,
              child: Center(
                child: Text(
                  'Debug: could not load bikes',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            );
          } else if (snapshot.data!.isEmpty) {
            body = SizedBox(
              height: 160,
              child: Center(
                child: Text(
                  'Debug: no bikes in system',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            );
          } else {
            final bikes = snapshot.data!;
            body = Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: bikes.length,
                itemBuilder: (context, index) {
                  final bike = bikes[index];
                  return ListTile(
                    leading: const Icon(Icons.pedal_bike_rounded),
                    title: Text(bike.code),
                    subtitle: Text(
                      '${_debugBikeStatusLabel(bike.status)} · '
                      'battery ${bike.batteryPercent}%',
                    ),
                    onTap: () => Navigator.pop(context, bike),
                  );
                },
              ),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text(
                  'Debug: choose a bike',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              body,
            ],
          );
        },
      ),
    );
  }
}

String _debugBikeStatusLabel(BikeDatabaseStatus status) => switch (status) {
  BikeDatabaseStatus.available => 'available',
  BikeDatabaseStatus.reserved => 'reserved',
  BikeDatabaseStatus.inUse => 'in use',
  BikeDatabaseStatus.maintenance => 'maintenance',
  BikeDatabaseStatus.retired => 'retired',
};

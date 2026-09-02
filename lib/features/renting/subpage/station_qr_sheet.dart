part of '../renting_flow_page.dart';

/// Verified return entry point: scans the QR poster at the station (falls back
/// to manual station-code entry) and, on success, submits the return with the
/// rider's current position for the server-side geofence check.
Future<void> _handleStationScan(
  BuildContext context,
  RentingController controller,
) async {
  final input = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => _StationQrSheet(controller: controller),
  );
  if (input == null || input.trim().isEmpty) return;
  await controller.selectStationFromQr(input.trim());
  if (controller.error == null &&
      controller.stationQrToken != null &&
      controller.isAtStation) {
    await controller.beginReturn();
  }
}

class _StationQrSheet extends StatefulWidget {
  const _StationQrSheet({required this.controller});

  final RentingController controller;

  @override
  State<_StationQrSheet> createState() => _StationQrSheetState();
}

class _StationQrSheetState extends State<_StationQrSheet> {
  final _inputController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _submit(String value) {
    if (_submitted || value.trim().isEmpty) return;
    _submitted = true;
    Navigator.pop(context, value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.scanStationQr,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.scanStationQrDescription,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: MobileScanner(
                    key: const ValueKey('rent-station-scanner'),
                    onDetect: (capture) {
                      final barcode = capture.barcodes.firstOrNull;
                      final value = barcode?.rawValue;
                      if (value != null && value.trim().isNotEmpty) {
                        _submit(value);
                      }
                    },
                    errorBuilder: (context, error) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.videocam_off_rounded,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.l10n.cameraUnavailable,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey<String>('rent-station-code-input'),
                      controller: _inputController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: context.l10n.stationCodeLabel,
                        hintText: context.l10n.stationCodeHint,
                        prefixIcon: const Icon(Icons.qr_code_2_rounded),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: _submit,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: const ValueKey<String>('rent-station-code-submit'),
                    onPressed: () => _submit(_inputController.text),
                    child: Text(context.l10n.confirm),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final station in widget.controller.stations)
                    ActionChip(
                      key: ValueKey('rent-station-chip-${station.id}'),
                      label: Text(station.id),
                      onPressed: () => _submit(station.id),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

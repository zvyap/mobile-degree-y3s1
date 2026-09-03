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
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const ValueKey<String>('rent-choose-bike-button'),
          onPressed: () => _handleCameraTap(context, controller),
          icon: const Icon(Icons.touch_app_rounded),
          label: const Text('Choose Bike or Enter Code'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
}

Future<void> _handleCameraTap(
  BuildContext context,
  RentingController controller,
) async {
  final token = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => _DebugBikePickerSheet(controller: controller),
  );
  if (token == null || token.trim().isEmpty) return;
  await controller.scanBike(token.trim());
}

class _DebugBikePickerSheet extends StatefulWidget {
  const _DebugBikePickerSheet({required this.controller});

  final RentingController controller;

  @override
  State<_DebugBikePickerSheet> createState() => _DebugBikePickerSheetState();
}

class _DebugBikePickerSheetState extends State<_DebugBikePickerSheet> {
  final _inputController = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: FutureBuilder<List<BikeDatabaseRecord>>(
          future: widget.controller.listDebugBikes(),
          builder: (context, snapshot) {
            final bikes = snapshot.data ?? const [];
            final filteredBikes = _filter.isEmpty
                ? bikes
                : bikes.where((b) {
                    final query = _filter.toLowerCase();
                    return b.code.toLowerCase().contains(query) ||
                        b.status.name.toLowerCase().contains(query);
                  }).toList(growable: false);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Debug: choose a bike',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey<String>('rent-debug-qr-input'),
                          controller: _inputController,
                          decoration: InputDecoration(
                            labelText: 'QR UUID, URL, or Bike Code',
                            hintText: 'e.g. BIKE-C042',
                            prefixIcon: const Icon(Icons.qr_code_2_rounded),
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              Navigator.pop(context, value.trim());
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        key: const ValueKey<String>('rent-debug-qr-submit'),
                        onPressed: () {
                          final text = _inputController.text.trim();
                          if (text.isNotEmpty) {
                            Navigator.pop(context, text);
                          }
                        },
                        child: const Text('Scan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.star_rounded, size: 18),
                        label: const Text('Default BIKE-C042'),
                        onPressed: () => Navigator.pop(
                          context,
                          RentingController.demoBikeQrToken,
                        ),
                      ),
                      FilterChip(
                        label: const Text('Available only'),
                        selected: _filter == 'available',
                        onSelected: (selected) {
                          setState(() {
                            _filter = selected ? 'available' : '';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (snapshot.connectionState != ConnectionState.done)
                    const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (snapshot.hasError)
                    SizedBox(
                      height: 120,
                      child: Center(
                        child: Text(
                          'Debug: could not load bikes: ${snapshot.error}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.error,
                          ),
                        ),
                      ),
                    )
                  else if (filteredBikes.isEmpty)
                    SizedBox(
                      height: 120,
                      child: Center(
                        child: Text(
                          bikes.isEmpty
                              ? 'Debug: no bikes in system'
                              : 'No matching bikes found',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredBikes.length,
                        itemBuilder: (context, index) {
                          final bike = filteredBikes[index];
                          final isAvailable =
                              bike.status == BikeDatabaseStatus.available;
                          return ListTile(
                            leading: Icon(
                              Icons.pedal_bike_rounded,
                              color: isAvailable
                                  ? scheme.primary
                                  : scheme.onSurface.withValues(alpha: 0.45),
                            ),
                            title: Text(
                              bike.code,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${_debugBikeStatusLabel(bike.status)} · '
                              'battery ${bike.batteryPercent}%',
                            ),
                            trailing: isAvailable
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: scheme.secondary.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Available',
                                      style: TextStyle(
                                        color: scheme.secondary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : null,
                            onTap: () => Navigator.pop(
                              context,
                              bike.qrToken.isNotEmpty
                                  ? bike.qrToken
                                  : bike.code,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
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
  BikeDatabaseStatus.lost => 'lost',
};

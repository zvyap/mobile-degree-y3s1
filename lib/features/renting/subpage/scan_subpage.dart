part of '../renting_flow_page.dart';

class ScanStage extends StatefulWidget {
  const ScanStage({
    required this.controller,
    @visibleForTesting this.scannerController,
    @visibleForTesting this.mockPermissionDenied,
    @visibleForTesting this.onGrantPermission,
    super.key,
  });

  final RentingController controller;
  final MobileScannerController? scannerController;
  final bool? mockPermissionDenied;
  final VoidCallback? onGrantPermission;

  @override
  State<ScanStage> createState() => _ScanStageState();
}

typedef _ScanStage = ScanStage;

class _ScanStageState extends State<ScanStage> with WidgetsBindingObserver {
  MobileScannerController? _scannerController;
  bool _isProcessing = false;
  bool _isShowingErrorDialog = false;
  bool _torchOn = false;
  String? _lastScannedValue;
  DateTime? _lastScanTime;

  bool get _isTest => Platform.environment.containsKey('FLUTTER_TEST');

  bool get _isPermissionDenied {
    if (widget.mockPermissionDenied != null) {
      return widget.mockPermissionDenied!;
    }
    final controller = _scannerController;
    if (controller == null) return false;
    final state = controller.value;
    return state.error?.errorCode == MobileScannerErrorCode.permissionDenied ||
        (state.isInitialized && !state.hasCameraPermission);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!_isTest || widget.scannerController != null) {
      _initScanner();
    }
  }

  void _initScanner() {
    _scannerController = widget.scannerController ??
        MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          detectionTimeoutMs: 250,
          formats: const [BarcodeFormat.qrCode],
          autoZoom: true,
          returnImage: false,
          facing: CameraFacing.back,
        );
    _scannerController!.addListener(_onScannerStateChanged);
  }

  void _onScannerStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant _ScanStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scannerController != widget.scannerController) {
      oldWidget.scannerController?.removeListener(_onScannerStateChanged);
      _scannerController = widget.scannerController;
      _scannerController?.addListener(_onScannerStateChanged);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isTest || _scannerController == null) return;
    final controller = _scannerController!;

    switch (state) {
      case AppLifecycleState.resumed:
        if (!controller.value.isRunning && !controller.value.isStarting) {
          unawaited(controller.start().catchError((_) {}));
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        if (controller.value.isRunning) {
          unawaited(controller.stop().catchError((_) {}));
        }
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController?.removeListener(_onScannerStateChanged);
    if (widget.scannerController == null) {
      unawaited(_scannerController?.dispose());
    }
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || _isShowingErrorDialog || widget.controller.isBusy) {
      return;
    }
    final now = DateTime.now();

    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue?.trim();
      if (raw == null || raw.isEmpty) continue;

      if (raw == _lastScannedValue &&
          _lastScanTime != null &&
          now.difference(_lastScanTime!).inMilliseconds < 2000) {
        continue;
      }

      _lastScannedValue = raw;
      _lastScanTime = now;
      _isProcessing = true;

      widget.controller.scanBike(raw).whenComplete(() {
        if (!mounted) return;
        setState(() => _isProcessing = false);
        if (widget.controller.error == RentalError.invalidQr) {
          _showInvalidQrDialog();
        }
      });
      break;
    }
  }

  Future<void> _showInvalidQrDialog() async {
    if (!mounted || _isShowingErrorDialog) return;
    setState(() => _isShowingErrorDialog = true);
    await showInvalidQrDialog(context, controller: widget.controller);
    if (mounted) {
      setState(() {
        _isShowingErrorDialog = false;
        _lastScanTime = DateTime.now();
      });
    }
  }

  Future<void> _toggleTorch() async {
    final controller = _scannerController;
    if (controller == null || !controller.value.isRunning) return;
    try {
      await controller.toggleTorch();
      if (mounted) {
        setState(() => _torchOn = !_torchOn);
      }
    } catch (_) {}
  }

  Future<void> _grantPermission() async {
    widget.onGrantPermission?.call();
    final controller = _scannerController;
    if (controller == null) return;
    try {
      await controller.start();
    } catch (_) {}
    if (mounted && _isPermissionDenied) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.cameraPermissionSettingsPrompt),
          action: SnackBarAction(
            label: context.l10n.settings,
            onPressed: () {
              unawaited(Geolocator.openAppSettings());
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 0.82,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: (_isTest && widget.scannerController == null)
                ? (widget.mockPermissionDenied == true
                    ? _buildNoPermissionView(context)
                    : _buildFallbackPreview(context))
                : Stack(
                    children: [
                      Positioned.fill(
                        child: MobileScanner(
                          controller: _scannerController,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error) {
                            if (error.errorCode ==
                                MobileScannerErrorCode.permissionDenied) {
                              return _buildNoPermissionView(context);
                            }
                            return _buildFallbackPreview(context);
                          },
                          onDetect: _onDetect,
                        ),
                      ),
                      if (_isPermissionDenied)
                        Positioned.fill(
                          child: _buildNoPermissionView(context),
                        )
                      else
                        _buildOverlay(context),
                    ],
                  ),
          ),
        ),
        if (widget.controller.error != null && !_isShowingErrorDialog) ...[
          const SizedBox(height: 10),
          _ErrorPanel(message: _rentalError(context, widget.controller)),
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
          onPressed: () => _handleCameraTap(
            context,
            widget.controller,
            onInvalidQr: _showInvalidQrDialog,
          ),
          icon: const Icon(Icons.touch_app_rounded),
          label: const Text('Choose Bike or Enter Code'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildNoPermissionView(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      label:
          '${context.l10n.cameraNoPermission}. ${context.l10n.cameraPermissionDescription}',
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1D24),
              scheme.error.withValues(alpha: 0.12),
              const Color(0xFF0D0F14),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Camera status pill top left
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.no_photography_rounded,
                      color: scheme.error,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.cameraNoPermission,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Center icon & "No Permission"
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: scheme.error.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: scheme.error.withValues(alpha: 0.35),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.no_photography_rounded,
                        size: 40,
                        color: scheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.cameraNoPermission,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom small description and Grant Permission button
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.l10n.cameraPermissionDescription,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      key: const ValueKey<String>('rent-grant-permission-button'),
                      onPressed: _grantPermission,
                      icon: const Icon(Icons.camera_alt_rounded, size: 18),
                      label: Text(context.l10n.grantPermission),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Stack(
      children: [
        // Camera status pill top left
        Positioned(
          top: 14,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _isProcessing ? 'Scanning...' : context.l10n.cameraReady,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Control top right (Torch)
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _torchOn
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
                color: _torchOn ? Colors.amber : Colors.white,
                size: 20,
              ),
              tooltip: 'Flashlight',
              onPressed: _toggleTorch,
            ),
          ),
        ),

        // Viewfinder corners in the center
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
                if (_isProcessing)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: scheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Bottom guide text
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.l10n.pointCamera,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackPreview(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      button: true,
      label: context.l10n.cameraPreviewSemantics,
      child: GestureDetector(
        key: const ValueKey<String>('rent-camera-preview'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleCameraTap(
          context,
          widget.controller,
          onInvalidQr: _showInvalidQrDialog,
        ),
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
    );
  }
}

Future<void> showInvalidQrDialog(
  BuildContext context, {
  RentingController? controller,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final scheme = theme.colorScheme;
      return AlertDialog(
        icon: Icon(
          Icons.qr_code_scanner_rounded,
          size: 32,
          color: scheme.error,
        ),
        title: const Text('Invalid QR Code'),
        content: Text(
          dialogContext.l10n.errorInvalidQr,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            key: const ValueKey<String>('rent-invalid-qr-ok-button'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(120, 48),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
  controller?.clearError();
}

Future<void> _handleCameraTap(
  BuildContext context,
  RentingController controller, {
  Future<void> Function()? onInvalidQr,
}) async {
  final token = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => _DebugBikePickerSheet(controller: controller),
  );
  if (token == null || token.trim().isEmpty) return;
  await controller.scanBike(token.trim());
  if (controller.error == RentalError.invalidQr) {
    if (onInvalidQr != null) {
      await onInvalidQr();
    } else if (context.mounted) {
      await showInvalidQrDialog(context, controller: controller);
    }
  }
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

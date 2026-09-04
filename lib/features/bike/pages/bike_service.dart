import 'package:flutter/material.dart';

import '../models/bike.dart';
import '../repositories/bike_repository.dart';

class ServiceBikePage extends StatefulWidget {
  const ServiceBikePage({
    super.key,
    required this.bikeId,
  });

  final int bikeId;

  @override
  State<ServiceBikePage> createState() =>
      _ServiceBikePageState();
}

class _ServiceBikePageState extends State<ServiceBikePage> {
  final BikeRepository _bikeRepository = BikeRepository();

  Bike? _bike;

  bool _isLoading = true;
  bool _isSaving = false;

  String? _error;

  bool _brakeSystem = false;
  bool _tyres = false;
  bool _chainAndGears = false;
  bool _seatAndFrame = false;
  bool _bellAndLights = false;
  bool _qrLock = false;

  // ===========================================================================
  // CHECKLIST
  // ===========================================================================

  int get _completedCount {
    final checklist = [
      _brakeSystem,
      _tyres,
      _chainAndGears,
      _seatAndFrame,
      _bellAndLights,
      _qrLock,
    ];

    return checklist.where((item) => item).length;
  }

  bool get _allCompleted {
    return _completedCount == 6;
  }

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _loadBike();
  }

  // ===========================================================================
  // LOAD BIKE
  // ===========================================================================

  Future<void> _loadBike() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final bike = await _bikeRepository.getBike(
        widget.bikeId,
      );

      if (!mounted) return;

      setState(() {
        _bike = bike;
        _isLoading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  // ===========================================================================
  // START SERVICE
  // ===========================================================================

  Future<void> _startService() async {
    final bike = _bike;

    if (bike == null || _isSaving) {
      return;
    }

    if (bike.status == 'reserved') {
      showSnackBar(
        'A reserved bike cannot be serviced.',
      );
      return;
    }

    if (bike.status == 'in_use') {
      showSnackBar(
        'A bike currently in use cannot be serviced.',
      );
      return;
    }

    if (bike.status == 'retired') {
      showSnackBar(
        'A retired bike cannot be serviced.',
      );
      return;
    }

    if (bike.status == 'maintenance') {
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      await _bikeRepository.startBikeService(
        bikeId: widget.bikeId,
      );

      if (!mounted) return;

      final updatedBike = await _bikeRepository.getBike(
        widget.bikeId,
      );

      if (!mounted) return;

      setState(() {
        _bike = updatedBike;
        _isSaving = false;
      });

      showSnackBar(
        'Bike service started',
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      showSnackBar(
        'Failed to start service: $error',
      );
    }
  }

  // ===========================================================================
  // COMPLETE SERVICE
  // ===========================================================================

  Future<void> _completeService() async {
    final bike = _bike;

    if (bike == null || _isSaving) {
      return;
    }

    if (bike.status != 'maintenance') {
      showSnackBar(
        'Start the service before completing it.',
      );
      return;
    }

    if (!_allCompleted) {
      showSnackBar(
        'Complete all inspection items first.',
      );
      return;
    }

    // Your DB requires an available bike to have a station.
    if (bike.currentStationId == null) {
      showSnackBar(
        'Assign the bike to a station before completing service.',
      );
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      await _bikeRepository.completeBikeService(
        bikeId: widget.bikeId,
      );

      if (!mounted) return;

      showSnackBar(
        'Bike service completed successfully',
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      showSnackBar(
        'Failed to complete service: $error',
      );
    }
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  void showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'available':
        return 'Available';

      case 'reserved':
        return 'Reserved';

      case 'in_use':
        return 'In use';

      case 'maintenance':
        return 'In service';

      case 'retired':
        return 'Retired';

      default:
        return status;
    }
  }

  bool _serviceBlocked(String status) {
    return status == 'reserved' ||
        status == 'in_use' ||
        status == 'retired';
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // -------------------------------------------------------------------------
    // Loading
    // -------------------------------------------------------------------------

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // -------------------------------------------------------------------------
    // Error
    // -------------------------------------------------------------------------

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: scheme.error,
              ),

              const SizedBox(height: 12),

              const Text(
                'Unable to load bike',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _error!,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _loadBike,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bike = _bike!;

    final blocked = _serviceBlocked(
      bike.status,
    );

    final inService =
        bike.status == 'maintenance';

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        32,
      ),
      children: [
        // =====================================================================
        // TITLE
        // =====================================================================

        Text(
          'Service',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Inspect and service ${bike.code}.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(
              alpha: 0.7,
            ),
          ),
        ),

        const SizedBox(height: 18),

        // =====================================================================
        // BIKE SUMMARY
        // =====================================================================

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outline.withValues(
                alpha: 0.8,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFFFF3D6,
                  ),
                  borderRadius:
                  BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.directions_bike_rounded,
                  size: 36,
                  color: Color(
                    0xFFE7B928,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      bike.code,
                      style:
                      theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: scheme.primary,
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            bike.stationName ??
                                'No station assigned',
                            style:
                            theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: inService
                      ? const Color(
                    0xFFFFF3D6,
                  )
                      : scheme.surfaceContainerHighest,
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(
                    bike.status,
                  ),
                  style: TextStyle(
                    color: inService
                        ? const Color(
                      0xFFE6A919,
                    )
                        : scheme.onSurface,
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // =====================================================================
        // BLOCKED MESSAGE
        // =====================================================================

        if (blocked) ...[
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.block_rounded,
                  color:
                  scheme.onErrorContainer,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    bike.status == 'reserved'
                        ? 'This bike is currently reserved and cannot enter service.'
                        : bike.status == 'in_use'
                        ? 'This bike is currently in use and cannot enter service.'
                        : 'This bike has been retired and cannot enter service.',
                    style: TextStyle(
                      color:
                      scheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 28),

        // =====================================================================
        // SERVICE STATE
        // =====================================================================

        if (!blocked && !inService) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
              scheme.surfaceContainerHighest,
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.build_outlined,
                  color: scheme.primary,
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'Start service to place this bike into maintenance mode before carrying out the inspection.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _isSaving
                  ? null
                  : _startService,
              icon: _isSaving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(
                Icons.build_rounded,
              ),
              label: const Text(
                'Start Service',
                style: TextStyle(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ),
        ],

        // =====================================================================
        // INSPECTION CHECKLIST
        // =====================================================================

        if (inService) ...[
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Inspection checklist',
                style:
                theme.textTheme.titleMedium?.copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              Text(
                '$_completedCount of 6 complete',
                style:
                theme.textTheme.labelMedium?.copyWith(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius:
              BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outline.withValues(
                  alpha: 0.8,
                ),
              ),
            ),
            child: Column(
              children: [
                _InspectionItem(
                  title: 'Brake system',
                  completed: _brakeSystem,
                  onChanged: (value) {
                    setState(() {
                      _brakeSystem = value;
                    });
                  },
                ),

                _InspectionItem(
                  title: 'Front & rear tyres',
                  completed: _tyres,
                  onChanged: (value) {
                    setState(() {
                      _tyres = value;
                    });
                  },
                ),

                _InspectionItem(
                  title: 'Chain and gears',
                  completed: _chainAndGears,
                  onChanged: (value) {
                    setState(() {
                      _chainAndGears = value;
                    });
                  },
                ),

                _InspectionItem(
                  title: 'Seat and frame',
                  completed: _seatAndFrame,
                  onChanged: (value) {
                    setState(() {
                      _seatAndFrame = value;
                    });
                  },
                ),

                _InspectionItem(
                  title: 'Bell and lights',
                  completed: _bellAndLights,
                  onChanged: (value) {
                    setState(() {
                      _bellAndLights = value;
                    });
                  },
                ),

                _InspectionItem(
                  title: 'QR lock mechanism',
                  completed: _qrLock,
                  showDivider: false,
                  onChanged: (value) {
                    setState(() {
                      _qrLock = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ===================================================================
          // CHECKLIST INFO
          // ===================================================================

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:
              scheme.surfaceContainerHighest,
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: scheme.primary,
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'All inspection items must be completed before the bike can return to Available status.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ===================================================================
          // COMPLETE SERVICE
          // ===================================================================

          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed:
              _isSaving || !_allCompleted
                  ? null
                  : _completeService,
              style: FilledButton.styleFrom(
                backgroundColor:
                const Color(
                  0xFFFFF3D6,
                ),
                foregroundColor:
                const Color(
                  0xFFF29B00,
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                width: 22,
                height: 22,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'Complete Service',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// =============================================================================
// INSPECTION ITEM
// =============================================================================

class _InspectionItem extends StatelessWidget {
  const _InspectionItem({
    required this.title,
    required this.completed,
    required this.onChanged,
    this.showDivider = true,
  });

  final String title;
  final bool completed;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: () {
            onChanged(!completed);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 11,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 150,
                  ),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: completed
                        ? const Color(
                      0xFF18C796,
                    )
                        : scheme.surface,
                    borderRadius:
                    BorderRadius.circular(7),
                    border: Border.all(
                      color: completed
                          ? const Color(
                        0xFF18C796,
                      )
                          : scheme.outline,
                    ),
                  ),
                  child: completed
                      ? const Icon(
                    Icons.check_rounded,
                    size: 19,
                    color: Colors.white,
                  )
                      : null,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    style:
                    theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),

                Text(
                  completed
                      ? 'Done'
                      : 'Pending',
                  style:
                  theme.textTheme.labelSmall?.copyWith(
                    color: completed
                        ? const Color(
                      0xFF18C796,
                    )
                        : scheme.onSurface
                        .withValues(
                      alpha: 0.6,
                    ),
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (showDivider)
          Padding(
            padding:
            const EdgeInsets.only(
              left: 38,
            ),
            child: Divider(
              height: 1,
              color:
              scheme.outline.withValues(
                alpha: 0.7,
              ),
            ),
          ),
      ],
    );
  }
}
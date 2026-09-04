import 'package:flutter/material.dart';

import '../models/bike.dart';
import '../models/station_availability.dart';
import '../repositories/bike_repository.dart';
import '../repositories/station_repository.dart';

class TransferBikePage extends StatefulWidget {
  const TransferBikePage({
    super.key,
    required this.bikeId,
  });

  final int bikeId;

  @override
  State<TransferBikePage> createState() =>
      _TransferBikePageState();
}

class _TransferBikePageState extends State<TransferBikePage> {
  final BikeRepository _bikeRepository = BikeRepository();

  final StationRepository _stationRepository =
  StationRepository();

  Bike? _bike;

  List<StationAvailability> _stations = [];

  int? _destinationStationId;

  bool _isLoading = true;
  bool _isTransferring = false;

  String? _error;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  // ===========================================================================
  // LOAD BIKE + STATIONS
  // ===========================================================================

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final bike = await _bikeRepository.getBike(
        widget.bikeId,
      );

      final stations =
      await _stationRepository.getStationAvailability();

      if (!mounted) return;

      final availableDestinations = stations.where((station) {
        return station.id != bike.currentStationId;
      }).toList();

      setState(() {
        _bike = bike;
        _stations = availableDestinations;

        if (availableDestinations.isNotEmpty) {
          _destinationStationId =
              availableDestinations.first.id;
        }

        _isLoading = false;
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
  // TRANSFER BIKE
  // ===========================================================================

  Future<void> _transferBike() async {
    if (_isTransferring) return;

    final bike = _bike;

    if (bike == null) {
      return;
    }

    if (_destinationStationId == null) {
      showSnackBar(
        'Please select a destination station',
      );
      return;
    }

    // Rental system controls these states.
    if (bike.status == 'in_use') {
      showSnackBar(
        'A bike currently in use cannot be transferred.',
      );
      return;
    }

    if (bike.status == 'reserved') {
      showSnackBar(
        'A reserved bike cannot be transferred.',
      );
      return;
    }

    final destination = _getDestinationStation();

    if (destination == null) {
      showSnackBar(
        'Destination station could not be found.',
      );
      return;
    }

    if (!destination.isActive) {
      showSnackBar(
        'Destination station is inactive.',
      );
      return;
    }

    if (destination.availableDocks <= 0) {
      showSnackBar(
        'Destination station has no available docks.',
      );
      return;
    }

    try {
      setState(() {
        _isTransferring = true;
      });

      await _bikeRepository.transferBike(
        bikeId: widget.bikeId,
        stationId: _destinationStationId!,
      );

      if (!mounted) return;

      showSnackBar(
        'Bike transferred successfully',
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isTransferring = false;
      });

      showSnackBar(
        'Failed to transfer bike: $error',
      );
    }
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  StationAvailability? _getCurrentStation() {
    final bike = _bike;

    if (bike?.currentStationId == null) {
      return null;
    }

    // Current station was excluded from destination list,
    // so we cannot search _stations for it.
    return null;
  }

  StationAvailability? _getDestinationStation() {
    if (_destinationStationId == null) {
      return null;
    }

    for (final station in _stations) {
      if (station.id == _destinationStationId) {
        return station;
      }
    }

    return null;
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
        return 'Maintenance';

      case 'retired':
        return 'Retired';

      default:
        return status;
    }
  }

  void showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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
                color: scheme.error,
                size: 48,
              ),

              const SizedBox(height: 12),

              const Text(
                'Unable to load transfer information',
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
                onPressed: _loadData,
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
    final destination = _getDestinationStation();

    final bool transferBlocked =
        bike.status == 'in_use' ||
            bike.status == 'reserved';

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
          'Transfer bike',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Move ${bike.code} to another station.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(
              alpha: 0.7,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // =====================================================================
        // BIKE CARD
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.directions_bike_rounded,
                  color: scheme.onPrimaryContainer,
                  size: 34,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      bike.code,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _statusLabel(bike.status),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      bike.stationName ??
                          'No station assigned',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // =====================================================================
        // BLOCKED STATUS
        // =====================================================================

        if (transferBlocked) ...[
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.block_rounded,
                  color: scheme.onErrorContainer,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    bike.status == 'in_use'
                        ? 'This bike is currently in use and cannot be transferred.'
                        : 'This bike is currently reserved and cannot be transferred.',
                    style: TextStyle(
                      color: scheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 22),

        // =====================================================================
        // TRANSFER ROUTE
        // =====================================================================

        Text(
          'Transfer route',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outline.withValues(
                alpha: 0.8,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------------------------
              // FROM
              // ----------------------------------------------------------------

              Text(
                'FROM',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  Icon(
                    Icons.trip_origin_rounded,
                    color: scheme.primary,
                    size: 20,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      bike.stationName ??
                          'No station assigned',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  const SizedBox(width: 9),

                  Container(
                    width: 2,
                    height: 32,
                    color: scheme.outline.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ----------------------------------------------------------------
              // TO
              // ----------------------------------------------------------------

              Text(
                'TO',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              if (_stations.isEmpty)
                const Text(
                  'No destination stations are available.',
                )
              else
                DropdownButtonFormField<int>(
                  initialValue: _destinationStationId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                    ),
                  ),
                  items: _stations.map((station) {
                    return DropdownMenuItem<int>(
                      value: station.id,
                      enabled: station.availableDocks > 0,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              station.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          Text(
                            '${station.availableDocks} docks',
                            style:
                            theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged:
                  transferBlocked || _isTransferring
                      ? null
                      : (value) {
                    setState(() {
                      _destinationStationId =
                          value;
                    });
                  },
                ),

              if (destination != null) ...[
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                    scheme.surfaceContainerHighest,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      _StationInfoRow(
                        label: 'Available bikes',
                        value:
                        '${destination.availableBikes}',
                      ),

                      const SizedBox(height: 6),

                      _StationInfoRow(
                        label: 'Available docks',
                        value:
                        '${destination.availableDocks}',
                      ),

                      const SizedBox(height: 6),

                      _StationInfoRow(
                        label: 'Capacity',
                        value:
                        '${destination.capacity}',
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // =====================================================================
        // INFO
        // =====================================================================

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: scheme.primary,
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'The bike location will be updated immediately after confirmation.',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // =====================================================================
        // CONFIRM
        // =====================================================================

        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed:
            transferBlocked ||
                _isTransferring ||
                _destinationStationId == null ||
                destination?.availableDocks == 0
                ? null
                : _transferBike,
            child: _isTransferring
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.compare_arrows_rounded,
                ),

                SizedBox(width: 8),

                Text(
                  'Confirm transfer',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// STATION INFO ROW
// =============================================================================

class _StationInfoRow extends StatelessWidget {
  const _StationInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall,
          ),
        ),

        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
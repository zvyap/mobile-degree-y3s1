import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

import '../models/bike.dart';
import '../repositories/bike_repository.dart';
import '../widgets/bike_qr_modal.dart';

class BikeManagementPage extends StatefulWidget {
  const BikeManagementPage({
    super.key,
    required this.onAddBike,
    required this.onOpenBikeDetails,
    required this.onOpenReportList,
    required this.onMakeReport,
  });

  static const Color _cardColor = Color(0xFF1D2939);
  static const Color _accentColor = Color(0xFF0E8EA8);
  static const Color _borderColor = Color(0xFFD2DCE6);

  final ValueChanged<String> onOpenBikeDetails;
  final VoidCallback onOpenReportList;
  final VoidCallback onAddBike;
  final ValueChanged<String> onMakeReport;

  @override
  State<BikeManagementPage> createState() =>
      _BikeManagementPageState();
}

class _BikeManagementPageState extends State<BikeManagementPage> {
  final BikeRepository _bikeRepository = BikeRepository();

  List<Bike> _bikes = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBikes();
  }

  // ===========================================================================
  // LOAD BIKES FROM SUPABASE
  // ===========================================================================

  Future<void> _loadBikes() async {
    try {
      if (_bikes.isEmpty) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final bikes = await _bikeRepository.getBikes();

      if (!mounted) return;

      setState(() {
        _bikes = bikes;
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
  // BUILD PAGE
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadBikes,
      child: ListView(
        key: const ValueKey<String>('bike-management-page'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: [
          // -------------------------------------------------------------------
          // Title + buttons
          // -------------------------------------------------------------------

          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.fleetDescription,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.80),
                    fontSize: 16,
                  ),
                ),
              ),

              FilledButton.icon(
                onPressed: widget.onAddBike,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Bike'),
              ),

              const SizedBox(width: 8),

              OutlinedButton.icon(
                onPressed: widget.onOpenReportList,
                icon: const Icon(Icons.report_outlined),
                label: const Text('Reports'),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // -------------------------------------------------------------------
          // Search
          // -------------------------------------------------------------------

          const _SearchSection(),

          const SizedBox(height: 18),

          // -------------------------------------------------------------------
          // Status filters
          // -------------------------------------------------------------------

          _BikeStatusFilters(
            bikes: _bikes,
          ),

          const SizedBox(height: 24),

          // -------------------------------------------------------------------
          // Bike count
          // -------------------------------------------------------------------

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_bikes.length} ${_bikes.length == 1 ? 'bike' : 'bikes'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Sort: Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // -------------------------------------------------------------------
          // Loading state
          // -------------------------------------------------------------------

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )

          // -------------------------------------------------------------------
          // Error state
          // -------------------------------------------------------------------

          else if (_error != null)
            _buildErrorSection()

          // -------------------------------------------------------------------
          // Empty state
          // -------------------------------------------------------------------

          else if (_bikes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Center(
                  child: Text(
                    'No bikes found',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
              )

            // -------------------------------------------------------------------
            // Bike cards from Supabase
            // -------------------------------------------------------------------

            else
              for (int index = 0; index < _bikes.length; index++) ...[
                _buildBikeCard(
                  context,
                  _bikes[index],
                ),
                if (index != _bikes.length - 1)
                  const SizedBox(height: 16),
              ],
        ],
      ),
    );
  }

  // ===========================================================================
  // CREATE CARD FROM BIKE MODEL
  // ===========================================================================

  Widget _buildBikeCard(
      BuildContext context,
      Bike bike,
      ) {
    final BikeStatus bikeStatus = _convertBikeStatus(
      bike.status,
    );

    return _BikeCard(
      bikeId: bike.code,

      // Temporary until "model" exists in your Supabase table.
      model: 'Standard Bike',

      status: bikeStatus,

      // Temporary: currently this displays current_station_id.
      location:
      bike.stationName ??
          'No station assigned',

      description: _buildBikeDescription(bike),

      onViewDetails: () {
        widget.onOpenBikeDetails(
          bike.id,
        );
      },

      onMakeReport: () {
        widget.onMakeReport(
          bike.id,
        );
      },

      onShowQr: () {
        BikeQrModal.show(
          context,
          bikeCode: bike.code,
          qrToken: bike.qrToken,
          stationName: bike.stationName,
          status: bike.status,
        );
      },
    );
  }

  // ===========================================================================
  // BIKE DESCRIPTION
  // ===========================================================================

  String _buildBikeDescription(Bike bike) {
    final List<String> description = [];

    if (bike.batteryPercent != null) {
      description.add(
        'Battery ${bike.batteryPercent}%',
      );
    }

    if (bike.lastServiceAt != null) {
      description.add(
        'Last service ${_formatDate(bike.lastServiceAt!)}',
      );
    }

    if (description.isEmpty) {
      return 'No additional information';
    }

    return description.join(' • ');
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  // ===========================================================================
  // CONVERT DATABASE STATUS -> UI STATUS
  // ===========================================================================

  BikeStatus _convertBikeStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return BikeStatus.available;

      case 'maintenance':
      case 'in_service':
      case 'in service':
      case 'service':
        return BikeStatus.inService;

      case 'rented':
      case 'in_use':
      case 'in use':
        return BikeStatus.rented;

      case 'unavailable':
      case 'disabled':
      case 'lost':
        return BikeStatus.unavailable;

      default:
        return BikeStatus.unavailable;
    }
  }

  // ===========================================================================
  // ERROR SECTION
  // ===========================================================================

  Widget _buildErrorSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 40,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 48,
          ),

          const SizedBox(height: 12),

          const Text(
            'Unable to load bikes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            _error ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: _loadBikes,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// SEARCH
// ===========================================================================

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: BikeManagementPage._cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: BikeManagementPage._borderColor,
                width: 1.4,
              ),
            ),
            child: const TextField(
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.white70,
                  size: 28,
                ),
                hintText: 'Search bike ID or model',
                hintStyle: TextStyle(
                  color: Color(0xFF8F9BAB),
                  fontSize: 16,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 17,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: BikeManagementPage._cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: BikeManagementPage._borderColor,
              width: 1.4,
            ),
          ),
          child: IconButton(
            onPressed: () {
              // Filter functionality later.
            },
            icon: const Icon(
              Icons.filter_alt_outlined,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// STATUS FILTERS
// ===========================================================================

class _BikeStatusFilters extends StatelessWidget {
  const _BikeStatusFilters({
    required this.bikes,
  });

  final List<Bike> bikes;

  @override
  Widget build(BuildContext context) {
    final int availableCount = bikes.where((bike) {
      return bike.status.toLowerCase() == 'available';
    }).length;

    final int maintenanceCount = bikes.where((bike) {
      final String status = bike.status.toLowerCase();

      return status == 'maintenance' ||
          status == 'in_service' ||
          status == 'in service' ||
          status == 'service';
    }).length;

    final int rentedCount = bikes.where((bike) {
      final String status = bike.status.toLowerCase();

      return status == 'rented' ||
          status == 'in_use' ||
          status == 'in use';
    }).length;

    final int unavailableCount = bikes.where((bike) {
      final String status = bike.status.toLowerCase();

      return status == 'unavailable' ||
          status == 'disabled' ||
          status == 'lost';
    }).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatusFilterChip(
            label: 'All ${bikes.length}',
            selected: true,
          ),

          const SizedBox(width: 10),

          _StatusFilterChip(
            label: 'Available $availableCount',
          ),

          const SizedBox(width: 10),

          _StatusFilterChip(
            label: 'Maintenance $maintenanceCount',
          ),

          const SizedBox(width: 10),

          _StatusFilterChip(
            label: 'Rented $rentedCount',
          ),

          const SizedBox(width: 10),

          _StatusFilterChip(
            label: 'Unavailable $unavailableCount',
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// STATUS FILTER CHIP
// ===========================================================================

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: selected
            ? BikeManagementPage._accentColor
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected
              ? Colors.white
              : const Color(0xFF667386),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ===========================================================================
// BIKE CARD
// ===========================================================================

class _BikeCard extends StatelessWidget {
  const _BikeCard({
    required this.bikeId,
    required this.model,
    required this.status,
    required this.location,
    required this.description,
    required this.onViewDetails,
    required this.onMakeReport,
    required this.onShowQr,
  });

  final String bikeId;
  final String model;
  final BikeStatus status;
  final String location;
  final String description;

  final VoidCallback onViewDetails;
  final VoidCallback onMakeReport;
  final VoidCallback onShowQr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BikeManagementPage._cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: BikeManagementPage._borderColor,
          width: 1.3,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------------------------------------------------------
          // Bike image placeholder
          // -------------------------------------------------------------------

          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: status.placeholderColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.directions_bike_rounded,
              size: 52,
              color: status.iconColor,
            ),
          ),

          const SizedBox(width: 14),

          // -------------------------------------------------------------------
          // Bike information
          // -------------------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        bikeId,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    _BikeStatusBadge(
                      status: status,
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  model,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF6F8397),
                      size: 23,
                    ),

                    const SizedBox(width: 5),

                    Expanded(
                      child: Text(
                        location,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    IconButton(
                      icon: const Icon(
                        Icons.qr_code_2_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: 'View QR code',
                      onPressed: onShowQr,
                    ),

                    PopupMenuButton<BikeMenuAction>(
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      onSelected: (action) {
                        switch (action) {
                          case BikeMenuAction.details:
                            onViewDetails();
                            break;

                          case BikeMenuAction.makeReport:
                            onMakeReport();
                            break;

                          case BikeMenuAction.showQr:
                            onShowQr();
                            break;
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem<BikeMenuAction>(
                          value: BikeMenuAction.details,
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                              ),
                              SizedBox(width: 10),
                              Text('Bike details'),
                            ],
                          ),
                        ),

                        PopupMenuItem<BikeMenuAction>(
                          value: BikeMenuAction.showQr,
                          child: Row(
                            children: [
                              Icon(
                                Icons.qr_code_2_rounded,
                              ),
                              SizedBox(width: 10),
                              Text('QR code'),
                            ],
                          ),
                        ),

                        PopupMenuItem<BikeMenuAction>(
                          value: BikeMenuAction.makeReport,
                          child: Row(
                            children: [
                              Icon(
                                Icons.report_outlined,
                              ),
                              SizedBox(width: 10),
                              Text('Reports'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                Text(
                  description,
                  style: TextStyle(
                    color: status.descriptionColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// STATUS BADGE
// ===========================================================================

class _BikeStatusBadge extends StatelessWidget {
  const _BikeStatusBadge({
    required this.status,
  });

  final BikeStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: status.badgeBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.badgeTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ===========================================================================
// BIKE STATUS
// ===========================================================================

enum BikeStatus {
  available,
  inService,
  rented,
  unavailable;

  String get label {
    return switch (this) {
      available => 'Available',
      inService => 'In service',
      rented => 'Rented',
      unavailable => 'Unavailable',
    };
  }

  Color get badgeBackgroundColor {
    return switch (this) {
      available => const Color(0xFFE1F6EC),
      inService => const Color(0xFFFFF3D6),
      rented => const Color(0xFFEDE5FF),
      unavailable => const Color(0xFFFFE5E5),
    };
  }

  Color get badgeTextColor {
    return switch (this) {
      available => const Color(0xFF12A36D),
      inService => const Color(0xFFE6A919),
      rented => const Color(0xFF8C5AE8),
      unavailable => const Color(0xFFE24B4B),
    };
  }

  Color get descriptionColor {
    return switch (this) {
      available => Colors.white70,
      inService => const Color(0xFFE6A919),
      rented => Colors.white70,
      unavailable => const Color(0xFFE24B4B),
    };
  }

  Color get placeholderColor {
    return switch (this) {
      available => const Color(0xFFE3F3ED),
      inService => const Color(0xFFFFF3D8),
      rented => const Color(0xFFF2F2F2),
      unavailable => const Color(0xFFF2F2F2),
    };
  }

  Color get iconColor {
    return switch (this) {
      available => const Color(0xFF618A91),
      inService => const Color(0xFFD8B844),
      rented => const Color(0xFF607D8B),
      unavailable => const Color(0xFF424242),
    };
  }
}

// ===========================================================================
// BIKE CARD ACTION
// ===========================================================================

enum BikeMenuAction {
  details,
  makeReport,
  showQr,
}
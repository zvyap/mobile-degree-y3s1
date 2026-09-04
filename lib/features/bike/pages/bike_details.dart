import 'package:flutter/material.dart';

import '../models/bike.dart';
import '../models/bike_performance.dart';
import '../models/bike_report.dart';

import '../repositories/bike_repository.dart';
import '../repositories/bike_report_repository.dart';

import '../widgets/bike_qr_modal.dart';

// =============================================================================
// MENU ACTIONS
// =============================================================================

enum BikeDetailMenuAction {
  makeReport,
  retireBike,
}

// =============================================================================
// BIKE DETAILS PAGE
// =============================================================================

class BikeDetailsPage extends StatefulWidget {
  const BikeDetailsPage({
    super.key,
    required this.bikeId,
    required this.onEditBike,
    required this.onTransferBike,
    required this.onServiceBike,
    required this.onMakeReport,
  });

  final int bikeId;

  final VoidCallback onEditBike;
  final VoidCallback onTransferBike;
  final VoidCallback onServiceBike;
  final VoidCallback onMakeReport;

  @override
  State<BikeDetailsPage> createState() =>
      _BikeDetailsPageState();
}

// =============================================================================
// STATE
// =============================================================================

class _BikeDetailsPageState extends State<BikeDetailsPage> {
  final BikeRepository _bikeRepository =
  BikeRepository();

  final BikeReportRepository _bikeReportRepository =
  BikeReportRepository();

  Bike? _bike;

  BikePerformance? _performance;

  List<BikeReport> _bikeReports = [];

  bool _isLoading = true;
  bool _isRetiring = false;

  String? _error;

  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();

    _loadBike();
  }

  // ===========================================================================
  // LOAD BIKE DETAILS
  // ===========================================================================

  Future<void> _loadBike() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // -----------------------------------------------------------------------
      // Bike
      // -----------------------------------------------------------------------

      final bike =
      await _bikeRepository.getBike(
        widget.bikeId,
      );

      // -----------------------------------------------------------------------
      // Reports belonging to this bike
      // -----------------------------------------------------------------------

      final reports =
      await _bikeReportRepository.getReportsForBike(
        widget.bikeId,
      );

      // -----------------------------------------------------------------------
      // Rental performance
      // -----------------------------------------------------------------------

      final performance =
      await _bikeRepository.getBikePerformance(
        widget.bikeId,
      );

      if (!mounted) return;

      setState(() {
        _bike = bike;
        _bikeReports = reports;
        _performance = performance;

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
  // SNACKBAR
  // ===========================================================================

  void showSnackBar(String message) {
    final messenger =
    ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ===========================================================================
  // MENU
  // ===========================================================================

  void _handleMenuAction(
      BikeDetailMenuAction action,
      ) {
    switch (action) {
      case BikeDetailMenuAction.makeReport:
        widget.onMakeReport();
        break;

      case BikeDetailMenuAction.retireBike:
        _confirmRetireBike();
        break;
    }
  }

  // ===========================================================================
  // BIKE STATUS
  // ===========================================================================

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

  Color _statusBackgroundColor(
      String status,
      ) {
    switch (status) {
      case 'available':
        return const Color(
          0xFFDDF7E9,
        );

      case 'reserved':
        return const Color(
          0xFFDDEBFF,
        );

      case 'in_use':
        return const Color(
          0xFFEDE5FF,
        );

      case 'maintenance':
        return const Color(
          0xFFFFF3D6,
        );

      case 'retired':
        return const Color(
          0xFFFFE5E5,
        );

      default:
        return const Color(
          0xFFE8E8E8,
        );
    }
  }

  Color _statusTextColor(
      String status,
      ) {
    switch (status) {
      case 'available':
        return const Color(
          0xFF159A67,
        );

      case 'reserved':
        return const Color(
          0xFF3478C8,
        );

      case 'in_use':
        return const Color(
          0xFF8C5AE8,
        );

      case 'maintenance':
        return const Color(
          0xFFE6A919,
        );

      case 'retired':
        return const Color(
          0xFFE24B4B,
        );

      default:
        return const Color(
          0xFF666666,
        );
    }
  }

  // ===========================================================================
  // REPORT HELPERS
  // ===========================================================================

  String _reportCategoryLabel(
      String category,
      ) {
    switch (category) {
      case 'brakes':
        return 'Brake System';

      case 'tyres':
        return 'Tyres';

      case 'chain_gears':
        return 'Chain & Gears';

      case 'seat_frame':
        return 'Seat & Frame';

      case 'bell_lights':
        return 'Bell & Lights';

      case 'qr_lock':
        return 'QR / Lock';

      case 'other':
        return 'Other';

      default:
        return category;
    }
  }

  String _reportStatusLabel(
      String status,
      ) {
    switch (status) {
      case 'pending':
        return 'Pending';

      case 'approved':
        return 'Approved';

      case 'rejected':
        return 'Rejected';

      default:
        return status;
    }
  }

  String _formatReportId(int id) {
    return 'RPT-${id.toString().padLeft(4, '0')}';
  }

  // ===========================================================================
  // DATE HELPERS
  // ===========================================================================

  String _formatReportDate(
      DateTime date,
      ) {
    final local =
    date.toLocal();

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final hour =
    local.hour
        .toString()
        .padLeft(2, '0');

    final minute =
    local.minute
        .toString()
        .padLeft(2, '0');

    return '${local.day} '
        '${months[local.month - 1]} '
        '${local.year} • '
        '$hour:$minute';
  }

  String _formatDate(
      DateTime date,
      ) {
    final local =
    date.toLocal();

    final day =
    local.day
        .toString()
        .padLeft(2, '0');

    final month =
    local.month
        .toString()
        .padLeft(2, '0');

    return '$day/$month/${local.year}';
  }

  // ===========================================================================
  // RETIRE BIKE
  // ===========================================================================

  Future<void> _confirmRetireBike() async {
    final bike = _bike;

    if (bike == null ||
        _isRetiring) {
      return;
    }

    // -------------------------------------------------------------------------
    // Reserved bike
    // -------------------------------------------------------------------------

    if (bike.status == 'reserved') {
      showSnackBar(
        'A reserved bike cannot be retired.',
      );

      return;
    }

    // -------------------------------------------------------------------------
    // Bike currently being rented
    // -------------------------------------------------------------------------

    if (bike.status == 'in_use') {
      showSnackBar(
        'A bike currently in use cannot be retired.',
      );

      return;
    }

    // -------------------------------------------------------------------------
    // Already retired
    // -------------------------------------------------------------------------

    if (bike.status == 'retired') {
      showSnackBar(
        'This bike is already retired.',
      );

      return;
    }

    // -------------------------------------------------------------------------
    // Confirmation dialog
    // -------------------------------------------------------------------------

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme =
        Theme.of(dialogContext);

        final scheme =
            theme.colorScheme;

        return AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            color: scheme.error,
            size: 42,
          ),
          title: const Text(
            'Retire Bike?',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to retire ${bike.code}?',
                textAlign:
                TextAlign.center,
                style:
                theme.textTheme.bodyMedium,
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                'The bike will no longer be available for rental.',
                textAlign:
                TextAlign.center,
                style:
                theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface
                      .withValues(
                    alpha: 0.65,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child:
              const Text(
                'Cancel',
              ),
            ),

            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              style:
              FilledButton.styleFrom(
                backgroundColor:
                scheme.error,
                foregroundColor:
                scheme.onError,
              ),
              child:
              const Text(
                'Retire Bike',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    // -------------------------------------------------------------------------
    // Update database
    // -------------------------------------------------------------------------

    try {
      setState(() {
        _isRetiring = true;
      });

      await _bikeRepository.retireBike(
        bikeId: widget.bikeId,
      );

      if (!mounted) return;

      showSnackBar(
        '${bike.code} has been retired',
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isRetiring = false;
      });

      showSnackBar(
        'Failed to retire bike: $error',
      );
    }
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    // -------------------------------------------------------------------------
    // Loading
    // -------------------------------------------------------------------------

    if (_isLoading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    // -------------------------------------------------------------------------
    // Error
    // -------------------------------------------------------------------------

    if (_error != null) {
      return Center(
        child: Padding(
          padding:
          const EdgeInsets.all(
            24,
          ),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: scheme.error,
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                'Unable to load bike details',
                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                _error!,
                textAlign:
                TextAlign.center,
              ),

              const SizedBox(
                height: 16,
              ),

              OutlinedButton.icon(
                onPressed:
                _loadBike,
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

    final bike = _bike;

    if (bike == null) {
      return const Center(
        child: Text(
          'Bike not found',
        ),
      );
    }

    // -------------------------------------------------------------------------
    // Main page
    // -------------------------------------------------------------------------

    return RefreshIndicator(
      onRefresh: _loadBike,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding:
        const EdgeInsets.fromLTRB(
          18,
          16,
          18,
          32,
        ),
        children: [
          // ===================================================================
          // MAIN BIKE CARD
          // ===================================================================

          Container(
            padding:
            const EdgeInsets.all(
              12,
            ),
            decoration:
            BoxDecoration(
              color: scheme
                  .surfaceContainer,
              borderRadius:
              BorderRadius.circular(
                18,
              ),
              border:
              Border.all(
                color: scheme.outline
                    .withValues(
                  alpha: 0.8,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // -------------------------------------------------------------
                // Bike icon
                // -------------------------------------------------------------

                Container(
                  width: 104,
                  height: 104,
                  decoration:
                  BoxDecoration(
                    color: scheme
                        .primaryContainer,
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: Icon(
                    Icons.directions_bike_rounded,
                    size: 70,
                    color: scheme
                        .onPrimaryContainer,
                  ),
                ),

                const SizedBox(
                  width: 16,
                ),

                // -------------------------------------------------------------
                // Information
                // -------------------------------------------------------------

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // ---------------------------------------------------
                          // Bike code
                          // ---------------------------------------------------

                          Expanded(
                            child: Text(
                              bike.code,
                              style: theme
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                fontWeight:
                                FontWeight.w800,
                              ),
                            ),
                          ),

                          // ---------------------------------------------------
                          // Status
                          // ---------------------------------------------------

                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 5,
                            ),
                            decoration:
                            BoxDecoration(
                              color:
                              _statusBackgroundColor(
                                bike.status,
                              ),
                              borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                            ),
                            child: Text(
                              _statusLabel(
                                bike.status,
                              ),
                              style:
                              TextStyle(
                                color:
                                _statusTextColor(
                                  bike.status,
                                ),
                                fontWeight:
                                FontWeight.w700,
                                fontSize:
                                11,
                              ),
                            ),
                          ),

                          // ---------------------------------------------------
                          // Menu
                          // ---------------------------------------------------

                          PopupMenuButton<
                              BikeDetailMenuAction>(
                            padding:
                            EdgeInsets.zero,
                            icon:
                            const Icon(
                              Icons.more_vert_rounded,
                            ),
                            onSelected:
                            _handleMenuAction,
                            itemBuilder:
                                (context) {
                              return [
                                const PopupMenuItem<
                                    BikeDetailMenuAction>(
                                  value:
                                  BikeDetailMenuAction
                                      .makeReport,
                                  child:
                                  Row(
                                    children: [
                                      Icon(
                                        Icons
                                            .report_outlined,
                                        size:
                                        20,
                                      ),
                                      SizedBox(
                                        width:
                                        10,
                                      ),
                                      Text(
                                        'Make Report',
                                      ),
                                    ],
                                  ),
                                ),

                                PopupMenuItem<
                                    BikeDetailMenuAction>(
                                  value:
                                  BikeDetailMenuAction
                                      .retireBike,
                                  child:
                                  Row(
                                    children: [
                                      Icon(
                                        Icons
                                            .archive_outlined,
                                        size:
                                        20,
                                        color:
                                        scheme.error,
                                      ),

                                      const SizedBox(
                                        width:
                                        10,
                                      ),

                                      Text(
                                        'Retire Bike',
                                        style:
                                        TextStyle(
                                          color:
                                          scheme.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ];
                            },
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // -------------------------------------------------------
                      // Station
                      // -------------------------------------------------------

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 19,
                            color:
                            scheme.primary,
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          Expanded(
                            child: Text(
                              bike.stationName ??
                                  'No station assigned',
                              style: theme
                                  .textTheme
                                  .bodySmall,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Divider(
                        height: 1,
                        color: scheme.outline
                            .withValues(
                          alpha: 0.7,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      // -------------------------------------------------------
                      // QR
                      // -------------------------------------------------------

                      InkWell(
                        key: const ValueKey(
                          'bike-details-qr-button',
                        ),
                        borderRadius:
                        BorderRadius.circular(
                          8,
                        ),
                        onTap: () {
                          BikeQrModal.show(
                            context,
                            bikeCode:
                            bike.code,
                            qrToken:
                            bike.qrToken,
                            stationName:
                            bike.stationName,
                            status:
                            bike.status,
                          );
                        },
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal:
                            2,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child:
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'QR: ${bike.qrToken}',
                                      maxLines:
                                      1,
                                      overflow:
                                      TextOverflow.ellipsis,
                                      style: theme
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                        fontWeight:
                                        FontWeight.w700,
                                      ),
                                    ),

                                    const SizedBox(
                                      height:
                                      2,
                                    ),

                                    Text(
                                      'Tap to view QR code',
                                      style: theme
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                        color:
                                        scheme.primary,
                                        fontWeight:
                                        FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                width:
                                8,
                              ),

                              Container(
                                width:
                                42,
                                height:
                                42,
                                decoration:
                                BoxDecoration(
                                  color:
                                  Colors.white,
                                  borderRadius:
                                  BorderRadius.circular(
                                    6,
                                  ),
                                ),
                                child:
                                const Icon(
                                  Icons.qr_code_2_rounded,
                                  color:
                                  Colors.black,
                                  size:
                                  36,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          // ===================================================================
          // ACTION BUTTONS
          // ===================================================================

          Row(
            children: [
              Expanded(
                child:
                _BikeActionButton(
                  icon:
                  Icons.edit_outlined,
                  label:
                  'Edit',
                  onPressed:
                  widget.onEditBike,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child:
                _BikeActionButton(
                  icon:
                  Icons.compare_arrows_rounded,
                  label:
                  'Transfer',
                  onPressed:
                  widget.onTransferBike,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child:
                _BikeActionButton(
                  icon:
                  Icons.build_rounded,
                  label:
                  'Service',
                  onPressed:
                  widget.onServiceBike,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          // ===================================================================
          // PERFORMANCE
          // ===================================================================

          Text(
            'Performance overview',
            style: theme
                .textTheme
                .titleMedium
                ?.copyWith(
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Row(
            children: [
              Expanded(
                child:
                _PerformanceCard(
                  label:
                  'Rental count',
                  value:
                  '${_performance?.rentalCount ?? 0}',
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child:
                _PerformanceCard(
                  label:
                  'Distance',
                  value:
                  '${(_performance?.totalDistanceKm ?? 0).toStringAsFixed(1)} km',
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child:
                _PerformanceCard(
                  label:
                  'Reports',
                  value:
                  '${_bikeReports.length}',
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          // ===================================================================
          // TABS
          // ===================================================================

          Row(
            children: [
              Expanded(
                child:
                _BikeDetailsTab(
                  label:
                  'Overview',
                  selected:
                  _selectedTab == 0,
                  onTap: () {
                    setState(() {
                      _selectedTab =
                      0;
                    });
                  },
                ),
              ),

              Expanded(
                child:
                _BikeDetailsTab(
                  label:
                  'Reports (${_bikeReports.length})',
                  selected:
                  _selectedTab == 1,
                  onTap: () {
                    setState(() {
                      _selectedTab =
                      1;
                    });
                  },
                ),
              ),
            ],
          ),

          Divider(
            height: 1,
            color:
            scheme.outline,
          ),

          const SizedBox(
            height: 16,
          ),

          // ===================================================================
          // TAB CONTENT
          // ===================================================================

          if (_selectedTab == 0)
            _buildOverview(
              context,
              bike,
            )
          else
            _buildReports(
              context,
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // OVERVIEW
  // ===========================================================================

  Widget _buildOverview(
      BuildContext context,
      Bike bike,
      ) {
    final theme =
    Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Bike information',
          style: theme
              .textTheme
              .titleSmall
              ?.copyWith(
            fontWeight:
            FontWeight.w800,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        _InformationRow(
          label:
          'Current station',
          value:
          bike.stationName ??
              'Not assigned',
        ),

        _InformationRow(
          label:
          'Battery',
          value:
          bike.batteryPercent != null
              ? '${bike.batteryPercent}%'
              : 'Not recorded',
        ),

        _InformationRow(
          label:
          'Status',
          value:
          _statusLabel(
            bike.status,
          ),
        ),

        _InformationRow(
          label:
          'Last service',
          value:
          bike.lastServiceAt != null
              ? _formatDate(
            bike.lastServiceAt!,
          )
              : 'Not recorded',
        ),
      ],
    );
  }

  // ===========================================================================
  // REPORTS
  // ===========================================================================

  Widget _buildReports(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    // -------------------------------------------------------------------------
    // Empty
    // -------------------------------------------------------------------------

    if (_bikeReports.isEmpty) {
      return Container(
        width:
        double.infinity,
        padding:
        const EdgeInsets.symmetric(
          vertical: 40,
          horizontal: 20,
        ),
        child: Column(
          children: [
            Icon(
              Icons.report_outlined,
              size: 48,
              color: scheme.onSurface
                  .withValues(
                alpha: 0.5,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              'No reports yet',
              style: theme
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              'Reports related to this bike will appear here.',
              textAlign:
              TextAlign.center,
              style: theme
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color: scheme.onSurface
                    .withValues(
                  alpha: 0.6,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // -------------------------------------------------------------------------
    // Reports
    // -------------------------------------------------------------------------

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Bike reports',
                style: theme
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),

            Text(
              '${_bikeReports.length} '
                  '${_bikeReports.length == 1 ? 'report' : 'reports'}',
              style: theme
                  .textTheme
                  .labelMedium
                  ?.copyWith(
                color: scheme.onSurface
                    .withValues(
                  alpha: 0.6,
                ),
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        ..._bikeReports.map(
              (report) {
            return Padding(
              padding:
              const EdgeInsets.only(
                bottom: 12,
              ),
              child:
              _BikeReportCard(
                reportId:
                _formatReportId(
                  report.id,
                ),
                category:
                _reportCategoryLabel(
                  report.category,
                ),
                description:
                report.description,
                status:
                _reportStatusLabel(
                  report.status,
                ),
                reportedAt:
                _formatReportDate(
                  report.createdAt,
                ),
                reviewNote:
                report.reviewNote,
              ),
            );
          },
        ),
      ],
    );
  }
}

// =============================================================================
// BIKE ACTION BUTTON
// =============================================================================

class _BikeActionButton
    extends StatelessWidget {
  const _BikeActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(
      BuildContext context,
      ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return OutlinedButton(
      onPressed:
      onPressed,
      style:
      OutlinedButton.styleFrom(
        minimumSize:
        const Size(
          0,
          58,
        ),
        side:
        BorderSide(
          color:
          scheme.outline,
        ),
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
            14,
          ),
        ),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 8,
        ),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 21,
          ),

          const SizedBox(
            width: 7,
          ),

          Text(
            label,
            style:
            const TextStyle(
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PERFORMANCE CARD
// =============================================================================

class _PerformanceCard
    extends StatelessWidget {
  const _PerformanceCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    return Container(
      height: 72,
      padding:
      const EdgeInsets.all(
        11,
      ),
      decoration:
      BoxDecoration(
        color:
        scheme.surfaceContainer,
        borderRadius:
        BorderRadius.circular(
          14,
        ),
        border:
        Border.all(
          color:
          scheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style:
            theme.textTheme.labelSmall,
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            value,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: theme
                .textTheme
                .titleMedium
                ?.copyWith(
              fontWeight:
              FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// REPORT CARD
// =============================================================================

class _BikeReportCard
    extends StatelessWidget {
  const _BikeReportCard({
    required this.reportId,
    required this.category,
    required this.description,
    required this.status,
    required this.reportedAt,
    this.reviewNote,
  });

  final String reportId;
  final String category;
  final String description;
  final String status;
  final String reportedAt;
  final String? reviewNote;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    Color statusBackground;
    Color statusForeground;
    IconData statusIcon;

    switch (status) {
      case 'Approved':
        statusBackground =
        const Color(
          0xFFDDF7E9,
        );

        statusForeground =
        const Color(
          0xFF159A67,
        );

        statusIcon =
            Icons.check_circle_outline_rounded;

        break;

      case 'Rejected':
        statusBackground =
        const Color(
          0xFFFFE5E5,
        );

        statusForeground =
        const Color(
          0xFFE24B4B,
        );

        statusIcon =
            Icons.cancel_outlined;

        break;

      default:
        statusBackground =
        const Color(
          0xFFFFF3D6,
        );

        statusForeground =
        const Color(
          0xFFE6A919,
        );

        statusIcon =
            Icons.schedule_rounded;
    }

    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(
        14,
      ),
      decoration:
      BoxDecoration(
        color:
        scheme.surfaceContainer,
        borderRadius:
        BorderRadius.circular(
          14,
        ),
        border:
        Border.all(
          color: scheme.outline
              .withValues(
            alpha: 0.7,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // -------------------------------------------------------------------
          // Report ID + status
          // -------------------------------------------------------------------

          Row(
            children: [
              Icon(
                Icons.report_outlined,
                size: 20,
                color:
                scheme.primary,
              ),

              const SizedBox(
                width: 7,
              ),

              Expanded(
                child: Text(
                  reportId,
                  style: theme
                      .textTheme
                      .labelMedium
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration:
                BoxDecoration(
                  color:
                  statusBackground,
                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),
                child: Row(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 14,
                      color:
                      statusForeground,
                    ),

                    const SizedBox(
                      width: 4,
                    ),

                    Text(
                      status,
                      style:
                      TextStyle(
                        color:
                        statusForeground,
                        fontSize:
                        11,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          // -------------------------------------------------------------------
          // Category
          // -------------------------------------------------------------------

          Text(
            category,
            style: theme
                .textTheme
                .bodyMedium
                ?.copyWith(
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          // -------------------------------------------------------------------
          // Description
          // -------------------------------------------------------------------

          Text(
            description,
            maxLines: 3,
            overflow:
            TextOverflow.ellipsis,
            style: theme
                .textTheme
                .bodySmall
                ?.copyWith(
              height: 1.4,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Divider(
            height: 1,
            color: scheme.outline
                .withValues(
              alpha: 0.5,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          // -------------------------------------------------------------------
          // Report date
          // -------------------------------------------------------------------

          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 15,
                color: scheme.onSurface
                    .withValues(
                  alpha: 0.6,
                ),
              ),

              const SizedBox(
                width: 5,
              ),

              Expanded(
                child: Text(
                  'Reported $reportedAt',
                  style: theme
                      .textTheme
                      .labelSmall
                      ?.copyWith(
                    color: scheme.onSurface
                        .withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // -------------------------------------------------------------------
          // Review note
          // -------------------------------------------------------------------

          if (status != 'Pending' &&
              reviewNote != null &&
              reviewNote!
                  .trim()
                  .isNotEmpty) ...[
            const SizedBox(
              height: 12,
            ),

            Container(
              width:
              double.infinity,
              padding:
              const EdgeInsets.all(
                10,
              ),
              decoration:
              BoxDecoration(
                color: scheme
                    .surfaceContainerHighest,
                borderRadius:
                BorderRadius.circular(
                  8,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review note',
                    style: theme
                        .textTheme
                        .labelSmall
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    reviewNote!,
                    style: theme
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// TAB
// =============================================================================

class _BikeDetailsTab
    extends StatelessWidget {
  const _BikeDetailsTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    return InkWell(
      onTap:
      onTap,
      child: Container(
        padding:
        const EdgeInsets.only(
          bottom: 8,
        ),
        decoration:
        BoxDecoration(
          border:
          Border(
            bottom:
            BorderSide(
              color: selected
                  ? scheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign:
          TextAlign.center,
          style: theme
              .textTheme
              .bodyMedium
              ?.copyWith(
            fontWeight:
            FontWeight.w700,
            color: selected
                ? scheme.onSurface
                : scheme.onSurface
                .withValues(
              alpha: 0.65,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// INFORMATION ROW
// =============================================================================

class _InformationRow
    extends StatelessWidget {
  const _InformationRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 12,
      ),
      decoration:
      BoxDecoration(
        border:
        Border(
          bottom:
          BorderSide(
            color: scheme.outline
                .withValues(
              alpha: 0.8,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme
                  .textTheme
                  .bodySmall,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Flexible(
            child: Text(
              value,
              textAlign:
              TextAlign.right,
              style: theme
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
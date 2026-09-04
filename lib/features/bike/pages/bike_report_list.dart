import 'package:flutter/material.dart';

import '../models/bike_report.dart';
import '../repositories/bike_report_repository.dart';

class BikeReportPage extends StatefulWidget {
  const BikeReportPage({
    super.key,
    required this.onOpenReportDetail,
    required this.onOpenPendingReports,
    required this.onAddReport,
  });

  final ValueChanged<int> onOpenReportDetail;
  final VoidCallback onOpenPendingReports;
  final VoidCallback onAddReport;

  @override
  State<BikeReportPage> createState() =>
      _BikeReportPageState();
}

class _BikeReportPageState extends State<BikeReportPage> {
  final BikeReportRepository _reportRepository =
  BikeReportRepository();

  final TextEditingController _searchController =
  TextEditingController();

  List<BikeReport> _reports = [];

  bool _isLoading = true;
  String? _error;

  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();

    _loadReports();

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // LOAD REPORTS
  // ===========================================================================

  Future<void> _loadReports() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final reports =
      await _reportRepository.getReports();

      if (!mounted) return;

      setState(() {
        _reports = reports;
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
  // FILTERED REPORTS
  // ===========================================================================

  List<BikeReport> get _filteredReports {
    final query =
    _searchController.text.trim().toLowerCase();

    return _reports.where((report) {
      // -----------------------------------------------------------------------
      // Status filter
      // -----------------------------------------------------------------------

      final matchesStatus =
          _selectedFilter == 'all' ||
              report.status == _selectedFilter;

      if (!matchesStatus) {
        return false;
      }

      // -----------------------------------------------------------------------
      // Search
      // -----------------------------------------------------------------------

      if (query.isEmpty) {
        return true;
      }

      final reportNumber =
      _formatReportId(report.id).toLowerCase();

      final bikeCode =
          report.bikeCode?.toLowerCase() ?? '';

      final category =
      _categoryLabel(report.category)
          .toLowerCase();

      final description =
      report.description.toLowerCase();

      return reportNumber.contains(query) ||
          bikeCode.contains(query) ||
          category.contains(query) ||
          description.contains(query);
    }).toList();
  }

  // ===========================================================================
  // COUNTS
  // ===========================================================================

  int get _pendingCount {
    return _reports
        .where(
          (report) =>
      report.status == 'pending',
    )
        .length;
  }

  int get _approvedCount {
    return _reports
        .where(
          (report) =>
      report.status == 'approved',
    )
        .length;
  }

  int get _rejectedCount {
    return _reports
        .where(
          (report) =>
      report.status == 'rejected',
    )
        .length;
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  String _formatReportId(int id) {
    return 'RPT-${id.toString().padLeft(4, '0')}';
  }

  String _categoryLabel(String category) {
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

  String _statusLabel(String status) {
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

  String _formatDateTime(DateTime date) {
    final local = date.toLocal();

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
    local.hour.toString().padLeft(2, '0');

    final minute =
    local.minute.toString().padLeft(2, '0');

    return '${local.day} '
        '${months[local.month - 1]} '
        '${local.year} • $hour:$minute';
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
                'Unable to load reports',
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
                onPressed: _loadReports,
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

    final reports = _filteredReports;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadReports,
          child: ListView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              18,
              16,
              18,
              100,
            ),
            children: [
              // ===============================================================
              // TITLE
              // ===============================================================

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Condition reports',
                          style: theme
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          'Review and resolve bike issues.',
                          style: theme
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: scheme.onSurface
                                .withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // -----------------------------------------------------------
                  // Pending reports
                  // -----------------------------------------------------------

                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      FilledButton(
                        onPressed:
                        widget.onOpenPendingReports,
                        child: const Text(
                          'Pending Reports',
                        ),
                      ),

                      if (_pendingCount > 0)
                        Positioned(
                          right: -5,
                          top: -8,
                          child: Container(
                            constraints:
                            const BoxConstraints(
                              minWidth: 22,
                              minHeight: 22,
                            ),
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            alignment:
                            Alignment.center,
                            decoration:
                            BoxDecoration(
                              color: scheme.error,
                              shape:
                              BoxShape.circle,
                            ),
                            child: Text(
                              _pendingCount > 99
                                  ? '99+'
                                  : '$_pendingCount',
                              style: TextStyle(
                                color:
                                scheme.onError,
                                fontSize: 10,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ===============================================================
              // SEARCH
              // ===============================================================

              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText:
                  'Search report or bike ID',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                  ),
                  suffixIcon:
                  _searchController.text.isEmpty
                      ? null
                      : IconButton(
                    onPressed: () {
                      _searchController
                          .clear();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                  ),
                  filled: true,
                  fillColor:
                  scheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ===============================================================
              // FILTERS
              // ===============================================================

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ReportFilterChip(
                      label:
                      'All ${_reports.length}',
                      selected:
                      _selectedFilter == 'all',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'all';
                        });
                      },
                    ),

                    const SizedBox(width: 8),

                    _ReportFilterChip(
                      label:
                      'Pending $_pendingCount',
                      selected:
                      _selectedFilter ==
                          'pending',
                      onTap: () {
                        setState(() {
                          _selectedFilter =
                          'pending';
                        });
                      },
                    ),

                    const SizedBox(width: 8),

                    _ReportFilterChip(
                      label:
                      'Approved $_approvedCount',
                      selected:
                      _selectedFilter ==
                          'approved',
                      onTap: () {
                        setState(() {
                          _selectedFilter =
                          'approved';
                        });
                      },
                    ),

                    const SizedBox(width: 8),

                    _ReportFilterChip(
                      label:
                      'Rejected $_rejectedCount',
                      selected:
                      _selectedFilter ==
                          'rejected',
                      onTap: () {
                        setState(() {
                          _selectedFilter =
                          'rejected';
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===============================================================
              // HEADER
              // ===============================================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedFilter == 'pending'
                        ? 'Pending reports'
                        : 'Reports',
                    style: theme
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  Text(
                    'Newest first',
                    style: theme
                        .textTheme
                        .labelMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ===============================================================
              // EMPTY
              // ===============================================================

              if (reports.isEmpty)
                _EmptyReports(
                  hasSearch:
                  _searchController
                      .text
                      .trim()
                      .isNotEmpty,
                )
              else
                ...reports.map(
                      (report) => Padding(
                    padding:
                    const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: _ReportCard(
                      reportId:
                      _formatReportId(
                        report.id,
                      ),
                      bikeId:
                      report.bikeCode ??
                          'Bike #${report.bikeId}',
                      issue:
                      _categoryLabel(
                        report.category,
                      ),
                      description:
                      report.description,
                      location:
                      report.stationName ??
                          'No station assigned',
                      status:
                      _statusLabel(
                        report.status,
                      ),
                      reportedTime:
                      _formatDateTime(
                        report.createdAt,
                      ),
                      onOpenDetail: () {
                        widget
                            .onOpenReportDetail(
                          report.id,
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),

        // =====================================================================
        // ADD REPORT
        // =====================================================================

        Positioned(
          right: 22,
          bottom: 24,
          child: FloatingActionButton(
            onPressed: widget.onAddReport,
            child: const Icon(
              Icons.add_rounded,
              size: 34,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// REPORT CARD
// =============================================================================

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.reportId,
    required this.bikeId,
    required this.issue,
    required this.description,
    required this.location,
    required this.status,
    required this.reportedTime,
    required this.onOpenDetail,
  });

  final String reportId;
  final String bikeId;
  final String issue;
  final String description;
  final String location;
  final String status;
  final String reportedTime;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'Approved':
        backgroundColor =
        const Color(0xFFDDF7E9);
        textColor =
        const Color(0xFF159A67);
        break;

      case 'Rejected':
        backgroundColor =
        const Color(0xFFFFE5E5);
        textColor =
        const Color(0xFFE24B4B);
        break;

      default:
        backgroundColor =
        const Color(0xFFFFF3D6);
        textColor =
        const Color(0xFFE6A919);
    }

    return InkWell(
      onTap: onOpenDetail,
      borderRadius:
      BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
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
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color:
                    scheme.primaryContainer,
                    borderRadius:
                    BorderRadius.circular(9),
                  ),
                  child: Icon(
                    Icons
                        .directions_bike_rounded,
                    color: scheme
                        .onPrimaryContainer,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            reportId,
                            style: theme
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),

                          const Spacer(),

                          const Icon(
                            Icons
                                .chevron_right_rounded,
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '$bikeId • $issue',
                        style: theme
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        description,
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style:
                        theme.textTheme.bodySmall,
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Icon(
                            Icons
                                .location_on_outlined,
                            size: 15,
                            color:
                            scheme.primary,
                          ),

                          const SizedBox(width: 3),

                          Expanded(
                            child: Text(
                              location,
                              style: theme
                                  .textTheme
                                  .bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Divider(
              height: 1,
              color:
              scheme.outline.withValues(
                alpha: 0.6,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Reported $reportedTime',
                    style: theme
                        .textTheme
                        .labelSmall,
                  ),
                ),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 11,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// FILTER CHIP
// =============================================================================

class _ReportFilterChip extends StatelessWidget {
  const _ReportFilterChip({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme =
        Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary
              : scheme.surface,
          borderRadius:
          BorderRadius.circular(20),
          border: selected
              ? null
              : Border.all(
            color: scheme.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? scheme.onPrimary
                : scheme.onSurface,
            fontSize: 11,
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// EMPTY
// =============================================================================

class _EmptyReports extends StatelessWidget {
  const _EmptyReports({
    required this.hasSearch,
  });

  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 48,
      ),
      child: Column(
        children: [
          Icon(
            hasSearch
                ? Icons.search_off_rounded
                : Icons.report_outlined,
            size: 52,
            color:
            scheme.onSurface.withValues(
              alpha: 0.4,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            hasSearch
                ? 'No matching reports'
                : 'No reports yet',
            style:
            theme.textTheme.titleMedium?.copyWith(
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            hasSearch
                ? 'Try a different search term.'
                : 'Bike condition reports will appear here.',
            textAlign: TextAlign.center,
            style:
            theme.textTheme.bodySmall?.copyWith(
              color:
              scheme.onSurface.withValues(
                alpha: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
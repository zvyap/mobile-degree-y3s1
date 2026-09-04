import 'package:flutter/material.dart';

import '../models/bike_report.dart';
import '../repositories/bike_report_repository.dart';

class PendingBikeReportsPage extends StatefulWidget {
  const PendingBikeReportsPage({
    super.key,
    required this.onOpenReportDetail,
  });

  final ValueChanged<int> onOpenReportDetail;

  @override
  State<PendingBikeReportsPage> createState() =>
      _PendingBikeReportsPageState();
}

class _PendingBikeReportsPageState
    extends State<PendingBikeReportsPage> {
  final BikeReportRepository _reportRepository =
  BikeReportRepository();

  final TextEditingController _searchController =
  TextEditingController();

  List<BikeReport> _reports = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _loadReports();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // SEARCH
  // ===========================================================================

  void _onSearchChanged() {
    setState(() {});
  }

  // ===========================================================================
  // LOAD PENDING REPORTS
  // ===========================================================================

  Future<void> _loadReports() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final reports =
      await _reportRepository.getPendingReports();

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

    if (query.isEmpty) {
      return _reports;
    }

    return _reports.where((report) {
      final reportId =
      _formatReportId(report.id).toLowerCase();

      final bikeCode =
          report.bikeCode?.toLowerCase() ?? '';

      final category =
      _categoryLabel(report.category)
          .toLowerCase();

      final description =
      report.description.toLowerCase();

      final station =
          report.stationName?.toLowerCase() ?? '';

      return reportId.contains(query) ||
          bikeCode.contains(query) ||
          category.contains(query) ||
          description.contains(query) ||
          station.contains(query);
    }).toList();
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
        '${local.year} • '
        '$hour:$minute';
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // -------------------------------------------------------------------------
    // LOADING
    // -------------------------------------------------------------------------

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // -------------------------------------------------------------------------
    // ERROR
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

              Text(
                'Unable to load pending reports',
                style:
                theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
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

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          18,
          16,
          18,
          32,
        ),
        children: [
          // ===================================================================
          // TITLE
          // ===================================================================

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending reports',
                      style: theme
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'Review and approve pending reports',
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

              // ---------------------------------------------------------------
              // PENDING COUNT
              // ---------------------------------------------------------------

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color:
                  const Color(0xFFFFF3D6),
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 17,
                      color:
                      Color(0xFFE6A919),
                    ),

                    const SizedBox(width: 5),

                    Text(
                      '${_reports.length}',
                      style:
                      const TextStyle(
                        color:
                        Color(0xFFE6A919),
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ===================================================================
          // SEARCH
          // ===================================================================

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

          const SizedBox(height: 20),

          // ===================================================================
          // QUEUE HEADER
          // ===================================================================

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Review queue',
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
                  color: scheme.onSurface
                      .withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ===================================================================
          // REPORTS
          // ===================================================================

          if (reports.isEmpty)
            _EmptyPendingReports(
              searching: _searchController
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
                child: _PendingReportCard(
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
                  reportedTime:
                  _formatDateTime(
                    report.createdAt,
                  ),
                  onOpenDetail: () {
                    widget.onOpenReportDetail(
                      report.id,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// PENDING REPORT CARD
// =============================================================================

class _PendingReportCard extends StatelessWidget {
  const _PendingReportCard({
    required this.reportId,
    required this.bikeId,
    required this.issue,
    required this.description,
    required this.location,
    required this.reportedTime,
    required this.onOpenDetail,
  });

  final String reportId;
  final String bikeId;
  final String issue;
  final String description;
  final String location;
  final String reportedTime;

  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
            color: scheme.outline
                .withValues(
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
                // -------------------------------------------------------------
                // BIKE ICON
                // -------------------------------------------------------------

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

                // -------------------------------------------------------------
                // REPORT INFO
                // -------------------------------------------------------------

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              reportId,
                              style: theme
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                fontWeight:
                                FontWeight
                                    .w800,
                              ),
                            ),
                          ),

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
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Divider(
              height: 1,
              color: scheme.outline
                  .withValues(
                alpha: 0.5,
              ),
            ),

            const SizedBox(height: 10),

            // -----------------------------------------------------------------
            // LOCATION + STATUS
            // -----------------------------------------------------------------

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
                    location,
                    style: theme
                        .textTheme
                        .labelSmall,
                  ),
                ),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color:
                    const Color(
                      0xFFFFF3D6,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      color:
                      Color(0xFFE6A919),
                      fontSize: 11,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Reported $reportedTime',
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

            const SizedBox(height: 10),

            // -----------------------------------------------------------------
            // REVIEW BUTTON
            // -----------------------------------------------------------------

            Align(
              alignment:
              Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onOpenDetail,
                icon: const Icon(
                  Icons
                      .rate_review_outlined,
                  size: 18,
                ),
                label: const Text(
                  'Review',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================

class _EmptyPendingReports
    extends StatelessWidget {
  const _EmptyPendingReports({
    required this.searching,
  });

  final bool searching;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 60,
      ),
      child: Column(
        children: [
          Icon(
            searching
                ? Icons.search_off_rounded
                : Icons.task_alt_rounded,
            size: 56,
            color: scheme.onSurface
                .withValues(
              alpha: 0.35,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            searching
                ? 'No matching reports'
                : 'No pending reports',
            style: theme
                .textTheme
                .titleMedium
                ?.copyWith(
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            searching
                ? 'Try another search term.'
                : 'All submitted bike reports have been reviewed.',
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
}
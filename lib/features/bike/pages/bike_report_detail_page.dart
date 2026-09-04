import 'package:flutter/material.dart';

import '../models/bike_report.dart';
import '../repositories/bike_report_repository.dart';

class BikeReportDetailPage extends StatefulWidget {
  const BikeReportDetailPage({
    super.key,
    required this.reportId,
  });

  final int reportId;

  @override
  State<BikeReportDetailPage> createState() =>
      _ReportDetailPageState();
}

class _ReportDetailPageState extends State<BikeReportDetailPage> {
  final BikeReportRepository _reportRepository =
  BikeReportRepository();

  BikeReport? _report;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _loadReport();
  }

  // ===========================================================================
  // LOAD REPORT
  // ===========================================================================

  Future<void> _loadReport() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final report =
      await _reportRepository.getReport(widget.reportId);

      if (!mounted) return;

      setState(() {
        _report = report;
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

  Color _statusBackground(
      String status,
      ) {
    switch (status) {
      case 'approved':
        return const Color(0xFFDDF7E9);

      case 'rejected':
        return const Color(0xFFFFE5E5);

      default:
        return const Color(0xFFFFF3D6);
    }
  }

  Color _statusForeground(
      String status,
      ) {
    switch (status) {
      case 'approved':
        return const Color(0xFF159A67);

      case 'rejected':
        return const Color(0xFFE24B4B);

      default:
        return const Color(0xFFE6A919);
    }
  }

  IconData _statusIcon(
      String status,
      ) {
    switch (status) {
      case 'approved':
        return Icons.check_circle_outline_rounded;

      case 'rejected':
        return Icons.cancel_outlined;

      default:
        return Icons.schedule_rounded;
    }
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
                size: 50,
                color: scheme.error,
              ),

              const SizedBox(height: 12),

              Text(
                'Unable to load report',
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

              const SizedBox(height: 18),

              OutlinedButton.icon(
                onPressed: _loadReport,
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

    final report = _report;

    if (report == null) {
      return const Center(
        child: Text(
          'Report not found',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReport,
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
                      'Report details',
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
                      _formatReportId(
                        report.id,
                      ),
                      style: theme
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: scheme.onSurface
                            .withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------------------------------------------------------------
              // STATUS
              // ---------------------------------------------------------------

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _statusBackground(
                    report.status,
                  ),
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _statusIcon(
                        report.status,
                      ),
                      size: 17,
                      color: _statusForeground(
                        report.status,
                      ),
                    ),

                    const SizedBox(width: 5),

                    Text(
                      _statusLabel(
                        report.status,
                      ),
                      style: TextStyle(
                        color: _statusForeground(
                          report.status,
                        ),
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ===================================================================
          // BIKE
          // ===================================================================

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius:
              BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outline.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color:
                    scheme.primaryContainer,
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.directions_bike_rounded,
                    size: 36,
                    color:
                    scheme.onPrimaryContainer,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.bikeCode ??
                            'Bike #${report.bikeId}',
                        style: theme
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Icon(
                            Icons
                                .location_on_outlined,
                            size: 16,
                            color: scheme.primary,
                          ),

                          const SizedBox(width: 4),

                          Expanded(
                            child: Text(
                              report.stationName ??
                                  'No station assigned',
                              style: theme
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: scheme
                                    .onSurface
                                    .withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ===================================================================
          // REPORT INFORMATION
          // ===================================================================

          Text(
            'Report information',
            style:
            theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          _DetailCard(
            children: [
              _DetailRow(
                icon:
                Icons.build_circle_outlined,
                label: 'Problem',
                value: _categoryLabel(
                  report.category,
                ),
              ),

              const Divider(height: 24),

              _DetailRow(
                icon:
                Icons.schedule_rounded,
                label: 'Reported',
                value: _formatDateTime(
                  report.createdAt,
                ),
              ),

              const Divider(height: 24),

              _DetailRow(
                icon:
                Icons.tag_rounded,
                label: 'Report ID',
                value: _formatReportId(
                  report.id,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ===================================================================
          // DESCRIPTION
          // ===================================================================

          Text(
            'Issue description',
            style:
            theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius:
              BorderRadius.circular(14),
              border: Border.all(
                color: scheme.outline.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            child: Text(
              report.description,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ===================================================================
          // REVIEW RESULT
          // ===================================================================

          if (report.status == 'pending')
            _PendingReviewCard()
          else
            _ReviewResultCard(
              report: report,
              formatDateTime:
              _formatDateTime,
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// DETAIL CARD
// =============================================================================

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outline.withValues(
            alpha: 0.7,
          ),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// =============================================================================
// DETAIL ROW
// =============================================================================

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius:
            BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 20,
            color:
            scheme.onPrimaryContainer,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme
                    .textTheme
                    .labelMedium
                    ?.copyWith(
                  color: scheme.onSurface
                      .withValues(
                    alpha: 0.6,
                  ),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: theme
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// PENDING REVIEW
// =============================================================================

class _PendingReviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3D6),
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.schedule_rounded,
            color: Color(0xFFE6A919),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending review',
                  style: theme
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w800,
                    color:
                    const Color(0xFFE6A919),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'This report has not been reviewed yet.',
                  style:
                  theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// REVIEW RESULT
// =============================================================================

class _ReviewResultCard extends StatelessWidget {
  const _ReviewResultCard({
    required this.report,
    required this.formatDateTime,
  });

  final BikeReport report;
  final String Function(DateTime)
  formatDateTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final approved =
        report.status == 'approved';

    final background = approved
        ? const Color(0xFFDDF7E9)
        : const Color(0xFFFFE5E5);

    final foreground = approved
        ? const Color(0xFF159A67)
        : const Color(0xFFE24B4B);

    final icon = approved
        ? Icons.check_circle_outline_rounded
        : Icons.cancel_outlined;

    final title = approved
        ? 'Report approved'
        : 'Report rejected';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: foreground,
              ),

              const SizedBox(width: 8),

              Text(
                title,
                style: theme
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w800,
                  color: foreground,
                ),
              ),
            ],
          ),

          if (report.reviewedAt != null) ...[
            const SizedBox(height: 10),

            Text(
              'Reviewed ${formatDateTime(report.reviewedAt!)}',
              style:
              theme.textTheme.bodySmall,
            ),
          ],

          const SizedBox(height: 12),

          Text(
            'Review note',
            style: theme
                .textTheme
                .labelMedium
                ?.copyWith(
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            report.reviewNote == null ||
                report.reviewNote!
                    .trim()
                    .isEmpty
                ? 'No review note provided.'
                : report.reviewNote!,
            style:
            theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
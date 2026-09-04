import 'package:flutter/material.dart';

import '../models/bike_report.dart';
import '../repositories/bike_report_repository.dart';

class PendingReportDetail extends StatefulWidget {
  const PendingReportDetail({
    super.key,
    required this.reportId,
  });

  final int reportId;

  @override
  State<PendingReportDetail> createState() =>
      _PendingReportDetailState();
}

class _PendingReportDetailState
    extends State<PendingReportDetail> {
  final BikeReportRepository _reportRepository =
  BikeReportRepository();

  final TextEditingController _reviewNoteController =
  TextEditingController();

  BikeReport? _report;

  bool _isLoading = true;
  bool _isSubmitting = false;

  String? _error;

  @override
  void initState() {
    super.initState();

    _loadReport();
  }

  @override
  void dispose() {
    _reviewNoteController.dispose();

    super.dispose();
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
      await _reportRepository.getReport(
        widget.reportId,
      );

      if (!mounted) return;

      setState(() {
        _report = report;
        _reviewNoteController.text =
            report.reviewNote ?? '';
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
  // APPROVE
  // ===========================================================================

  Future<void> _approveReport() async {
    final report = _report;

    if (report == null ||
        _isSubmitting) {
      return;
    }

    if (report.status != 'pending') {
      _showSnackBar(
        'This report has already been reviewed.',
      );
      return;
    }

    final confirmed =
    await _showConfirmationDialog(
      title: 'Approve Report?',
      message:
      'Approve ${_formatReportId(report.id)} for ${report.bikeCode ?? 'this bike'}?',
      confirmLabel: 'Approve',
      approve: true,
    );

    if (confirmed != true) {
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      await _reportRepository.approveReport(
        reportId: report.id,
        reviewNote:
        _reviewNoteController.text.trim(),
      );

      if (!mounted) return;

      _showSnackBar(
        '${_formatReportId(report.id)} approved',
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showSnackBar(
        'Failed to approve report: $error',
      );
    }
  }

  // ===========================================================================
  // REJECT
  // ===========================================================================

  Future<void> _rejectReport() async {
    final report = _report;

    if (report == null ||
        _isSubmitting) {
      return;
    }

    if (report.status != 'pending') {
      _showSnackBar(
        'This report has already been reviewed.',
      );
      return;
    }

    final confirmed =
    await _showConfirmationDialog(
      title: 'Decline Report?',
      message:
      'Decline ${_formatReportId(report.id)}?',
      confirmLabel: 'Decline',
      approve: false,
    );

    if (confirmed != true) {
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      await _reportRepository.rejectReport(
        reportId: report.id,
        reviewNote:
        _reviewNoteController.text.trim(),
      );

      if (!mounted) return;

      _showSnackBar(
        '${_formatReportId(report.id)} declined',
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showSnackBar(
        'Failed to decline report: $error',
      );
    }
  }

  // ===========================================================================
  // CONFIRMATION
  // ===========================================================================

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required bool approve,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme =
        Theme.of(dialogContext);

        final scheme =
            theme.colorScheme;

        final actionColor = approve
            ? const Color(0xFF18A877)
            : scheme.error;

        return AlertDialog(
          icon: Icon(
            approve
                ? Icons
                .check_circle_outline_rounded
                : Icons
                .cancel_outlined,
            size: 42,
            color: actionColor,
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
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
                actionColor,
              ),
              child: Text(
                confirmLabel,
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  void _showSnackBar(
      String message,
      ) {
    final messenger =
    ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String _formatReportId(int id) {
    return 'RPT-${id.toString().padLeft(4, '0')}';
  }

  String _categoryLabel(
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

  String _formatDateTime(
      DateTime date,
      ) {
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

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    // -------------------------------------------------------------------------
    // LOADING
    // -------------------------------------------------------------------------

    if (_isLoading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    // -------------------------------------------------------------------------
    // ERROR
    // -------------------------------------------------------------------------

    if (_error != null) {
      return Center(
        child: Padding(
          padding:
          const EdgeInsets.all(24),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Icon(
                Icons
                    .error_outline_rounded,
                size: 48,
                color: scheme.error,
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                'Unable to load report',
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
                _loadReport,
                icon: const Icon(
                  Icons
                      .refresh_rounded,
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
        padding:
        const EdgeInsets.fromLTRB(
          18,
          16,
          18,
          32,
        ),
        children: [
          // ===================================================================
          // TITLE
          // ===================================================================

          Text(
            'Pending Report Details',
            style: theme
                .textTheme
                .headlineSmall
                ?.copyWith(
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            'Review the submitted bike condition report.',
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

          const SizedBox(
            height: 18,
          ),

          // ===================================================================
          // BIKE SUMMARY
          // ===================================================================

          Container(
            padding:
            const EdgeInsets.all(
              14,
            ),
            decoration:
            BoxDecoration(
              color: scheme
                  .surfaceContainer,
              borderRadius:
              BorderRadius.circular(
                16,
              ),
              border: Border.all(
                color: scheme.outline
                    .withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration:
                  BoxDecoration(
                    color: scheme
                        .primaryContainer,
                    borderRadius:
                    BorderRadius
                        .circular(
                      10,
                    ),
                  ),
                  child: Icon(
                    Icons
                        .directions_bike_rounded,
                    size: 40,
                    color: scheme
                        .onPrimaryContainer,
                  ),
                ),

                const SizedBox(
                  width: 14,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        '${_formatReportId(report.id)} • '
                            '${report.bikeCode ?? 'Bike #${report.bikeId}'}',
                        style: theme
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          fontWeight:
                          FontWeight
                              .w800,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        _categoryLabel(
                          report.category,
                        ),
                        style: theme
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          fontWeight:
                          FontWeight
                              .w700,
                        ),
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      Row(
                        children: [
                          Icon(
                            Icons
                                .location_on_outlined,
                            size: 17,
                            color: scheme
                                .onSurface
                                .withValues(
                              alpha:
                              0.6,
                            ),
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          Expanded(
                            child: Text(
                              report.stationName ??
                                  'No station assigned',
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

                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFFFF3D6,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(
                      20,
                    ),
                  ),
                  child:
                  const Text(
                    'Pending',
                    style:
                    TextStyle(
                      color: Color(
                        0xFFE6A919,
                      ),
                      fontSize: 11,
                      fontWeight:
                      FontWeight
                          .w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          // ===================================================================
          // PROBLEM
          // ===================================================================

          Text(
            'Problem',
            style: theme
                .textTheme
                .titleSmall
                ?.copyWith(
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Align(
            alignment:
            Alignment.centerLeft,
            child: _ProblemBadge(
              label:
              _categoryLabel(
                report.category,
              ),
              selected: true,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          // ===================================================================
          // DESCRIPTION
          // ===================================================================

          Text(
            'Description',
            style: theme
                .textTheme
                .titleSmall
                ?.copyWith(
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Container(
            width: double.infinity,
            constraints:
            const BoxConstraints(
              minHeight: 100,
            ),
            padding:
            const EdgeInsets.all(
              14,
            ),
            decoration:
            BoxDecoration(
              color: scheme
                  .surfaceContainer,
              borderRadius:
              BorderRadius.circular(
                10,
              ),
              border: Border.all(
                color: scheme.outline
                    .withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            child: Text(
              report.description,
              style: theme
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          // ===================================================================
          // REPORT INFORMATION
          // ===================================================================

          Text(
            'Report information',
            style: theme
                .textTheme
                .titleSmall
                ?.copyWith(
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Container(
            padding:
            const EdgeInsets.all(
              14,
            ),
            decoration:
            BoxDecoration(
              color: scheme
                  .surfaceContainer,
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: Column(
              children: [
                _InformationRow(
                  label:
                  'Report ID',
                  value:
                  _formatReportId(
                    report.id,
                  ),
                ),

                const Divider(),

                _InformationRow(
                  label:
                  'Bike ID',
                  value:
                  report.bikeCode ??
                      'Bike #${report.bikeId}',
                ),

                const Divider(),

                _InformationRow(
                  label:
                  'Problem',
                  value:
                  _categoryLabel(
                    report.category,
                  ),
                ),

                const Divider(),

                _InformationRow(
                  label:
                  'Reported',
                  value:
                  _formatDateTime(
                    report.createdAt,
                  ),
                ),

                const Divider(),

                const _InformationRow(
                  label:
                  'Status',
                  value:
                  'Pending',
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          // ===================================================================
          // REVIEW NOTE
          // ===================================================================

          Text(
            'Review note',
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

          Text(
            'Optional note explaining the review decision.',
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

          const SizedBox(
            height: 10,
          ),

          TextField(
            controller:
            _reviewNoteController,
            minLines: 3,
            maxLines: 5,
            maxLength: 250,
            decoration:
            const InputDecoration(
              hintText:
              'Enter review note...',
              border:
              OutlineInputBorder(),
              alignLabelWithHint:
              true,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          // ===================================================================
          // DECLINE / APPROVE
          // ===================================================================

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child:
                  OutlinedButton(
                    onPressed:
                    _isSubmitting
                        ? null
                        : _rejectReport,
                    style:
                    OutlinedButton
                        .styleFrom(
                      foregroundColor:
                      scheme.error,
                      side:
                      BorderSide(
                        color: scheme
                            .error,
                      ),
                    ),
                    child:
                    const Text(
                      'Decline Report',
                      style:
                      TextStyle(
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 16,
              ),

              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed:
                    _isSubmitting
                        ? null
                        : _approveReport,
                    child:
                    _isSubmitting
                        ? const SizedBox(
                      width:
                      21,
                      height:
                      21,
                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2,
                      ),
                    )
                        : const Text(
                      'Approve Report',
                      style:
                      TextStyle(
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PROBLEM BADGE
// =============================================================================

class _ProblemBadge
    extends StatelessWidget {
  const _ProblemBadge({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(
      BuildContext context,
      ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 10,
      ),
      decoration:
      BoxDecoration(
        color: selected
            ? scheme.primary
            .withValues(
          alpha: 0.20,
        )
            : scheme
            .surfaceContainer,
        borderRadius:
        BorderRadius.circular(
          10,
        ),
        border: Border.all(
          color: selected
              ? scheme.primary
              : scheme.outline,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected
              ? scheme.primary
              : scheme.onSurface,
          fontWeight:
          FontWeight.w700,
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

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style:
              theme.textTheme.bodySmall,
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
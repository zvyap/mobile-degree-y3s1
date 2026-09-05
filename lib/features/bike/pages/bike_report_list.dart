import 'package:bike_renting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final ValueChanged<int?> onAddReport;

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
  bool _isAdmin = false;
  bool _isCancelling = false;

  int? _cancellingReportId;

  String? _error;

  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();

    _loadReports();
    _loadCurrentUserRole();

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
  // LOAD CURRENT USER ROLE
  // ===========================================================================

  Future<void> _loadCurrentUserRole() async {
    try {
      final supabase =
          Supabase.instance.client;

      final user =
          supabase.auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _isAdmin = false;
        });

        return;
      }

      final profile =
      await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      if (!mounted) return;

      setState(() {
        _isAdmin =
            profile['role'] == 'admin';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isAdmin = false;
      });
    }
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
  // CANCEL REPORT
  // ===========================================================================

  Future<void> _cancelReport(
      BikeReport report,
      ) async {
    final l10n =
    AppLocalizations.of(context);

    if (_isCancelling) {
      return;
    }

    if (report.status != 'pending') {
      _showSnackBar(
        l10n.onlyPendingReportsCanBeCancelled,
      );

      return;
    }

    final confirmed =
    await _showCancelConfirmation(
      report,
    );

    if (confirmed != true) {
      return;
    }

    try {
      setState(() {
        _isCancelling = true;
        _cancellingReportId =
            report.id;
      });

      await _reportRepository.cancelReport(
        reportId: report.id,
      );

      if (!mounted) return;

      _showSnackBar(
        l10n.reportCancelled(
          _formatReportId(
            report.id,
          ),
        ),
      );

      await _loadReports();
    } catch (error) {
      if (!mounted) return;

      _showSnackBar(
        l10n.failedToCancelReport(
          error.toString(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
          _cancellingReportId = null;
        });
      }
    }
  }

  Future<bool?> _showCancelConfirmation(
      BikeReport report,
      ) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme =
            Theme.of(
              dialogContext,
            ).colorScheme;

        final l10n =
        AppLocalizations.of(
          dialogContext,
        );

        return AlertDialog(
          icon: Icon(
            Icons.cancel_outlined,
            size: 42,
            color: scheme.error,
          ),
          title: Text(
            l10n.cancelReportQuestion,
            textAlign:
            TextAlign.center,
          ),
          content: Text(
            l10n.cancelReportConfirmation(
              _formatReportId(
                report.id,
              ),
            ),
            textAlign:
            TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: Text(
                l10n.keepReport,
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
              child: Text(
                l10n.cancelReport,
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // FILTERED REPORTS
  // ===========================================================================

  List<BikeReport> get _filteredReports {
    final l10n =
    AppLocalizations.of(context);

    final query =
    _searchController.text
        .trim()
        .toLowerCase();

    return _reports.where((report) {
      final matchesStatus =
          _selectedFilter == 'all' ||
              report.status ==
                  _selectedFilter;

      if (!matchesStatus) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final reportNumber =
      _formatReportId(
        report.id,
      ).toLowerCase();

      final bikeCode =
          report.bikeCode
              ?.toLowerCase() ??
              '';

      final category =
      _categoryLabel(
        report.category,
        l10n,
      ).toLowerCase();

      final description =
      report.description
          .toLowerCase();

      return reportNumber
          .contains(query) ||
          bikeCode
              .contains(query) ||
          category
              .contains(query) ||
          description
              .contains(query);
    }).toList();
  }

  // ===========================================================================
  // COUNTS
  // ===========================================================================

  int get _pendingCount {
    return _reports
        .where(
          (report) =>
      report.status ==
          'pending',
    )
        .length;
  }

  int get _approvedCount {
    return _reports
        .where(
          (report) =>
      report.status ==
          'approved',
    )
        .length;
  }

  int get _rejectedCount {
    return _reports
        .where(
          (report) =>
      report.status ==
          'rejected',
    )
        .length;
  }

  int get _cancelledCount {
    return _reports
        .where(
          (report) =>
      report.status ==
          'cancelled',
    )
        .length;
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
        content:
        Text(message),
      ),
    );
  }

  String _formatReportId(
      int id,
      ) {
    return 'RPT-${id.toString().padLeft(4, '0')}';
  }

  String _categoryLabel(
      String category,
      AppLocalizations l10n,
      ) {
    switch (category) {
      case 'brakes':
        return l10n.brakeSystem;

      case 'tyres':
        return l10n.tyres;

      case 'chain_gears':
        return l10n.chainAndGears;

      case 'seat_frame':
        return l10n.seatAndFrame;

      case 'bell_lights':
        return l10n.bellAndLights;

      case 'qr_lock':
        return l10n.qrLock;

      case 'other':
        return l10n.other;

      default:
        return category;
    }
  }

  String _statusLabel(
      String status,
      AppLocalizations l10n,
      ) {
    switch (status) {
      case 'pending':
        return l10n.pending;

      case 'approved':
        return l10n.approved;

      case 'rejected':
        return l10n.rejected;

      case 'cancelled':
        return l10n.cancelled;

      default:
        return status;
    }
  }

  String _formatDateTime(
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
        .padLeft(
      2,
      '0',
    );

    final minute =
    local.minute
        .toString()
        .padLeft(
      2,
      '0',
    );

    return '${local.day} '
        '${months[local.month - 1]} '
        '${local.year} • '
        '$hour:$minute';
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

    final l10n =
    AppLocalizations.of(context);

    if (_isLoading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

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
                color:
                scheme.error,
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                l10n.unableToLoadReports,
                style:
                const TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.w700,
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
                _loadReports,
                icon:
                const Icon(
                  Icons.refresh_rounded,
                ),
                label:
                Text(
                  l10n.retry,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final reports =
        _filteredReports;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh:
          _loadReports,
          child: ListView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding:
            const EdgeInsets.fromLTRB(
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
                    child:
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.conditionReports,
                          style: theme
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),

                        const SizedBox(
                          height:
                          2,
                        ),

                        Text(
                          _isAdmin
                              ? l10n.reviewAndResolveBikeIssues
                              : l10n.trackSubmittedBikeReports,
                          style: theme
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: scheme.onSurface
                                .withValues(
                              alpha:
                              0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_isAdmin)
                    Stack(
                      clipBehavior:
                      Clip.none,
                      children: [
                        FilledButton(
                          onPressed:
                          widget
                              .onOpenPendingReports,
                          child:
                          Text(
                            l10n.pendingReports,
                          ),
                        ),

                        if (_pendingCount >
                            0)
                          Positioned(
                            right:
                            -5,
                            top:
                            -8,
                            child:
                            Container(
                              constraints:
                              const BoxConstraints(
                                minWidth:
                                22,
                                minHeight:
                                22,
                              ),
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal:
                                5,
                              ),
                              alignment:
                              Alignment.center,
                              decoration:
                              BoxDecoration(
                                color:
                                scheme.error,
                                shape:
                                BoxShape.circle,
                              ),
                              child:
                              Text(
                                _pendingCount >
                                    99
                                    ? '99+'
                                    : '$_pendingCount',
                                style:
                                TextStyle(
                                  color:
                                  scheme.onError,
                                  fontSize:
                                  10,
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

              const SizedBox(
                height: 18,
              ),

              // ===============================================================
              // SEARCH
              // ===============================================================

              TextField(
                controller:
                _searchController,
                decoration:
                InputDecoration(
                  hintText:
                  l10n.searchReportOrBikeId,
                  prefixIcon:
                  const Icon(
                    Icons.search_rounded,
                  ),
                  suffixIcon:
                  _searchController
                      .text
                      .isEmpty
                      ? null
                      : IconButton(
                    onPressed:
                        () {
                      _searchController
                          .clear();
                    },
                    icon:
                    const Icon(
                      Icons.close_rounded,
                    ),
                  ),
                  filled:
                  true,
                  fillColor:
                  scheme.surfaceContainer,
                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // ===============================================================
              // FILTERS
              // ===============================================================

              SingleChildScrollView(
                scrollDirection:
                Axis.horizontal,
                child: Row(
                  children: [
                    _ReportFilterChip(
                      label:
                      l10n.allReports(
                        _reports.length,
                      ),
                      selected:
                      _selectedFilter ==
                          'all',
                      onTap:
                          () {
                        setState(() {
                          _selectedFilter =
                          'all';
                        });
                      },
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    _ReportFilterChip(
                      label:
                      l10n.pendingReportsCount(
                        _pendingCount,
                      ),
                      selected:
                      _selectedFilter ==
                          'pending',
                      onTap:
                          () {
                        setState(() {
                          _selectedFilter =
                          'pending';
                        });
                      },
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    _ReportFilterChip(
                      label:
                      l10n.approvedReportsCount(
                        _approvedCount,
                      ),
                      selected:
                      _selectedFilter ==
                          'approved',
                      onTap:
                          () {
                        setState(() {
                          _selectedFilter =
                          'approved';
                        });
                      },
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    _ReportFilterChip(
                      label:
                      l10n.rejectedReportsCount(
                        _rejectedCount,
                      ),
                      selected:
                      _selectedFilter ==
                          'rejected',
                      onTap:
                          () {
                        setState(() {
                          _selectedFilter =
                          'rejected';
                        });
                      },
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    _ReportFilterChip(
                      label:
                      l10n.cancelledReportsCount(
                        _cancelledCount,
                      ),
                      selected:
                      _selectedFilter ==
                          'cancelled',
                      onTap:
                          () {
                        setState(() {
                          _selectedFilter =
                          'cancelled';
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // ===============================================================
              // HEADER
              // ===============================================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                children: [
                  Text(
                    _selectedFilter ==
                        'all'
                        ? l10n.reports
                        : '${_statusLabel(
                      _selectedFilter,
                      l10n,
                    )} ${l10n.reports.toLowerCase()}',
                    style: theme
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  Text(
                    l10n.newestFirst,
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

              const SizedBox(
                height: 14,
              ),

              // ===============================================================
              // REPORT LIST
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
                      (report) {
                    final canCancel =
                        !_isAdmin &&
                            report.status ==
                                'pending';

                    final cancellingThisReport =
                        _isCancelling &&
                            _cancellingReportId ==
                                report.id;

                    return Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child:
                      _ReportCard(
                        reportId:
                        report.id,
                        bikeId:
                        report.bikeCode ??
                            'Bike #${report.bikeId}',
                        issue:
                        _categoryLabel(
                          report.category,
                          l10n,
                        ),
                        description:
                        report.description,
                        location:
                        report.stationName ??
                            'No station assigned',
                        status:
                        _statusLabel(
                          report.status,
                          l10n,
                        ),
                        rawStatus:
                        report.status,
                        reportedTime:
                        _formatDateTime(
                          report.createdAt,
                        ),
                        canCancel:
                        canCancel,
                        isCancelling:
                        cancellingThisReport,
                        onCancel:
                        canCancel
                            ? () {
                          _cancelReport(
                            report,
                          );
                        }
                            : null,
                        onOpenDetail:
                            () {
                          widget
                              .onOpenReportDetail(
                            report.id,
                          );
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ),

        // =====================================================================
        // ADD REPORT
        // =====================================================================

        Positioned(
          right:
          22,
          bottom:
          24,
          child:
          FloatingActionButton(
            onPressed:
                () {
              widget.onAddReport(
                null,
              );
            },
            child:
            const Icon(
              Icons.add_rounded,
              size:
              34,
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
    required this.rawStatus,
    required this.reportedTime,
    required this.onOpenDetail,
    required this.canCancel,
    required this.isCancelling,
    this.onCancel,
  });

  final int reportId;
  final String bikeId;
  final String issue;
  final String description;
  final String location;
  final String status;
  final String rawStatus;
  final String reportedTime;

  final VoidCallback onOpenDetail;

  final bool canCancel;
  final bool isCancelling;

  final VoidCallback? onCancel;

  String _formatReportId(
      int id,
      ) {
    return 'RPT-${id.toString().padLeft(4, '0')}';
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    final l10n =
    AppLocalizations.of(context);

    Color backgroundColor;
    Color textColor;

    switch (rawStatus) {
      case 'approved':
        backgroundColor =
        const Color(
          0xFFDDF7E9,
        );

        textColor =
        const Color(
          0xFF159A67,
        );

        break;

      case 'rejected':
        backgroundColor =
        const Color(
          0xFFFFE5E5,
        );

        textColor =
        const Color(
          0xFFE24B4B,
        );

        break;

      case 'cancelled':
        backgroundColor =
            scheme.surfaceContainerHighest;

        textColor =
            scheme.onSurface.withValues(
              alpha:
              0.65,
            );

        break;

      default:
        backgroundColor =
        const Color(
          0xFFFFF3D6,
        );

        textColor =
        const Color(
          0xFFE6A919,
        );
    }

    return InkWell(
      onTap:
      onOpenDetail,
      borderRadius:
      BorderRadius.circular(
        16,
      ),
      child:
      Container(
        padding:
        const EdgeInsets.all(
          12,
        ),
        decoration:
        BoxDecoration(
          color:
          scheme.surfaceContainer,
          borderRadius:
          BorderRadius.circular(
            16,
          ),
          border:
          Border.all(
            color: scheme.outline
                .withValues(
              alpha:
              0.8,
            ),
          ),
        ),
        child:
        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width:
                  46,
                  height:
                  46,
                  decoration:
                  BoxDecoration(
                    color: scheme
                        .primaryContainer,
                    borderRadius:
                    BorderRadius.circular(
                      9,
                    ),
                  ),
                  child:
                  Icon(
                    Icons.directions_bike_rounded,
                    color: scheme
                        .onPrimaryContainer,
                  ),
                ),

                const SizedBox(
                  width:
                  12,
                ),

                Expanded(
                  child:
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _formatReportId(
                              reportId,
                            ),
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
                            Icons.chevron_right_rounded,
                          ),
                        ],
                      ),

                      const SizedBox(
                        height:
                        4,
                      ),

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

                      const SizedBox(
                        height:
                        5,
                      ),

                      Text(
                        description,
                        maxLines:
                        2,
                        overflow:
                        TextOverflow.ellipsis,
                        style:
                        theme.textTheme.bodySmall,
                      ),

                      const SizedBox(
                        height:
                        6,
                      ),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size:
                            15,
                            color:
                            scheme.primary,
                          ),

                          const SizedBox(
                            width:
                            3,
                          ),

                          Expanded(
                            child:
                            Text(
                              location,
                              style:
                              theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height:
              12,
            ),

            Divider(
              height:
              1,
              color: scheme.outline
                  .withValues(
                alpha:
                0.6,
              ),
            ),

            const SizedBox(
              height:
              10,
            ),

            Row(
              children: [
                Expanded(
                  child:
                  Text(
                    '${l10n.reported} $reportedTime',
                    style:
                    theme.textTheme.labelSmall,
                  ),
                ),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal:
                    12,
                    vertical:
                    6,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    backgroundColor,
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),
                  child:
                  Text(
                    status,
                    style:
                    TextStyle(
                      color:
                      textColor,
                      fontSize:
                      11,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            if (canCancel) ...[
              const SizedBox(
                height:
                10,
              ),

              Align(
                alignment:
                Alignment.centerRight,
                child:
                TextButton.icon(
                  onPressed:
                  isCancelling
                      ? null
                      : onCancel,
                  style:
                  TextButton.styleFrom(
                    foregroundColor:
                    scheme.error,
                  ),
                  icon:
                  isCancelling
                      ? SizedBox(
                    width:
                    16,
                    height:
                    16,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2,
                      color:
                      scheme.error,
                    ),
                  )
                      : const Icon(
                    Icons.cancel_outlined,
                    size:
                    18,
                  ),
                  label:
                  Text(
                    isCancelling
                        ? l10n.pleaseWait
                        : l10n.cancelReport,
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
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
  Widget build(
      BuildContext context,
      ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return InkWell(
      onTap:
      onTap,
      borderRadius:
      BorderRadius.circular(
        20,
      ),
      child:
      Container(
        padding:
        const EdgeInsets.symmetric(
          horizontal:
          14,
          vertical:
          7,
        ),
        decoration:
        BoxDecoration(
          color:
          selected
              ? scheme.primary
              : scheme.surface,
          borderRadius:
          BorderRadius.circular(
            20,
          ),
          border:
          selected
              ? null
              : Border.all(
            color:
            scheme.outline,
          ),
        ),
        child:
        Text(
          label,
          style:
          TextStyle(
            color:
            selected
                ? scheme.onPrimary
                : scheme.onSurface,
            fontSize:
            11,
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
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    final l10n =
    AppLocalizations.of(context);

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical:
        48,
      ),
      child:
      Column(
        children: [
          Icon(
            hasSearch
                ? Icons.search_off_rounded
                : Icons.report_outlined,
            size:
            52,
            color: scheme
                .onSurface
                .withValues(
              alpha:
              0.4,
            ),
          ),

          const SizedBox(
            height:
            12,
          ),

          Text(
            hasSearch
                ? l10n.noMatchingReports
                : l10n.noReportsYet,
            style: theme
                .textTheme
                .titleMedium
                ?.copyWith(
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(
            height:
            4,
          ),

          Text(
            hasSearch
                ? l10n.tryDifferentSearchTerm
                : l10n.bikeConditionReportsAppearHere,
            textAlign:
            TextAlign.center,
            style: theme
                .textTheme
                .bodySmall
                ?.copyWith(
              color: scheme
                  .onSurface
                  .withValues(
                alpha:
                0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
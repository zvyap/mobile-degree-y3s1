import 'package:bike_renting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      _BikeReportDetailPageState();
}

class _BikeReportDetailPageState
    extends State<BikeReportDetailPage> {
  final BikeReportRepository _reportRepository =
  BikeReportRepository();

  BikeReport? _report;

  String? _photoUrl;
  String? _photoError;

  bool _isLoading = true;
  bool _isPhotoLoading = false;
  bool _isCancelling = false;
  bool _isAdmin = false;

  String? _error;

  @override
  void initState() {
    super.initState();

    _loadCurrentUserRole();
    _loadReport();
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
  // LOAD REPORT
  // ===========================================================================

  Future<void> _loadReport() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _photoError = null;
      });

      final report =
      await _reportRepository.getReport(
        widget.reportId,
      );

      if (!mounted) return;

      setState(() {
        _report = report;
        _isLoading = false;
      });

      await _loadPhoto(report);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  // ===========================================================================
  // LOAD PHOTO
  // ===========================================================================

  Future<void> _loadPhoto(
      BikeReport report,
      ) async {
    try {
      setState(() {
        _isPhotoLoading = true;
        _photoUrl = null;
        _photoError = null;
      });

      final photoUrl =
      await _reportRepository.getReportPhotoUrl(
        reportId: report.id,
        reporterId: report.reporterId,
      );

      if (!mounted) return;

      setState(() {
        _photoUrl = photoUrl;
        _isPhotoLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _photoError = error.toString();
        _isPhotoLoading = false;
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

      await _loadReport();
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
      BuildContext context,
      DateTime date,
      ) {
    final local =
    date.toLocal();

    final material =
    MaterialLocalizations.of(
      context,
    );

    final dateText =
    material.formatMediumDate(
      local,
    );

    final timeText =
    material.formatTimeOfDay(
      TimeOfDay.fromDateTime(
        local,
      ),
      alwaysUse24HourFormat:
      MediaQuery.alwaysUse24HourFormatOf(
        context,
      ),
    );

    return '$dateText • $timeText';
  }

  Color _statusBackground(
      BuildContext context,
      String status,
      ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    switch (status) {
      case 'approved':
        return const Color(
          0xFFDDF7E9,
        );

      case 'rejected':
        return const Color(
          0xFFFFE5E5,
        );

      case 'cancelled':
        return scheme
            .surfaceContainerHighest;

      default:
        return const Color(
          0xFFFFF3D6,
        );
    }
  }

  Color _statusForeground(
      BuildContext context,
      String status,
      ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    switch (status) {
      case 'approved':
        return const Color(
          0xFF159A67,
        );

      case 'rejected':
        return const Color(
          0xFFE24B4B,
        );

      case 'cancelled':
        return scheme.onSurface
            .withValues(
          alpha: 0.65,
        );

      default:
        return const Color(
          0xFFE6A919,
        );
    }
  }

  IconData _statusIcon(
      String status,
      ) {
    switch (status) {
      case 'approved':
        return Icons
            .check_circle_outline_rounded;

      case 'rejected':
        return Icons.cancel_outlined;

      case 'cancelled':
        return Icons
            .block_rounded;

      default:
        return Icons.schedule_rounded;
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

    final l10n =
    AppLocalizations.of(context);

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
          const EdgeInsets.all(
            24,
          ),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 50,
                color:
                scheme.error,
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                l10n.unableToLoadReport,
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
                style:
                theme.textTheme.bodySmall,
              ),

              const SizedBox(
                height: 18,
              ),

              OutlinedButton.icon(
                onPressed:
                _loadReport,
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

    final report =
        _report;

    if (report == null) {
      return Center(
        child: Text(
          l10n.reportNotFound,
        ),
      );
    }

    final currentUser =
        Supabase.instance.client.auth.currentUser;

    final isOwner =
        currentUser != null &&
            report.reporterId ==
                currentUser.id;

    final canCancel =
        !_isAdmin &&
            isOwner &&
            report.status ==
                'pending';

    return RefreshIndicator(
      onRefresh:
      _loadReport,
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
          // TITLE + STATUS
          // ===================================================================

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reportDetails,
                      style: theme
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      _formatReportId(
                        report.id,
                      ),
                      style: theme
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: scheme
                            .onSurface
                            .withValues(
                          alpha:
                          0.65,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal:
                  12,
                  vertical:
                  7,
                ),
                decoration:
                BoxDecoration(
                  color:
                  _statusBackground(
                    context,
                    report.status,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),
                child:
                Row(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Icon(
                      _statusIcon(
                        report.status,
                      ),
                      size:
                      17,
                      color:
                      _statusForeground(
                        context,
                        report.status,
                      ),
                    ),

                    const SizedBox(
                      width:
                      5,
                    ),

                    Text(
                      _statusLabel(
                        report.status,
                        l10n,
                      ),
                      style:
                      TextStyle(
                        color:
                        _statusForeground(
                          context,
                          report.status,
                        ),
                        fontSize:
                        12,
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
            height: 20,
          ),

          // ===================================================================
          // BIKE
          // ===================================================================

          Container(
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
                16,
              ),
              border:
              Border.all(
                color: scheme.outline
                    .withValues(
                  alpha:
                  0.7,
                ),
              ),
            ),
            child:
            Row(
              children: [
                Container(
                  width:
                  58,
                  height:
                  58,
                  decoration:
                  BoxDecoration(
                    color: scheme
                        .primaryContainer,
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                  child:
                  Icon(
                    Icons.directions_bike_rounded,
                    size:
                    36,
                    color: scheme
                        .onPrimaryContainer,
                  ),
                ),

                const SizedBox(
                  width:
                  14,
                ),

                Expanded(
                  child:
                  Column(
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

                      const SizedBox(
                        height:
                        5,
                      ),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size:
                            16,
                            color:
                            scheme.primary,
                          ),

                          const SizedBox(
                            width:
                            4,
                          ),

                          Expanded(
                            child:
                            Text(
                              report.stationName ??
                                  l10n.noStationAssigned,
                              style: theme
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: scheme
                                    .onSurface
                                    .withValues(
                                  alpha:
                                  0.7,
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

          const SizedBox(
            height: 20,
          ),

          // ===================================================================
          // REPORT INFORMATION
          // ===================================================================

          Text(
            l10n.reportInformation,
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

          _DetailCard(
            children: [
              _DetailRow(
                icon:
                Icons.build_circle_outlined,
                label:
                l10n.problem,
                value:
                _categoryLabel(
                  report.category,
                  l10n,
                ),
              ),

              const Divider(
                height: 24,
              ),

              _DetailRow(
                icon:
                Icons.schedule_rounded,
                label:
                l10n.reported,
                value:
                _formatDateTime(
                  context,
                  report.createdAt,
                ),
              ),

              const Divider(
                height: 24,
              ),

              _DetailRow(
                icon:
                Icons.tag_rounded,
                label:
                l10n.reportIdLabel,
                value:
                _formatReportId(
                  report.id,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          // ===================================================================
          // PHOTO
          // ===================================================================

          Text(
            l10n.photo,
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

          if (_isPhotoLoading)
            Container(
              width:
              double.infinity,
              height:
              180,
              alignment:
              Alignment.center,
              decoration:
              BoxDecoration(
                color: scheme
                    .surfaceContainer,
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
              child:
              const CircularProgressIndicator(),
            )
          else if (_photoUrl != null)
            _ReportPhoto(
              photoUrl:
              _photoUrl!,
            )
          else if (_photoError != null)
              _PhotoPlaceholder(
                icon:
                Icons.broken_image_outlined,
                title:
                l10n.photoUnavailable,
                message:
                l10n.photoCouldNotBeLoaded,
              )
            else
              _PhotoPlaceholder(
                icon:
                Icons.image_not_supported_outlined,
                title:
                l10n.noPhotoAttached,
                message:
                l10n.reportWithoutPhoto,
              ),

          const SizedBox(
            height: 20,
          ),

          // ===================================================================
          // DESCRIPTION
          // ===================================================================

          Text(
            l10n.issueDescription,
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

          Container(
            width:
            double.infinity,
            padding:
            const EdgeInsets.all(
              15,
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
                  alpha:
                  0.7,
                ),
              ),
            ),
            child:
            Text(
              report.description,
              style: theme
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                height:
                1.5,
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          // ===================================================================
          // STATUS RESULT
          // ===================================================================

          if (report.status == 'pending')
            _PendingReviewCard(
              canCancel:
              canCancel,
              isCancelling:
              _isCancelling,
              onCancel:
              canCancel
                  ? () {
                _cancelReport(
                  report,
                );
              }
                  : null,
            )
          else if (report.status ==
              'cancelled')
            const _CancelledReportCard()
          else
            _ReviewResultCard(
              report:
              report,
              formatDateTime:
                  (date) =>
                  _formatDateTime(
                    context,
                    date,
                  ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// REPORT PHOTO
// =============================================================================

class _ReportPhoto extends StatelessWidget {
  const _ReportPhoto({
    required this.photoUrl,
  });

  final String photoUrl;

  @override
  Widget build(
      BuildContext context,
      ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    final l10n =
    AppLocalizations.of(context);

    return ClipRRect(
      borderRadius:
      BorderRadius.circular(
        14,
      ),
      child:
      Image.network(
        photoUrl,
        width:
        double.infinity,
        height:
        240,
        fit:
        BoxFit.cover,
        loadingBuilder: (
            context,
            child,
            loadingProgress,
            ) {
          if (loadingProgress ==
              null) {
            return child;
          }

          return Container(
            width:
            double.infinity,
            height:
            240,
            alignment:
            Alignment.center,
            color:
            scheme.surfaceContainer,
            child:
            const CircularProgressIndicator(),
          );
        },
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return _PhotoPlaceholder(
            icon:
            Icons.broken_image_outlined,
            title:
            l10n.unableToDisplayPhoto,
            message:
            l10n.attachedPhotoCouldNotBeDisplayed,
          );
        },
      ),
    );
  }
}

// =============================================================================
// PHOTO PLACEHOLDER
// =============================================================================

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    return Container(
      width:
      double.infinity,
      height:
      180,
      padding:
      const EdgeInsets.all(
        20,
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
            alpha:
            0.7,
          ),
        ),
      ),
      child:
      Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size:
            38,
            color: scheme
                .onSurface
                .withValues(
              alpha:
              0.45,
            ),
          ),

          const SizedBox(
            height:
            8,
          ),

          Text(
            title,
            style: theme
                .textTheme
                .bodyMedium
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
            message,
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

// =============================================================================
// DETAIL CARD
// =============================================================================

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(
      BuildContext context,
      ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return Container(
      padding:
      const EdgeInsets.all(
        15,
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
            alpha:
            0.7,
          ),
        ),
      ),
      child:
      Column(
        children:
        children,
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
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width:
          38,
          height:
          38,
          alignment:
          Alignment.center,
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
            icon,
            size:
            20,
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
              Text(
                label,
                style: theme
                    .textTheme
                    .labelMedium
                    ?.copyWith(
                  color: scheme
                      .onSurface
                      .withValues(
                    alpha:
                    0.6,
                  ),
                ),
              ),

              const SizedBox(
                height:
                3,
              ),

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
  const _PendingReviewCard({
    required this.canCancel,
    required this.isCancelling,
    this.onCancel,
  });

  final bool canCancel;
  final bool isCancelling;
  final VoidCallback? onCancel;

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

    return Container(
      padding:
      const EdgeInsets.all(
        15,
      ),
      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFFFFF3D6,
        ),
        borderRadius:
        BorderRadius.circular(
          14,
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
              const Icon(
                Icons.schedule_rounded,
                color:
                Color(
                  0xFFE6A919,
                ),
              ),

              const SizedBox(
                width:
                10,
              ),

              Expanded(
                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pendingReview,
                      style: theme
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w800,
                        color:
                        const Color(
                          0xFFE6A919,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height:
                      4,
                    ),

                    Text(
                      l10n.pendingReviewDescription,
                      style:
                      theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (canCancel) ...[
            const SizedBox(
              height: 14,
            ),

            SizedBox(
              width:
              double.infinity,
              child:
              OutlinedButton.icon(
                onPressed:
                isCancelling
                    ? null
                    : onCancel,
                style:
                OutlinedButton.styleFrom(
                  foregroundColor:
                  scheme.error,
                  side:
                  BorderSide(
                    color:
                    scheme.error,
                  ),
                ),
                icon:
                isCancelling
                    ? SizedBox(
                  width:
                  17,
                  height:
                  17,
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
                ),
                label:
                Text(
                  isCancelling
                      ? l10n.pleaseWait
                      : l10n.cancelReport,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// CANCELLED REPORT
// =============================================================================

class _CancelledReportCard extends StatelessWidget {
  const _CancelledReportCard();

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

    return Container(
      padding:
      const EdgeInsets.all(
        15,
      ),
      decoration:
      BoxDecoration(
        color:
        scheme.surfaceContainerHighest,
        borderRadius:
        BorderRadius.circular(
          14,
        ),
      ),
      child:
      Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.block_rounded,
            color: scheme.onSurface
                .withValues(
              alpha:
              0.65,
            ),
          ),

          const SizedBox(
            width:
            10,
          ),

          Expanded(
            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reportCancelledStatus,
                  style: theme
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height:
                  4,
                ),

                Text(
                  l10n.reportCancelledDescription,
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
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final l10n =
    AppLocalizations.of(context);

    final approved =
        report.status ==
            'approved';

    final background =
    approved
        ? const Color(
      0xFFDDF7E9,
    )
        : const Color(
      0xFFFFE5E5,
    );

    final foreground =
    approved
        ? const Color(
      0xFF159A67,
    )
        : const Color(
      0xFFE24B4B,
    );

    final icon =
    approved
        ? Icons
        .check_circle_outline_rounded
        : Icons
        .cancel_outlined;

    final title =
    approved
        ? l10n.reportApproved
        : l10n.reportRejected;

    return Container(
      padding:
      const EdgeInsets.all(
        15,
      ),
      decoration:
      BoxDecoration(
        color:
        background,
        borderRadius:
        BorderRadius.circular(
          14,
        ),
      ),
      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color:
                foreground,
              ),

              const SizedBox(
                width:
                8,
              ),

              Text(
                title,
                style: theme
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w800,
                  color:
                  foreground,
                ),
              ),
            ],
          ),

          if (report.reviewedAt !=
              null) ...[
            const SizedBox(
              height:
              10,
            ),

            Text(
              '${l10n.reviewed} '
                  '${formatDateTime(report.reviewedAt!)}',
              style:
              theme.textTheme.bodySmall,
            ),
          ],

          const SizedBox(
            height:
            12,
          ),

          Text(
            l10n.reviewNote,
            style: theme
                .textTheme
                .labelMedium
                ?.copyWith(
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(
            height:
            5,
          ),

          Text(
            report.reviewNote ==
                null ||
                report.reviewNote!
                    .trim()
                    .isEmpty
                ? l10n.noReviewNoteProvided
                : report.reviewNote!,
            style:
            theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
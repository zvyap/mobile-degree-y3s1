import 'dart:async';

import 'package:bike_renting_app/data/models/admin_rental_session.dart';
import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/data/repositories/rental_repository.dart';
import 'package:bike_renting_app/features/renting/renting_controller.dart';
import 'package:bike_renting_app/l10n/app_formats.dart';
import 'package:flutter/material.dart';

class AdminRentalDetailPage extends StatefulWidget {
  const AdminRentalDetailPage({
    super.key,
    required this.rentalId,
    required this.repository,
    this.rentingController,
    this.onSessionEnded,
    this.enableTicker = true,
  });

  final int rentalId;
  final RentalSessionRepository repository;
  final RentingController? rentingController;
  final VoidCallback? onSessionEnded;
  final bool enableTicker;

  @override
  State<AdminRentalDetailPage> createState() => _AdminRentalDetailPageState();
}

class _AdminRentalDetailPageState extends State<AdminRentalDetailPage> {
  AdminRentalSession? _session;
  bool _isLoading = true;
  bool _isEnding = false;
  String? _error;
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    _loadDetails();
    if (widget.enableTicker) {
      _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final details = await widget.repository.getRentalSessionDetails(widget.rentalId);
      if (!mounted) return;
      setState(() {
        _session = details;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleForceEnd() async {
    final session = _session;
    if (session == null || _isEnding) return;

    final bikeCode = session.bike?.code ?? 'Bike #${session.rental.bikeId}';
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final scheme = theme.colorScheme;
        return AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: scheme.error,
          ),
          title: const Text(
            'Force End Renting Session?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to force end the active rental for $bikeCode?\n\n'
            'The bike will be returned to the station, fare will be finalized, '
            'and the rider will receive a notification that the session was ended by admin.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const ValueKey('confirm-force-end-btn'),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Force End Session'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isEnding = true);

    try {
      await widget.repository.adminForceEndRental(widget.rentalId);

      // If the currently local active session in RentingController is this rental,
      // trigger the local force end handler immediately without alerting the admin as victim.
      if (widget.rentingController?.rentalId == widget.rentalId) {
        widget.rentingController?.handleAdminForceEnd(null, false);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Renting session successfully ended by admin.'),
          backgroundColor: Colors.green,
        ),
      );

      _tickerTimer?.cancel();
      setState(() => _isEnding = false);
      _loadDetails();
      if (widget.onSessionEnded != null) {
        widget.onSessionEnded!();
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isEnding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to end session: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final session = _session;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          session != null ? 'Rental ${session.publicId}' : 'Rental Details',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadDetails,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48, color: scheme.error),
                        const SizedBox(height: 12),
                        Text('Failed to load session details', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(_error!, style: TextStyle(color: scheme.error), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _loadDetails,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : session == null
                  ? const Center(child: Text('Rental session not found'))
                  : _buildDetailsContent(context, session),
    );
  }

  Widget _buildDetailsContent(BuildContext context, AdminRentalSession session) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = DateTime.now();
    final elapsedSecs = session.currentElapsedSeconds(now);
    final fare = session.currentFare(now);

    final isSessionActive = session.status != RentalDatabaseStatus.completed &&
        session.status != RentalDatabaseStatus.cancelled &&
        session.status != RentalDatabaseStatus.lost;

    return ListView(
      key: const ValueKey('admin-rental-detail-page'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // Overdue warning banner if overdue
        if (session.isOverdue) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.error.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: scheme.onErrorContainer, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This ride is OVERDUE! Exceeded deadline.',
                    style: TextStyle(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Status & Live Metrics Card
        Card(
          elevation: 0,
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Session Status',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusBadge(scheme, session),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricColumn(
                      context,
                      icon: Icons.timer_outlined,
                      label: 'Duration',
                      value: context.formats.duration(elapsedSecs),
                      color: scheme.primary,
                    ),
                    _buildMetricColumn(
                      context,
                      icon: Icons.route_outlined,
                      label: 'Distance',
                      value: '${context.formats.decimal(session.distanceKm, decimalDigits: 1)} km',
                      color: scheme.onSurface,
                    ),
                    _buildMetricColumn(
                      context,
                      icon: Icons.payments_outlined,
                      label: 'Est. Fare',
                      value: context.formats.currency(fare),
                      color: scheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Bike Details Card
        _buildSectionCard(
          context,
          title: 'Bike Details',
          icon: Icons.directions_bike_rounded,
          children: [
            _buildDetailRow('Bike Code', session.bike?.code ?? 'BIKE #${session.rental.bikeId}'),
            _buildDetailRow(
              'Battery Level',
              session.bike != null ? '${session.bike!.batteryPercent}%' : 'N/A',
              trailing: session.bike != null
                  ? Icon(
                      _batteryIcon(session.bike!.batteryPercent),
                      color: _batteryColor(scheme, session.bike!.batteryPercent),
                      size: 20,
                    )
                  : null,
            ),
            _buildDetailRow(
              'Bike Status',
              session.bike?.status.name.toUpperCase() ?? 'N/A',
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Rider Details Card
        _buildSectionCard(
          context,
          title: 'Rider Details',
          icon: Icons.person_rounded,
          children: [
            _buildDetailRow(
              'Display Name',
              session.user?.displayName.isNotEmpty == true
                  ? session.user!.displayName
                  : 'Not provided',
            ),
            _buildDetailRow(
              'User ID',
              session.rental.userId ?? 'Anonymous',
            ),
            if (session.user?.phone != null && session.user!.phone!.isNotEmpty)
              _buildDetailRow('Phone', session.user!.phone!),
            if (session.user != null)
              _buildDetailRow(
                'Account Status',
                session.user!.accountStatus.name.toUpperCase(),
              ),
          ],
        ),
        const SizedBox(height: 14),

        // Stations Card
        _buildSectionCard(
          context,
          title: 'Station Info',
          icon: Icons.location_on_rounded,
          children: [
            _buildDetailRow(
              'Start Station',
              session.startStation?.name ?? 'Station #${session.rental.startStationId}',
            ),
            if (session.startStation?.address != null)
              _buildDetailRow(
                'Start Address',
                session.startStation!.address,
              ),
            _buildDetailRow(
              'End Station',
              session.endStation?.name ??
                  (session.status == RentalDatabaseStatus.returning
                      ? 'Returning to selected station'
                      : 'Not yet returned'),
            ),
            if (session.endStation?.address != null)
              _buildDetailRow(
                'End Address',
                session.endStation!.address,
              ),
          ],
        ),
        const SizedBox(height: 14),

        // Rates & Plan Card
        _buildSectionCard(
          context,
          title: 'Rates & Pricing',
          icon: Icons.receipt_long_rounded,
          children: [
            _buildDetailRow('Unlock Fee', context.formats.currency(session.unlockFee)),
            _buildDetailRow(
              'Per Minute Rate',
              '${context.formats.currency(session.perMinuteRate)} / min',
            ),
            _buildDetailRow(
              'Hold / Deposit Amount',
              context.formats.currency(session.holdAmount),
            ),
            _buildDetailRow('Currency', session.currency),
            if (session.rental.finalFare != null)
              _buildDetailRow(
                'Final Fare',
                context.formats.currency(session.rental.finalFare!),
              ),
          ],
        ),
        const SizedBox(height: 14),

        // Timestamps Card
        _buildSectionCard(
          context,
          title: 'Timeline',
          icon: Icons.schedule_rounded,
          children: [
            _buildDetailRow(
              'Created At',
              '${context.formats.date(session.createdAt)} · ${context.formats.time(session.createdAt)}',
            ),
            if (session.startedAt != null)
              _buildDetailRow(
                'Started At',
                '${context.formats.date(session.startedAt!)} · ${context.formats.time(session.startedAt!)}',
              ),
            if (session.returnRequestedAt != null)
              _buildDetailRow(
                'Return Requested',
                '${context.formats.date(session.returnRequestedAt!)} · ${context.formats.time(session.returnRequestedAt!)}',
              ),
            if (session.rideDeadlineAt != null)
              _buildDetailRow(
                'Ride Deadline',
                '${context.formats.date(session.rideDeadlineAt!)} · ${context.formats.time(session.rideDeadlineAt!)}',
              ),
            if (session.overdueAt != null)
              _buildDetailRow(
                'Overdue Since',
                '${context.formats.date(session.overdueAt!)} · ${context.formats.time(session.overdueAt!)}',
              ),
            if (session.failureReason != null)
              _buildDetailRow(
                'Failure Reason',
                session.failureReason!,
              ),
          ],
        ),
        const SizedBox(height: 24),

        // Critical Admin Action: Force End Session
        if (isSessionActive)
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              key: const ValueKey('admin-force-end-btn'),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _isEnding ? null : _handleForceEnd,
              icon: _isEnding
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.power_settings_new_rounded),
              label: Text(
                _isEnding ? 'Ending Session...' : 'End Renting Session',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline_rounded, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  'This renting session has ended',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Widget? trailing}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 6),
                  trailing,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ColorScheme scheme, AdminRentalSession session) {
    if (session.isOverdue) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'OVERDUE',
          style: TextStyle(
            color: scheme.onErrorContainer,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final (label, bg, fg) = switch (session.status) {
      RentalDatabaseStatus.active => (
          'IN RIDE',
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
        ),
      RentalDatabaseStatus.returning => (
          'RETURNING',
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
        ),
      RentalDatabaseStatus.reserved ||
      RentalDatabaseStatus.pendingAuthorization ||
      RentalDatabaseStatus.authorized => (
          'RESERVED',
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        ),
      _ => (
          session.status.name.toUpperCase(),
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _batteryIcon(int percent) {
    if (percent >= 90) return Icons.battery_full_rounded;
    if (percent >= 60) return Icons.battery_6_bar_rounded;
    if (percent >= 40) return Icons.battery_4_bar_rounded;
    if (percent >= 20) return Icons.battery_2_bar_rounded;
    return Icons.battery_alert_rounded;
  }

  Color _batteryColor(ColorScheme scheme, int percent) {
    if (percent >= 40) return Colors.green;
    if (percent >= 20) return Colors.orange;
    return scheme.error;
  }
}

import 'dart:async';

import 'package:bike_renting_app/data/models/admin_rental_session.dart';
import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/data/repositories/rental_repository.dart';
import 'package:bike_renting_app/l10n/app_formats.dart';
import 'package:flutter/material.dart';

enum _RentalFilter {
  all,
  active,
  returning,
  reserved,
  ended,
}

class AdminRentalsRouteArguments {
  const AdminRentalsRouteArguments({
    this.userId,
    this.userName,
  });

  final String? userId;
  final String? userName;
}

class AdminRentalsPage extends StatefulWidget {
  const AdminRentalsPage({
    super.key,
    required this.repository,
    required this.onOpenDetails,
    this.userId,
    this.userName,
    this.enableTicker = true,
  });

  final RentalSessionRepository repository;
  final FutureOr<void> Function(int) onOpenDetails;
  final String? userId;
  final String? userName;
  final bool enableTicker;

  @override
  State<AdminRentalsPage> createState() => _AdminRentalsPageState();
}

class _AdminRentalsPageState extends State<AdminRentalsPage> {
  List<AdminRentalSession> _sessions = [];
  bool _isLoading = true;
  String? _error;
  _RentalFilter _filter = _RentalFilter.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _tickerTimer;
  bool _showEndedSessions = false;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _showEndedSessions = true;
    }
    _loadSessions();
    if (widget.enableTicker) {
      _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void didUpdateWidget(covariant AdminRentalsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      if (widget.userId != null) {
        _showEndedSessions = true;
      }
      _loadSessions();
    }
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    try {
      if (_sessions.isEmpty) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }
      final result = await widget.repository.listActiveRentals(
        includeEnded: _showEndedSessions,
      );
      if (!mounted) return;
      setState(() {
        _sessions = result;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  List<AdminRentalSession> get _userSessions {
    if (widget.userId == null) return _sessions;
    return _sessions.where((session) {
      final sessionUserId = session.user?.id ?? session.rental.userId;
      return sessionUserId == widget.userId;
    }).toList();
  }

  String get _pageTitle {
    if (widget.userId != null) {
      final name = widget.userName?.trim().isNotEmpty == true
          ? widget.userName!.trim()
          : (_userSessions.firstOrNull?.user?.displayName.trim().isNotEmpty == true
              ? _userSessions.firstOrNull!.user!.displayName.trim()
              : 'User');
      return "$name's Rental";
    }
    return 'All User Rental';
  }

  List<AdminRentalSession> get _filteredSessions {
    final query = _searchQuery.trim().toLowerCase();
    return _userSessions.where((session) {
      // Default only show ongoing sessions
      if (!_showEndedSessions && session.isEnded) {
        return false;
      }

      // Status filter
      final matchesFilter = switch (_filter) {
        _RentalFilter.all => true,
        _RentalFilter.active => session.status == RentalDatabaseStatus.active,
        _RentalFilter.returning => session.status == RentalDatabaseStatus.returning,
        _RentalFilter.reserved => session.status == RentalDatabaseStatus.reserved ||
            session.status == RentalDatabaseStatus.pendingAuthorization,
        _RentalFilter.ended => session.isEnded,
      };
      if (!matchesFilter) return false;

      // Date range filter
      if (_selectedDateRange != null) {
        final sessionDate = session.startedAt ?? session.createdAt;
        final start = DateTime(
          _selectedDateRange!.start.year,
          _selectedDateRange!.start.month,
          _selectedDateRange!.start.day,
        );
        final end = DateTime(
          _selectedDateRange!.end.year,
          _selectedDateRange!.end.month,
          _selectedDateRange!.end.day,
          23,
          59,
          59,
          999,
        );
        if (sessionDate.isBefore(start) || sessionDate.isAfter(end)) {
          return false;
        }
      }

      // Text search
      if (query.isEmpty) return true;
      final bikeCode = session.bike?.code.toLowerCase() ?? '';
      final publicId = session.publicId.toLowerCase();
      final userName = session.user?.displayName.toLowerCase() ?? '';
      final userPhone = session.user?.phone?.toLowerCase() ?? '';
      final startStation = session.startStation?.name.toLowerCase() ?? '';
      final endStation = session.endStation?.name.toLowerCase() ?? '';

      return bikeCode.contains(query) ||
          publicId.contains(query) ||
          userName.contains(query) ||
          userPhone.contains(query) ||
          startStation.contains(query) ||
          endStation.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final filtered = _filteredSessions;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadSessions,
        child: ListView(
          key: const ValueKey<String>('admin-rentals-page'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pageTitle,
                        key: const ValueKey('admin-rentals-title'),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monitor active renting sessions and rental history',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.68),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const ValueKey('admin-rentals-refresh-btn'),
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _loadSessions,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Search field
            TextField(
              key: const ValueKey('admin-rentals-search'),
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by bike, rider, or station...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 12),

            // Controls: Date Range Filter + Show Ended Checkbox
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('admin-rentals-date-range-btn'),
                    icon: Icon(
                      _selectedDateRange != null
                          ? Icons.date_range_rounded
                          : Icons.calendar_today_outlined,
                      size: 18,
                    ),
                    label: Text(
                      _selectedDateRange != null
                          ? '${context.formats.date(_selectedDateRange!.start)} - ${context.formats.date(_selectedDateRange!.end)}'
                          : 'All Dates',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _selectDateRange,
                  ),
                ),
                if (_selectedDateRange != null) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    key: const ValueKey('admin-rentals-clear-date-btn'),
                    tooltip: 'Clear date range',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(() => _selectedDateRange = null),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Show ended sessions checkbox
            InkWell(
              key: const ValueKey('admin-rentals-show-ended-tile'),
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                setState(() {
                  _showEndedSessions = !_showEndedSessions;
                  if (!_showEndedSessions && _filter == _RentalFilter.ended) {
                    _filter = _RentalFilter.all;
                  }
                });
                _loadSessions();
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Row(
                  children: [
                    Checkbox(
                      key: const ValueKey('admin-rentals-show-ended-checkbox'),
                      value: _showEndedSessions,
                      onChanged: (val) {
                        setState(() {
                          _showEndedSessions = val ?? false;
                          if (!_showEndedSessions && _filter == _RentalFilter.ended) {
                            _filter = _RentalFilter.all;
                          }
                        });
                        _loadSessions();
                      },
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Show ended sessions',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All ($_totalCount)', _RentalFilter.all),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Riding (${_countByStatus(RentalDatabaseStatus.active)})',
                    _RentalFilter.active,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Returning (${_countByStatus(RentalDatabaseStatus.returning)})',
                    _RentalFilter.returning,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Reserved (${_countReserved()})',
                    _RentalFilter.reserved,
                  ),
                  if (_showEndedSessions) ...[
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Ended (${_countEnded()})',
                      _RentalFilter.ended,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Loading / Error / Empty / List
            if (_isLoading && _sessions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null && _sessions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline_rounded, size: 48, color: scheme.error),
                      const SizedBox(height: 12),
                      Text('Failed to load rentals', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(_error!, style: TextStyle(color: scheme.error), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _loadSessions,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.pedal_bike_rounded,
                        size: 64,
                        color: scheme.onSurface.withValues(alpha: 0.38),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No rentals match your search'
                            : (widget.userId != null
                                ? 'No rentals found for this user'
                                : 'No Active Renting Sessions'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Try adjusting your search or filter criteria'
                            : (widget.userId != null
                                ? 'This user has no recorded rentals.'
                                : 'There are currently no bikes being rented or reserved.'),
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.60),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filtered.map((session) => _RentalSessionCard(
                    session: session,
                    onTap: () async {
                      await widget.onOpenDetails(session.id);
                      if (mounted) _loadSessions();
                    },
                  )),
          ],
        ),
      ),
    );
  }

  int get _totalCount {
    if (_showEndedSessions) return _userSessions.length;
    return _userSessions.where((s) => !s.isEnded).length;
  }

  int _countByStatus(RentalDatabaseStatus status) {
    return _userSessions.where((s) => s.status == status).length;
  }

  int _countReserved() {
    return _userSessions.where((s) =>
        s.status == RentalDatabaseStatus.reserved ||
        s.status == RentalDatabaseStatus.pendingAuthorization).length;
  }

  int _countEnded() {
    return _userSessions.where((s) => s.isEnded).length;
  }

  Widget _buildFilterChip(String label, _RentalFilter filter) {
    final selected = _filter == filter;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = filter),
    );
  }
}

class _RentalSessionCard extends StatelessWidget {
  const _RentalSessionCard({
    required this.session,
    required this.onTap,
  });

  final AdminRentalSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = DateTime.now();
    final elapsedSecs = session.currentElapsedSeconds(now);
    final fare = session.currentFare(now);

    return Card(
      key: ValueKey<String>('admin-rental-card-${session.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: session.isOverdue
              ? scheme.error.withValues(alpha: 0.6)
              : scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Bike Code + Status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.directions_bike_rounded,
                          size: 22,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.bike?.code ?? 'BIKE #${session.rental.bikeId}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            session.publicId,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _buildStatusChip(scheme, session),
                ],
              ),
              const SizedBox(height: 14),

              // Middle: Rider info & Station
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 16,
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            session.user?.displayName.isNotEmpty == true
                                ? session.user!.displayName
                                : (session.rental.userId != null
                                    ? 'User ${session.rental.userId!.substring(0, 8)}'
                                    : 'Anonymous Rider'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (session.bike != null)
                    Row(
                      children: [
                        Icon(
                          _batteryIcon(session.bike!.batteryPercent),
                          size: 16,
                          color: _batteryColor(scheme, session.bike!.batteryPercent),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${session.bike!.batteryPercent}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 6),

              // Station row
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      session.status == RentalDatabaseStatus.returning && session.endStation != null
                          ? '${session.startStation?.name ?? "Start"} → ${session.endStation!.name}'
                          : session.startStation?.name ?? 'Station #${session.rental.startStationId}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.75),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Bottom row: Live duration, distance, estimated fare, and chevron
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Duration
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.formats.duration(elapsedSecs),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),

                  // Distance
                  Row(
                    children: [
                      Icon(
                        Icons.route_outlined,
                        size: 16,
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${context.formats.decimal(session.distanceKm, decimalDigits: 1)} km',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),

                  // Fare
                  Text(
                    context.formats.currency(fare),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                    ),
                  ),

                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ColorScheme scheme, AdminRentalSession session) {
    if (session.isOverdue) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'OVERDUE',
          style: TextStyle(
            color: scheme.onErrorContainer,
            fontSize: 11,
            fontWeight: FontWeight.w800,
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
      RentalDatabaseStatus.completed => (
          'COMPLETED',
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
        ),
      RentalDatabaseStatus.cancelled => (
          'CANCELLED',
          scheme.errorContainer,
          scheme.onErrorContainer,
        ),
      RentalDatabaseStatus.lost => (
          'LOST',
          scheme.errorContainer,
          scheme.onErrorContainer,
        ),
      _ => (
          session.status.name.toUpperCase(),
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
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

import 'package:flutter/material.dart';

class PendingBikeReportsPage extends StatefulWidget {
  const PendingBikeReportsPage({
    super.key,
    this.onOpenReportDetail,
  });

  // Optional for now.
  // Later you can pass the report ID to the detail page.
  final ValueChanged<String>? onOpenReportDetail;

  @override
  State<PendingBikeReportsPage> createState() =>
      _PendingBikeReportsPageState();
}

class _PendingBikeReportsPageState extends State<PendingBikeReportsPage> {
  bool _showReport = true;

  void showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _approveReport() {
    setState(() {
      _showReport = false;
    });

    // TODO: Update report status in database later.

    showSnackBar('Report approved');
  }

  void _declineReport() {
    setState(() {
      _showReport = false;
    });

    // TODO: Update report status in database later.

    showSnackBar('Report declined');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      children: [
        // ============================================================
        // TITLE
        // ============================================================

        Text(
          'Pending reports',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          'Review and Approve pending reports',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),

        const SizedBox(height: 18),

        // ============================================================
        // SEARCH + FILTER
        // ============================================================

        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search report or bike ID',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                  ),
                  filled: true,
                  fillColor: scheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            SizedBox(
              width: 52,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Filter later.
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(
                  Icons.filter_alt_outlined,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ============================================================
        // SEVERITY FILTERS
        // ============================================================

        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _PendingReportFilter(
                label: 'All 1',
                selected: true,
              ),

              SizedBox(width: 8),

              _PendingReportFilter(
                label: 'High Severity 1',
              ),

              SizedBox(width: 8),

              _PendingReportFilter(
                label: 'Medium Severity 0',
              ),

              SizedBox(width: 8),

              _PendingReportFilter(
                label: 'Low Severity 0',
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ============================================================
        // PRIORITY QUEUE
        // ============================================================

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Priority queue',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            Text(
              'Newest first',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // ============================================================
        // PENDING REPORT
        // ============================================================

        if (_showReport)
          _PendingReportCard(
            reportId: 'RPT-1000',
            bikeId: 'BR-1000',
            issue: 'Front & Rear Tyres Issue',
            location: 'ABC Arena',
            severity: 'High',

            onOpenDetail: () {
              if (widget.onOpenReportDetail != null) {
                widget.onOpenReportDetail!('RPT-1000');
              } else {
                showSnackBar('Report detail: RPT-1000');
              }
            },

            onDecline: _declineReport,
            onApprove: _approveReport,
          ),

        if (!_showReport)
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 52,
                  color: scheme.onSurface.withValues(alpha: 0.4),
                ),

                const SizedBox(height: 10),

                Text(
                  'No pending reports',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// PENDING REPORT CARD
// ============================================================================

class _PendingReportCard extends StatelessWidget {
  const _PendingReportCard({
    required this.reportId,
    required this.bikeId,
    required this.issue,
    required this.location,
    required this.severity,
    required this.onOpenDetail,
    required this.onDecline,
    required this.onApprove,
  });

  final String reportId;
  final String bikeId;
  final String issue;
  final String location;
  final String severity;

  final VoidCallback onOpenDetail;
  final VoidCallback onDecline;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------------
              // Bike image placeholder
              // --------------------------------------------------------

              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.directions_bike_rounded,
                ),
              ),

              const SizedBox(width: 12),

              // --------------------------------------------------------
              // Report information
              // --------------------------------------------------------

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          reportId,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(width: 2),

                        InkWell(
                          onTap: onOpenDetail,
                          borderRadius: BorderRadius.circular(20),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '$bikeId • $issue',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      location,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // --------------------------------------------------------
              // Severity
              // --------------------------------------------------------

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5E5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  severity,
                  style: const TextStyle(
                    color: Color(0xFFE84D4D),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ==========================================================
          // APPROVE / DECLINE
          // ==========================================================

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onDecline,
                child: Text(
                  'Decline',
                  style: TextStyle(
                    color: scheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 4),

              TextButton(
                onPressed: onApprove,
                child: const Text(
                  'Approve',
                  style: TextStyle(
                    color: Color(0xFF18C796),
                    fontWeight: FontWeight.w700,
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

// ============================================================================
// FILTER
// ============================================================================

class _PendingReportFilter extends StatelessWidget {
  const _PendingReportFilter({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: selected
            ? scheme.primary
            : scheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected
              ? scheme.onPrimary
              : scheme.onSurface,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
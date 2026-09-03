import 'package:flutter/material.dart';

class BikeReportPage extends StatelessWidget {
  const BikeReportPage({
    super.key,
    required this.onOpenReportDetail,
    required this.onOpenPendingReports,
    required this.onAddReport,
  });


  final ValueChanged<String> onOpenReportDetail;
  final VoidCallback onOpenPendingReports;
  final VoidCallback onAddReport;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
          children: [
            // =========================================================
            // Title
            // =========================================================

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Condition reports',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        'Review, assign and resolve bike issues.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    FilledButton(
                      onPressed: onOpenPendingReports,
                      child: const Text('Pending Report'),
                    ),

                    Positioned(
                      right: -4,
                      top: -8,
                      child: Container(
                        width: 21,
                        height: 21,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '1',
                          style: TextStyle(
                            color: scheme.onError,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),

            // =========================================================
            // Search
            // =========================================================

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
                      // Filter later
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

            // =========================================================
            // Filter chips
            // =========================================================

            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ReportFilterChip(
                    label: 'All 1',
                    selected: true,
                  ),
                  SizedBox(width: 8),
                  _ReportFilterChip(
                    label: 'High Severity 1',
                  ),
                  SizedBox(width: 8),
                  _ReportFilterChip(
                    label: 'Medium Severity 0',
                  ),
                  SizedBox(width: 8),
                  _ReportFilterChip(
                    label: 'Low Severity 0',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // =========================================================
            // Queue header
            // =========================================================

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

            // =========================================================
            // Reports
            // =========================================================

            _ReportCard(
              reportId: 'RPT-2045',
              bikeId: 'BR-1107',
              issue: 'Front & Rear Tyres Issue',
              location: 'University',
              severity: 'High',
              reportedTime: '20 July 21:30',
              onOpenDetail: () {
                onOpenReportDetail('RPT-2045');
              },
            ),

            const SizedBox(height: 24),

            _ReportCard(
              reportId: 'RPT-2045',
              bikeId: 'BR-1042',
              issue: 'Brake System Issue',
              location: 'Folk Valley',
              severity: 'In service',
              reportedTime: '17 July 09:44',
              onOpenDetail: () {
                onOpenReportDetail('RPT-2045');
              },
            ),
          ],
        ),

        // =============================================================
        // Add report floating button
        // =============================================================

        Positioned(
          right: 22,
          bottom: 24,
          child: FloatingActionButton(
            onPressed:onAddReport
            ,
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
    required this.location,
    required this.severity,
    required this.reportedTime,
    required this.onOpenDetail,
  });

  final String reportId;
  final String bikeId;
  final String issue;
  final String location;
  final String severity;
  final String reportedTime;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final isHigh = severity == 'High';

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bike placeholder
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

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------------------------------------------------
                    // Report ID + arrow
                    // -------------------------------------------------

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
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                            ),
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

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isHigh
                      ? const Color(0xFFFFE6E6)
                      : const Color(0xFFFFF3D6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  severity,
                  style: TextStyle(
                    color: isHigh
                        ? const Color(0xFFE84D4D)
                        : const Color(0xFFF09B00),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Divider(
            height: 1,
            color: scheme.outline.withValues(alpha: 0.6),
          ),

          const SizedBox(height: 10),

          Text(
            'Reported   Time: $reportedTime',
            style: theme.textTheme.labelSmall,
          ),
        ],
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
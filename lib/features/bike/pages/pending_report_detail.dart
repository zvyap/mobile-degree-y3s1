import 'package:flutter/material.dart';

class PendingReportDetail extends StatelessWidget {
  const PendingReportDetail({
    super.key,
    required this.reportId,
  });

  final String reportId;

  void _showSnackBar(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _approveReport(BuildContext context) {
    // TODO: Update report status to "approved" in Supabase later.

    _showSnackBar(
      context,
      'Report $reportId approved',
    );
  }

  void _declineReport(BuildContext context) {
    // TODO: Update report status to "declined" in Supabase later.

    _showSnackBar(
      context,
      'Report $reportId declined',
    );
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
          'Pending Report Details',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Review the submitted bike condition report.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),

        const SizedBox(height: 18),

        // ============================================================
        // REPORT / BIKE SUMMARY
        // ============================================================

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bike image placeholder
              Container(
                width: 72,
                height: 62,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.directions_bike_rounded,
                  size: 44,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$reportId • BR-1000',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Front & Rear Tyres Issue',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: scheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),

                        const SizedBox(width: 4),

                        Text(
                          'ABC Arena',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Severity
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Severity',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'High',
                      style: TextStyle(
                        color: Color(0xFFE84D4D),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // ============================================================
        // PROBLEMS
        // ============================================================

        Text(
          'Problems',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 12),

        const Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ProblemBadge(
              label: 'Brakes',
              selected: true,
            ),
            _ProblemBadge(
              label: 'Tyres',
              selected: true,
            ),
            _ProblemBadge(
              label: 'Chains',
            ),
            _ProblemBadge(
              label: 'Seat',
            ),
            _ProblemBadge(
              label: 'Lights',
            ),
            _ProblemBadge(
              label: 'Others',
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ============================================================
        // DESCRIPTION
        // ============================================================

        Text(
          'Description',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 100,
          ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.7),
            ),
          ),
          child: Text(
            'The brake does not respond and the rear tyre appears damaged.',
            style: theme.textTheme.bodyMedium,
          ),
        ),

        const SizedBox(height: 22),

        // ============================================================
        // PHOTOS
        // ============================================================

        Text(
          'Photos',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            // Photo placeholder
            Container(
              width: 115,
              height: 90,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.image_outlined,
                size: 46,
                color: scheme.onSurface.withValues(
                  alpha: 0.5,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Container(
              width: 115,
              height: 90,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.image_outlined,
                size: 46,
                color: scheme.onSurface.withValues(
                  alpha: 0.5,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // ============================================================
        // REPORT INFORMATION
        // ============================================================

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const _InformationRow(
                label: 'Report ID',
                value: 'RPT-1000',
              ),

              const Divider(),

              const _InformationRow(
                label: 'Bike ID',
                value: 'BR-1000',
              ),

              const Divider(),

              const _InformationRow(
                label: 'Reported',
                value: '20 July 21:30',
              ),

              const Divider(),

              const _InformationRow(
                label: 'Status',
                value: 'Pending',
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // ============================================================
        // DECLINE / APPROVE
        // ============================================================

        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    _declineReport(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.error,
                    side: BorderSide(
                      color: scheme.error,
                    ),
                  ),
                  child: const Text(
                    'Decline Report',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    _approveReport(context);
                  },
                  child: const Text(
                    'Approve Report',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// PROBLEM BADGE
// =============================================================================

class _ProblemBadge extends StatelessWidget {
  const _ProblemBadge({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 105,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? scheme.primary.withValues(alpha: 0.20)
            : scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
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
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// =============================================================================
// INFORMATION ROW
// =============================================================================

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ),

          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
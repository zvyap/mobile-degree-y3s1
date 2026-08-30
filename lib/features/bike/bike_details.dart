import 'package:flutter/material.dart';

enum BikeDetailMenuAction {
  makeReport,
  deleteBike,
}

class BikeDetailsPage extends StatefulWidget {
  const BikeDetailsPage({
    super.key,
    required this.bikeId,
    required this.onEditBike,
  });

  final String bikeId;
  final VoidCallback onEditBike;
  @override
  State<BikeDetailsPage> createState() => _BikeDetailsPageState();
}

class _BikeDetailsPageState extends State<BikeDetailsPage> {
  int _selectedTab = 0;

  void showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _handleMenuAction(BikeDetailMenuAction action) {
    if (action == BikeDetailMenuAction.makeReport) {
      showSnackBar('Open Make Report page');
    } else if (action == BikeDetailMenuAction.deleteBike) {
      showSnackBar('Delete bike');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      children: [
        // ===========================================================
        // BIKE MAIN CARD
        // ===========================================================

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.8),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------------------------------------------
              // Bike image placeholder
              // -------------------------------------------------------

              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.directions_bike_rounded,
                  size: 70,
                  color: scheme.onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 16),

              // -------------------------------------------------------
              // Bike information
              // -------------------------------------------------------

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.bikeId,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        // Status
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDF7E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Available',
                            style: TextStyle(
                              color: Color(0xFF159A67),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        // ---------------------------------------------------
                        // Three-dot menu
                        // ---------------------------------------------------

                        PopupMenuButton<BikeDetailMenuAction>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.more_vert_rounded,
                          ),
                          onSelected: _handleMenuAction,
                          itemBuilder: (context) {
                            return [
                              const PopupMenuItem(
                                value: BikeDetailMenuAction.makeReport,
                                child: Text('Make Report'),
                              ),
                              PopupMenuItem(
                                value: BikeDetailMenuAction.deleteBike,
                                child: Text(
                                  'Delete Bike',
                                  style: TextStyle(
                                    color: scheme.error,
                                  ),
                                ),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),

                    Text(
                      'Road Bike',
                      style: theme.textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 19,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Gurney Paragon',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Divider(
                      height: 1,
                      color: scheme.outline.withValues(alpha: 0.7),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'QR: R1028-ABC',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        // QR placeholder
                        Container(
                          width: 42,
                          height: 42,
                          color: Colors.white,
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            color: Colors.black,
                            size: 38,
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

        const SizedBox(height: 14),

        // ===========================================================
        // ACTION BUTTONS
        // ===========================================================

        Row(
          children: [
            Expanded(
              child: _BikeActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onPressed: widget.onEditBike,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _BikeActionButton(
                icon: Icons.compare_arrows_rounded,
                label: 'Transfer',
                onPressed: () {
                  showSnackBar('Open Transfer Bike page');
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _BikeActionButton(
                icon: Icons.build_rounded,
                label: 'Service',
                onPressed: () {
                  showSnackBar('Open Service page');
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ===========================================================
        // PERFORMANCE OVERVIEW
        // ===========================================================

        Text(
          'Performance overview',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _PerformanceCard(
                label: 'Rental count',
                value: '342',
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _PerformanceCard(
                label: 'Distance',
                value: '1,248 km',
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _PerformanceCard(
                label: 'Condition',
                value: 'Good',
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ===========================================================
        // OVERVIEW / REPORTS TABS
        // ===========================================================

        Row(
          children: [
            Expanded(
              child: _BikeDetailsTab(
                label: 'Overview',
                selected: _selectedTab == 0,
                onTap: () {
                  setState(() {
                    _selectedTab = 0;
                  });
                },
              ),
            ),
            Expanded(
              child: _BikeDetailsTab(
                label: 'Reports',
                selected: _selectedTab == 1,
                onTap: () {
                  setState(() {
                    _selectedTab = 1;
                  });
                },
              ),
            ),
          ],
        ),

        Divider(
          height: 1,
          color: scheme.outline,
        ),

        const SizedBox(height: 16),

        // ===========================================================
        // TAB CONTENT
        // ===========================================================

        if (_selectedTab == 0)
          _buildOverview(context)
        else
          _buildReports(context),
      ],
    );
  }

  // =========================================================================
  // OVERVIEW TAB
  // =========================================================================

  Widget _buildOverview(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bike information',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 4),

        const _InformationRow(
          label: 'Current station',
          value: 'Gurney Paragon',
        ),

        const _InformationRow(
          label: 'Purchase date',
          value: '18 Jan 2025',
        ),

        const _InformationRow(
          label: 'Next service',
          value: '02 Aug 2026',
        ),

        const SizedBox(height: 64),

        Text(
          'Recent activity',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            const Icon(
              Icons.circle,
              size: 11,
              color: Color(0xFF19C997),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                'Returned to Central Park Station',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Text(
              '09:52',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================================
  // REPORT TAB
  // =========================================================================

  Widget _buildReports(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 40,
        horizontal: 20,
      ),
      child: Column(
        children: [
          Icon(
            Icons.report_outlined,
            size: 48,
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),

          const SizedBox(height: 10),

          Text(
            'No reports yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Reports related to this bike will appear here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ACTION BUTTON
// =============================================================================

class _BikeActionButton extends StatelessWidget {
  const _BikeActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 58),
        side: BorderSide(
          color: scheme.outline,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 21,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PERFORMANCE CARD
// =============================================================================

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      height: 72,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// OVERVIEW / REPORT TAB
// =============================================================================

class _BikeDetailsTab extends StatelessWidget {
  const _BikeDetailsTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(
          bottom: 8,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected
                  ? scheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: selected
                ? scheme.onSurface
                : scheme.onSurface.withValues(alpha: 0.65),
          ),
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
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: scheme.outline.withValues(alpha: 0.8),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ),

          const SizedBox(width: 12),

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
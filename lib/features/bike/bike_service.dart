import 'package:flutter/material.dart';

class ServiceBikePage extends StatefulWidget {
  const ServiceBikePage({
    super.key,
    required this.bikeId,
  });

  final String bikeId;

  @override
  State<ServiceBikePage> createState() => _ServiceBikePageState();
}

class _ServiceBikePageState extends State<ServiceBikePage> {
  DateTime _finishDate = DateTime(2026, 7, 24);

  bool _brakeSystem = true;
  bool _tyres = true;
  bool _chainAndGears = false;
  bool _seatAndFrame = true;
  bool _bellAndLights = false;
  bool _qrLock = true;

  // Count how many inspection items are completed.
  int get _completedCount {
    final checklist = [
      _brakeSystem,
      _tyres,
      _chainAndGears,
      _seatAndFrame,
      _bellAndLights,
      _qrLock,
    ];

    return checklist.where((item) => item).length;
  }

  void showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _selectFinishDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _finishDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      setState(() {
        _finishDate = selectedDate;
      });
    }
  }

  void _submitService() {
    // TODO: Save service information into database later.

    showSnackBar(
      'Service information submitted for ${widget.bikeId}',
    );
  }

  String _formatDate(DateTime date) {
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      children: [
        // ============================================================
        // Title
        // ============================================================

        Text(
          'Service',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 18),

        // ============================================================
        // Bike summary
        // ============================================================

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.8),
            ),
          ),
          child: Row(
            children: [
              // Bike image placeholder
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.directions_bike_rounded,
                  size: 36,
                  color: Color(0xFFE7B928),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.bikeId} • Standard City Bike',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Reported brake issue',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.error,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'In service',
                  style: TextStyle(
                    color: Color(0xFFE6A919),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ============================================================
        // Checklist title
        // ============================================================

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Inspection checklist',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            Text(
              '$_completedCount of 6 complete',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ============================================================
        // Inspection checklist
        // ============================================================

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.8),
            ),
          ),
          child: Column(
            children: [
              _InspectionItem(
                title: 'Brake system',
                status: 'Done',
                completed: _brakeSystem,
                onChanged: (value) {
                  setState(() {
                    _brakeSystem = value;
                  });
                },
              ),

              _InspectionItem(
                title: 'Front & rear tyres',
                status: 'Done',
                completed: _tyres,
                onChanged: (value) {
                  setState(() {
                    _tyres = value;
                  });
                },
              ),

              _InspectionItem(
                title: 'Chain and gears',
                status: 'Needs lubrication',
                completed: _chainAndGears,
                warning: true,
                onChanged: (value) {
                  setState(() {
                    _chainAndGears = value;
                  });
                },
              ),

              _InspectionItem(
                title: 'Seat and frame',
                status: 'Done',
                completed: _seatAndFrame,
                onChanged: (value) {
                  setState(() {
                    _seatAndFrame = value;
                  });
                },
              ),

              _InspectionItem(
                title: 'Bell and lights',
                status: 'Light not working',
                completed: _bellAndLights,
                error: true,
                onChanged: (value) {
                  setState(() {
                    _bellAndLights = value;
                  });
                },
              ),

              _InspectionItem(
                title: 'QR lock mechanism',
                status: 'Done',
                completed: _qrLock,
                showDivider: false,
                onChanged: (value) {
                  setState(() {
                    _qrLock = value;
                  });
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ============================================================
        // Finish date
        // ============================================================

        InkWell(
          onTap: _selectFinishDate,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outline.withValues(alpha: 0.8),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 30),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Finish By',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        _formatDate(_finishDate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.calendar_month_outlined,
                  color: scheme.primary,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 36),

        // ============================================================
        // Submit
        // ============================================================

        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: _submitService,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFFF3D6),
              foregroundColor: const Color(0xFFF29B00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// INSPECTION ITEM
// =============================================================================

class _InspectionItem extends StatelessWidget {
  const _InspectionItem({
    required this.title,
    required this.status,
    required this.completed,
    required this.onChanged,
    this.warning = false,
    this.error = false,
    this.showDivider = true,
  });

  final String title;
  final String status;
  final bool completed;
  final ValueChanged<bool> onChanged;

  final bool warning;
  final bool error;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Color statusColor;

    if (completed) {
      statusColor = const Color(0xFF18C796);
    } else if (error) {
      statusColor = scheme.error;
    } else if (warning) {
      statusColor = const Color(0xFFE6A919);
    } else {
      statusColor = scheme.onSurface.withValues(alpha: 0.6);
    }

    return Column(
      children: [
        InkWell(
          onTap: () {
            onChanged(!completed);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 9,
            ),
            child: Row(
              children: [
                // -----------------------------------------------------
                // Checkbox
                // -----------------------------------------------------

                GestureDetector(
                  onTap: () {
                    onChanged(!completed);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: completed
                          ? const Color(0xFF18C796)
                          : scheme.surface,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: completed
                            ? const Color(0xFF18C796)
                            : scheme.outline,
                      ),
                    ),
                    child: completed
                        ? const Icon(
                      Icons.check_rounded,
                      size: 19,
                      color: Colors.white,
                    )
                        : null,
                  ),
                ),

                const SizedBox(width: 12),

                // -----------------------------------------------------
                // Inspection text
                // -----------------------------------------------------

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        status,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),

        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 38),
            child: Divider(
              height: 1,
              color: scheme.outline.withValues(alpha: 0.7),
            ),
          ),
      ],
    );
  }
}
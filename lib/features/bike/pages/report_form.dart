import 'package:flutter/material.dart';

class ReportFormPage extends StatefulWidget {
  const ReportFormPage({
    super.key,
    this.bikeId,
  });

  final String? bikeId;

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController =
  TextEditingController();

  String? _selectedBikeId;
  String? _selectedProblem;
  String? _selectedSeverity;

  @override
  void initState() {
    super.initState();

    _selectedBikeId = widget.bikeId;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
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

  void _submitReport() {
    if (_selectedBikeId == null) {
      showSnackBar('Please select a bike');
      return;
    }

    if (_selectedProblem == null) {
      showSnackBar('Please select a problem');
      return;
    }

    if (_selectedSeverity == null) {
      showSnackBar('Please select a severity');
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // TODO: Save report into Supabase later.

    showSnackBar('Report submitted successfully');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
        children: [
          // =========================================================
          // TITLE
          // =========================================================

          Text(
            'Report bike condition',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Help us keep every ride safe.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 18),

          // =========================================================
          // BIKE
          // =========================================================

          if (_selectedBikeId != null)
            _BikeSummaryCard(
              bikeId: _selectedBikeId!,
            )
          else
            _BikeSelector(
              value: _selectedBikeId,
              onChanged: (value) {
                setState(() {
                  _selectedBikeId = value;
                });
              },
            ),

          const SizedBox(height: 20),

          // =========================================================
          // PROBLEM
          // =========================================================

          Text(
            'What is the problem?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.65,
            children: [
              _ProblemButton(
                label: 'Brakes',
                selected: _selectedProblem == 'Brakes',
                onPressed: () {
                  setState(() {
                    _selectedProblem = 'Brakes';
                  });
                },
              ),
              _ProblemButton(
                label: 'Tyres',
                selected: _selectedProblem == 'Tyres',
                onPressed: () {
                  setState(() {
                    _selectedProblem = 'Tyres';
                  });
                },
              ),
              _ProblemButton(
                label: 'Chain',
                selected: _selectedProblem == 'Chain',
                onPressed: () {
                  setState(() {
                    _selectedProblem = 'Chain';
                  });
                },
              ),
              _ProblemButton(
                label: 'Seat',
                selected: _selectedProblem == 'Seat',
                onPressed: () {
                  setState(() {
                    _selectedProblem = 'Seat';
                  });
                },
              ),
              _ProblemButton(
                label: 'Lights',
                selected: _selectedProblem == 'Lights',
                onPressed: () {
                  setState(() {
                    _selectedProblem = 'Lights';
                  });
                },
              ),
              _ProblemButton(
                label: 'Other',
                selected: _selectedProblem == 'Other',
                onPressed: () {
                  setState(() {
                    _selectedProblem = 'Other';
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // =========================================================
          // SEVERITY
          // =========================================================

          Text(
            'Severity',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _SeverityButton(
                  label: 'Low',
                  selected: _selectedSeverity == 'Low',
                  onPressed: () {
                    setState(() {
                      _selectedSeverity = 'Low';
                    });
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _SeverityButton(
                  label: 'Medium',
                  selected: _selectedSeverity == 'Medium',
                  onPressed: () {
                    setState(() {
                      _selectedSeverity = 'Medium';
                    });
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _SeverityButton(
                  label: 'High',
                  selected: _selectedSeverity == 'High',
                  highSeverity: true,
                  onPressed: () {
                    setState(() {
                      _selectedSeverity = 'High';
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // =========================================================
          // DESCRIPTION
          // =========================================================

          Text(
            'Describe the issue',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: _descriptionController,
            minLines: 4,
            maxLines: 5,
            maxLength: 250,
            decoration: const InputDecoration(
              hintText: 'Describe the problem...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please describe the problem';
              }

              return null;
            },
          ),

          const SizedBox(height: 14),

          // =========================================================
          // PHOTOS
          // =========================================================

          Text(
            'Add photos',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              // Temporary uploaded-photo placeholder
              Container(
                width: 115,
                height: 90,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 45,
                        color: scheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),

                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 19,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // TODO: Image picker later.
                  showSnackBar(
                    'Photo picker will be implemented later',
                  );
                },
                child: Container(
                  width: 100,
                  height: 90,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: scheme.onPrimaryContainer,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Add photo',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // =========================================================
          // REPORT BUTTON
          // =========================================================

          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _submitReport,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFCCCC),
                foregroundColor: const Color(0xFFF33F49),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Report',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BIKE SUMMARY
// ============================================================================

class _BikeSummaryCard extends StatelessWidget {
  const _BikeSummaryCard({
    required this.bikeId,
  });

  final String bikeId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outline,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.directions_bike_rounded,
              size: 36,
              color: scheme.onPrimaryContainer,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$bikeId • Standard City Bike',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Folk Valley',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BIKE SELECTOR
// ============================================================================

class _BikeSelector extends StatelessWidget {
  const _BikeSelector({
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: const Text('Select bike'),
      decoration: const InputDecoration(
        labelText: 'Bike',
      ),
      items: const [
        DropdownMenuItem(
          value: 'BR-1000',
          child: Text('BR-1000 • Standard City Bike'),
        ),
        DropdownMenuItem(
          value: 'BR-1028',
          child: Text('BR-1028 • Standard Road Bike'),
        ),
        DropdownMenuItem(
          value: 'BR-1042',
          child: Text('BR-1042 • Standard City Bike'),
        ),
        DropdownMenuItem(
          value: 'BR-1107',
          child: Text('BR-1107 • Standard Road Bike'),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

// ============================================================================
// PROBLEM BUTTON
// ============================================================================

class _ProblemButton extends StatelessWidget {
  const _ProblemButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected
            ? scheme.primary.withValues(alpha: 0.18)
            : scheme.surfaceContainer,
        foregroundColor: selected
            ? scheme.primary
            : scheme.onSurface,
        side: BorderSide(
          color: selected
              ? scheme.primary
              : scheme.outline,
          width: selected ? 1.5 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ============================================================================
// SEVERITY BUTTON
// ============================================================================

class _SeverityButton extends StatelessWidget {
  const _SeverityButton({
    required this.label,
    required this.selected,
    required this.onPressed,
    this.highSeverity = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final bool highSeverity;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final selectedColor = highSeverity
        ? const Color(0xFFF7464C)
        : scheme.primary;

    return SizedBox(
      height: 42,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected
              ? selectedColor
              : scheme.surfaceContainer,
          foregroundColor: selected
              ? Colors.white
              : scheme.onSurface,
          side: BorderSide(
            color: selected
                ? selectedColor
                : scheme.outline,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
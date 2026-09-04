import 'package:flutter/material.dart';

import '../models/bike.dart';
import '../repositories/bike_repository.dart';
import '../repositories/bike_report_repository.dart';

class ReportFormPage extends StatefulWidget {
  const ReportFormPage({
    super.key,
    this.bikeId,
  });

  final int? bikeId;

  @override
  State<ReportFormPage> createState() =>
      _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController =
  TextEditingController();

  final BikeRepository _bikeRepository =
  BikeRepository();

  final BikeReportRepository _reportRepository =
  BikeReportRepository();

  List<Bike> _bikes = [];

  int? _selectedBikeId;
  String? _selectedProblem;

  bool _isLoading = true;
  bool _isSubmitting = false;

  String? _error;

  @override
  void initState() {
    super.initState();

    _selectedBikeId = widget.bikeId;

    _loadBikes();
  }

  @override
  void dispose() {
    _descriptionController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // LOAD BIKES
  // ===========================================================================

  Future<void> _loadBikes() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final bikes = await _bikeRepository.getBikes();

      if (!mounted) return;

      setState(() {
        // Retired bikes do not need new condition reports.
        _bikes = bikes
            .where(
              (bike) => bike.status != 'retired',
        )
            .toList();

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
  // SELECTED BIKE
  // ===========================================================================

  Bike? get _selectedBike {
    if (_selectedBikeId == null) {
      return null;
    }

    for (final bike in _bikes) {
      if (bike.id == _selectedBikeId) {
        return bike;
      }
    }

    return null;
  }

  // ===========================================================================
  // SUBMIT REPORT
  // ===========================================================================

  Future<void> _submitReport() async {
    if (_isSubmitting) return;

    if (_selectedBikeId == null) {
      showSnackBar(
        'Please select a bike',
      );
      return;
    }

    if (_selectedProblem == null) {
      showSnackBar(
        'Please select a problem',
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      await _reportRepository.createReport(
        bikeId: _selectedBikeId!,
        category: _selectedProblem!,
        description:
        _descriptionController.text.trim(),
      );

      if (!mounted) return;

      showSnackBar(
        'Report submitted successfully',
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      showSnackBar(
        'Failed to submit report: $error',
      );
    }
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  void showSnackBar(String message) {
    final messenger =
    ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'available':
        return 'Available';

      case 'reserved':
        return 'Reserved';

      case 'in_use':
        return 'In use';

      case 'maintenance':
        return 'Maintenance';

      case 'retired':
        return 'Retired';

      default:
        return status;
    }
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // -------------------------------------------------------------------------
    // Loading
    // -------------------------------------------------------------------------

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // -------------------------------------------------------------------------
    // Error
    // -------------------------------------------------------------------------

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: scheme.error,
              ),

              const SizedBox(height: 12),

              const Text(
                'Unable to load bikes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _error!,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _loadBikes,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final selectedBike = _selectedBike;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          18,
          16,
          18,
          32,
        ),
        children: [
          // ===================================================================
          // TITLE
          // ===================================================================

          Text(
            'Report bike condition',
            style:
            theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Help us keep every ride safe.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(
                alpha: 0.7,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ===================================================================
          // BIKE
          // ===================================================================

          if (widget.bikeId != null &&
              selectedBike != null)
            _BikeSummaryCard(
              bike: selectedBike,
              statusLabel: _statusLabel(
                selectedBike.status,
              ),
            )
          else
            _BikeSelector(
              bikes: _bikes,
              value: _selectedBikeId,
              onChanged: (value) {
                setState(() {
                  _selectedBikeId = value;
                });
              },
            ),

          const SizedBox(height: 24),

          // ===================================================================
          // PROBLEM
          // ===================================================================

          Text(
            'What is the problem?',
            style:
            theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics:
            const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              _ProblemButton(
                label: 'Brakes',
                icon:
                Icons.settings_input_component_rounded,
                selected:
                _selectedProblem == 'brakes',
                onPressed: () {
                  setState(() {
                    _selectedProblem = 'brakes';
                  });
                },
              ),

              _ProblemButton(
                label: 'Tyres',
                icon:
                Icons.circle_outlined,
                selected:
                _selectedProblem == 'tyres',
                onPressed: () {
                  setState(() {
                    _selectedProblem = 'tyres';
                  });
                },
              ),

              _ProblemButton(
                label: 'Chain',
                icon:
                Icons.settings_rounded,
                selected:
                _selectedProblem ==
                    'chain_gears',
                onPressed: () {
                  setState(() {
                    _selectedProblem =
                    'chain_gears';
                  });
                },
              ),

              _ProblemButton(
                label: 'Seat / Frame',
                icon:
                Icons.directions_bike_outlined,
                selected:
                _selectedProblem ==
                    'seat_frame',
                onPressed: () {
                  setState(() {
                    _selectedProblem =
                    'seat_frame';
                  });
                },
              ),

              _ProblemButton(
                label: 'Bell / Lights',
                icon:
                Icons.lightbulb_outline_rounded,
                selected:
                _selectedProblem ==
                    'bell_lights',
                onPressed: () {
                  setState(() {
                    _selectedProblem =
                    'bell_lights';
                  });
                },
              ),

              _ProblemButton(
                label: 'QR / Lock',
                icon:
                Icons.qr_code_2_rounded,
                selected:
                _selectedProblem == 'qr_lock',
                onPressed: () {
                  setState(() {
                    _selectedProblem = 'qr_lock';
                  });
                },
              ),

              _ProblemButton(
                label: 'Other',
                icon:
                Icons.more_horiz_rounded,
                selected:
                _selectedProblem == 'other',
                onPressed: () {
                  setState(() {
                    _selectedProblem = 'other';
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ===================================================================
          // DESCRIPTION
          // ===================================================================

          Text(
            'Describe the issue',
            style:
            theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: _descriptionController,
            minLines: 4,
            maxLines: 6,
            maxLength: 250,
            decoration: const InputDecoration(
              hintText:
              'Describe what is wrong with the bike...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final description =
                  value?.trim() ?? '';

              if (description.isEmpty) {
                return 'Please describe the problem';
              }

              if (description.length < 5) {
                return 'Please provide more details';
              }

              return null;
            },
          ),

          const SizedBox(height: 10),

          // ===================================================================
          // INFORMATION
          // ===================================================================

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:
              scheme.surfaceContainerHighest,
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: scheme.primary,
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'The report will be reviewed by an administrator. '
                        'Submitting a report does not immediately change the bike status.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          // ===================================================================
          // SUBMIT
          // ===================================================================

          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _isSubmitting
                  ? null
                  : _submitReport,
              style: FilledButton.styleFrom(
                backgroundColor:
                const Color(0xFFFFCCCC),
                foregroundColor:
                const Color(0xFFF33F49),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                width: 22,
                height: 22,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.report_outlined,
                  ),

                  SizedBox(width: 8),

                  Text(
                    'Submit Report',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BIKE SUMMARY
// =============================================================================

class _BikeSummaryCard extends StatelessWidget {
  const _BikeSummaryCard({
    required this.bike,
    required this.statusLabel,
  });

  final Bike bike;
  final String statusLabel;

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
              borderRadius:
              BorderRadius.circular(10),
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
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  bike.code,
                  style:
                  theme.textTheme.bodyMedium?.copyWith(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  bike.stationName ??
                      'No station assigned',
                  style:
                  theme.textTheme.bodySmall?.copyWith(
                    color:
                    scheme.onSurface.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color:
              scheme.surfaceContainerHighest,
              borderRadius:
              BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel,
              style:
              theme.textTheme.labelSmall?.copyWith(
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BIKE SELECTOR
// =============================================================================

class _BikeSelector extends StatelessWidget {
  const _BikeSelector({
    required this.bikes,
    required this.value,
    required this.onChanged,
  });

  final List<Bike> bikes;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      isExpanded: true,
      hint: const Text(
        'Select bike',
      ),
      decoration: const InputDecoration(
        labelText: 'Bike',
        prefixIcon: Icon(
          Icons.directions_bike_outlined,
        ),
      ),
      items: bikes.map((bike) {
        return DropdownMenuItem<int>(
          value: bike.id,
          child: Text(
            bike.stationName == null
                ? bike.code
                : '${bike.code} • ${bike.stationName}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

// =============================================================================
// PROBLEM BUTTON
// =============================================================================

class _ProblemButton extends StatelessWidget {
  const _ProblemButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme =
        Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected
            ? scheme.primary.withValues(
          alpha: 0.18,
        )
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
          borderRadius:
          BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 8,
        ),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
          ),

          const SizedBox(height: 3),

          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight:
                FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
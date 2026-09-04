import 'package:flutter/material.dart';

import '../models/bike.dart';
import '../repositories/bike_repository.dart';

class EditBikePage extends StatefulWidget {
  const EditBikePage({
    super.key,
    required this.bikeId,
  });

  final int bikeId;

  @override
  State<EditBikePage> createState() => _EditBikePageState();
}

class _EditBikePageState extends State<EditBikePage> {
  final _formKey = GlobalKey<FormState>();

  final BikeRepository _bikeRepository = BikeRepository();

  late final TextEditingController _bikeCodeController;
  late final TextEditingController _batteryController;

  Bike? _bike;

  String _selectedStatus = 'available';

  bool _isLoading = true;
  bool _isSaving = false;

  String? _error;

  @override
  void initState() {
    super.initState();

    _bikeCodeController = TextEditingController();
    _batteryController = TextEditingController();

    _loadBike();
  }

  @override
  void dispose() {
    _bikeCodeController.dispose();
    _batteryController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // LOAD EXISTING BIKE
  // ===========================================================================

  Future<void> _loadBike() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final bike = await _bikeRepository.getBike(
        widget.bikeId,
      );

      if (!mounted) return;

      _bikeCodeController.text = bike.code;

      _batteryController.text =
          bike.batteryPercent?.toString() ?? '';

      setState(() {
        _bike = bike;
        _selectedStatus = _normalizeStatus(
          bike.status,
        );

        _isLoading = false;
        _error = null;
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
  // UPDATE BIKE
  // ===========================================================================

  Future<void> _updateBike() async {
    if (_isSaving) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final batteryPercent = int.tryParse(
      _batteryController.text.trim(),
    );

    if (batteryPercent == null) {
      showSnackBar(
        'Invalid battery percentage',
      );
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      await _bikeRepository.updateBike(
        bikeId: widget.bikeId,
        code: _bikeCodeController.text
            .trim()
            .toUpperCase(),
        batteryPercent: batteryPercent,
        status: _selectedStatus,
      );

      if (!mounted) return;

      showSnackBar(
        'Bike updated successfully',
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      showSnackBar(
        'Failed to update bike: $error',
      );
    }
  }

  // ===========================================================================
  // STATUS NORMALIZATION
  // ===========================================================================

  String _normalizeStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'available';

      case 'reserved':
        return 'reserved';

      case 'in_use':
        return 'in_use';

      case 'maintenance':
        return 'maintenance';

      case 'retired':
        return 'retired';

      default:
        return 'maintenance';
    }
  }

  // ===========================================================================
  // SNACKBAR
  // ===========================================================================

  void showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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
                'Unable to load bike',
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
                onPressed: _loadBike,
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

    final bike = _bike!;

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
            'Edit Bike',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Update bike information',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(
                alpha: 0.7,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ===================================================================
          // CURRENT BIKE SUMMARY
          // ===================================================================

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outline.withValues(
                  alpha: 0.6,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.directions_bike_rounded,
                    size: 40,
                    color: scheme.onPrimaryContainer,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bike.code,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 17,
                            color: scheme.primary,
                          ),

                          const SizedBox(width: 4),

                          Expanded(
                            child: Text(
                              bike.stationName ??
                                  'No station assigned',
                              style: theme.textTheme.bodySmall,
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

          const SizedBox(height: 28),

          // ===================================================================
          // BIKE CODE
          // ===================================================================

          _FormSection(
            label: 'Bike ID',
            child: TextFormField(
              controller: _bikeCodeController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'BIKE-C042',
                prefixIcon: Icon(
                  Icons.tag_rounded,
                ),
              ),
              validator: (value) {
                final code = value?.trim() ?? '';

                if (code.isEmpty) {
                  return 'Enter bike ID';
                }

                if (code.length < 3) {
                  return 'Bike ID is too short';
                }

                return null;
              },
            ),
          ),

          const SizedBox(height: 20),

          // ===================================================================
          // BATTERY
          // ===================================================================

          _FormSection(
            label: 'Battery percentage',
            child: TextFormField(
              controller: _batteryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '100',
                prefixIcon: Icon(
                  Icons.battery_full_rounded,
                ),
                suffixText: '%',
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Enter battery percentage';
                }

                final battery = int.tryParse(
                  value.trim(),
                );

                if (battery == null) {
                  return 'Enter a valid number';
                }

                if (battery < 0 || battery > 100) {
                  return 'Battery must be between 0 and 100';
                }

                return null;
              },
            ),
          ),

          const SizedBox(height: 20),

          // ===================================================================
          // STATUS
          // ===================================================================

          _FormSection(
            label: 'Status',
            child: DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              isExpanded: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.info_outline_rounded,
                ),
              ),
              items: [
                const DropdownMenuItem(
                  value: 'available',
                  child: Text('Available'),
                ),

                const DropdownMenuItem(
                  value: 'maintenance',
                  child: Text('Maintenance'),
                ),

                const DropdownMenuItem(
                  value: 'retired',
                  child: Text('Retired'),
                ),

                // If the bike is currently reserved,
                // preserve the value but don't offer it normally.
                if (_selectedStatus == 'reserved')
                  const DropdownMenuItem(
                    value: 'reserved',
                    child: Text('Reserved'),
                  ),

                // Same for an actively rented bike.
                if (_selectedStatus == 'in_use')
                  const DropdownMenuItem(
                    value: 'in_use',
                    child: Text('In use'),
                  ),
              ],
              onChanged:
              _isSaving ||
                  _selectedStatus == 'reserved' ||
                  _selectedStatus == 'in_use'
                  ? null
                  : (value) {
                if (value == null) return;

                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          // ===================================================================
          // STATION INFORMATION
          // ===================================================================

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_rounded,
                  color: scheme.primary,
                  size: 22,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'The current station is not changed from this page. '
                        'Use Transfer Bike to move the bike to another station.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ===================================================================
          // UPDATE BUTTON
          // ===================================================================

          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _isSaving
                  ? null
                  : _updateBike,
              child: _isSaving
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.save_outlined,
                  ),

                  SizedBox(width: 8),

                  Text(
                    'Update Bike',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
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
// FORM SECTION
// =============================================================================

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

// =============================================================================
// FIELD LABEL
// =============================================================================

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(
      this.text,
      );

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .labelMedium
          ?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
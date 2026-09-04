import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/station.dart';
import '../repositories/bike_repository.dart';
import '../repositories/station_repository.dart';

class AddBike extends StatefulWidget {
  const AddBike({
    super.key,
  });

  @override
  State<AddBike> createState() => _AddBikeState();
}

class _AddBikeState extends State<AddBike> {
  final _formKey = GlobalKey<FormState>();
   Uuid _uuid = Uuid();
  final BikeRepository _bikeRepository = BikeRepository();
  final StationRepository _stationRepository = StationRepository();

  final TextEditingController _bikeIdController =
  TextEditingController();

  final TextEditingController _batteryController =
  TextEditingController(
    text: '100',
  );

  List<Station> _stations = [];

  int? _selectedStationId;

  String _selectedStatus = 'available';

  String? _qrToken;

  int _currentStep = 0;

  bool _isLoadingStations = true;
  bool _isSaving = false;

  String? _stationError;

  @override
  void initState() {
    super.initState();

    _loadStations();
  }

  @override
  void dispose() {
    _bikeIdController.dispose();
    _batteryController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // LOAD STATIONS
  // ===========================================================================

  Future<void> _loadStations() async {
    try {
      setState(() {
        _isLoadingStations = true;
        _stationError = null;
      });

      final stations =
      await _stationRepository.getStations();

      if (!mounted) return;

      setState(() {
        _stations = stations;

        if (stations.isNotEmpty) {
          _selectedStationId ??= stations.first.id;
        }

        _isLoadingStations = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _stationError = error.toString();
        _isLoadingStations = false;
      });
    }
  }

  // ===========================================================================
  // SNACKBAR
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

  // ===========================================================================
  // GENERATE QR TOKEN
  // ===========================================================================

  String _generateQrToken() {
    return _uuid.v4();
  }

  // ===========================================================================
  // NEXT STEP
  // ===========================================================================

  void _goToNextStep(int nextStep) {
    if (nextStep == 1) {
      if (!(_formKey.currentState?.validate() ??
          false)) {
        return;
      }

      if (_selectedStationId == null) {
        showSnackBar(
          'Please select a station',
        );
        return;
      }

      setState(() {
        _qrToken = _generateQrToken();
        _currentStep = 1;
      });

      return;
    }

    if (nextStep == 2) {
      setState(() {
        _currentStep = 2;
      });
    }
  }

  // ===========================================================================
  // ADD BIKE TO SUPABASE
  // ===========================================================================

  Future<void> _addBike() async {
    final user = Supabase.instance.client.auth.currentUser;

    debugPrint('Current user: ${user?.id}');
    debugPrint('Current email: ${user?.email}');
    if (_isSaving) return;

    final batteryPercent =
    int.tryParse(
      _batteryController.text.trim(),
    );

    if (batteryPercent == null) {
      showSnackBar(
        'Invalid battery percentage',
      );
      return;
    }

    if (_selectedStationId == null) {
      showSnackBar(
        'No station selected',
      );
      return;
    }

    if (_qrToken == null) {
      showSnackBar(
        'QR token has not been generated',
      );
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      await _bikeRepository.addBike(
        code: _bikeIdController.text
            .trim()
            .toUpperCase(),
        qrToken: _qrToken!,
        stationId: _selectedStationId!,
        batteryPercent: batteryPercent,
        status: _selectedStatus,
      );

      if (!mounted) return;

      showSnackBar(
        'Bike added successfully',
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      showSnackBar(
        'Failed to add bike: $error',
      );
    }
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return switch (_currentStep) {
      0 => _buildStepOne(context),
      1 => _buildStepTwo(context),
      2 => _buildStepThree(context),
      _ => _buildStepOne(context),
    };
  }

  // ===========================================================================
  // STEP 1
  // ===========================================================================

  Widget _buildStepOne(
      BuildContext context,
      ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
          // -------------------------------------------------------------------
          // Title
          // -------------------------------------------------------------------

          Text(
            'Add new bike',
            style:
            theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Step 1 of 3 • Basic information',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(
                alpha: 0.75,
              ),
            ),
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius:
            BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: 1 / 3,
              minHeight: 6,
              backgroundColor:
              scheme.surfaceContainerHighest,
            ),
          ),

          const SizedBox(height: 28),

          // -------------------------------------------------------------------
          // Bike ID
          // -------------------------------------------------------------------

          _FormSection(
            label: 'Bike Code',
            child: TextFormField(
              controller:
              _bikeIdController,
              textCapitalization:
              TextCapitalization.characters,
              decoration:
              const InputDecoration(
                hintText: 'BIKE-1000',
                prefixIcon: Icon(
                  Icons.directions_bike_rounded,
                ),
              ),
              validator: (value) {
                final code =
                    value?.trim() ?? '';

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

          const SizedBox(height: 18),

          // -------------------------------------------------------------------
          // Station
          // -------------------------------------------------------------------

          const _FieldLabel(
            'Initial station',
          ),

          const SizedBox(height: 6),

          if (_isLoadingStations)
            const Padding(
              padding:
              EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: Center(
                child:
                CircularProgressIndicator(),
              ),
            )
          else if (_stationError != null)
            Container(
              padding:
              const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                scheme.errorContainer,
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unable to load stations',
                    style: TextStyle(
                      color: scheme
                          .onErrorContainer,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _stationError!,
                    style:
                    theme.textTheme.bodySmall,
                  ),

                  const SizedBox(height: 8),

                  OutlinedButton.icon(
                    onPressed:
                    _loadStations,
                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),
                    label: const Text(
                      'Retry',
                    ),
                  ),
                ],
              ),
            )
          else if (_stations.isEmpty)
              const Text(
                'No stations are available.',
              )
            else
              DropdownButtonFormField<int>(
                initialValue:
                _selectedStationId,
                isExpanded: true,
                decoration:
                const InputDecoration(
                  prefixIcon: Icon(
                    Icons
                        .location_on_outlined,
                  ),
                ),
                items: _stations.map(
                      (station) {
                    return DropdownMenuItem<
                        int>(
                      value: station.id,
                      child: Text(
                        station.name,
                        overflow:
                        TextOverflow.ellipsis,
                      ),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStationId =
                        value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Select a station';
                  }

                  return null;
                },
              ),

          const SizedBox(height: 18),

          // -------------------------------------------------------------------
          // Battery
          // -------------------------------------------------------------------

          _FormSection(
            label: 'Battery percentage',
            child: TextFormField(
              controller:
              _batteryController,
              keyboardType:
              TextInputType.number,
              decoration:
              const InputDecoration(
                hintText: '100',
                suffixText: '%',
                prefixIcon: Icon(
                  Icons.battery_full_rounded,
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Enter battery percentage';
                }

                final battery =
                int.tryParse(
                  value.trim(),
                );

                if (battery == null) {
                  return 'Enter a valid number';
                }

                if (battery < 0 ||
                    battery > 100) {
                  return 'Battery must be between 0 and 100';
                }

                return null;
              },
            ),
          ),

          const SizedBox(height: 18),

          // -------------------------------------------------------------------
          // Status
          // -------------------------------------------------------------------

          _FormSection(
            label: 'Initial status',
            child:
            DropdownButtonFormField<
                String>(
              initialValue:
              _selectedStatus,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 'available',
                  child: Text(
                    'Available',
                  ),
                ),
                DropdownMenuItem(
                  value: 'maintenance',
                  child: Text(
                    'Maintenance',
                  ),
                ),
                DropdownMenuItem(
                  value: 'unavailable',
                  child: Text(
                    'Unavailable',
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedStatus =
                      value;
                });
              },
            ),
          ),

          const SizedBox(height: 18),

          // -------------------------------------------------------------------
          // QR info
          // -------------------------------------------------------------------

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: scheme
                  .surfaceContainerHighest,
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_rounded,
                  color: scheme.primary,
                  size: 22,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A unique QR token will be generated automatically.',
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 2,
                      ),

                      Text(
                        'The QR code can later contain this token for bike scanning.',
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: scheme
                              .onSurface
                              .withValues(
                            alpha: 0.60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // -------------------------------------------------------------------
          // Next
          // -------------------------------------------------------------------

          Align(
            alignment:
            Alignment.centerRight,
            child: SizedBox(
              width: 125,
              height: 48,
              child: FilledButton(
                onPressed:
                _isLoadingStations ||
                    _stations.isEmpty
                    ? null
                    : () {
                  _goToNextStep(
                    1,
                  );
                },
                child: const Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons
                          .chevron_right_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // STEP 2 - QR TOKEN
  // ===========================================================================

  Widget _buildStepTwo(
      BuildContext context,
      ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        32,
      ),
      children: [
        Text(
          'Add new bike',
          style:
          theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Step 2 of 3 • QR code',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(
              alpha: 0.75,
            ),
          ),
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius:
          BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: 2 / 3,
            minHeight: 6,
            backgroundColor:
            scheme.surfaceContainerHighest,
          ),
        ),

        const SizedBox(height: 28),

        Text(
          'Bike QR Code',
          style:
          theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'The following token will identify this bike when scanned.',
          style: theme.textTheme.bodySmall,
        ),

        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color:
            scheme.surfaceContainer,
            borderRadius:
            BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outline
                  .withValues(
                alpha: 0.5,
              ),
            ),
          ),
          child: Column(
            children: [
              // ---------------------------------------------------------------
              // Bike code
              // ---------------------------------------------------------------

              Text(
                _bikeIdController.text
                    .trim()
                    .toUpperCase(),
                style: theme
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const SizedBox(height: 24),

              // ---------------------------------------------------------------
              // QR placeholder
              // ---------------------------------------------------------------

              Container(
                width: 220,
                height: 220,
                alignment:
                Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  size: 190,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'QR Token',
                style: theme
                    .textTheme
                    .labelMedium
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              SelectableText(
                _qrToken ??
                    'Not generated',
                textAlign:
                TextAlign.center,
                style:
                theme.textTheme.bodySmall,
              ),

              const SizedBox(height: 12),

              Text(
                'The visual QR image is currently a placeholder. Later we can generate an actual QR code from this token.',
                textAlign:
                TextAlign.center,
                style: theme
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                  color: scheme.onSurface
                      .withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 60),

        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 125,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 0;
                  });
                },
                child: const Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons
                          .chevron_left_rounded,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              width: 125,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  _goToNextStep(2);
                },
                child: const Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons
                          .chevron_right_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // STEP 3 - REVIEW
  // ===========================================================================

  Widget _buildStepThree(
      BuildContext context,
      ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final selectedStation =
    _getSelectedStation();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        32,
      ),
      children: [
        Text(
          'Add new bike',
          style:
          theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Step 3 of 3 • Review information',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(
              alpha: 0.75,
            ),
          ),
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius:
          BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: 1,
            minHeight: 6,
            backgroundColor:
            scheme.surfaceContainerHighest,
          ),
        ),

        const SizedBox(height: 28),

        // ---------------------------------------------------------------------
        // Review card
        // ---------------------------------------------------------------------

        Container(
          width: double.infinity,
          padding:
          const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color:
            scheme.surfaceContainer,
            borderRadius:
            BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outline
                  .withValues(
                alpha: 0.5,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Bike information',
                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const SizedBox(height: 20),

              _reviewRow(
                context,
                label: 'Bike ID:',
                value:
                _bikeIdController.text
                    .trim()
                    .toUpperCase(),
              ),

              const SizedBox(height: 14),

              _reviewRow(
                context,
                label: 'Initial station:',
                value:
                selectedStation?.name ??
                    'Not selected',
              ),

              const SizedBox(height: 14),

              _reviewRow(
                context,
                label: 'Battery:',
                value:
                '${_batteryController.text.trim()}%',
              ),

              const SizedBox(height: 14),

              _reviewRow(
                context,
                label: 'Status:',
                value: _statusDisplayName(
                  _selectedStatus,
                ),
              ),

              const SizedBox(height: 24),

              Divider(
                color: scheme.outline
                    .withValues(
                  alpha: 0.5,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Generated QR Code',
                style: theme
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  alignment:
                  Alignment.center,
                  color: Colors.white,
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    size: 105,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: SelectableText(
                  _qrToken ??
                      'Not generated',
                  textAlign:
                  TextAlign.center,
                  style:
                  theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // ---------------------------------------------------------------------
        // Back + Add
        // ---------------------------------------------------------------------

        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 125,
              height: 48,
              child: OutlinedButton(
                onPressed: _isSaving
                    ? null
                    : () {
                  setState(() {
                    _currentStep = 1;
                  });
                },
                child: const Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons
                          .chevron_left_rounded,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              width: 125,
              height: 48,
              child: FilledButton(
                onPressed:
                _isSaving
                    ? null
                    : _addBike,
                child: _isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Add Bike',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  Station? _getSelectedStation() {
    if (_selectedStationId == null) {
      return null;
    }

    for (final station in _stations) {
      if (station.id ==
          _selectedStationId) {
        return station;
      }
    }

    return null;
  }

  String _statusDisplayName(
      String status,
      ) {
    switch (status) {
      case 'available':
        return 'Available';

      case 'maintenance':
        return 'Maintenance';

      case 'unavailable':
        return 'Unavailable';

      default:
        return status;
    }
  }

  Widget _reviewRow(
      BuildContext context, {
        required String label,
        required String value,
      }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: theme
                .textTheme
                .bodySmall
                ?.copyWith(
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            value,
            style:
            theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// FIELD SECTION
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
      crossAxisAlignment:
      CrossAxisAlignment.start,
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
        fontWeight:
        FontWeight.w700,
      ),
    );
  }
}
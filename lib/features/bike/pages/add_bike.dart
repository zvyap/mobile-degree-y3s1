import 'package:bike_renting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

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

  final Uuid _uuid = const Uuid();

  final BikeRepository _bikeRepository =
  BikeRepository();

  final StationRepository _stationRepository =
  StationRepository();

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
          _selectedStationId ??=
              stations.first.id;
        }

        _isLoadingStations = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _stationError =
            error.toString();

        _isLoadingStations =
        false;
      });
    }
  }

  // ===========================================================================
  // SNACKBAR
  // ===========================================================================

  void _showSnackBar(
      String message,
      ) {
    final messenger =
    ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content:
        Text(message),
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

  void _goToNextStep(
      int nextStep,
      ) {
    final l10n =
    AppLocalizations.of(context);

    if (nextStep == 1) {
      if (!(_formKey.currentState
          ?.validate() ??
          false)) {
        return;
      }

      if (_selectedStationId ==
          null) {
        _showSnackBar(
          l10n.pleaseSelectStation,
        );

        return;
      }

      setState(() {
        _qrToken =
            _generateQrToken();

        _currentStep =
        1;
      });

      return;
    }

    if (nextStep == 2) {
      setState(() {
        _currentStep =
        2;
      });
    }
  }

  // ===========================================================================
  // ADD BIKE TO SUPABASE
  // ===========================================================================

  Future<void> _addBike() async {
    final l10n =
    AppLocalizations.of(context);

    final user =
        Supabase.instance.client.auth.currentUser;

    debugPrint(
      'Current user: ${user?.id}',
    );

    debugPrint(
      'Current email: ${user?.email}',
    );

    if (_isSaving) return;

    final batteryPercent =
    int.tryParse(
      _batteryController.text
          .trim(),
    );

    if (batteryPercent ==
        null) {
      _showSnackBar(
        l10n.invalidBatteryPercentage,
      );

      return;
    }

    if (_selectedStationId ==
        null) {
      _showSnackBar(
        l10n.noStationSelected,
      );

      return;
    }

    if (_qrToken == null) {
      _showSnackBar(
        l10n.qrTokenNotGenerated,
      );

      return;
    }

    try {
      setState(() {
        _isSaving =
        true;
      });

      await _bikeRepository.addBike(
        code:
        _bikeIdController.text
            .trim()
            .toUpperCase(),
        qrToken:
        _qrToken!,
        stationId:
        _selectedStationId!,
        batteryPercent:
        batteryPercent,
        status:
        _selectedStatus,
      );

      if (!mounted) return;

      _showSnackBar(
        l10n.bikeAddedSuccessfully,
      );

      Navigator.of(context)
          .pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving =
        false;
      });

      _showSnackBar(
        l10n.failedToAddBike(
          error.toString(),
        ),
      );
    }
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return switch (_currentStep) {
      0 => _buildStepOne(
        context,
      ),
      1 => _buildStepTwo(
        context,
      ),
      2 => _buildStepThree(
        context,
      ),
      _ => _buildStepOne(
        context,
      ),
    };
  }

  // ===========================================================================
  // STEP 1
  // ===========================================================================

  Widget _buildStepOne(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    final l10n =
    AppLocalizations.of(context);

    return Form(
      key:
      _formKey,
      child:
      ListView(
        padding:
        const EdgeInsets.fromLTRB(
          18,
          16,
          18,
          32,
        ),
        children: [
          // -------------------------------------------------------------------
          // TITLE
          // -------------------------------------------------------------------

          Text(
            l10n.addNewBike,
            style: theme
                .textTheme
                .headlineSmall
                ?.copyWith(
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height:
            8,
          ),

          Text(
            l10n.step1BasicInformation,
            style: theme
                .textTheme
                .bodySmall
                ?.copyWith(
              color: scheme
                  .onSurface
                  .withValues(
                alpha:
                0.75,
              ),
            ),
          ),

          const SizedBox(
            height:
            10,
          ),

          ClipRRect(
            borderRadius:
            BorderRadius.circular(
              20,
            ),
            child:
            LinearProgressIndicator(
              value:
              1 / 3,
              minHeight:
              6,
              backgroundColor:
              scheme.surfaceContainerHighest,
            ),
          ),

          const SizedBox(
            height:
            28,
          ),

          // -------------------------------------------------------------------
          // BIKE CODE
          // -------------------------------------------------------------------

          _FormSection(
            label:
            l10n.bikeCode,
            child:
            TextFormField(
              controller:
              _bikeIdController,
              textCapitalization:
              TextCapitalization.characters,
              decoration:
              const InputDecoration(
                hintText:
                'BIKE-1000',
                prefixIcon:
                Icon(
                  Icons.directions_bike_rounded,
                ),
              ),
              validator:
                  (value) {
                final code =
                    value?.trim() ??
                        '';

                if (code.isEmpty) {
                  return l10n
                      .enterBikeCode;
                }

                if (code.length <
                    3) {
                  return l10n
                      .bikeCodeTooShort;
                }

                return null;
              },
            ),
          ),

          const SizedBox(
            height:
            18,
          ),

          // -------------------------------------------------------------------
          // STATION
          // -------------------------------------------------------------------

          _FieldLabel(
            l10n.initialStation,
          ),

          const SizedBox(
            height:
            6,
          ),

          if (_isLoadingStations)
            const Padding(
              padding:
              EdgeInsets.symmetric(
                vertical:
                20,
              ),
              child:
              Center(
                child:
                CircularProgressIndicator(),
              ),
            )
          else if (_stationError !=
              null)
            Container(
              padding:
              const EdgeInsets.all(
                12,
              ),
              decoration:
              BoxDecoration(
                color:
                scheme.errorContainer,
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
              child:
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.unableToLoadStations,
                    style:
                    TextStyle(
                      color:
                      scheme.onErrorContainer,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height:
                    8,
                  ),

                  Text(
                    _stationError!,
                    style:
                    theme.textTheme.bodySmall,
                  ),

                  const SizedBox(
                    height:
                    8,
                  ),

                  OutlinedButton.icon(
                    onPressed:
                    _loadStations,
                    icon:
                    const Icon(
                      Icons.refresh_rounded,
                    ),
                    label:
                    Text(
                      l10n.retry,
                    ),
                  ),
                ],
              ),
            )
          else if (_stations.isEmpty)
              Text(
                l10n.noStationsAvailable,
              )
            else
              DropdownButtonFormField<int>(
                initialValue:
                _selectedStationId,
                isExpanded:
                true,
                decoration:
                const InputDecoration(
                  prefixIcon:
                  Icon(
                    Icons.location_on_outlined,
                  ),
                ),
                items:
                _stations.map(
                      (station) {
                    return DropdownMenuItem<int>(
                      value:
                      station.id,
                      child:
                      Text(
                        station.name,
                        overflow:
                        TextOverflow.ellipsis,
                      ),
                    );
                  },
                ).toList(),
                onChanged:
                    (value) {
                  setState(() {
                    _selectedStationId =
                        value;
                  });
                },
                validator:
                    (value) {
                  if (value ==
                      null) {
                    return l10n
                        .selectStation;
                  }

                  return null;
                },
              ),

          const SizedBox(
            height:
            18,
          ),

          // -------------------------------------------------------------------
          // BATTERY
          // -------------------------------------------------------------------

          _FormSection(
            label:
            l10n.batteryPercentage,
            child:
            TextFormField(
              controller:
              _batteryController,
              keyboardType:
              TextInputType.number,
              decoration:
              const InputDecoration(
                hintText:
                '100',
                suffixText:
                '%',
                prefixIcon:
                Icon(
                  Icons.battery_full_rounded,
                ),
              ),
              validator:
                  (value) {
                if (value ==
                    null ||
                    value
                        .trim()
                        .isEmpty) {
                  return l10n
                      .enterBatteryPercentage;
                }

                final battery =
                int.tryParse(
                  value.trim(),
                );

                if (battery ==
                    null) {
                  return l10n
                      .enterValidNumber;
                }

                if (battery <
                    0 ||
                    battery >
                        100) {
                  return l10n
                      .batteryRangeError;
                }

                return null;
              },
            ),
          ),

          const SizedBox(
            height:
            18,
          ),

          // -------------------------------------------------------------------
          // STATUS
          // -------------------------------------------------------------------

          _FormSection(
            label:
            l10n.initialStatus,
            child:
            DropdownButtonFormField<String>(
              initialValue:
              _selectedStatus,
              isExpanded:
              true,
              items: [
                DropdownMenuItem(
                  value:
                  'available',
                  child:
                  Text(
                    l10n.available,
                  ),
                ),
                DropdownMenuItem(
                  value:
                  'maintenance',
                  child:
                  Text(
                    l10n.maintenance,
                  ),
                ),
                DropdownMenuItem(
                  value:
                  'retired',
                  child:
                  Text(
                    l10n.retired,
                  ),
                ),
              ],
              onChanged:
                  (value) {
                if (value ==
                    null) {
                  return;
                }

                setState(() {
                  _selectedStatus =
                      value;
                });
              },
            ),
          ),

          const SizedBox(
            height:
            18,
          ),

          // -------------------------------------------------------------------
          // QR INFO
          // -------------------------------------------------------------------

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal:
              12,
              vertical:
              11,
            ),
            decoration:
            BoxDecoration(
              color:
              scheme.surfaceContainerHighest,
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child:
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_rounded,
                  color:
                  scheme.primary,
                  size:
                  22,
                ),

                const SizedBox(
                  width:
                  10,
                ),

                Expanded(
                  child:
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.qrGeneratedAutomatically,
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height:
                        2,
                      ),

                      Text(
                        l10n.qrScanningDescription,
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: scheme
                              .onSurface
                              .withValues(
                            alpha:
                            0.60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height:
            28,
          ),

          // -------------------------------------------------------------------
          // NEXT
          // -------------------------------------------------------------------

          Align(
            alignment:
            Alignment.centerRight,
            child:
            SizedBox(
              width:
              125,
              height:
              48,
              child:
              FilledButton(
                onPressed:
                _isLoadingStations ||
                    _stations.isEmpty
                    ? null
                    : () {
                  _goToNextStep(
                    1,
                  );
                },
                child:
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.next,
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      width:
                      8,
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
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
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    final l10n =
    AppLocalizations.of(context);

    return ListView(
      padding:
      const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        32,
      ),
      children: [
        Text(
          l10n.addNewBike,
          style: theme
              .textTheme
              .headlineSmall
              ?.copyWith(
            fontWeight:
            FontWeight.w800,
          ),
        ),

        const SizedBox(
          height:
          8,
        ),

        Text(
          l10n.step2QrCode,
          style: theme
              .textTheme
              .bodySmall
              ?.copyWith(
            color: scheme
                .onSurface
                .withValues(
              alpha:
              0.75,
            ),
          ),
        ),

        const SizedBox(
          height:
          10,
        ),

        ClipRRect(
          borderRadius:
          BorderRadius.circular(
            20,
          ),
          child:
          LinearProgressIndicator(
            value:
            2 / 3,
            minHeight:
            6,
            backgroundColor:
            scheme.surfaceContainerHighest,
          ),
        ),

        const SizedBox(
          height:
          28,
        ),

        Text(
          l10n.bikeQrCode,
          style: theme
              .textTheme
              .titleMedium
              ?.copyWith(
            fontWeight:
            FontWeight.w800,
          ),
        ),

        const SizedBox(
          height:
          8,
        ),

        Text(
          l10n.qrTokenIdentifiesBike,
          style:
          theme.textTheme.bodySmall,
        ),

        const SizedBox(
          height:
          24,
        ),

        Container(
          width:
          double.infinity,
          padding:
          const EdgeInsets.all(
            24,
          ),
          decoration:
          BoxDecoration(
            color:
            scheme.surfaceContainer,
            borderRadius:
            BorderRadius.circular(
              16,
            ),
            border:
            Border.all(
              color: scheme.outline
                  .withValues(
                alpha:
                0.5,
              ),
            ),
          ),
          child:
          Column(
            children: [
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

              const SizedBox(
                height:
                24,
              ),

              Container(
                width:
                220,
                height:
                220,
                alignment:
                Alignment.center,
                decoration:
                BoxDecoration(
                  color:
                  Colors.white,
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child:
                const Icon(
                  Icons.qr_code_2_rounded,
                  size:
                  190,
                  color:
                  Colors.black,
                ),
              ),

              const SizedBox(
                height:
                24,
              ),

              Text(
                l10n.qrToken,
                style: theme
                    .textTheme
                    .labelMedium
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              const SizedBox(
                height:
                8,
              ),

              SelectableText(
                _qrToken ??
                    l10n.notGenerated,
                textAlign:
                TextAlign.center,
                style:
                theme.textTheme.bodySmall,
              ),

              const SizedBox(
                height:
                12,
              ),

              Text(
                l10n.qrPlaceholderDescription,
                textAlign:
                TextAlign.center,
                style: theme
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                  color: scheme
                      .onSurface
                      .withValues(
                    alpha:
                    0.6,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height:
          60,
        ),

        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width:
              125,
              height:
              48,
              child:
              OutlinedButton(
                onPressed:
                    () {
                  setState(() {
                    _currentStep =
                    0;
                  });
                },
                child:
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.chevron_left_rounded,
                    ),
                    const SizedBox(
                      width:
                      6,
                    ),
                    Text(
                      l10n.back,
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              width:
              125,
              height:
              48,
              child:
              FilledButton(
                onPressed:
                    () {
                  _goToNextStep(
                    2,
                  );
                },
                child:
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.next,
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      width:
                      6,
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
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
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    final l10n =
    AppLocalizations.of(context);

    final selectedStation =
    _getSelectedStation();

    return ListView(
      padding:
      const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        32,
      ),
      children: [
        Text(
          l10n.addNewBike,
          style: theme
              .textTheme
              .headlineSmall
              ?.copyWith(
            fontWeight:
            FontWeight.w800,
          ),
        ),

        const SizedBox(
          height:
          8,
        ),

        Text(
          l10n.step3ReviewInformation,
          style: theme
              .textTheme
              .bodySmall
              ?.copyWith(
            color: scheme
                .onSurface
                .withValues(
              alpha:
              0.75,
            ),
          ),
        ),

        const SizedBox(
          height:
          10,
        ),

        ClipRRect(
          borderRadius:
          BorderRadius.circular(
            20,
          ),
          child:
          LinearProgressIndicator(
            value:
            1,
            minHeight:
            6,
            backgroundColor:
            scheme.surfaceContainerHighest,
          ),
        ),

        const SizedBox(
          height:
          28,
        ),

        // ---------------------------------------------------------------------
        // REVIEW CARD
        // ---------------------------------------------------------------------

        Container(
          width:
          double.infinity,
          padding:
          const EdgeInsets.all(
            18,
          ),
          decoration:
          BoxDecoration(
            color:
            scheme.surfaceContainer,
            borderRadius:
            BorderRadius.circular(
              16,
            ),
            border:
            Border.all(
              color: scheme.outline
                  .withValues(
                alpha:
                0.5,
              ),
            ),
          ),
          child:
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                l10n.bikeInformation,
                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const SizedBox(
                height:
                20,
              ),

              _reviewRow(
                context,
                label:
                '${l10n.bikeId}:',
                value:
                _bikeIdController.text
                    .trim()
                    .toUpperCase(),
              ),

              const SizedBox(
                height:
                14,
              ),

              _reviewRow(
                context,
                label:
                '${l10n.initialStation}:',
                value:
                selectedStation?.name ??
                    l10n.notSelected,
              ),

              const SizedBox(
                height:
                14,
              ),

              _reviewRow(
                context,
                label:
                '${l10n.battery}:',
                value:
                '${_batteryController.text.trim()}%',
              ),

              const SizedBox(
                height:
                14,
              ),

              _reviewRow(
                context,
                label:
                '${l10n.status}:',
                value:
                _statusDisplayName(
                  _selectedStatus,
                  l10n,
                ),
              ),

              const SizedBox(
                height:
                24,
              ),

              Divider(
                color: scheme.outline
                    .withValues(
                  alpha:
                  0.5,
                ),
              ),

              const SizedBox(
                height:
                18,
              ),

              Text(
                l10n.generatedQrCode,
                style: theme
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const SizedBox(
                height:
                18,
              ),

              Center(
                child:
                Container(
                  width:
                  120,
                  height:
                  120,
                  alignment:
                  Alignment.center,
                  color:
                  Colors.white,
                  child:
                  const Icon(
                    Icons.qr_code_2_rounded,
                    size:
                    105,
                    color:
                    Colors.black,
                  ),
                ),
              ),

              const SizedBox(
                height:
                12,
              ),

              Center(
                child:
                SelectableText(
                  _qrToken ??
                      l10n.notGenerated,
                  textAlign:
                  TextAlign.center,
                  style:
                  theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height:
          40,
        ),

        // ---------------------------------------------------------------------
        // BACK + ADD
        // ---------------------------------------------------------------------

        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width:
              125,
              height:
              48,
              child:
              OutlinedButton(
                onPressed:
                _isSaving
                    ? null
                    : () {
                  setState(() {
                    _currentStep =
                    1;
                  });
                },
                child:
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.chevron_left_rounded,
                    ),
                    const SizedBox(
                      width:
                      6,
                    ),
                    Text(
                      l10n.back,
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              width:
              125,
              height:
              48,
              child:
              FilledButton(
                onPressed:
                _isSaving
                    ? null
                    : _addBike,
                child:
                _isSaving
                    ? const SizedBox(
                  width:
                  20,
                  height:
                  20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth:
                    2,
                  ),
                )
                    : Text(
                  l10n.addBike,
                  style:
                  const TextStyle(
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
    if (_selectedStationId ==
        null) {
      return null;
    }

    for (final station
    in _stations) {
      if (station.id ==
          _selectedStationId) {
        return station;
      }
    }

    return null;
  }

  String _statusDisplayName(
      String status,
      AppLocalizations l10n,
      ) {
    switch (status) {
      case 'available':
        return l10n.available;

      case 'maintenance':
        return l10n.maintenance;

      case 'retired':
        return l10n.retired;

      default:
        return status;
    }
  }

  Widget _reviewRow(
      BuildContext context, {
        required String label,
        required String value,
      }) {
    final theme =
    Theme.of(context);

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        SizedBox(
          width:
          130,
          child:
          Text(
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

        const SizedBox(
          width:
          8,
        ),

        Expanded(
          child:
          Text(
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
  Widget build(
      BuildContext context,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _FieldLabel(
          label,
        ),
        const SizedBox(
          height:
          6,
        ),
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
  Widget build(
      BuildContext context,
      ) {
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
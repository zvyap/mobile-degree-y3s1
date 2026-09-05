import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

import '../models/bike.dart';
import '../repositories/bike_repository.dart';
import '../widgets/bike_qr_modal.dart';

class BikeManagementPage extends StatefulWidget {
  const BikeManagementPage({
    super.key,
    required this.onAddBike,
    required this.onOpenBikeDetails,
    required this.onOpenReportList,
    required this.onMakeReport,
  });

  final ValueChanged<int> onOpenBikeDetails;
  final VoidCallback onOpenReportList;
  final VoidCallback onAddBike;
  final ValueChanged<int> onMakeReport;

  @override
  State<BikeManagementPage> createState() =>
      _BikeManagementPageState();
}

class _BikeManagementPageState
    extends State<BikeManagementPage> {
  final BikeRepository _bikeRepository =
  BikeRepository();

  final TextEditingController _searchController =
  TextEditingController();

  List<Bike> _bikes = [];

  bool _isLoading = true;

  String? _error;

  String _selectedStatusFilter = 'all';

  @override
  void initState() {
    super.initState();

    _loadBikes();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // LOAD BIKES
  // ===========================================================================

  Future<void> _loadBikes() async {
    try {
      if (_bikes.isEmpty) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final bikes =
      await _bikeRepository.getBikes();

      if (!mounted) return;

      setState(() {
        _bikes = bikes;
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
  // FILTERED BIKES
  // ===========================================================================

  List<Bike> get _filteredBikes {
    final query =
    _searchController.text
        .trim()
        .toLowerCase();

    final filtered = _bikes.where(
          (bike) {
        final bikeStatus =
        _convertBikeStatus(
          bike.status,
        );

        final matchesStatus =
            _selectedStatusFilter ==
                'all' ||
                _statusFilterKey(
                  bikeStatus,
                ) ==
                    _selectedStatusFilter;

        if (!matchesStatus) {
          return false;
        }

        if (query.isEmpty) {
          return true;
        }

        final bikeCode =
        bike.code.toLowerCase();

        final station =
            bike.stationName
                ?.toLowerCase() ??
                '';

        final databaseStatus =
        bike.status.toLowerCase();

        final displayedStatus =
        bikeStatus.label
            .toLowerCase();

        final battery =
            bike.batteryPercent
                ?.toString() ??
                '';

        final description =
        _buildBikeDescription(
          bike,
        ).toLowerCase();

        return bikeCode
            .contains(query) ||
            station.contains(query) ||
            databaseStatus
                .contains(query) ||
            displayedStatus
                .contains(query) ||
            battery.contains(query) ||
            description
                .contains(query);
      },
    ).toList();

    return filtered;
  }

  // ===========================================================================
  // SEARCH
  // ===========================================================================

  void _onSearchChanged(
      String value,
      ) {
    setState(() {});
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {});
  }

  // ===========================================================================
  // BUILD PAGE
  // ===========================================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    final visibleBikes =
        _filteredBikes;

    return RefreshIndicator(
      onRefresh:
      _loadBikes,
      child:
      ListView(
        key:
        const ValueKey<String>(
          'bike-management-page',
        ),
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding:
        const EdgeInsets.fromLTRB(
          18,
          16,
          18,
          32,
        ),
        children: [
          // -------------------------------------------------------------------
          // TITLE + ACTIONS
          // -------------------------------------------------------------------

          Row(
            children: [
              Expanded(
                child:
                Text(
                  context.l10n.fleetDescription,
                  style: theme
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: scheme
                        .onSurface
                        .withValues(
                      alpha:
                      0.7,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              FilledButton.icon(
                onPressed:
                widget.onAddBike,
                icon:
                const Icon(
                  Icons.add_rounded,
                ),
                label:
                Text(
                  context.l10n.addBike,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              OutlinedButton.icon(
                onPressed:
                widget
                    .onOpenReportList,
                icon:
                const Icon(
                  Icons.report_outlined,
                ),
                label:
                Text(
                  context.l10n.reports,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 24,
          ),

          // -------------------------------------------------------------------
          // SEARCH
          // -------------------------------------------------------------------

          _SearchSection(
            controller:
            _searchController,
            onChanged:
            _onSearchChanged,
            onClear:
            _clearSearch,
          ),

          const SizedBox(
            height: 14,
          ),

          // -------------------------------------------------------------------
          // STATUS FILTERS
          // -------------------------------------------------------------------

          _BikeStatusFilters(
            bikes:
            _bikes,
            selectedFilter:
            _selectedStatusFilter,
            onSelected:
                (filter) {
              setState(() {
                _selectedStatusFilter =
                    filter;
              });
            },
          ),

          const SizedBox(
            height: 20,
          ),

          // -------------------------------------------------------------------
          // BIKE COUNT
          // -------------------------------------------------------------------

          Row(
            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
            children: [
              Text(
                visibleBikes.length ==
                    1
                    ? '1 bike'
                    : '${visibleBikes.length} bikes',
                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              Text(
                'Sort: Status',
                style: theme
                    .textTheme
                    .labelMedium
                    ?.copyWith(
                  color: scheme
                      .onSurface
                      .withValues(
                    alpha:
                    0.7,
                  ),
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          // -------------------------------------------------------------------
          // LOADING
          // -------------------------------------------------------------------

          if (_isLoading)
            const Padding(
              padding:
              EdgeInsets.symmetric(
                vertical:
                50,
              ),
              child:
              Center(
                child:
                CircularProgressIndicator(),
              ),
            )

          // -------------------------------------------------------------------
          // ERROR
          // -------------------------------------------------------------------

          else if (_error !=
              null)
            _buildErrorSection(
              context,
            )

          // -------------------------------------------------------------------
          // NO BIKES IN DATABASE
          // -------------------------------------------------------------------

          else if (_bikes.isEmpty)
              _EmptyBikeState(
                icon:
                Icons.directions_bike_outlined,
                title:
                'No bikes found',
                message:
                'Bikes added to the fleet will appear here.',
              )

            // -------------------------------------------------------------------
            // SEARCH / FILTER EMPTY
            // -------------------------------------------------------------------

            else if (visibleBikes
                  .isEmpty)
                _EmptyBikeState(
                  icon:
                  Icons.search_off_rounded,
                  title:
                  'No matching bikes',
                  message:
                  'Try a different search term or status.',
                )

              // -------------------------------------------------------------------
              // BIKE CARDS
              // -------------------------------------------------------------------

              else
                for (int index = 0;
                index <
                    visibleBikes.length;
                index++) ...[
                  _buildBikeCard(
                    context,
                    visibleBikes[index],
                  ),

                  if (index !=
                      visibleBikes.length -
                          1)
                    const SizedBox(
                      height:
                      12,
                    ),
                ],
        ],
      ),
    );
  }

  // ===========================================================================
  // CREATE CARD FROM BIKE
  // ===========================================================================

  Widget _buildBikeCard(
      BuildContext context,
      Bike bike,
      ) {
    final bikeStatus =
    _convertBikeStatus(
      bike.status,
    );

    return _BikeCard(
      bikeId:
      bike.code,
      status:
      bikeStatus,
      location:
      bike.stationName ??
          'No station assigned',
      description:
      _buildBikeDescription(
        bike,
      ),
      onViewDetails:
          () {
        widget.onOpenBikeDetails(
          bike.id,
        );
      },
      onMakeReport:
          () {
        widget.onMakeReport(
          bike.id,
        );
      },
      onShowQr:
          () {
        BikeQrModal.show(
          context,
          bikeCode:
          bike.code,
          qrToken:
          bike.qrToken,
          stationName:
          bike.stationName,
          status:
          bike.status,
        );
      },
    );
  }

  // ===========================================================================
  // BIKE DESCRIPTION
  // ===========================================================================

  String _buildBikeDescription(
      Bike bike,
      ) {
    final description =
    <String>[];

    if (bike.batteryPercent !=
        null) {
      description.add(
        'Battery ${bike.batteryPercent}%',
      );
    }

    if (bike.lastServiceAt !=
        null) {
      description.add(
        'Last service ${_formatDate(bike.lastServiceAt!)}',
      );
    }

    if (description.isEmpty) {
      return 'No additional information';
    }

    return description.join(
      ' • ',
    );
  }

  String _formatDate(
      DateTime date,
      ) {
    final day =
    date.day
        .toString()
        .padLeft(
      2,
      '0',
    );

    final month =
    date.month
        .toString()
        .padLeft(
      2,
      '0',
    );

    return '$day/$month/${date.year}';
  }

  // ===========================================================================
  // STATUS
  // ===========================================================================

  BikeStatus _convertBikeStatus(
      String status,
      ) {
    return _bikeStatusFromDatabase(
      status,
    );
  }

  String _statusFilterKey(
      BikeStatus status,
      ) {
    return switch (status) {
      BikeStatus.available =>
      'available',
      BikeStatus.inService =>
      'maintenance',
      BikeStatus.rented =>
      'rented',
      BikeStatus.unavailable =>
      'unavailable',
    };
  }

  // ===========================================================================
  // ERROR SECTION
  // ===========================================================================

  Widget _buildErrorSection(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical:
        40,
      ),
      child:
      Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color:
            scheme.error,
            size:
            48,
          ),

          const SizedBox(
            height:
            12,
          ),

          Text(
            'Unable to load bikes',
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
            6,
          ),

          Text(
            _error ??
                '',
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
                0.65,
              ),
            ),
          ),

          const SizedBox(
            height:
            16,
          ),

          OutlinedButton.icon(
            onPressed:
            _loadBikes,
            icon:
            const Icon(
              Icons.refresh_rounded,
            ),
            label:
            Text(
              context.l10n.retry,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SEARCH
// =============================================================================

class _SearchSection
    extends StatelessWidget {
  const _SearchSection({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(
      BuildContext context,
      ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return TextField(
      controller:
      controller,
      onChanged:
      onChanged,
      textInputAction:
      TextInputAction.search,
      onSubmitted:
          (_) {
        FocusScope.of(context)
            .unfocus();

        onChanged(
          controller.text,
        );
      },
      decoration:
      InputDecoration(
        hintText:
        'Search bike ID or station',
        prefixIcon:
        IconButton(
          tooltip:
          'Search',
          onPressed:
              () {
            FocusScope.of(context)
                .unfocus();

            onChanged(
              controller.text,
            );
          },
          icon:
          const Icon(
            Icons.search_rounded,
          ),
        ),
        suffixIcon:
        controller.text.isEmpty
            ? null
            : IconButton(
          tooltip:
          'Clear search',
          onPressed:
          onClear,
          icon:
          const Icon(
            Icons.close_rounded,
          ),
        ),
        filled:
        true,
        fillColor:
        scheme.surfaceContainer,
        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            14,
          ),
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            14,
          ),
          borderSide:
          BorderSide(
            color: scheme.outline
                .withValues(
              alpha:
              0.6,
            ),
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            14,
          ),
          borderSide:
          BorderSide(
            color:
            scheme.primary,
            width:
            1.5,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// STATUS FILTERS
// =============================================================================

class _BikeStatusFilters
    extends StatelessWidget {
  const _BikeStatusFilters({
    required this.bikes,
    required this.selectedFilter,
    required this.onSelected,
  });

  final List<Bike> bikes;
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  @override
  Widget build(
      BuildContext context,
      ) {
    final availableCount =
        bikes.where(
              (bike) {
            return _bikeStatusFromDatabase(
              bike.status,
            ) ==
                BikeStatus.available;
          },
        ).length;

    final maintenanceCount =
        bikes.where(
              (bike) {
            return _bikeStatusFromDatabase(
              bike.status,
            ) ==
                BikeStatus.inService;
          },
        ).length;

    final rentedCount =
        bikes.where(
              (bike) {
            return _bikeStatusFromDatabase(
              bike.status,
            ) ==
                BikeStatus.rented;
          },
        ).length;

    final unavailableCount =
        bikes.where(
              (bike) {
            return _bikeStatusFromDatabase(
              bike.status,
            ) ==
                BikeStatus.unavailable;
          },
        ).length;

    return SingleChildScrollView(
      scrollDirection:
      Axis.horizontal,
      child:
      Row(
        children: [
          _StatusFilterChip(
            label:
            'All ${bikes.length}',
            selected:
            selectedFilter ==
                'all',
            onTap:
                () {
              onSelected(
                'all',
              );
            },
          ),

          const SizedBox(
            width:
            8,
          ),

          _StatusFilterChip(
            label:
            'Available $availableCount',
            selected:
            selectedFilter ==
                'available',
            onTap:
                () {
              onSelected(
                'available',
              );
            },
          ),

          const SizedBox(
            width:
            8,
          ),

          _StatusFilterChip(
            label:
            'Maintenance $maintenanceCount',
            selected:
            selectedFilter ==
                'maintenance',
            onTap:
                () {
              onSelected(
                'maintenance',
              );
            },
          ),

          const SizedBox(
            width:
            8,
          ),

          _StatusFilterChip(
            label:
            'Rented $rentedCount',
            selected:
            selectedFilter ==
                'rented',
            onTap:
                () {
              onSelected(
                'rented',
              );
            },
          ),

          const SizedBox(
            width:
            8,
          ),

          _StatusFilterChip(
            label:
            'Unavailable $unavailableCount',
            selected:
            selectedFilter ==
                'unavailable',
            onTap:
                () {
              onSelected(
                'unavailable',
              );
            },
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// STATUS FILTER CHIP
// =============================================================================

class _StatusFilterChip
    extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return InkWell(
      onTap:
      onTap,
      borderRadius:
      BorderRadius.circular(
        20,
      ),
      child:
      Container(
        padding:
        const EdgeInsets.symmetric(
          horizontal:
          14,
          vertical:
          7,
        ),
        decoration:
        BoxDecoration(
          color:
          selected
              ? scheme.primary
              : scheme.surface,
          borderRadius:
          BorderRadius.circular(
            20,
          ),
          border:
          selected
              ? null
              : Border.all(
            color:
            scheme.outline,
          ),
        ),
        child:
        Text(
          label,
          style:
          TextStyle(
            color:
            selected
                ? scheme.onPrimary
                : scheme.onSurface,
            fontSize:
            11,
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// BIKE CARD
// =============================================================================

class _BikeCard
    extends StatelessWidget {
  const _BikeCard({
    required this.bikeId,
    required this.status,
    required this.location,
    required this.description,
    required this.onViewDetails,
    required this.onMakeReport,
    required this.onShowQr,
  });

  final String bikeId;
  final BikeStatus status;
  final String location;
  final String description;

  final VoidCallback onViewDetails;
  final VoidCallback onMakeReport;
  final VoidCallback onShowQr;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    return InkWell(
      onTap:
      onViewDetails,
      borderRadius:
      BorderRadius.circular(
        16,
      ),
      child:
      Container(
        padding:
        const EdgeInsets.all(
          14,
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
              0.7,
            ),
          ),
        ),
        child:
        Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // -----------------------------------------------------------------
            // BIKE ICON
            // -----------------------------------------------------------------

            Container(
              width:
              82,
              height:
              82,
              decoration:
              BoxDecoration(
                color:
                status.placeholderColor(
                  scheme,
                ),
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
              child:
              Icon(
                Icons.directions_bike_rounded,
                size:
                46,
                color:
                status.iconColor(
                  scheme,
                ),
              ),
            ),

            const SizedBox(
              width:
              14,
            ),

            // -----------------------------------------------------------------
            // INFORMATION
            // -----------------------------------------------------------------

            Expanded(
              child:
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child:
                        Text(
                          bikeId,
                          style: theme
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                      ),

                      _BikeStatusBadge(
                        status:
                        status,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height:
                    10,
                  ),

                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color:
                        scheme.primary,
                        size:
                        18,
                      ),

                      const SizedBox(
                        width:
                        4,
                      ),

                      Expanded(
                        child:
                        Text(
                          location,
                          overflow:
                          TextOverflow.ellipsis,
                          style:
                          theme.textTheme.bodySmall,
                        ),
                      ),

                      IconButton(
                        tooltip:
                        'View QR code',
                        onPressed:
                        onShowQr,
                        icon:
                        Icon(
                          Icons.qr_code_2_rounded,
                          color:
                          scheme.onSurface,
                        ),
                      ),

                      PopupMenuButton<BikeMenuAction>(
                        icon:
                        Icon(
                          Icons.more_horiz_rounded,
                          color:
                          scheme.onSurface,
                        ),
                        onSelected:
                            (action) {
                          switch (action) {
                            case BikeMenuAction
                                .details:
                              onViewDetails();

                              break;

                            case BikeMenuAction
                                .makeReport:
                              onMakeReport();

                              break;

                            case BikeMenuAction
                                .showQr:
                              onShowQr();

                              break;
                          }
                        },
                        itemBuilder:
                            (context) => [
                          const PopupMenuItem<
                              BikeMenuAction>(
                            value:
                            BikeMenuAction.details,
                            child:
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                ),
                                SizedBox(
                                  width:
                                  10,
                                ),
                                Text(
                                  'Bike details',
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem<
                              BikeMenuAction>(
                            value:
                            BikeMenuAction.showQr,
                            child:
                            Row(
                              children: [
                                Icon(
                                  Icons.qr_code_2_rounded,
                                ),
                                SizedBox(
                                  width:
                                  10,
                                ),
                                Text(
                                  'QR code',
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem<
                              BikeMenuAction>(
                            value:
                            BikeMenuAction.makeReport,
                            child:
                            Row(
                              children: [
                                Icon(
                                  Icons.report_outlined,
                                ),
                                SizedBox(
                                  width:
                                  10,
                                ),
                                Text(
                                  'Reports',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(
                    height:
                    4,
                  ),

                  Text(
                    description,
                    style: theme
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      color:
                      status.descriptionColor(
                        scheme,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// STATUS BADGE
// =============================================================================

class _BikeStatusBadge
    extends StatelessWidget {
  const _BikeStatusBadge({
    required this.status,
  });

  final BikeStatus status;

  @override
  Widget build(
      BuildContext context,
      ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal:
        12,
        vertical:
        6,
      ),
      decoration:
      BoxDecoration(
        color:
        status.badgeBackgroundColor,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),
      child:
      Text(
        status.label,
        style:
        TextStyle(
          color:
          status.badgeTextColor,
          fontSize:
          11,
          fontWeight:
          FontWeight.w700,
        ),
      ),
    );
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================

class _EmptyBikeState
    extends StatelessWidget {
  const _EmptyBikeState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical:
        48,
      ),
      child:
      Column(
        children: [
          Icon(
            icon,
            size:
            52,
            color: scheme
                .onSurface
                .withValues(
              alpha:
              0.4,
            ),
          ),

          const SizedBox(
            height:
            12,
          ),

          Text(
            title,
            style: theme
                .textTheme
                .titleMedium
                ?.copyWith(
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(
            height:
            4,
          ),

          Text(
            message,
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
    );
  }
}

// =============================================================================
// DATABASE STATUS -> UI STATUS
// =============================================================================

BikeStatus _bikeStatusFromDatabase(
    String status,
    ) {
  switch (status.toLowerCase()) {
    case 'available':
      return BikeStatus.available;

    case 'maintenance':
    case 'in_service':
    case 'in service':
    case 'service':
      return BikeStatus.inService;

    case 'reserved':
    case 'rented':
    case 'in_use':
    case 'in use':
      return BikeStatus.rented;

    case 'retired':
    case 'unavailable':
    case 'disabled':
    case 'lost':
      return BikeStatus.unavailable;

    default:
      return BikeStatus.unavailable;
  }
}

// =============================================================================
// BIKE STATUS
// =============================================================================

enum BikeStatus {
  available,
  inService,
  rented,
  unavailable;

  String get label {
    return switch (this) {
      available =>
      'Available',
      inService =>
      'Maintenance',
      rented =>
      'Rented',
      unavailable =>
      'Unavailable',
    };
  }

  Color get badgeBackgroundColor {
    return switch (this) {
      available =>
      const Color(
        0xFFDDF7E9,
      ),
      inService =>
      const Color(
        0xFFFFF3D6,
      ),
      rented =>
      const Color(
        0xFFEDE5FF,
      ),
      unavailable =>
      const Color(
        0xFFFFE5E5,
      ),
    };
  }

  Color get badgeTextColor {
    return switch (this) {
      available =>
      const Color(
        0xFF159A67,
      ),
      inService =>
      const Color(
        0xFFE6A919,
      ),
      rented =>
      const Color(
        0xFF8C5AE8,
      ),
      unavailable =>
      const Color(
        0xFFE24B4B,
      ),
    };
  }

  Color descriptionColor(
      ColorScheme scheme,
      ) {
    return switch (this) {
      available =>
          scheme.onSurface
              .withValues(
            alpha:
            0.65,
          ),
      inService =>
      const Color(
        0xFFE6A919,
      ),
      rented =>
          scheme.onSurface
              .withValues(
            alpha:
            0.65,
          ),
      unavailable =>
      const Color(
        0xFFE24B4B,
      ),
    };
  }

  Color placeholderColor(
      ColorScheme scheme,
      ) {
    return switch (this) {
      available =>
      scheme.primaryContainer,
      inService =>
      const Color(
        0xFFFFF3D8,
      ),
      rented =>
      scheme.secondaryContainer,
      unavailable =>
      scheme.surfaceContainerHighest,
    };
  }

  Color iconColor(
      ColorScheme scheme,
      ) {
    return switch (this) {
      available =>
      scheme.onPrimaryContainer,
      inService =>
      const Color(
        0xFFD8B844,
      ),
      rented =>
      scheme.onSecondaryContainer,
      unavailable =>
          scheme.onSurface
              .withValues(
            alpha:
            0.65,
          ),
    };
  }
}

// =============================================================================
// BIKE CARD ACTION
// =============================================================================

enum BikeMenuAction {
  details,
  makeReport,
  showQr,
}
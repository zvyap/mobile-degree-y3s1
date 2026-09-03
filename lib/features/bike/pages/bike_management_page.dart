import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import '../models/bike.dart';
import '../repositories/bike_repository.dart';

class BikeManagementPage extends StatelessWidget {
  const BikeManagementPage({
    super.key,
    required this.onAddBike,
    required this.onOpenBikeDetails,
    required this.onOpenReportList,
    required this.onMakeReport
  });

  static const Color _cardColor = Color(0xFF1D2939);
  static const Color _accentColor = Color(0xFF0E8EA8);
  static const Color _borderColor = Color(0xFFD2DCE6);

  final ValueChanged<String> onOpenBikeDetails;
  final VoidCallback onOpenReportList;
  final VoidCallback onAddBike;
  // Add this
  final ValueChanged<String> onMakeReport;
  @override
  Widget build(BuildContext context) {
    return ListView(
          key: const ValueKey<String>('bike-management-page'),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [

            // -------------------------------------------------------
            // Page title
            // -------------------------------------------------------
            Row(
            children: [
            Text(
            context.l10n.fleetDescription,
            style: TextStyle(
            color: Colors.white.withValues(alpha: 0.80),
            fontSize: 16,
            ),
            ),FilledButton.icon(onPressed: onAddBike, icon: const Icon(Icons.add_rounded) ,label: const Text("Add Bike")),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onOpenReportList,
                icon: const Icon(Icons.report_outlined),
                label: const Text('Reports'),
              ),
            ],
            ),

            const SizedBox(height: 4),


            const SizedBox(height: 24),

            // -------------------------------------------------------
            // Search + filter button
            // -------------------------------------------------------
            const _SearchSection(),

            const SizedBox(height: 18),

            // -------------------------------------------------------
            // Status filters
            // -------------------------------------------------------
            const _BikeStatusFilters(),

            const SizedBox(height: 24),

            // -------------------------------------------------------
            // Bike count and sorting
            // -------------------------------------------------------
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '40 bikes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Sort: Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // -------------------------------------------------------
            // Bikes
            // -------------------------------------------------------
             _BikeCard(
              bikeId: 'BR-1028',
              model: 'Standard Road Bike',
              status: BikeStatus.available,
              location: 'Gurney Paragon',
              description: 'Last service 4 days ago',

               onViewDetails: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(
                     content: Text('Opening details'),
                   ),
                 );
                 onOpenBikeDetails('BR-1028');
               },

               onMakeReport: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(
                     content: Text('Opening reports'),
                   ),
                 );

                 onMakeReport('BR-1028');
               },
            ),

            const SizedBox(height: 16),

            _BikeCard(
              bikeId: 'BR-1042',
              model: 'Standard City Bike',
              status: BikeStatus.inService,
              location: 'Folk Valley',
              description: 'Brake issue • Finish by 24/07/2026',

              onViewDetails: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening details'),
                  ),
                );
              },

              onMakeReport: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening reports'),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            _BikeCard(
              bikeId: 'BR-0986',
              model: 'Standard City Bike',
              status: BikeStatus.rented,
              location: 'University TARUMT',
              description: 'Return By 23 July 22:48',

              onViewDetails: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening details'),
                  ),
                );
              },

              onMakeReport: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening reports'),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            _BikeCard(
              bikeId: 'BR-1107',
              model: 'Standard Road Bike',
              status: BikeStatus.unavailable,
              location: 'University TARUMT',
              description: 'Tyre puncture • 1 Open Report',

              onViewDetails: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening details'),
                  ),
                );
                onOpenBikeDetails('BR-1107');
              },

              onMakeReport: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening reports'),
                  ),
                );
                onMakeReport('BR-1107');
              },
            ),
          ],
        );
  }
}

// ===========================================================================
// SEARCH
// ===========================================================================

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: BikeManagementPage._cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: BikeManagementPage._borderColor,
                width: 1.4,
              ),
            ),
            child: const TextField(
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.white70,
                  size: 28,
                ),
                hintText: 'Search bike ID or model',
                hintStyle: TextStyle(
                  color: Color(0xFF8F9BAB),
                  fontSize: 16,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 17,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: BikeManagementPage._cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: BikeManagementPage._borderColor,
              width: 1.4,
            ),
          ),
          child: IconButton(
            onPressed: () {
              // Filter functionality later
            },
            icon: const Icon(
              Icons.filter_alt_outlined,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// FILTER CHIPS
// ===========================================================================

class _BikeStatusFilters extends StatelessWidget {
  const _BikeStatusFilters();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatusFilterChip(
            label: 'All 40',
            selected: true,
          ),
          SizedBox(width: 10),
          _StatusFilterChip(
            label: 'Available',
          ),
          SizedBox(width: 10),
          _StatusFilterChip(
            label: 'Maintenance',
          ),
          SizedBox(width: 10),
          _StatusFilterChip(
            label: 'Unavailable',
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: selected
            ? BikeManagementPage._accentColor
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected
              ? Colors.white
              : const Color(0xFF667386),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ===========================================================================
// BIKE CARD
// ===========================================================================

class _BikeCard extends StatelessWidget {
  const _BikeCard({
    required this.bikeId,
    required this.model,
    required this.status,
    required this.location,
    required this.description,
    required this.onViewDetails,
    required this.onMakeReport,

  });

  final String bikeId;
  final String model;
  final BikeStatus status;
  final String location;
  final String description;

  //callnack
  final VoidCallback onViewDetails;
  final VoidCallback onMakeReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BikeManagementPage._cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: BikeManagementPage._borderColor,
          width: 1.3,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------------------
          // Image placeholder
          // ---------------------------------------------------------
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: status.placeholderColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.directions_bike_rounded,
              size: 52,
              color: status.iconColor,
            ),
          ),

          const SizedBox(width: 14),

          // ---------------------------------------------------------
          // Bike information
          // ---------------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        bikeId,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    _BikeStatusBadge(status: status),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  model,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF6F8397),
                      size: 23,
                    ),

                    const SizedBox(width: 5),

                    Expanded(
                      child: Text(
                        location,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),

                   PopupMenuButton<BikeMenuAction>(
                     icon: const Icon(
                       Icons.more_horiz_rounded,
                       color: Colors.white,
                       size: 28,
                     ),

                     onSelected: (action) {
                       if (action == BikeMenuAction.details) {
                         onViewDetails();
                       } else if (action == BikeMenuAction.makeReport) {
                          onMakeReport();
                       }
                     },

                     itemBuilder: (context) => const [
                       PopupMenuItem(
                         value: BikeMenuAction.details,
                         child: Row(
                           children: [
                             Icon(Icons.info_outline_rounded),
                             SizedBox(width: 10),
                             Text('Bike details'),
                           ],
                         ),
                       ),

                       PopupMenuItem(
                         value: BikeMenuAction.makeReport,
                         child: Row(
                           children: [
                             Icon(Icons.report_outlined),
                             SizedBox(width: 10),
                             Text('Reports'),
                           ],
                         ),
                       ),
                     ],
                   )
                  ],
                ),

                const SizedBox(height: 2),

                Text(
                  description,
                  style: TextStyle(
                    color: status.descriptionColor,
                    fontSize: 13,
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

// ===========================================================================
// STATUS BADGE
// ===========================================================================

class _BikeStatusBadge extends StatelessWidget {
  const _BikeStatusBadge({
    required this.status,
  });

  final BikeStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: status.badgeBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.badgeTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ===========================================================================
// BIKE STATUS
// ===========================================================================

enum BikeStatus {
  available,
  inService,
  rented,
  unavailable;

  String get label {
    return switch (this) {
      available => 'Available',
      inService => 'In service',
      rented => 'Rented',
      unavailable => 'Unavailable',
    };
  }

  Color get badgeBackgroundColor {
    return switch (this) {
      available => const Color(0xFFE1F6EC),
      inService => const Color(0xFFFFF3D6),
      rented => const Color(0xFFEDE5FF),
      unavailable => const Color(0xFFFFE5E5),
    };
  }

  Color get badgeTextColor {
    return switch (this) {
      available => const Color(0xFF12A36D),
      inService => const Color(0xFFE6A919),
      rented => const Color(0xFF8C5AE8),
      unavailable => const Color(0xFFE24B4B),
    };
  }

  Color get descriptionColor {
    return switch (this) {
      available => Colors.white70,
      inService => const Color(0xFFE6A919),
      rented => Colors.white70,
      unavailable => const Color(0xFFE24B4B),
    };
  }

  Color get placeholderColor {
    return switch (this) {
      available => const Color(0xFFE3F3ED),
      inService => const Color(0xFFFFF3D8),
      rented => const Color(0xFFF2F2F2),
      unavailable => const Color(0xFFF2F2F2),
    };
  }

  Color get iconColor {
    return switch (this) {
      available => const Color(0xFF618A91),
      inService => const Color(0xFFD8B844),
      rented => const Color(0xFF607D8B),
      unavailable => const Color(0xFF424242),
    };
  }
}

// ===========================================================================
// BikeCard Action
// ===========================================================================

enum BikeMenuAction{
  details,
  makeReport,
}
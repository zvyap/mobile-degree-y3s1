import 'package:bike_renting_app/features/home/home_page.dart';
import 'package:bike_renting_app/features/modules/module_page.dart';
import 'package:bike_renting_app/features/qr/qr_scan_page.dart';
import 'package:bike_renting_app/navigation/bike_bottom_nav_bar.dart';
import 'package:bike_renting_app/shared/motion.dart';
import 'package:flutter/material.dart';

class BikeShell extends StatefulWidget {
  const BikeShell({super.key, required this.onToggleTheme});

  final ValueChanged<Brightness> onToggleTheme;

  @override
  State<BikeShell> createState() => _BikeShellState();
}

class _BikeShellState extends State<BikeShell> {
  int _selectedIndex = 0;

  void _selectPage(int index) {
    if (_selectedIndex == index) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shouldReduceMotion = reduceMotion(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _AppHeader(onToggleTheme: widget.onToggleTheme),
            Expanded(
              child: AnimatedSwitcher(
                duration: shouldReduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  if (shouldReduceMotion) {
                    return child;
                  }

                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );

                  return FadeTransition(
                    opacity: curved,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(curved),
                      child: child,
                    ),
                  );
                },
                child: _PageContent(
                  key: ValueKey<int>(_selectedIndex),
                  selectedIndex: _selectedIndex,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BikeBottomNavBar(
        selectedIndex: _selectedIndex,
        onSelected: _selectPage,
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.onToggleTheme});

  final ValueChanged<Brightness> onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.directions_bike_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BikeRent',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                Text(
                  'Campus bike renting',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.68),
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: isDark ? 'Switch to light theme' : 'Switch to dark theme',
            child: IconButton(
              onPressed: () => onToggleTheme(theme.brightness),
              icon: AnimatedSwitcher(
                duration: motionDuration(context, 180),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey<bool>(isDark),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return switch (selectedIndex) {
      0 => const HomePage(),
      1 => const ModulePage(
        title: 'Bike Management',
        subtitle: 'Fleet health, battery status, and maintenance queue.',
        icon: Icons.directions_bike_rounded,
        accent: Color(0xFF0E9F6E),
      ),
      2 => const QrScanPage(),
      3 => const ModulePage(
        title: 'Stations',
        subtitle: 'Dock capacity, nearby stations, and return points.',
        icon: Icons.map_rounded,
        accent: Color(0xFFF59E0B),
      ),
      _ => const ModulePage(
        title: 'User',
        subtitle: 'Profile, wallet, permissions, and ride history.',
        icon: Icons.person_rounded,
        accent: Color(0xFF7C3AED),
      ),
    };
  }
}

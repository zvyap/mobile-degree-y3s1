import 'package:bike_renting_app/shared/motion.dart';
import 'package:flutter/material.dart';

class BikeBottomNavBar extends StatelessWidget {
  const BikeBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    _NavItem('Home', Icons.home_rounded),
    _NavItem('Bikes', Icons.directions_bike_rounded),
    _NavItem('Scan', Icons.qr_code_scanner_rounded),
    _NavItem('Stations', Icons.map_rounded),
    _NavItem('User', Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 96 + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 16,
            right: 16,
            bottom: 10 + bottomInset,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: scheme.outline.withValues(alpha: isDark ? 0.58 : 0.9),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 12 + bottomInset,
            child: SizedBox(
              height: 66,
              child: Row(
                children: [
                  Expanded(
                    child: _NavTab(
                      item: _items[0],
                      selected: selectedIndex == 0,
                      onTap: () => onSelected(0),
                    ),
                  ),
                  Expanded(
                    child: _NavTab(
                      item: _items[1],
                      selected: selectedIndex == 1,
                      onTap: () => onSelected(1),
                    ),
                  ),
                  const SizedBox(width: 82),
                  Expanded(
                    child: _NavTab(
                      item: _items[3],
                      selected: selectedIndex == 3,
                      onTap: () => onSelected(3),
                    ),
                  ),
                  Expanded(
                    child: _NavTab(
                      item: _items[4],
                      selected: selectedIndex == 4,
                      onTap: () => onSelected(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _CenterNavButton(
              item: _items[2],
              selected: selectedIndex == 2,
              onTap: () => onSelected(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final duration = motionDuration(context, 180);
    final foreground = selected
        ? scheme.primary
        : scheme.onSurface.withValues(alpha: 0.62);

    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey<String>('nav-${item.label.toLowerCase()}'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOutCubic,
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primary.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: foreground, size: 22),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterNavButton extends StatelessWidget {
  const _CenterNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final duration = motionDuration(context, 200);

    return Semantics(
      selected: selected,
      button: true,
      label: 'Scan QR code',
      child: AnimatedScale(
        scale: selected ? 1.05 : 1,
        duration: duration,
        curve: Curves.easeOutCubic,
        child: Material(
          color: selected ? scheme.secondary : scheme.primary,
          shape: const CircleBorder(),
          elevation: selected ? 12 : 8,
          shadowColor: scheme.primary.withValues(alpha: 0.35),
          child: InkWell(
            key: const ValueKey<String>('nav-scan'),
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 72,
              height: 72,
              child: Icon(item.icon, color: Colors.white, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

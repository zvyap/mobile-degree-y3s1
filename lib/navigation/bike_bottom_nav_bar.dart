import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/navigation/app_page.dart';
import 'package:bike_renting_app/shared/motion.dart';
import 'package:flutter/material.dart';

class BikeBottomNavBar extends StatelessWidget {
  const BikeBottomNavBar({
    super.key,
    required this.selectedPage,
    required this.rideActive,
    required this.onSelected,
  });

  final AppPage selectedPage;
  final bool rideActive;
  final ValueChanged<AppPage> onSelected;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final accessibilityExtra = (textScale - 1) * 20;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 96 + accessibilityExtra + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 16,
            right: 16,
            bottom: 10 + bottomInset,
            child: Container(
              height: 70 + accessibilityExtra,
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
              height: 66 + accessibilityExtra,
              child: Row(
                children: [
                  Expanded(
                    child: _NavTab(
                      page: AppPage.home,
                      selected: selectedPage == AppPage.home,
                      onTap: () => onSelected(AppPage.home),
                    ),
                  ),
                  Expanded(
                    child: _NavTab(
                      page: AppPage.stations,
                      selected: selectedPage == AppPage.stations,
                      onTap: () => onSelected(AppPage.stations),
                    ),
                  ),
                  const SizedBox(width: 82),
                  Expanded(
                    child: _NavTab(
                      page: AppPage.history,
                      selected: selectedPage == AppPage.history,
                      onTap: () => onSelected(AppPage.history),
                    ),
                  ),
                  Expanded(
                    child: _NavTab(
                      page: AppPage.profile,
                      selected: selectedPage == AppPage.profile,
                      onTap: () => onSelected(AppPage.profile),
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
              page: AppPage.scan,
              selected: selectedPage == AppPage.scan,
              rideActive: rideActive,
              onTap: () => onSelected(AppPage.scan),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.page,
    required this.selected,
    required this.onTap,
  });

  final AppPage page;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final duration = motionDuration(context, 180);
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final accessibilityExtra = (textScale - 1) * 20;
    final foreground = selected
        ? scheme.primary
        : scheme.onSurface.withValues(alpha: 0.62);
    final label = page.navigationLabel(context.l10n);

    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey<String>('nav-${page.name}'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOutCubic,
              height: 54 + accessibilityExtra,
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primary.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(page.icon, color: foreground, size: 22),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: foreground,
                      fontSize: 10.5,
                      height: 1.05,
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
    required this.page,
    required this.selected,
    required this.rideActive,
    required this.onTap,
  });

  final AppPage page;
  final bool selected;
  final bool rideActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final duration = motionDuration(context, 200);

    final label = rideActive
        ? context.l10n.currentRide
        : context.l10n.scanQrCode;
    final background = rideActive
        ? scheme.secondary
        : selected
        ? scheme.secondary
        : scheme.primary;

    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: AnimatedScale(
        scale: selected ? 1.05 : 1,
        duration: duration,
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: duration,
          padding: EdgeInsets.all(rideActive ? 3 : 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: rideActive
                ? Border.all(
                    color: scheme.secondary.withValues(alpha: 0.42),
                    width: 2,
                  )
                : null,
          ),
          child: Material(
            color: background,
            shape: const CircleBorder(),
            elevation: selected || rideActive ? 12 : 8,
            shadowColor: background.withValues(alpha: 0.35),
            child: InkWell(
              key: const ValueKey<String>('nav-scan'),
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: rideActive ? 66 : 72,
                height: rideActive ? 66 : 72,
                child: AnimatedSwitcher(
                  duration: duration,
                  child: Icon(
                    rideActive ? Icons.directions_bike_rounded : page.icon,
                    key: ValueKey<bool>(rideActive),
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

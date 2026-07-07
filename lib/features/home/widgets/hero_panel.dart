import 'package:flutter/material.dart';

class HeroPanel extends StatelessWidget {
  const HeroPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 680;
        final content = [
          Expanded(
            flex: isWide ? 6 : 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.72),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: isDark ? 0.12 : 0.8,
                      ),
                    ),
                  ),
                  child: Text(
                    'Nearest station: 240m',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Rent a bike in seconds',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                    letterSpacing: 0,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Find nearby bikes, unlock with QR, and return at any open station.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: (isDark ? Colors.white : const Color(0xFF0F172A))
                        .withValues(alpha: 0.72),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text('Scan and rent'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.near_me_rounded),
                      label: const Text('Find station'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isWide) const SizedBox(width: 28) else const SizedBox(height: 24),
          Expanded(flex: isWide ? 4 : 0, child: const HeroBikeVisual()),
        ];

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: isDark ? 0.30 : 0.10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: scheme.primary.withValues(alpha: isDark ? 0.22 : 0.16),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary.withValues(alpha: isDark ? 0.44 : 0.16),
                scheme.secondary.withValues(alpha: isDark ? 0.26 : 0.12),
                scheme.tertiary.withValues(alpha: isDark ? 0.16 : 0.10),
              ],
            ),
          ),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: content,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: content,
                ),
        );
      },
    );
  }
}

class HeroBikeVisual extends StatelessWidget {
  const HeroBikeVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 168,
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : scheme.surface).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.16 : 0.64),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.directions_bike_rounded,
              size: 88,
              color: scheme.primary,
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: _MiniBadge(
              icon: Icons.bolt_rounded,
              label: 'Fast',
              color: scheme.tertiary,
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: _MiniBadge(
              icon: Icons.lock_open_rounded,
              label: 'QR unlock',
              color: scheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

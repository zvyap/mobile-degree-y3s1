import 'package:bike_renting_app/shared/ui_components.dart';
import 'package:flutter/material.dart';

class QrScanPage extends StatelessWidget {
  const QrScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalInset = width > 920 ? (width - 860) / 2 : 20.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(horizontalInset, 8, horizontalInset, 28),
      children: const [
        Entrance(child: _QrScannerCard()),
        SizedBox(height: 16),
        SurfacePanel(
          child: Row(
            children: [
              IconTile(icon: Icons.info_rounded, color: Color(0xFF0369A1)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Camera integration pending. Dummy scan page ready for QR renting flow.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QrScannerCard extends StatelessWidget {
  const _QrScannerCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SurfacePanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(
                icon: Icons.qr_code_scanner_rounded,
                color: scheme.primary,
                size: 52,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan QR Code',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Point camera at bike QR to start renting.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: isDark ? 0.18 : 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: isDark ? 0.34 : 0.22),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  const _ScannerCorner(alignment: Alignment.topLeft),
                  const _ScannerCorner(alignment: Alignment.topRight),
                  const _ScannerCorner(alignment: Alignment.bottomLeft),
                  const _ScannerCorner(alignment: Alignment.bottomRight),
                  Center(
                    child: Icon(
                      Icons.qr_code_2_rounded,
                      size: 112,
                      color: scheme.primary.withValues(alpha: 0.62),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.directions_bike_rounded),
            label: const Text('Use dummy bike QR'),
          ),
        ],
      ),
    );
  }
}

class _ScannerCorner extends StatelessWidget {
  const _ScannerCorner({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 34,
          height: 34,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: alignment.y < 0
                    ? BorderSide(color: color, width: 4)
                    : BorderSide.none,
                bottom: alignment.y > 0
                    ? BorderSide(color: color, width: 4)
                    : BorderSide.none,
                left: alignment.x < 0
                    ? BorderSide(color: color, width: 4)
                    : BorderSide.none,
                right: alignment.x > 0
                    ? BorderSide(color: color, width: 4)
                    : BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

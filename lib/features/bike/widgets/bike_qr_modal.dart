import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Modal dialog that displays a scannable QR code for a specific bike.
///
/// Features:
/// - High-contrast QR code rendering with high error correction (Level H)
/// - Left button: "Export" to save QR badge to gallery
/// - Right button: "Close" to dismiss
/// - Material 3 theme styling with accessible 48dp touch targets
class BikeQrModal extends StatefulWidget {
  const BikeQrModal({
    super.key,
    required this.bikeCode,
    required this.qrToken,
    this.stationName,
    this.status,
  });

  final String bikeCode;
  final String qrToken;
  final String? stationName;
  final String? status;

  /// Convenience method to display the modal dialog.
  static Future<void> show(
    BuildContext context, {
    required String bikeCode,
    required String qrToken,
    String? stationName,
    String? status,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => BikeQrModal(
        bikeCode: bikeCode,
        qrToken: qrToken,
        stationName: stationName,
        status: status,
      ),
    );
  }

  @override
  State<BikeQrModal> createState() => _BikeQrModalState();
}

class _BikeQrModalState extends State<BikeQrModal> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isExporting = false;

  String get _qrPayload =>
      widget.qrToken.isNotEmpty ? widget.qrToken : widget.bikeCode;

  Future<void> _exportToGallery() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    try {
      // 1. Check or request gallery permission
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Gallery permission is required to export QR code'),
            ),
          );
          return;
        }
      }

      // 2. Render repaint boundary into image bytes
      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Failed to capture QR code image')),
        );
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Failed to encode QR image')),
        );
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();

      // 3. Save to gallery via Gal
      await Gal.putImageBytes(
        pngBytes,
        name: 'bike_qr_${widget.bikeCode.toLowerCase().replaceAll(' ', '_')}',
      );

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('QR code for ${widget.bikeCode} exported to gallery!'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0E9F6E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to export: $e'),
          backgroundColor: errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: scheme.outline.withValues(alpha: isDark ? 0.4 : 0.8),
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // -------------------------------------------------------------
              // Header
              // -------------------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.qr_code_2_rounded,
                          color: scheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.bikeCode,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Bike QR Code',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    key: const ValueKey('bike-qr-top-close-button'),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // -------------------------------------------------------------
              // QR Code Badge (RepaintBoundary for gallery export)
              // -------------------------------------------------------------
              Center(
                child: RepaintBoundary(
                  key: _repaintBoundaryKey,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.35 : 0.08,
                          ),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Card mini header
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.directions_bike_rounded,
                              size: 18,
                              color: Color(0xFF0369A1),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.bikeCode,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // High error correction QR image
                        QrImageView(
                          data: _qrPayload,
                          version: QrVersions.auto,
                          size: 220,
                          // Level H provides up to ~30% error correction,
                          // making scanning resilient to dirt, damage, and angles
                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                          padding: const EdgeInsets.all(4),
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Scan with BikeRent Scanner',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (widget.stationName != null &&
                  widget.stationName!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.stationName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 22),

              // -------------------------------------------------------------
              // Bottom Two Buttons: Left = Export, Right = Close
              // -------------------------------------------------------------
              Row(
                children: [
                  // Left button: Export to gallery
                  Expanded(
                    child: FilledButton.icon(
                      key: const ValueKey('bike-qr-export-button'),
                      onPressed: _isExporting ? null : _exportToGallery,
                      icon: _isExporting
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: scheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.file_download_outlined, size: 20),
                      label: const Text('Export'),
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Right button: Close
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('bike-qr-close-button'),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      label: const Text('Close'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: scheme.onSurface,
                        side: BorderSide(
                          color: scheme.outline.withValues(
                            alpha: isDark ? 0.6 : 1.0,
                          ),
                        ),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

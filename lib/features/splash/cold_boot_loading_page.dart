import 'dart:async';
import 'package:bike_renting_app/navigation/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cold boot loading page displaying the Malaysia smart city bike rental banner.
class ColdBootLoadingPage extends StatefulWidget {
  const ColdBootLoadingPage({
    super.key,
    required this.onToggleTheme,
  });

  final ValueChanged<Brightness> onToggleTheme;

  @override
  State<ColdBootLoadingPage> createState() => _ColdBootLoadingPageState();
}

class _ColdBootLoadingPageState extends State<ColdBootLoadingPage> {
  bool _isReady = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startColdBootTimer();
  }

  void _startColdBootTimer() {
    _timer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() => _isReady = true);
      }
    });
  }

  void _skip() {
    _timer?.cancel();
    if (mounted && !_isReady) {
      setState(() => _isReady = true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;

    return AnimatedSwitcher(
      duration: reducedMotion ? Duration.zero : const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _isReady
          ? AuthGate(
              key: const ValueKey('auth_gate_view'),
              onToggleTheme: widget.onToggleTheme,
            )
          : _ColdBootBannerView(
              key: const ValueKey('cold_boot_banner_view'),
              onTap: _skip,
            ),
    );
  }
}

class _ColdBootBannerView extends StatelessWidget {
  const _ColdBootBannerView({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF030F2F),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF030F2F),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Malaysia Smart City Bike Rent Banner
              Image.asset(
                'assets/images/cold_boot_banner.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                semanticLabel:
                    'Smart bike rental station with docked bicycles in modern Malaysian smart city infrastructure',
              ),

              // 2. Top Scrim for Status Bar Legibility
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 120,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.65),
                        Colors.black.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Top Branding Pill
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x99030F2F),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: const Color(0x3300E5FF),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.directions_bike_rounded,
                            size: 18,
                            color: Color(0xFF00FFC2),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'BikeRent',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Bottom Scrim & Loading Information
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        const Color(0xF0030F2F),
                        const Color(0xB3030F2F),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Clean City · Smart Ride',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Eco-friendly bike transit connecting Malaysia\'s urban centers.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Progress Indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: const LinearProgressIndicator(
                            minHeight: 4,
                            backgroundColor: Color(0x33FFFFFF),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF00E5FF),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Connecting to station network...',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Tap to skip',
                              style: TextStyle(
                                color: const Color(0xFF00FFC2).withValues(alpha: 0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

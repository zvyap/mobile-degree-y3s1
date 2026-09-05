import 'package:bike_renting_app/l10n/app_localizations.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/features/splash/cold_boot_loading_page.dart';
import 'package:bike_renting_app/shared/app_toast.dart';
import 'package:bike_renting_app/shared/connection_service.dart';
import 'package:bike_renting_app/shared/location_safeguard.dart';
import 'package:bike_renting_app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BikeRentingApp extends StatefulWidget {
  const BikeRentingApp({
    super.key,
    this.testInternet = testInternetConnection,
    this.testSupabase = testSupabaseConnection,
    this.initSupabase = ensureSupabaseInitialized,
    this.minimumSplashDuration = const Duration(milliseconds: 600),
    this.initialLocale,
  });

  final Future<bool> Function() testInternet;
  final Future<bool> Function() testSupabase;
  final Future<void> Function() initSupabase;
  final Duration minimumSplashDuration;
  final Locale? initialLocale;

  @override
  State<BikeRentingApp> createState() => _BikeRentingAppState();
}

class _BikeRentingAppState extends State<BikeRentingApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late Locale? _locale = widget.initialLocale ?? const Locale('en');

  void _toggleTheme(Brightness currentBrightness) {
    setState(() {
      _themeMode = currentBrightness == Brightness.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  void _setLocale(Locale? locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.l10n.appName,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      themeMode: _themeMode,
      theme: AppTheme.build(Brightness.light),
      darkTheme: AppTheme.build(Brightness.dark),
      builder: (context, child) => AppLocaleScope(
        locale: _locale,
        onLocaleChanged: _setLocale,
        child: AppToastHost(
          child: LocationSafeguard(child: child!),
        ),
      ),
      home: ColdBootLoadingPage(
        onToggleTheme: _toggleTheme,
        testInternet: widget.testInternet,
        testSupabase: widget.testSupabase,
        initSupabase: widget.initSupabase,
        minimumDuration: widget.minimumSplashDuration,
      ),
    );
  }
}

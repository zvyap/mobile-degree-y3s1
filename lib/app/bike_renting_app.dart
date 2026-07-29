import 'package:bike_renting_app/l10n/app_localizations.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/shell/bike_shell.dart';
import 'package:bike_renting_app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BikeRentingApp extends StatefulWidget {
  const BikeRentingApp({super.key});

  @override
  State<BikeRentingApp> createState() => _BikeRentingAppState();
}

class _BikeRentingAppState extends State<BikeRentingApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(Brightness currentBrightness) {
    setState(() {
      _themeMode = currentBrightness == Brightness.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.l10n.appName,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: _themeMode,
      theme: AppTheme.build(Brightness.light),
      darkTheme: AppTheme.build(Brightness.dark),
      home: BikeShell(onToggleTheme: _toggleTheme),
    );
  }
}

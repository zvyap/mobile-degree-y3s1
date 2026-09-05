import 'package:bike_renting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum AppPage {
  home(routeName: '/home', icon: Icons.home_rounded),
  stations(routeName: '/stations', icon: Icons.map_rounded),
  scan(routeName: '/scan', icon: Icons.qr_code_scanner_rounded),
  history(routeName: '/history', icon: Icons.history_rounded),
  rideDetails(routeName: '/history/details', icon: Icons.receipt_long_rounded),
  profile(routeName: '/profile', icon: Icons.person_rounded),
  admin(routeName: '/admin', icon: Icons.admin_panel_settings_rounded),
  userManagement(routeName: '/admin/users', icon: Icons.manage_accounts_rounded),
  editUser(routeName: '/admin/users/edit', icon: Icons.edit_rounded),
  addUser(routeName: '/admin/users/add', icon: Icons.person_add_rounded),
  bikeManagement(routeName: '/admin/bikes', icon: Icons.directions_bike_rounded,),
  addbike(routeName: '/admin/bike/addBike', icon: Icons.add_rounded),
  editBike(routeName: '/admin/bike/editBike', icon: Icons.add_rounded),
  bikeDetail(routeName: '/admin/bike/bikeDetail', icon: Icons.receipt_long_rounded ),
  bikeReport(routeName: '/admin/bike/bikeReport', icon: Icons.receipt_long_rounded ),
  transferBike(routeName: '/admin/bike/transfer', icon: Icons.compare_arrows_rounded,),
  serviceBike(routeName: '/admin/bike/service', icon: Icons.build_rounded,),
  bikeReportDetail(routeName: '/admin/bike/reports/detail', icon: Icons.description_outlined,),
  pendingBikeReports(routeName: '/admin/bike/reports/pending', icon: Icons.pending_actions_rounded,),
  stationManagement(routeName: '/admin/stations', icon: Icons.map_rounded),
  reportForm(routeName: '/admin/bikes/reports/new', icon: Icons.add_rounded,),
  pendingReportDetail(routeName: '/admin/bikes/reports/pending/detail',icon: Icons.description_outlined,),
  settings(routeName: '/settings', icon: Icons.settings_rounded),
  paymentMethods(routeName: '/settings/payment-methods', icon: Icons.payment_rounded),
  rentingManagement(routeName: '/admin/rentals', icon: Icons.pedal_bike_rounded),
  rentingDetail(routeName: '/admin/rentals/detail', icon: Icons.receipt_long_rounded);

  const AppPage({required this.routeName, required this.icon});

  final String routeName;
  final IconData icon;

  String title(AppLocalizations l10n) => switch (this) {
    home => l10n.home,
    stations => l10n.stations,
    scan => l10n.bikeSession,
    history => l10n.history,
    rideDetails => l10n.rideDetails,
    profile => l10n.profile,
    admin => l10n.adminManagement,
    userManagement => l10n.userManagement,
    editUser => 'Edit User',
    addUser => 'Add new User',
    bikeManagement => l10n.bikeManagement,
    stationManagement => l10n.stationManagement,
    addbike => l10n.addBike,
    settings => l10n.settings,
    bikeDetail => l10n.bikeDetail,
    bikeReport => l10n.bikeReport,
    editBike => l10n.editBike,
    transferBike => l10n.transferBike,
    serviceBike => l10n.serviceBike,
    bikeReportDetail => l10n.reportDetail,
    pendingBikeReports => l10n.pendingReports,
    reportForm => l10n.newReport,
    pendingReportDetail => l10n.pendingReportDetails,
    paymentMethods => l10n.paymentMethods,
    rentingManagement => 'Rental Management',
    rentingDetail => 'Rental Details',
  };

  String navigationLabel(AppLocalizations l10n) => switch (this) {
    home => l10n.home,
    stations => l10n.stations,
    scan => l10n.scan,
    history => l10n.history,
    profile => l10n.profile,
    _ => throw StateError('$name is not a navigation page'),
  };

  bool get isNavigationRoot => navigationPages.contains(this);

  int? get navigationIndex =>
      isNavigationRoot ? navigationPages.indexOf(this) : null;

  static const navigationPages = [home, stations, scan, history, profile];

  static AppPage? fromRouteName(String? routeName) {
    for (final page in values) {
      if (page.routeName == routeName) return page;
    }
    return null;
  }
}

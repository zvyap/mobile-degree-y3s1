import 'package:bike_renting_app/bike_station/shared_map.dart';
import 'package:bike_renting_app/bike_station/station_map.dart';
import 'package:bike_renting_app/features/admin/admin_management_page.dart';
import 'package:bike_renting_app/features/admin/admin_rentals_page.dart';
import 'package:bike_renting_app/features/admin/admin_rental_detail_page.dart';
import 'package:bike_renting_app/features/bike/pages/bike_details.dart';
import 'package:bike_renting_app/features/bike/pages/bike_management_page.dart';
import 'package:bike_renting_app/features/home/home_page.dart';
import 'package:bike_renting_app/features/user/profile_controller.dart';
import 'package:bike_renting_app/features/user/profile_page.dart';
import 'package:bike_renting_app/features/history/ride_details_page.dart';
import 'package:bike_renting_app/features/history/ride_history_models.dart';
import 'package:bike_renting_app/features/history/ride_history_page.dart';
import 'package:bike_renting_app/features/qr/qr_scan_page.dart';
import 'package:bike_renting_app/features/renting/renting_controller.dart';
import 'package:bike_renting_app/features/settings/settings_page.dart';
import 'package:bike_renting_app/features/user/user_controller.dart';
import 'package:bike_renting_app/features/user/user_management_page.dart';
import 'package:bike_renting_app/navigation/app_page.dart';
import 'package:bike_renting_app/shared/motion.dart';
import 'package:flutter/material.dart';
import 'package:bike_renting_app/features/bike/pages/add_bike.dart';
import 'package:bike_renting_app/features/bike/pages/bike_report_list.dart';
import 'package:bike_renting_app/features/bike/pages/edit_bike.dart';
import 'package:bike_renting_app/features/bike/pages/transfer_bike.dart';
import 'package:bike_renting_app/features/bike/pages/bike_service.dart';
import 'package:bike_renting_app/features/bike/pages/bike_report_detail_page.dart';
import 'package:bike_renting_app/features/bike/pages/pending_report_page.dart';
import 'package:bike_renting_app/features/bike/pages/report_form.dart';
import 'package:bike_renting_app/data/database/database_data_source.dart';
import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/data/repositories/payment_method_repository.dart';
import 'package:bike_renting_app/features/payment_methods/pages/payment_methods_page.dart';
import 'package:bike_renting_app/features/bike/pages/pending_report_detail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/user/add_user.dart';
import '../features/user/edit_user.dart';
class AppNavigator extends StatelessWidget {
  const AppNavigator({
    super.key,
    required this.navigatorKey,
    required this.observer,
    required this.rentingController,
    required this.profileController,
    required this.userController,
    required this.onSelectRootPage,
    required this.onOpenPage,
    required this.onToggleTheme,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final NavigatorObserver observer;
  final RentingController rentingController;
  final ProfileController profileController;
  final UserController userController;
  final ValueChanged<AppPage> onSelectRootPage;
  final ValueChanged<AppPage> onOpenPage;
  final ValueChanged<Brightness> onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: AppPage.home.routeName,
      observers: [observer],
      onGenerateRoute: (settings) {
        final page = AppPage.fromRouteName(settings.name) ?? AppPage.home;
        final duration = reduceMotion(context)
            ? Duration.zero
            : const Duration(milliseconds: 260);
        final routeArguments = page == AppPage.rideDetails
            ? settings.arguments
            : page;

        return PageRouteBuilder<void>(
          settings: RouteSettings(
            name: page.routeName,
            arguments: routeArguments,
          ),
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          pageBuilder: (context, animation, secondaryAnimation) =>
              _buildPage(context, page, settings.arguments),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            final outgoing = CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeInCubic,
              reverseCurve: Curves.easeOutCubic,
            );

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 1.0, end: 0.0).animate(outgoing),
                  child: child,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPage(BuildContext context, AppPage page, Object? arguments) {
    return switch (page) {
      AppPage.home => HomePage(
        rentingController: rentingController,
        onNavigate: onSelectRootPage,
      ),
      AppPage.stations => const RefinedUserBikeView(),
      AppPage.stationManagement => const AdminStationMapScreen(),
      AppPage.scan => QrScanPage(
        controller: rentingController,
        onRequestExit: () => onSelectRootPage(AppPage.home),
      ),
      AppPage.history => RideHistoryPage(
        onRideSelected: (ride) => Navigator.of(context).pushNamed(
          AppPage.rideDetails.routeName,
          arguments: RideDetailsRouteArguments(ride),
        ),
      ),
      AppPage.rideDetails => RideDetailsPage(
        ride: (arguments as RideDetailsRouteArguments).ride,
      ),
      AppPage.profile => ProfilePage(
        profileCTRL: profileController,
      ),
      AppPage.admin => AdminManagementPage(
        onNavigate: onSelectRootPage,
        onOpenUserManagement: () => onOpenPage(AppPage.userManagement),
        onOpenBikeManagement: () => onOpenPage(AppPage.bikeManagement),
        onOpenStationManagement: () => onOpenPage(AppPage.stationManagement),
        onOpenRentingManagement: () => onOpenPage(AppPage.rentingManagement),
      ),
      AppPage.rentingManagement => AdminRentalsPage(
        repository: rentingController.repository,
        userId: switch (arguments) {
          final AdminRentalsRouteArguments args => args.userId,
          final UserProfileRecord user => user.id,
          _ => null,
        },
        userName: switch (arguments) {
          final AdminRentalsRouteArguments args => args.userName,
          final UserProfileRecord user => user.displayName,
          _ => null,
        },
        onOpenDetails: (rentalId) => navigatorKey.currentState?.pushNamed(
          AppPage.rentingDetail.routeName,
          arguments: rentalId,
        ),
      ),
      AppPage.rentingDetail => AdminRentalDetailPage(
        rentalId: arguments is int ? arguments : 0,
        repository: rentingController.repository,
        rentingController: rentingController,
        onSessionEnded: () {
          navigatorKey.currentState?.pop(true);
        },
      ),
      AppPage.addbike => const AddBike(),
      AppPage.bikeDetail => BikeDetailsPage(
        bikeId: arguments as int,
        onEditBike: (){
          navigatorKey.currentState?.pushNamed(
            AppPage.editBike.routeName,
            arguments: arguments,
          );
        },
        onTransferBike: () {
          navigatorKey.currentState?.pushNamed(
            AppPage.transferBike.routeName,
            arguments: arguments,
          );
        },
        onServiceBike: () {
          navigatorKey.currentState?.pushNamed(
            AppPage.serviceBike.routeName,
            arguments: arguments,
          );
        },
        onMakeReport: () {
          navigatorKey.currentState?.pushNamed(
            AppPage.reportForm.routeName,
            arguments: arguments,
          );
        },
      ),
      AppPage.serviceBike => ServiceBikePage(
        bikeId: arguments as int,
      ),
      AppPage.transferBike => TransferBikePage(
        bikeId: arguments as int,
      ),
      AppPage.editBike => EditBikePage(
        bikeId: arguments as int,
      ),
      AppPage.bikeReport => BikeReportPage(
        onOpenReportDetail: (reportId) {
          navigatorKey.currentState?.pushNamed(
            AppPage.bikeReportDetail.routeName,
            arguments: reportId,
          );
        },
        onOpenPendingReports: (){
          navigatorKey.currentState?.pushNamed(
            AppPage.pendingBikeReports.routeName,
          );
        },
        onAddReport: (bikeId) {
          navigatorKey.currentState?.pushNamed(
            AppPage.reportForm.routeName,
            arguments: arguments,
          );
        },
      ),
      AppPage.reportForm => ReportFormPage(
        bikeId: arguments is int ? arguments : null,
      ),
      AppPage.pendingBikeReports => PendingBikeReportsPage(
        onOpenReportDetail: (reportId) {
          navigatorKey.currentState?.pushNamed(
            AppPage.pendingReportDetail.routeName,
            arguments: reportId,
          );
        },

      ),
      AppPage.pendingReportDetail => PendingReportDetail(
        reportId: arguments as int,
      ),
      AppPage.bikeReportDetail => BikeReportDetailPage(
        reportId: arguments as int,
      ),
      AppPage.bikeManagement => BikeManagementPage(
        onAddBike: () => onOpenPage(AppPage.addbike),
        onOpenBikeDetails: (bikeId) {
          navigatorKey.currentState?.pushNamed(
            AppPage.bikeDetail.routeName,
            arguments: bikeId,
          );
        },
        onOpenReportList: () {
          navigatorKey.currentState?.pushNamed(
            AppPage.bikeReport.routeName,
          );
        },
        onMakeReport: (bikeId) {
          navigatorKey.currentState?.pushNamed(
            AppPage.reportForm.routeName,
            arguments: bikeId,
          );
        },
      ),

      AppPage.editUser => EditUserPage(
        userCTRL: userController,
        userId: arguments as String,
      ),

      AppPage.addUser => AddUserPage(
        userCTRL: userController,
      ),
      AppPage.userManagement => UserManagementPage(
        userCTRL: userController,
        onEditUser: (userId) {
          navigatorKey.currentState?.pushNamed(
            AppPage.editUser.routeName,
            arguments: userId,
          );
        },
        onAddUser: () {
          navigatorKey.currentState?.pushNamed(
            AppPage.addUser.routeName,
          );
        },
        onOpenRentalHistory: (user) {
          navigatorKey.currentState?.pushNamed(
            AppPage.rentingManagement.routeName,
            arguments: AdminRentalsRouteArguments(
              userId: user.id,
              userName: user.displayName,
            ),
          );
        },
      ),

      AppPage.settings => SettingsPage(onToggleTheme: onToggleTheme),
      AppPage.paymentMethods => PaymentMethodsPage(
        repository: rentingController.paymentMethodRepository ??
            PaymentMethodRepository(
              SupabaseDatabaseDataSource(Supabase.instance.client),
            ),
      ),
    };
  }
}

class RideDetailsRouteArguments {
  const RideDetailsRouteArguments(this.ride);

  final RideHistoryEntry ride;
}

class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver(this.onPageChanged);

  final ValueChanged<AppPage> onPageChanged;

  void _notify(Route<dynamic>? route) {
    final arguments = route?.settings.arguments;
    final page = arguments is AppPage
        ? arguments
        : AppPage.fromRouteName(route?.settings.name);
    if (page != null) onPageChanged(page);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _notify(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _notify(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _notify(newRoute);
  }
}

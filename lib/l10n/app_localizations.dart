import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'BikeRent'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @stations.
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get stations;

  /// No description provided for @bikeSession.
  ///
  /// In en, this message translates to:
  /// **'Bike Session'**
  String get bikeSession;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @adminManagement.
  ///
  /// In en, this message translates to:
  /// **'Admin management'**
  String get adminManagement;

  /// No description provided for @bikeManagement.
  ///
  /// In en, this message translates to:
  /// **'Bike management'**
  String get bikeManagement;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get scanQrCode;

  /// No description provided for @currentRide.
  ///
  /// In en, this message translates to:
  /// **'Current ride'**
  String get currentRide;

  /// No description provided for @rideInProgress.
  ///
  /// In en, this message translates to:
  /// **'Your ride is in progress.'**
  String get rideInProgress;

  /// No description provided for @stationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Dock capacity, nearby stations, and return points.'**
  String get stationsDescription;

  /// No description provided for @rideHistory.
  ///
  /// In en, this message translates to:
  /// **'Ride history'**
  String get rideHistory;

  /// No description provided for @rideHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Review past rides, fares, and return stations.'**
  String get rideHistoryDescription;

  /// No description provided for @rideDetails.
  ///
  /// In en, this message translates to:
  /// **'Ride details'**
  String get rideDetails;

  /// No description provided for @pastRides.
  ///
  /// In en, this message translates to:
  /// **'Past rides'**
  String get pastRides;

  /// No description provided for @totalRides.
  ///
  /// In en, this message translates to:
  /// **'Total rides'**
  String get totalRides;

  /// No description provided for @totalDistance.
  ///
  /// In en, this message translates to:
  /// **'Total distance'**
  String get totalDistance;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get totalSpent;

  /// No description provided for @rideHistoryEntrySemantics.
  ///
  /// In en, this message translates to:
  /// **'Ride on {date} at {time}, from {fromStation} to {toStation}, duration {duration}, distance {distance}, fare {fare}. Tap for details.'**
  String rideHistoryEntrySemantics(
    String date,
    String time,
    String fromStation,
    String toStation,
    String duration,
    String distance,
    String fare,
  );

  /// No description provided for @rideCompleted.
  ///
  /// In en, this message translates to:
  /// **'Ride completed'**
  String get rideCompleted;

  /// No description provided for @journeyDetails.
  ///
  /// In en, this message translates to:
  /// **'Journey details'**
  String get journeyDetails;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @departedAt.
  ///
  /// In en, this message translates to:
  /// **'Departed at {time}'**
  String departedAt(String time);

  /// No description provided for @arrivedAt.
  ///
  /// In en, this message translates to:
  /// **'Arrived at {time}'**
  String arrivedAt(String time);

  /// No description provided for @rideSummary.
  ///
  /// In en, this message translates to:
  /// **'Ride summary'**
  String get rideSummary;

  /// No description provided for @bikeId.
  ///
  /// In en, this message translates to:
  /// **'Bike ID'**
  String get bikeId;

  /// No description provided for @paymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment details'**
  String get paymentDetails;

  /// No description provided for @depositHeld.
  ///
  /// In en, this message translates to:
  /// **'Deposit held'**
  String get depositHeld;

  /// No description provided for @rideFareFromDeposit.
  ///
  /// In en, this message translates to:
  /// **'Ride fare paid from deposit'**
  String get rideFareFromDeposit;

  /// No description provided for @depositRefunded.
  ///
  /// In en, this message translates to:
  /// **'Remaining deposit refunded'**
  String get depositRefunded;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total paid'**
  String get totalPaid;

  /// No description provided for @depositRefund.
  ///
  /// In en, this message translates to:
  /// **'Deposit refund'**
  String get depositRefund;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @depositPaymentExplanation.
  ///
  /// In en, this message translates to:
  /// **'The ride fare was taken from the deposit. The remaining deposit was refunded to the same payment method.'**
  String get depositPaymentExplanation;

  /// No description provided for @profileDescription.
  ///
  /// In en, this message translates to:
  /// **'Profile, wallet, permissions, and ride history.'**
  String get profileDescription;

  /// No description provided for @fleetDescription.
  ///
  /// In en, this message translates to:
  /// **'Fleet health, battery status, and maintenance queue.'**
  String get fleetDescription;

  /// No description provided for @adminDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage stations, bikes, and users.'**
  String get adminDescription;

  /// No description provided for @stationManagement.
  ///
  /// In en, this message translates to:
  /// **'Station management'**
  String get stationManagement;

  /// No description provided for @stationManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Stations, dock capacity, and return points'**
  String get stationManagementDescription;

  /// No description provided for @bikeManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Fleet health, battery status, and maintenance'**
  String get bikeManagementDescription;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User management'**
  String get userManagement;

  /// No description provided for @userManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'User profile, wallet, permissions, and ride history'**
  String get userManagementDescription;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get appSettings;

  /// No description provided for @appSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage appearance and ride permissions.'**
  String get appSettingsDescription;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get darkTheme;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @locationAccess.
  ///
  /// In en, this message translates to:
  /// **'Location access'**
  String get locationAccess;

  /// No description provided for @locationAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'Required while a ride is active'**
  String get locationAccessDescription;

  /// No description provided for @rideNotifications.
  ///
  /// In en, this message translates to:
  /// **'Ride notifications'**
  String get rideNotifications;

  /// No description provided for @rideNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Return reminders and payment updates'**
  String get rideNotificationsDescription;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'GOOD AFTERNOON'**
  String get goodAfternoon;

  /// No description provided for @readyToRide.
  ///
  /// In en, this message translates to:
  /// **'Ready to ride?'**
  String get readyToRide;

  /// No description provided for @bikeAvailability.
  ///
  /// In en, this message translates to:
  /// **'{bikeCount} bikes available across {stationCount} stations.'**
  String bikeAvailability(int bikeCount, int stationCount);

  /// No description provided for @unlockRate.
  ///
  /// In en, this message translates to:
  /// **'{unlockFee} unlock fee + {minuteRate} per started minute'**
  String unlockRate(String unlockFee, String minuteRate);

  /// No description provided for @scanBike.
  ///
  /// In en, this message translates to:
  /// **'Scan bike'**
  String get scanBike;

  /// No description provided for @findStation.
  ///
  /// In en, this message translates to:
  /// **'Find station'**
  String get findStation;

  /// No description provided for @returnStationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No return station is available right now.'**
  String get returnStationUnavailable;

  /// No description provided for @liveNetwork.
  ///
  /// In en, this message translates to:
  /// **'Live network'**
  String get liveNetwork;

  /// No description provided for @bikes.
  ///
  /// In en, this message translates to:
  /// **'Bikes'**
  String get bikes;

  /// No description provided for @openDocks.
  ///
  /// In en, this message translates to:
  /// **'Open docks'**
  String get openDocks;

  /// No description provided for @nearYou.
  ///
  /// In en, this message translates to:
  /// **'Near you'**
  String get nearYou;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @stationDistance.
  ///
  /// In en, this message translates to:
  /// **'{distance} m away'**
  String stationDistance(int distance);

  /// No description provided for @bikeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bike} other{{count} bikes}}'**
  String bikeCount(int count);

  /// No description provided for @dockCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dock} other{{count} docks}}'**
  String dockCount(int count);

  /// No description provided for @docksAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dock available} other{{count} docks available}}'**
  String docksAvailable(int count);

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @libraryStation.
  ///
  /// In en, this message translates to:
  /// **'Library Station'**
  String get libraryStation;

  /// No description provided for @mainGate.
  ///
  /// In en, this message translates to:
  /// **'Main Gate'**
  String get mainGate;

  /// No description provided for @centralStation.
  ///
  /// In en, this message translates to:
  /// **'Central Station'**
  String get centralStation;

  /// No description provided for @riversidePark.
  ///
  /// In en, this message translates to:
  /// **'Riverside Park'**
  String get riversidePark;

  /// No description provided for @marketSquare.
  ///
  /// In en, this message translates to:
  /// **'Market Square'**
  String get marketSquare;

  /// No description provided for @universityGate.
  ///
  /// In en, this message translates to:
  /// **'University Gate'**
  String get universityGate;

  /// No description provided for @rideConditions.
  ///
  /// In en, this message translates to:
  /// **'Ride conditions'**
  String get rideConditions;

  /// No description provided for @currentWeather.
  ///
  /// In en, this message translates to:
  /// **'Current weather'**
  String get currentWeather;

  /// No description provided for @partlyCloudy.
  ///
  /// In en, this message translates to:
  /// **'Partly cloudy'**
  String get partlyCloudy;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels like {temperature}'**
  String feelsLike(String temperature);

  /// No description provided for @scatteredThunderstorms.
  ///
  /// In en, this message translates to:
  /// **'Scattered thunderstorms'**
  String get scatteredThunderstorms;

  /// No description provided for @rainChance.
  ///
  /// In en, this message translates to:
  /// **'{chance}% rain'**
  String rainChance(int chance);

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @airQuality.
  ///
  /// In en, this message translates to:
  /// **'Air quality'**
  String get airQuality;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @nextHour.
  ///
  /// In en, this message translates to:
  /// **'Next hour · {condition}'**
  String nextHour(String condition);

  /// No description provided for @weatherValues.
  ///
  /// In en, this message translates to:
  /// **'{temperature} · {rainChance}'**
  String weatherValues(String temperature, String rainChance);

  /// No description provided for @weatherUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {time} · {date}'**
  String weatherUpdated(String time, String date);

  /// No description provided for @rideConditionsSemantics.
  ///
  /// In en, this message translates to:
  /// **'Ride conditions. Current location, {location}. Current weather, {condition}, {temperature}, {feelsLike}. Next hour, {nextCondition}, {nextTemperature}, {rainChance}. Humidity {humidity}. Air quality index {airQualityIndex}, {airQualityLabel}. Wind {wind}.'**
  String rideConditionsSemantics(
    String location,
    String condition,
    String temperature,
    String feelsLike,
    String nextCondition,
    String nextTemperature,
    String rainChance,
    String humidity,
    String airQualityIndex,
    String airQualityLabel,
    String wind,
  );

  /// No description provided for @scanStep.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanStep;

  /// No description provided for @rideStep.
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get rideStep;

  /// No description provided for @returnStep.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnStep;

  /// No description provided for @payStep.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get payStep;

  /// No description provided for @stepSemantics.
  ///
  /// In en, this message translates to:
  /// **'{label} step'**
  String stepSemantics(String label);

  /// No description provided for @cameraPreviewSemantics.
  ///
  /// In en, this message translates to:
  /// **'Camera preview. Tap to scan the bike QR code.'**
  String get cameraPreviewSemantics;

  /// No description provided for @cameraReady.
  ///
  /// In en, this message translates to:
  /// **'Camera ready'**
  String get cameraReady;

  /// No description provided for @cameraNoPermission.
  ///
  /// In en, this message translates to:
  /// **'No Permission'**
  String get cameraNoPermission;

  /// No description provided for @cameraPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan the bike QR code. Tap below to allow access.'**
  String get cameraPermissionDescription;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @cameraPermissionSettingsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required. Enable camera in device settings.'**
  String get cameraPermissionSettingsPrompt;

  /// No description provided for @pointCamera.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the QR code on the bike frame'**
  String get pointCamera;

  /// No description provided for @scanInstructions.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code on the bike frame to start your session'**
  String get scanInstructions;

  /// No description provided for @bikeReady.
  ///
  /// In en, this message translates to:
  /// **'Bike ready'**
  String get bikeReady;

  /// No description provided for @bikeReadyDescription.
  ///
  /// In en, this message translates to:
  /// **'Check the bike and fare before placing the test hold.'**
  String get bikeReadyDescription;

  /// No description provided for @bikeBatteryLocation.
  ///
  /// In en, this message translates to:
  /// **'{battery}% battery · {location}'**
  String bikeBatteryLocation(int battery, String location);

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @brakesSafe.
  ///
  /// In en, this message translates to:
  /// **'Brakes and tyres look safe'**
  String get brakesSafe;

  /// No description provided for @frameSafe.
  ///
  /// In en, this message translates to:
  /// **'Seat and frame have no visible damage'**
  String get frameSafe;

  /// No description provided for @lightsSafe.
  ///
  /// In en, this message translates to:
  /// **'Front and rear lights are working'**
  String get lightsSafe;

  /// No description provided for @reportBikeIssue.
  ///
  /// In en, this message translates to:
  /// **'Report bike issue'**
  String get reportBikeIssue;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @reviewHold.
  ///
  /// In en, this message translates to:
  /// **'Review {amount} hold'**
  String reviewHold(String amount);

  /// No description provided for @cancelRental.
  ///
  /// In en, this message translates to:
  /// **'Cancel rental'**
  String get cancelRental;

  /// No description provided for @holdExplanation.
  ///
  /// In en, this message translates to:
  /// **'The hold is not a charge. Unused funds are released after return.'**
  String get holdExplanation;

  /// No description provided for @authorizeCardHold.
  ///
  /// In en, this message translates to:
  /// **'Authorize test hold'**
  String get authorizeCardHold;

  /// No description provided for @authorizeCardHoldDescription.
  ///
  /// In en, this message translates to:
  /// **'Simulate approval of the test payment before the bike unlocks.'**
  String get authorizeCardHoldDescription;

  /// No description provided for @temporaryAuthorizationHold.
  ///
  /// In en, this message translates to:
  /// **'Temporary authorization hold'**
  String get temporaryAuthorizationHold;

  /// No description provided for @authorizeHold.
  ///
  /// In en, this message translates to:
  /// **'Authorize {amount} hold'**
  String authorizeHold(String amount);

  /// No description provided for @unlockBikeTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock the bike'**
  String get unlockBikeTitle;

  /// No description provided for @unlockBikeDescription.
  ///
  /// In en, this message translates to:
  /// **'Stay beside {bikeId} while the rear lock opens.'**
  String unlockBikeDescription(String bikeId);

  /// No description provided for @contactingBikeLock.
  ///
  /// In en, this message translates to:
  /// **'Contacting bike lock…'**
  String get contactingBikeLock;

  /// No description provided for @cardHoldAuthorized.
  ///
  /// In en, this message translates to:
  /// **'Test hold authorized'**
  String get cardHoldAuthorized;

  /// No description provided for @unlockBike.
  ///
  /// In en, this message translates to:
  /// **'Unlock bike'**
  String get unlockBike;

  /// No description provided for @rideActive.
  ///
  /// In en, this message translates to:
  /// **'Ride active'**
  String get rideActive;

  /// No description provided for @rideActiveDescription.
  ///
  /// In en, this message translates to:
  /// **'GPS tracks your position along the city route.'**
  String get rideActiveDescription;

  /// No description provided for @gpsActive.
  ///
  /// In en, this message translates to:
  /// **'GPS active'**
  String get gpsActive;

  /// No description provided for @gpsLost.
  ///
  /// In en, this message translates to:
  /// **'GPS lost'**
  String get gpsLost;

  /// No description provided for @restoreGps.
  ///
  /// In en, this message translates to:
  /// **'Restore GPS'**
  String get restoreGps;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @estimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated'**
  String get estimated;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String distanceKm(String distance);

  /// No description provided for @returnBike.
  ///
  /// In en, this message translates to:
  /// **'Return Bike'**
  String get returnBike;

  /// No description provided for @nearestReturnStation.
  ///
  /// In en, this message translates to:
  /// **'Nearest return station'**
  String get nearestReturnStation;

  /// No description provided for @otherNearbyStations.
  ///
  /// In en, this message translates to:
  /// **'Other nearby stations'**
  String get otherNearbyStations;

  /// No description provided for @phoneSafety.
  ///
  /// In en, this message translates to:
  /// **'Stop safely before using the phone or choosing a station.'**
  String get phoneSafety;

  /// No description provided for @continueRide.
  ///
  /// In en, this message translates to:
  /// **'Continue ride'**
  String get continueRide;

  /// No description provided for @chooseReturnStation.
  ///
  /// In en, this message translates to:
  /// **'Choose return station'**
  String get chooseReturnStation;

  /// No description provided for @chooseReturnStationDescription.
  ///
  /// In en, this message translates to:
  /// **'A free dock is required to finish the ride.'**
  String get chooseReturnStationDescription;

  /// No description provided for @withinReturnZone.
  ///
  /// In en, this message translates to:
  /// **'Within return zone'**
  String get withinReturnZone;

  /// No description provided for @confirmArrival.
  ///
  /// In en, this message translates to:
  /// **'Confirm arrival'**
  String get confirmArrival;

  /// No description provided for @continueToDock.
  ///
  /// In en, this message translates to:
  /// **'Continue to dock'**
  String get continueToDock;

  /// No description provided for @scanStationQr.
  ///
  /// In en, this message translates to:
  /// **'Scan station QR'**
  String get scanStationQr;

  /// No description provided for @scanStationQrDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR poster at the station, or enter its code, to verify the return.'**
  String get scanStationQrDescription;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable. Enter the station code below instead.'**
  String get cameraUnavailable;

  /// No description provided for @stationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Station code'**
  String get stationCodeLabel;

  /// No description provided for @stationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. CENTRAL'**
  String get stationCodeHint;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @rideDeadlineCountdown.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min left to return the bike'**
  String rideDeadlineCountdown(int minutes);

  /// No description provided for @rideOverdueTitle.
  ///
  /// In en, this message translates to:
  /// **'Ride overdue'**
  String get rideOverdueTitle;

  /// No description provided for @rideOverdueBody.
  ///
  /// In en, this message translates to:
  /// **'You passed the maximum ride time. Return the bike now — if it is not returned in time, the rental is closed as lost and the account is suspended.'**
  String get rideOverdueBody;

  /// No description provided for @extendRide.
  ///
  /// In en, this message translates to:
  /// **'Extend +60 min ({count} left)'**
  String extendRide(int count);

  /// No description provided for @noExtensionsLeft.
  ///
  /// In en, this message translates to:
  /// **'No extensions left'**
  String get noExtensionsLeft;

  /// No description provided for @secureBike.
  ///
  /// In en, this message translates to:
  /// **'Secure the bike'**
  String get secureBike;

  /// No description provided for @secureBikeDescription.
  ///
  /// In en, this message translates to:
  /// **'Push the front wheel into an open dock until it locks.'**
  String get secureBikeDescription;

  /// No description provided for @confirmBikeDocked.
  ///
  /// In en, this message translates to:
  /// **'Confirm bike is docked'**
  String get confirmBikeDocked;

  /// No description provided for @rideComplete.
  ///
  /// In en, this message translates to:
  /// **'Ride complete'**
  String get rideComplete;

  /// No description provided for @rideCompleteDescription.
  ///
  /// In en, this message translates to:
  /// **'The bike is secured. Review the final charge.'**
  String get rideCompleteDescription;

  /// No description provided for @unlockFee.
  ///
  /// In en, this message translates to:
  /// **'Unlock fee'**
  String get unlockFee;

  /// No description provided for @startedMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 started minute} other{{count} started minutes}}'**
  String startedMinutes(int count);

  /// No description provided for @rideDuration.
  ///
  /// In en, this message translates to:
  /// **'Ride duration'**
  String get rideDuration;

  /// No description provided for @timeFare.
  ///
  /// In en, this message translates to:
  /// **'Time fare'**
  String get timeFare;

  /// No description provided for @hourCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String hourCount(int count);

  /// No description provided for @minuteCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String minuteCount(int count);

  /// No description provided for @finalFare.
  ///
  /// In en, this message translates to:
  /// **'Final fare'**
  String get finalFare;

  /// No description provided for @holdReleased.
  ///
  /// In en, this message translates to:
  /// **'Hold released'**
  String get holdReleased;

  /// No description provided for @chargeAmount.
  ///
  /// In en, this message translates to:
  /// **'Charge {amount}'**
  String chargeAmount(String amount);

  /// No description provided for @ridePaid.
  ///
  /// In en, this message translates to:
  /// **'Ride paid'**
  String get ridePaid;

  /// No description provided for @paymentPending.
  ///
  /// In en, this message translates to:
  /// **'Ride ended · Payment pending'**
  String get paymentPending;

  /// No description provided for @holdReleasedDescription.
  ///
  /// In en, this message translates to:
  /// **'The remaining test hold has been released.'**
  String get holdReleasedDescription;

  /// No description provided for @paymentPendingDescription.
  ///
  /// In en, this message translates to:
  /// **'The bike is returned safely. Retry the simulated charge below.'**
  String get paymentPendingDescription;

  /// No description provided for @rideId.
  ///
  /// In en, this message translates to:
  /// **'Ride ID'**
  String get rideId;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @returnedAt.
  ///
  /// In en, this message translates to:
  /// **'Returned at'**
  String get returnedAt;

  /// No description provided for @retryPayment.
  ///
  /// In en, this message translates to:
  /// **'Retry payment'**
  String get retryPayment;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @rentAnotherBike.
  ///
  /// In en, this message translates to:
  /// **'Rent another bike'**
  String get rentAnotherBike;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait…'**
  String get pleaseWait;

  /// No description provided for @timeBasedPricing.
  ///
  /// In en, this message translates to:
  /// **'Time-based pricing'**
  String get timeBasedPricing;

  /// No description provided for @pricingFormula.
  ///
  /// In en, this message translates to:
  /// **'{unlockFee} + (started minutes × {minuteRate})'**
  String pricingFormula(String unlockFee, String minuteRate);

  /// No description provided for @pricingExample.
  ///
  /// In en, this message translates to:
  /// **'{minutes}-minute example'**
  String pricingExample(int minutes);

  /// No description provided for @pricingTimerDescription.
  ///
  /// In en, this message translates to:
  /// **'The timer starts after the bike unlocks and stops when the dock confirms the return.'**
  String get pricingTimerDescription;

  /// No description provided for @choosePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose payment method'**
  String get choosePaymentMethod;

  /// No description provided for @personalCard.
  ///
  /// In en, this message translates to:
  /// **'Personal card'**
  String get personalCard;

  /// No description provided for @travelCard.
  ///
  /// In en, this message translates to:
  /// **'Travel card'**
  String get travelCard;

  /// No description provided for @addCardFuture.
  ///
  /// In en, this message translates to:
  /// **'Adding a new card belongs to the future User module.'**
  String get addCardFuture;

  /// No description provided for @paypalSandbox.
  ///
  /// In en, this message translates to:
  /// **'Test payment'**
  String get paypalSandbox;

  /// No description provided for @paypalSandboxDescription.
  ///
  /// In en, this message translates to:
  /// **'Local simulation · No real money'**
  String get paypalSandboxDescription;

  /// No description provided for @paypalAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PayPal Sandbox account'**
  String get paypalAccountSubtitle;

  /// No description provided for @paypalCheckoutTitle.
  ///
  /// In en, this message translates to:
  /// **'PayPal Payment'**
  String get paypalCheckoutTitle;

  /// No description provided for @paypalCheckoutSemantics.
  ///
  /// In en, this message translates to:
  /// **'Secure PayPal Payment approval page'**
  String get paypalCheckoutSemantics;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @selectable.
  ///
  /// In en, this message translates to:
  /// **'Selectable'**
  String get selectable;

  /// No description provided for @cityMapSemantics.
  ///
  /// In en, this message translates to:
  /// **'City map showing current bike position and return stations'**
  String get cityMapSemantics;

  /// No description provided for @errorInvalidQr.
  ///
  /// In en, this message translates to:
  /// **'This QR code is not a BikeRent bike. Scan the code on the bike frame.'**
  String get errorInvalidQr;

  /// No description provided for @errorBikeReserved.
  ///
  /// In en, this message translates to:
  /// **'Bike {bikeId} is already reserved. Choose another bike and scan again.'**
  String errorBikeReserved(String bikeId);

  /// No description provided for @errorBikeMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Bike {bikeId} is currently under maintenance and cannot be rented. Choose another bike and scan again.'**
  String errorBikeMaintenance(String bikeId);

  /// No description provided for @errorBikeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Bike {bikeId} is currently unavailable and cannot be rented. Choose another bike and scan again.'**
  String errorBikeUnavailable(String bikeId);

  /// No description provided for @errorBikeLowBattery.
  ///
  /// In en, this message translates to:
  /// **'Bike {bikeId} has low battery ({percent}%) and cannot be rented. Minimum required is 10%. Choose another bike and scan again.'**
  String errorBikeLowBattery(String bikeId, int percent);

  /// No description provided for @lowBatteryWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Low Battery Warning'**
  String get lowBatteryWarningTitle;

  /// No description provided for @lowBatteryWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Bike {bikeId} battery is at {percent}%. Riding distance and motor assist may be limited. Do you want to continue?'**
  String lowBatteryWarningMessage(String bikeId, int percent);

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @bikeCannotBeRentedTitle.
  ///
  /// In en, this message translates to:
  /// **'Bike Cannot Be Rented'**
  String get bikeCannotBeRentedTitle;

  /// No description provided for @errorHoldDeclined.
  ///
  /// In en, this message translates to:
  /// **'The {amount} test hold was declined. Retry when ready.'**
  String errorHoldDeclined(String amount);

  /// No description provided for @errorPaymentConfiguration.
  ///
  /// In en, this message translates to:
  /// **'The local test payment simulator is unavailable.'**
  String get errorPaymentConfiguration;

  /// No description provided for @errorPaymentNetwork.
  ///
  /// In en, this message translates to:
  /// **'The local test payment failed. Retry when ready.'**
  String get errorPaymentNetwork;

  /// No description provided for @errorPaymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Test payment approval was cancelled. Retry when ready.'**
  String get errorPaymentCancelled;

  /// No description provided for @errorPaymentAuthorizationFailed.
  ///
  /// In en, this message translates to:
  /// **'The test payment could not authorize the hold. Retry when ready.'**
  String get errorPaymentAuthorizationFailed;

  /// No description provided for @errorPaymentCaptureFailed.
  ///
  /// In en, this message translates to:
  /// **'The test payment could not capture the ride fare. The payment remains pending; retry below.'**
  String get errorPaymentCaptureFailed;

  /// No description provided for @errorLockFailed.
  ///
  /// In en, this message translates to:
  /// **'The lock did not respond. Stand near the bike and try again.'**
  String get errorLockFailed;

  /// No description provided for @errorGpsLost.
  ///
  /// In en, this message translates to:
  /// **'GPS signal lost. Move to an open area and check location access.'**
  String get errorGpsLost;

  /// No description provided for @errorStationFull.
  ///
  /// In en, this message translates to:
  /// **'{station} has no free docks. Choose another station.'**
  String errorStationFull(String station);

  /// No description provided for @errorChooseStation.
  ///
  /// In en, this message translates to:
  /// **'Choose a return station first.'**
  String get errorChooseStation;

  /// No description provided for @errorOutsideReturnZone.
  ///
  /// In en, this message translates to:
  /// **'Move within 250 m of the selected station before returning the bike.'**
  String get errorOutsideReturnZone;

  /// No description provided for @errorStationQrMismatch.
  ///
  /// In en, this message translates to:
  /// **'That QR does not match the selected station. Scan the QR poster at the station or enter its code.'**
  String get errorStationQrMismatch;

  /// No description provided for @errorMaxExtensionsReached.
  ///
  /// In en, this message translates to:
  /// **'No ride extensions left. Return the bike to finish the rental.'**
  String get errorMaxExtensionsReached;

  /// No description provided for @errorLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is needed to verify the return. Enable it and retry.'**
  String get errorLocationPermissionDenied;

  /// No description provided for @errorAccountSuspended.
  ///
  /// In en, this message translates to:
  /// **'Account suspended: a previous bike was not returned. Contact support to restore it.'**
  String get errorAccountSuspended;

  /// No description provided for @errorDockNotDetected.
  ///
  /// In en, this message translates to:
  /// **'Dock not detected. Push the bike firmly into the dock and retry.'**
  String get errorDockNotDetected;

  /// No description provided for @errorAuthenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Demo rider sign-in failed. Check Supabase and retry.'**
  String get errorAuthenticationFailed;

  /// No description provided for @errorBackendConnection.
  ///
  /// In en, this message translates to:
  /// **'The rent service is unavailable. Check the connection and retry.'**
  String get errorBackendConnection;

  /// No description provided for @errorActiveRentalExists.
  ///
  /// In en, this message translates to:
  /// **'This rider already has an unfinished rental. Resume or finish it first.'**
  String get errorActiveRentalExists;

  /// No description provided for @errorStationMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Station {station} is currently under maintenance. You cannot rent or return bikes here.'**
  String errorStationMaintenance(String station);

  /// No description provided for @errorStationTerminated.
  ///
  /// In en, this message translates to:
  /// **'Station {station} has been terminated. You cannot rent or return bikes here.'**
  String errorStationTerminated(String station);

  /// No description provided for @errorStationMaintenanceGeneral.
  ///
  /// In en, this message translates to:
  /// **'This station is currently under maintenance. You cannot rent or return bikes here.'**
  String get errorStationMaintenanceGeneral;

  /// No description provided for @errorStationTerminatedGeneral.
  ///
  /// In en, this message translates to:
  /// **'This station has been terminated. You cannot rent or return bikes here.'**
  String get errorStationTerminatedGeneral;

  /// No description provided for @stationUnderMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Under Maintenance'**
  String get stationUnderMaintenance;

  /// No description provided for @stationCannotReturnMaintenance.
  ///
  /// In en, this message translates to:
  /// **'This station is under maintenance. You cannot return bikes here.'**
  String get stationCannotReturnMaintenance;

  /// No description provided for @errorInvalidRentalTransition.
  ///
  /// In en, this message translates to:
  /// **'The rental state changed on the server. Retry to restore it.'**
  String get errorInvalidRentalTransition;

  /// No description provided for @rideWarningDepositExceededTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit Time Exceeded'**
  String get rideWarningDepositExceededTitle;

  /// No description provided for @rideWarningDepositExceededBody.
  ///
  /// In en, this message translates to:
  /// **'You have borrowed the bike longer than the deposit time. Additional rental charges apply.'**
  String get rideWarningDepositExceededBody;

  /// No description provided for @rideWarningLegalActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal Action Warning'**
  String get rideWarningLegalActionTitle;

  /// No description provided for @rideWarningLegalActionBody.
  ///
  /// In en, this message translates to:
  /// **'Rental duration exceeded 2x the deposit time. Immediate legal action will be initiated if the bike is not returned.'**
  String get rideWarningLegalActionBody;

  /// No description provided for @rideWarningSuspiciousActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Suspicious Activity Detected'**
  String get rideWarningSuspiciousActivityTitle;

  /// No description provided for @rideWarningSuspiciousActivityBody.
  ///
  /// In en, this message translates to:
  /// **'Suspicious activity detected: You are unusually far from the pickup station.'**
  String get rideWarningSuspiciousActivityBody;

  /// No description provided for @rideWarningSuspiciousLegalTitle.
  ///
  /// In en, this message translates to:
  /// **'Suspicious Activity & Legal Action'**
  String get rideWarningSuspiciousLegalTitle;

  /// No description provided for @rideWarningSuspiciousLegalBody.
  ///
  /// In en, this message translates to:
  /// **'Suspicious activity detected far from station and deposit time exceeded. Immediate legal action will be taken if the bike is not returned.'**
  String get rideWarningSuspiciousLegalBody;

  /// No description provided for @addBike.
  ///
  /// In en, this message translates to:
  /// **'Add Bike'**
  String get addBike;

  /// No description provided for @editBike.
  ///
  /// In en, this message translates to:
  /// **'Edit Bike'**
  String get editBike;

  /// No description provided for @bikeDetail.
  ///
  /// In en, this message translates to:
  /// **'Bike Detail'**
  String get bikeDetail;

  /// No description provided for @bikeReport.
  ///
  /// In en, this message translates to:
  /// **'Bike Report'**
  String get bikeReport;

  /// No description provided for @transferBike.
  ///
  /// In en, this message translates to:
  /// **'Transfer Bike'**
  String get transferBike;

  /// No description provided for @serviceBike.
  ///
  /// In en, this message translates to:
  /// **'Service Bike'**
  String get serviceBike;

  /// No description provided for @reportDetail.
  ///
  /// In en, this message translates to:
  /// **'Report Detail'**
  String get reportDetail;

  /// No description provided for @pendingReports.
  ///
  /// In en, this message translates to:
  /// **'Pending Reports'**
  String get pendingReports;

  /// No description provided for @newReport.
  ///
  /// In en, this message translates to:
  /// **'New Report'**
  String get newReport;

  /// No description provided for @pendingReportDetails.
  ///
  /// In en, this message translates to:
  /// **'Pending Report Details'**
  String get pendingReportDetails;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @conditionReports.
  ///
  /// In en, this message translates to:
  /// **'Condition reports'**
  String get conditionReports;

  /// No description provided for @reviewAndResolveBikeIssues.
  ///
  /// In en, this message translates to:
  /// **'Review and resolve bike issues.'**
  String get reviewAndResolveBikeIssues;

  /// No description provided for @trackSubmittedBikeReports.
  ///
  /// In en, this message translates to:
  /// **'Track your submitted bike reports.'**
  String get trackSubmittedBikeReports;

  /// No description provided for @searchReportOrBikeId.
  ///
  /// In en, this message translates to:
  /// **'Search report or bike ID'**
  String get searchReportOrBikeId;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get newestFirst;

  /// No description provided for @cancelReport.
  ///
  /// In en, this message translates to:
  /// **'Cancel Report'**
  String get cancelReport;

  /// No description provided for @cancelReportQuestion.
  ///
  /// In en, this message translates to:
  /// **'Cancel Report?'**
  String get cancelReportQuestion;

  /// No description provided for @keepReport.
  ///
  /// In en, this message translates to:
  /// **'Keep Report'**
  String get keepReport;

  /// No description provided for @cancelReportConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Cancel {reportId}? This report will no longer be reviewed by an administrator.'**
  String cancelReportConfirmation(String reportId);

  /// No description provided for @reportCancelled.
  ///
  /// In en, this message translates to:
  /// **'{reportId} cancelled.'**
  String reportCancelled(String reportId);

  /// No description provided for @failedToCancelReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel report: {error}'**
  String failedToCancelReport(String error);

  /// No description provided for @onlyPendingReportsCanBeCancelled.
  ///
  /// In en, this message translates to:
  /// **'Only pending reports can be cancelled.'**
  String get onlyPendingReportsCanBeCancelled;

  /// No description provided for @allReports.
  ///
  /// In en, this message translates to:
  /// **'All {count}'**
  String allReports(int count);

  /// No description provided for @pendingReportsCount.
  ///
  /// In en, this message translates to:
  /// **'Pending {count}'**
  String pendingReportsCount(int count);

  /// No description provided for @approvedReportsCount.
  ///
  /// In en, this message translates to:
  /// **'Approved {count}'**
  String approvedReportsCount(int count);

  /// No description provided for @rejectedReportsCount.
  ///
  /// In en, this message translates to:
  /// **'Rejected {count}'**
  String rejectedReportsCount(int count);

  /// No description provided for @cancelledReportsCount.
  ///
  /// In en, this message translates to:
  /// **'Cancelled {count}'**
  String cancelledReportsCount(int count);

  /// No description provided for @noMatchingReports.
  ///
  /// In en, this message translates to:
  /// **'No matching reports'**
  String get noMatchingReports;

  /// No description provided for @noReportsYet.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get noReportsYet;

  /// No description provided for @tryDifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term.'**
  String get tryDifferentSearchTerm;

  /// No description provided for @bikeConditionReportsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Bike condition reports will appear here.'**
  String get bikeConditionReportsAppearHere;

  /// No description provided for @reported.
  ///
  /// In en, this message translates to:
  /// **'Reported'**
  String get reported;

  /// No description provided for @unableToLoadReports.
  ///
  /// In en, this message translates to:
  /// **'Unable to load reports'**
  String get unableToLoadReports;

  /// No description provided for @brakeSystem.
  ///
  /// In en, this message translates to:
  /// **'Brake System'**
  String get brakeSystem;

  /// No description provided for @tyres.
  ///
  /// In en, this message translates to:
  /// **'Tyres'**
  String get tyres;

  /// No description provided for @chainAndGears.
  ///
  /// In en, this message translates to:
  /// **'Chain & Gears'**
  String get chainAndGears;

  /// No description provided for @seatAndFrame.
  ///
  /// In en, this message translates to:
  /// **'Seat & Frame'**
  String get seatAndFrame;

  /// No description provided for @bellAndLights.
  ///
  /// In en, this message translates to:
  /// **'Bell & Lights'**
  String get bellAndLights;

  /// No description provided for @qrLock.
  ///
  /// In en, this message translates to:
  /// **'QR / Lock'**
  String get qrLock;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @unableToLoadReport.
  ///
  /// In en, this message translates to:
  /// **'Unable to load report'**
  String get unableToLoadReport;

  /// No description provided for @reportNotFound.
  ///
  /// In en, this message translates to:
  /// **'Report not found'**
  String get reportNotFound;

  /// No description provided for @reportDetails.
  ///
  /// In en, this message translates to:
  /// **'Report details'**
  String get reportDetails;

  /// No description provided for @noStationAssigned.
  ///
  /// In en, this message translates to:
  /// **'No station assigned'**
  String get noStationAssigned;

  /// No description provided for @reportInformation.
  ///
  /// In en, this message translates to:
  /// **'Report information'**
  String get reportInformation;

  /// No description provided for @problem.
  ///
  /// In en, this message translates to:
  /// **'Problem'**
  String get problem;

  /// No description provided for @reportIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Report ID'**
  String get reportIdLabel;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @photoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Photo unavailable'**
  String get photoUnavailable;

  /// No description provided for @photoCouldNotBeLoaded.
  ///
  /// In en, this message translates to:
  /// **'The report photo could not be loaded.'**
  String get photoCouldNotBeLoaded;

  /// No description provided for @unableToDisplayPhoto.
  ///
  /// In en, this message translates to:
  /// **'Unable to display photo'**
  String get unableToDisplayPhoto;

  /// No description provided for @attachedPhotoCouldNotBeDisplayed.
  ///
  /// In en, this message translates to:
  /// **'The attached photo could not be displayed.'**
  String get attachedPhotoCouldNotBeDisplayed;

  /// No description provided for @noPhotoAttached.
  ///
  /// In en, this message translates to:
  /// **'No photo attached'**
  String get noPhotoAttached;

  /// No description provided for @reportWithoutPhoto.
  ///
  /// In en, this message translates to:
  /// **'This report was submitted without a photo.'**
  String get reportWithoutPhoto;

  /// No description provided for @issueDescription.
  ///
  /// In en, this message translates to:
  /// **'Issue description'**
  String get issueDescription;

  /// No description provided for @pendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get pendingReview;

  /// No description provided for @pendingReviewDescription.
  ///
  /// In en, this message translates to:
  /// **'This report has not been reviewed yet.'**
  String get pendingReviewDescription;

  /// No description provided for @reportApproved.
  ///
  /// In en, this message translates to:
  /// **'Report approved'**
  String get reportApproved;

  /// No description provided for @reportRejected.
  ///
  /// In en, this message translates to:
  /// **'Report rejected'**
  String get reportRejected;

  /// No description provided for @reviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get reviewed;

  /// No description provided for @reviewNote.
  ///
  /// In en, this message translates to:
  /// **'Review note'**
  String get reviewNote;

  /// No description provided for @noReviewNoteProvided.
  ///
  /// In en, this message translates to:
  /// **'No review note provided.'**
  String get noReviewNoteProvided;

  /// No description provided for @reportCancelledStatus.
  ///
  /// In en, this message translates to:
  /// **'Report cancelled'**
  String get reportCancelledStatus;

  /// No description provided for @reportCancelledDescription.
  ///
  /// In en, this message translates to:
  /// **'You cancelled this report before it was reviewed.'**
  String get reportCancelledDescription;

  /// No description provided for @addNewBike.
  ///
  /// In en, this message translates to:
  /// **'Add new bike'**
  String get addNewBike;

  /// No description provided for @step1BasicInformation.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 3 • Basic information'**
  String get step1BasicInformation;

  /// No description provided for @step2QrCode.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 3 • QR code'**
  String get step2QrCode;

  /// No description provided for @step3ReviewInformation.
  ///
  /// In en, this message translates to:
  /// **'Step 3 of 3 • Review information'**
  String get step3ReviewInformation;

  /// No description provided for @bikeCode.
  ///
  /// In en, this message translates to:
  /// **'Bike Code'**
  String get bikeCode;

  /// No description provided for @enterBikeCode.
  ///
  /// In en, this message translates to:
  /// **'Enter bike code'**
  String get enterBikeCode;

  /// No description provided for @bikeCodeTooShort.
  ///
  /// In en, this message translates to:
  /// **'Bike code is too short'**
  String get bikeCodeTooShort;

  /// No description provided for @initialStation.
  ///
  /// In en, this message translates to:
  /// **'Initial station'**
  String get initialStation;

  /// No description provided for @pleaseSelectStation.
  ///
  /// In en, this message translates to:
  /// **'Please select a station'**
  String get pleaseSelectStation;

  /// No description provided for @selectStation.
  ///
  /// In en, this message translates to:
  /// **'Select a station'**
  String get selectStation;

  /// No description provided for @unableToLoadStations.
  ///
  /// In en, this message translates to:
  /// **'Unable to load stations'**
  String get unableToLoadStations;

  /// No description provided for @noStationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No stations are available.'**
  String get noStationsAvailable;

  /// No description provided for @noStationSelected.
  ///
  /// In en, this message translates to:
  /// **'No station selected'**
  String get noStationSelected;

  /// No description provided for @batteryPercentage.
  ///
  /// In en, this message translates to:
  /// **'Battery percentage'**
  String get batteryPercentage;

  /// No description provided for @enterBatteryPercentage.
  ///
  /// In en, this message translates to:
  /// **'Enter battery percentage'**
  String get enterBatteryPercentage;

  /// No description provided for @invalidBatteryPercentage.
  ///
  /// In en, this message translates to:
  /// **'Invalid battery percentage'**
  String get invalidBatteryPercentage;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @batteryRangeError.
  ///
  /// In en, this message translates to:
  /// **'Battery must be between 0 and 100'**
  String get batteryRangeError;

  /// No description provided for @battery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get battery;

  /// No description provided for @initialStatus.
  ///
  /// In en, this message translates to:
  /// **'Initial status'**
  String get initialStatus;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// No description provided for @retired.
  ///
  /// In en, this message translates to:
  /// **'Retired'**
  String get retired;

  /// No description provided for @qrGeneratedAutomatically.
  ///
  /// In en, this message translates to:
  /// **'A unique QR token will be generated automatically.'**
  String get qrGeneratedAutomatically;

  /// No description provided for @qrScanningDescription.
  ///
  /// In en, this message translates to:
  /// **'The QR code can later contain this token for bike scanning.'**
  String get qrScanningDescription;

  /// No description provided for @bikeQrCode.
  ///
  /// In en, this message translates to:
  /// **'Bike QR Code'**
  String get bikeQrCode;

  /// No description provided for @qrTokenIdentifiesBike.
  ///
  /// In en, this message translates to:
  /// **'The following token will identify this bike when scanned.'**
  String get qrTokenIdentifiesBike;

  /// No description provided for @qrToken.
  ///
  /// In en, this message translates to:
  /// **'QR Token'**
  String get qrToken;

  /// No description provided for @qrTokenNotGenerated.
  ///
  /// In en, this message translates to:
  /// **'QR token has not been generated'**
  String get qrTokenNotGenerated;

  /// No description provided for @notGenerated.
  ///
  /// In en, this message translates to:
  /// **'Not generated'**
  String get notGenerated;

  /// No description provided for @qrPlaceholderDescription.
  ///
  /// In en, this message translates to:
  /// **'The visual QR image is currently a placeholder. Later we can generate an actual QR code from this token.'**
  String get qrPlaceholderDescription;

  /// No description provided for @generatedQrCode.
  ///
  /// In en, this message translates to:
  /// **'Generated QR Code'**
  String get generatedQrCode;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @bikeInformation.
  ///
  /// In en, this message translates to:
  /// **'Bike information'**
  String get bikeInformation;

  /// No description provided for @notSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get notSelected;

  /// No description provided for @bikeAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Bike added successfully'**
  String get bikeAddedSuccessfully;

  /// No description provided for @failedToAddBike.
  ///
  /// In en, this message translates to:
  /// **'Failed to add bike: {error}'**
  String failedToAddBike(String error);

  /// No description provided for @managePaymentMethodsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage credit/debit cards and PayPal'**
  String get managePaymentMethodsSubtitle;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @termsOfServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rental rules, safety policies, and liabilities'**
  String get termsOfServiceSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Data protection, GPS location, and privacy rights'**
  String get privacyPolicySubtitle;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @onlineCheckout.
  ///
  /// In en, this message translates to:
  /// **'ONLINE CHECKOUT'**
  String get onlineCheckout;

  /// No description provided for @savedCards.
  ///
  /// In en, this message translates to:
  /// **'SAVED CARDS'**
  String get savedCards;

  /// No description provided for @savedCardsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} saved'**
  String savedCardsCount(int count);

  /// No description provided for @noCardsSaved.
  ///
  /// In en, this message translates to:
  /// **'No cards saved yet'**
  String get noCardsSaved;

  /// No description provided for @noCardsSavedDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a Visa or Mastercard for quick, seamless one-tap bike rentals.'**
  String get noCardsSavedDescription;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// No description provided for @removeCard.
  ///
  /// In en, this message translates to:
  /// **'Remove Card'**
  String get removeCard;

  /// No description provided for @removeCardConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove your {brand} ending in {lastFour}?'**
  String removeCardConfirmation(String brand, String lastFour);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @cardRemovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card removed successfully'**
  String get cardRemovedSuccess;

  /// No description provided for @failedToRemoveCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove card'**
  String get failedToRemoveCard;

  /// No description provided for @cardSetAsDefault.
  ///
  /// In en, this message translates to:
  /// **'{brand} set as default payment method'**
  String cardSetAsDefault(String brand);

  /// No description provided for @failedToUpdateDefaultCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to update default card'**
  String get failedToUpdateDefaultCard;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit Card'**
  String get editCard;

  /// No description provided for @cardUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card updated successfully'**
  String get cardUpdatedSuccess;

  /// No description provided for @failedToUpdateCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to update card'**
  String get failedToUpdateCard;

  /// No description provided for @cardAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card added successfully'**
  String get cardAddedSuccess;

  /// No description provided for @failedToAddCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to add card'**
  String get failedToAddCard;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @cardNumberHint.
  ///
  /// In en, this message translates to:
  /// **'4xxx xxxx xxxx xxxx'**
  String get cardNumberHint;

  /// No description provided for @cardholderName.
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get cardholderName;

  /// No description provided for @cardholderNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. John Doe'**
  String get cardholderNameHint;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @expiryDateHint.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get expiryDateHint;

  /// No description provided for @cvvCvc.
  ///
  /// In en, this message translates to:
  /// **'CVV / CVC'**
  String get cvvCvc;

  /// No description provided for @cvvHint.
  ///
  /// In en, this message translates to:
  /// **'•••'**
  String get cvvHint;

  /// No description provided for @setAsDefaultPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Set as default payment method'**
  String get setAsDefaultPaymentMethod;

  /// No description provided for @automaticallyUseCard.
  ///
  /// In en, this message translates to:
  /// **'Automatically use this card for bike rentals'**
  String get automaticallyUseCard;

  /// No description provided for @updateCard.
  ///
  /// In en, this message translates to:
  /// **'Update Card'**
  String get updateCard;

  /// No description provided for @cardExpiry.
  ///
  /// In en, this message translates to:
  /// **'Exp {month}/{year}'**
  String cardExpiry(String month, String year);

  /// No description provided for @activeCard.
  ///
  /// In en, this message translates to:
  /// **'Active Card'**
  String get activeCard;

  /// No description provided for @defaultBadge.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT'**
  String get defaultBadge;

  /// No description provided for @cardOptions.
  ///
  /// In en, this message translates to:
  /// **'Card options'**
  String get cardOptions;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get setAsDefault;

  /// No description provided for @editCardMenu.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get editCardMenu;

  /// No description provided for @removeCardMenu.
  ///
  /// In en, this message translates to:
  /// **'Remove card'**
  String get removeCardMenu;

  /// No description provided for @payPal.
  ///
  /// In en, this message translates to:
  /// **'PayPal'**
  String get payPal;

  /// No description provided for @payPalBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get payPalBuiltIn;

  /// No description provided for @payPalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Webview checkout · Always available'**
  String get payPalSubtitle;

  /// No description provided for @payPalInformation.
  ///
  /// In en, this message translates to:
  /// **'PayPal information'**
  String get payPalInformation;

  /// No description provided for @payPalIntegration.
  ///
  /// In en, this message translates to:
  /// **'PayPal Integration'**
  String get payPalIntegration;

  /// No description provided for @payPalAlwaysAvailable.
  ///
  /// In en, this message translates to:
  /// **'Always available payment option'**
  String get payPalAlwaysAvailable;

  /// No description provided for @payPalDescription.
  ///
  /// In en, this message translates to:
  /// **'PayPal checkout is processed on-demand through a secure in-app webview during bike rental authorization. It does not require storing credit or debit card details, so it cannot be edited or removed.'**
  String get payPalDescription;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @cardholderPreview.
  ///
  /// In en, this message translates to:
  /// **'CARDHOLDER'**
  String get cardholderPreview;

  /// No description provided for @cardholderNamePreview.
  ///
  /// In en, this message translates to:
  /// **'CARDHOLDER NAME'**
  String get cardholderNamePreview;

  /// No description provided for @expiresPreview.
  ///
  /// In en, this message translates to:
  /// **'EXPIRES'**
  String get expiresPreview;

  /// No description provided for @agree.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get agree;

  /// No description provided for @agreementConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Agreement Confirmation'**
  String get agreementConfirmation;

  /// No description provided for @agreementNotice.
  ///
  /// In en, this message translates to:
  /// **'By tapping \"{buttonText}\" above or below, you acknowledge that you have reviewed and accept these {title}.'**
  String agreementNotice(String buttonText, String title);

  /// No description provided for @agreeAndContinue.
  ///
  /// In en, this message translates to:
  /// **'{buttonText} & Continue'**
  String agreeAndContinue(String buttonText);

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Questions? Contact support@bikerent.app'**
  String get contactSupport;

  /// Error message when stations fail to fetch from database
  ///
  /// In en, this message translates to:
  /// **'Error loading stations: {error}'**
  String errorLoadingStations(String error);

  /// No description provided for @stationA.
  ///
  /// In en, this message translates to:
  /// **'Station A'**
  String get stationA;

  /// No description provided for @stationB.
  ///
  /// In en, this message translates to:
  /// **'Station B'**
  String get stationB;

  /// No description provided for @selectOriginStation.
  ///
  /// In en, this message translates to:
  /// **'Select origin station'**
  String get selectOriginStation;

  /// No description provided for @selectDestinationStation.
  ///
  /// In en, this message translates to:
  /// **'Select destination station'**
  String get selectDestinationStation;

  /// No description provided for @underMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Under Maintenance'**
  String get underMaintenance;

  /// No description provided for @selectedStationTooFar.
  ///
  /// In en, this message translates to:
  /// **'Selected Station are too far away'**
  String get selectedStationTooFar;

  /// No description provided for @etaLabel.
  ///
  /// In en, this message translates to:
  /// **'ETA:'**
  String get etaLabel;

  /// No description provided for @estimatedArrivalTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated Arrival Time (ETA)'**
  String get estimatedArrivalTime;

  /// Duration display in minutes for route calculation
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String durationInMinutes(int minutes);

  /// Calculated route distance in kilometers
  ///
  /// In en, this message translates to:
  /// **'Total Distance: {distance} km'**
  String totalDistanceKm(String distance);

  /// No description provided for @selectStationsToCalculateRoutePrompt.
  ///
  /// In en, this message translates to:
  /// **'Select Station A & Station B to calculate route.'**
  String get selectStationsToCalculateRoutePrompt;

  /// Error message when fetching station bikes fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load bikes: {error}'**
  String failedToLoadBikes(String error);

  /// No description provided for @invalidBikeIdError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open: Invalid Bike ID'**
  String get invalidBikeIdError;

  /// No description provided for @stationBikes.
  ///
  /// In en, this message translates to:
  /// **'Station Bikes'**
  String get stationBikes;

  /// No description provided for @locationCoordinatesNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Location coordinates not provided'**
  String get locationCoordinatesNotProvided;

  /// No description provided for @searchBikesCodeOrId.
  ///
  /// In en, this message translates to:
  /// **'Search bikes by code or ID'**
  String get searchBikesCodeOrId;

  /// No description provided for @noBikesInStationYet.
  ///
  /// In en, this message translates to:
  /// **'there is no bikes in this station yet'**
  String get noBikesInStationYet;

  /// No description provided for @noBikesMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No bikes match your search.'**
  String get noBikesMatchSearch;

  /// No description provided for @unknownStatus.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownStatus;

  /// Label indicating the operational status of a bike
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String bikeStatus(String status);

  /// Error message shown in SnackBar when station fetching fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load stations: {error}'**
  String failedToLoadStations(String error);

  /// No description provided for @searchStationHint.
  ///
  /// In en, this message translates to:
  /// **'Search station code, name or address...'**
  String get searchStationHint;

  /// No description provided for @longPressMapToAddStation.
  ///
  /// In en, this message translates to:
  /// **'Long-press map to add new station'**
  String get longPressMapToAddStation;

  /// No description provided for @noMatchingStationsFound.
  ///
  /// In en, this message translates to:
  /// **'No matching stations found.'**
  String get noMatchingStationsFound;

  /// No description provided for @unnamedStation.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Station'**
  String get unnamedStation;

  /// No description provided for @noAddress.
  ///
  /// In en, this message translates to:
  /// **'No address'**
  String get noAddress;

  /// No description provided for @stationNameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Station name cannot be empty.'**
  String get stationNameEmptyError;

  /// No description provided for @stationAddressEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Station address cannot be empty.'**
  String get stationAddressEmptyError;

  /// No description provided for @validCapacityError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number for max capacity.'**
  String get validCapacityError;

  /// Error message shown when the entered capacity is lower than current bikes
  ///
  /// In en, this message translates to:
  /// **'Max capacity ({capacity}) cannot be less than current docked bikes ({bikes}).'**
  String maxCapacityExceededError(int capacity, int bikes);

  /// No description provided for @stationUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Station updated successfully!'**
  String get stationUpdatedSuccess;

  /// No description provided for @stationAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Station added successfully!'**
  String get stationAddedSuccess;

  /// Error notification when saving station fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save station: {error}'**
  String failedToSaveStation(String error);

  /// No description provided for @removeStation.
  ///
  /// In en, this message translates to:
  /// **'Remove Station'**
  String get removeStation;

  /// No description provided for @confirmRemoveStationBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this station?'**
  String get confirmRemoveStationBody;

  /// No description provided for @stationRemovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Station removed successfully!'**
  String get stationRemovedSuccess;

  /// Error notification when deleting a station fails
  ///
  /// In en, this message translates to:
  /// **'Failed to remove station: {error}'**
  String failedToRemoveStation(String error);

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @stationName.
  ///
  /// In en, this message translates to:
  /// **'Station Name'**
  String get stationName;

  /// No description provided for @enterStationNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter station name...'**
  String get enterStationNameHint;

  /// No description provided for @stationCode.
  ///
  /// In en, this message translates to:
  /// **'Station Code'**
  String get stationCode;

  /// No description provided for @readOnly.
  ///
  /// In en, this message translates to:
  /// **'Read-Only'**
  String get readOnly;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @enterStationAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter station address...'**
  String get enterStationAddressHint;

  /// No description provided for @operatingStatus.
  ///
  /// In en, this message translates to:
  /// **'Operating status'**
  String get operatingStatus;

  /// No description provided for @currentDockedBikes.
  ///
  /// In en, this message translates to:
  /// **'Current Docked Bikes'**
  String get currentDockedBikes;

  /// No description provided for @maxBikesPerStation.
  ///
  /// In en, this message translates to:
  /// **'Max bike per station'**
  String get maxBikesPerStation;

  /// No description provided for @addStation.
  ///
  /// In en, this message translates to:
  /// **'Add Station'**
  String get addStation;

  /// No description provided for @updateStation.
  ///
  /// In en, this message translates to:
  /// **'Update Station'**
  String get updateStation;

  /// No description provided for @viewBikesAtStation.
  ///
  /// In en, this message translates to:
  /// **'View Bikes at Station'**
  String get viewBikesAtStation;

  /// No description provided for @noAddressSet.
  ///
  /// In en, this message translates to:
  /// **'No address set'**
  String get noAddressSet;

  /// No description provided for @noBikesAtStation.
  ///
  /// In en, this message translates to:
  /// **'No bikes at this station.'**
  String get noBikesAtStation;

  /// Notification when a station is successfully deactivated by an admin
  ///
  /// In en, this message translates to:
  /// **'{stationName} deactivated successfully'**
  String stationDeactivatedSuccess(String stationName);

  /// No description provided for @searchStationToRemove.
  ///
  /// In en, this message translates to:
  /// **'Search station to remove...'**
  String get searchStationToRemove;

  /// No description provided for @searchStationNameOrAddress.
  ///
  /// In en, this message translates to:
  /// **'Search station name or address...'**
  String get searchStationNameOrAddress;

  /// No description provided for @noStationsFound.
  ///
  /// In en, this message translates to:
  /// **'No stations found.'**
  String get noStationsFound;

  /// Pluralized count of available bikes
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bike} other{{count} bikes}}'**
  String bikesCount(int count);

  /// No description provided for @currentlySelected.
  ///
  /// In en, this message translates to:
  /// **'Currently Selected'**
  String get currentlySelected;

  /// No description provided for @targetStationToRemove.
  ///
  /// In en, this message translates to:
  /// **'Target Station to Remove'**
  String get targetStationToRemove;

  /// No description provided for @closestToYou.
  ///
  /// In en, this message translates to:
  /// **'Closest to you'**
  String get closestToYou;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @allActiveStations.
  ///
  /// In en, this message translates to:
  /// **'All Active Stations'**
  String get allActiveStations;

  /// No description provided for @nearbyStations.
  ///
  /// In en, this message translates to:
  /// **'Nearby Stations'**
  String get nearbyStations;

  /// Subtitle format for featured station displaying address, bike count, and optional distance
  ///
  /// In en, this message translates to:
  /// **'{address} • {count} Bikes{distance}'**
  String stationSummarySubtitle(String address, int count, String distance);

  /// Title prompt for admin station removal confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure to remove\n{stationName}?'**
  String confirmRemoveStationTitle(String stationName);

  /// No description provided for @actionIrreversibleWarning.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible, are you sure to continue?'**
  String get actionIrreversibleWarning;

  /// No description provided for @removeLocation.
  ///
  /// In en, this message translates to:
  /// **'Remove Location'**
  String get removeLocation;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @scanningLabel.
  ///
  /// In en, this message translates to:
  /// **'Scanning…'**
  String get scanningLabel;

  /// No description provided for @flashlightTooltip.
  ///
  /// In en, this message translates to:
  /// **'Flashlight'**
  String get flashlightTooltip;

  /// No description provided for @invalidQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR Code'**
  String get invalidQrTitle;

  /// No description provided for @reservationExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Reservation expires in {time}'**
  String reservationExpiresIn(String time);

  /// No description provided for @rentalTimedOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Rental Timed Out'**
  String get rentalTimedOutTitle;

  /// No description provided for @rentalTimedOutBody.
  ///
  /// In en, this message translates to:
  /// **'Your bike reservation timed out after the {minutes}-minute limit. The bike has been released.'**
  String rentalTimedOutBody(int minutes);

  /// No description provided for @forceEndedTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Ended by Admin'**
  String get forceEndedTitle;

  /// No description provided for @rentalEndedTitle.
  ///
  /// In en, this message translates to:
  /// **'Rental Ended'**
  String get rentalEndedTitle;

  /// No description provided for @rentalEndedBody.
  ///
  /// In en, this message translates to:
  /// **'Your rental session has ended. Start a new ride whenever you\'re ready.'**
  String get rentalEndedBody;

  /// No description provided for @returnAtStation.
  ///
  /// In en, this message translates to:
  /// **'Return at {station}'**
  String returnAtStation(String station);

  /// No description provided for @originStation.
  ///
  /// In en, this message translates to:
  /// **'Origin Station'**
  String get originStation;

  /// No description provided for @tripStartedHere.
  ///
  /// In en, this message translates to:
  /// **'Trip started here'**
  String get tripStartedHere;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @yourGpsPosition.
  ///
  /// In en, this message translates to:
  /// **'Your GPS position'**
  String get yourGpsPosition;

  /// No description provided for @stationDetailsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Station details'**
  String get stationDetailsTooltip;

  /// No description provided for @addPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Add Payment Method'**
  String get addPaymentMethod;

  /// No description provided for @lowBatteryFallbackBike.
  ///
  /// In en, this message translates to:
  /// **'this bike'**
  String get lowBatteryFallbackBike;

  /// No description provided for @errorStationFullGeneral.
  ///
  /// In en, this message translates to:
  /// **'Nearby stations have no free docks right now. Please try again shortly.'**
  String get errorStationFullGeneral;

  /// No description provided for @termsNoticePrefix.
  ///
  /// In en, this message translates to:
  /// **'By proceeding with the renting process, you are considered to accept and clear the '**
  String get termsNoticePrefix;

  /// No description provided for @termsNoticeMiddle.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get termsNoticeMiddle;

  /// No description provided for @termsNoticeSuffix.
  ///
  /// In en, this message translates to:
  /// **' of the app.'**
  String get termsNoticeSuffix;

  /// No description provided for @rideHistoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Ride history could not be loaded.'**
  String get rideHistoryLoadFailed;

  /// No description provided for @noCompletedRides.
  ///
  /// In en, this message translates to:
  /// **'No completed rides yet.'**
  String get noCompletedRides;

  /// No description provided for @weatherConnectionFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get weatherConnectionFailedTitle;

  /// No description provided for @weatherConnectionFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the weather service. Please check your internet connection and try again.'**
  String get weatherConnectionFailedBody;

  /// No description provided for @weatherTimeoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out'**
  String get weatherTimeoutTitle;

  /// No description provided for @weatherTimeoutBody.
  ///
  /// In en, this message translates to:
  /// **'The weather service took too long to respond. Please check your connection and try again.'**
  String get weatherTimeoutBody;

  /// No description provided for @weatherRateLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate limit reached'**
  String get weatherRateLimitTitle;

  /// No description provided for @weatherRateLimitBody.
  ///
  /// In en, this message translates to:
  /// **'The weather service is temporarily busy. Please wait a moment and try again.'**
  String get weatherRateLimitBody;

  /// No description provided for @weatherLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get weatherLocationTitle;

  /// No description provided for @weatherLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Location access is required to show current weather. Please enable GPS and grant permission.'**
  String get weatherLocationBody;

  /// No description provided for @weatherOutsideMalaysiaTitle.
  ///
  /// In en, this message translates to:
  /// **'Outside service area'**
  String get weatherOutsideMalaysiaTitle;

  /// No description provided for @weatherOutsideMalaysiaBody.
  ///
  /// In en, this message translates to:
  /// **'Weather forecast is only available for locations in Malaysia.'**
  String get weatherOutsideMalaysiaBody;

  /// No description provided for @weatherServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Service unavailable'**
  String get weatherServiceTitle;

  /// No description provided for @weatherServiceBody.
  ///
  /// In en, this message translates to:
  /// **'The weather service is temporarily unavailable. Please try again later.'**
  String get weatherServiceBody;

  /// No description provided for @weatherNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Weather unavailable'**
  String get weatherNotFoundTitle;

  /// No description provided for @weatherNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'No weather forecast found for this location.'**
  String get weatherNotFoundBody;

  /// No description provided for @weatherGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Weather unavailable'**
  String get weatherGenericTitle;

  /// No description provided for @weatherGenericBody.
  ///
  /// In en, this message translates to:
  /// **'Unable to load ride conditions right now. Please try again.'**
  String get weatherGenericBody;

  /// No description provided for @aqiModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get aqiModerate;

  /// No description provided for @aqiUnhealthy.
  ///
  /// In en, this message translates to:
  /// **'Unhealthy'**
  String get aqiUnhealthy;

  /// No description provided for @aqiVeryUnhealthy.
  ///
  /// In en, this message translates to:
  /// **'Very Unhealthy'**
  String get aqiVeryUnhealthy;

  /// No description provided for @aqiHazardous.
  ///
  /// In en, this message translates to:
  /// **'Hazardous'**
  String get aqiHazardous;

  /// No description provided for @rideConditionsRateLimitSemantics.
  ///
  /// In en, this message translates to:
  /// **'Ride conditions. Rate limit reached.'**
  String get rideConditionsRateLimitSemantics;

  /// No description provided for @rideConditionsErrorSemantics.
  ///
  /// In en, this message translates to:
  /// **'Ride conditions. {title}: {message}.'**
  String rideConditionsErrorSemantics(String title, String message);

  /// No description provided for @pmSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'User session expired. Please log in again.'**
  String get pmSessionExpired;

  /// No description provided for @pmCardInUse.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete card: it is currently attached to an active or pending rental.'**
  String get pmCardInUse;

  /// No description provided for @pmDuplicateCard.
  ///
  /// In en, this message translates to:
  /// **'This card is already registered in your account.'**
  String get pmDuplicateCard;

  /// No description provided for @pmValidationError.
  ///
  /// In en, this message translates to:
  /// **'Validation error: {detail}'**
  String pmValidationError(String detail);

  /// No description provided for @pmUnknownError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get pmUnknownError;

  /// No description provided for @cvCardNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Card number is required'**
  String get cvCardNumberRequired;

  /// No description provided for @cvCardDigitsOnly.
  ///
  /// In en, this message translates to:
  /// **'Enter valid card digits'**
  String get cvCardDigitsOnly;

  /// No description provided for @cvCardBrandUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Only Visa and Mastercard are supported'**
  String get cvCardBrandUnsupported;

  /// No description provided for @cvCardNumberLength.
  ///
  /// In en, this message translates to:
  /// **'Card number must be 16 digits ({entered}/16)'**
  String cvCardNumberLength(int entered);

  /// No description provided for @cvCardNumberTooLong.
  ///
  /// In en, this message translates to:
  /// **'Card number exceeds 16 digits'**
  String get cvCardNumberTooLong;

  /// No description provided for @cvCardChecksumFailed.
  ///
  /// In en, this message translates to:
  /// **'Invalid card number (checksum failed)'**
  String get cvCardChecksumFailed;

  /// No description provided for @cvExpiryRequired.
  ///
  /// In en, this message translates to:
  /// **'Expiry date is required'**
  String get cvExpiryRequired;

  /// No description provided for @cvExpiryFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter expiry date as MM/YY'**
  String get cvExpiryFormat;

  /// No description provided for @cvExpiryInvalidMonth.
  ///
  /// In en, this message translates to:
  /// **'Invalid month (must be 01–12)'**
  String get cvExpiryInvalidMonth;

  /// No description provided for @cvExpiryInvalidYear.
  ///
  /// In en, this message translates to:
  /// **'Invalid expiry year'**
  String get cvExpiryInvalidYear;

  /// No description provided for @cvCardExpired.
  ///
  /// In en, this message translates to:
  /// **'Card has expired'**
  String get cvCardExpired;

  /// No description provided for @cvExpiryTooFar.
  ///
  /// In en, this message translates to:
  /// **'Expiry year too far in future'**
  String get cvExpiryTooFar;

  /// No description provided for @cvCvvRequired.
  ///
  /// In en, this message translates to:
  /// **'CVV code is required'**
  String get cvCvvRequired;

  /// No description provided for @cvCvvLength.
  ///
  /// In en, this message translates to:
  /// **'CVV must be 3 digits'**
  String get cvCvvLength;

  /// No description provided for @cvNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Cardholder name is required'**
  String get cvNameRequired;

  /// No description provided for @cvNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get cvNameTooShort;

  /// No description provided for @cvNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name cannot exceed 50 characters'**
  String get cvNameTooLong;

  /// No description provided for @cvNameInvalidChars.
  ///
  /// In en, this message translates to:
  /// **'Only letters, spaces, hyphens, and dots allowed'**
  String get cvNameInvalidChars;

  /// No description provided for @cvNameNeedsTwoParts.
  ///
  /// In en, this message translates to:
  /// **'Please enter first and last name'**
  String get cvNameNeedsTwoParts;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

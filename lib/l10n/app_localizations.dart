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
  /// **'Payment method'**
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

  /// No description provided for @reportingBike.
  ///
  /// In en, this message translates to:
  /// **'Reporting an issue for {bikeCode}'**
  String reportingBike(String bikeCode);

  /// No description provided for @chooseIssueType.
  ///
  /// In en, this message translates to:
  /// **'What is wrong?'**
  String get chooseIssueType;

  /// No description provided for @chooseIssueTypeError.
  ///
  /// In en, this message translates to:
  /// **'Choose an issue type.'**
  String get chooseIssueTypeError;

  /// No description provided for @issueBrakes.
  ///
  /// In en, this message translates to:
  /// **'Brakes'**
  String get issueBrakes;

  /// No description provided for @issueTyres.
  ///
  /// In en, this message translates to:
  /// **'Tyres'**
  String get issueTyres;

  /// No description provided for @issueLights.
  ///
  /// In en, this message translates to:
  /// **'Lights'**
  String get issueLights;

  /// No description provided for @issueLock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get issueLock;

  /// No description provided for @issueOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get issueOther;

  /// No description provided for @issueNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get issueNoteOptional;

  /// No description provided for @issueNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a short detail that may help.'**
  String get issueNoteHint;

  /// No description provided for @issueSessionOnly.
  ///
  /// In en, this message translates to:
  /// **'This note stays in the current app session and is not sent to support.'**
  String get issueSessionOnly;

  /// No description provided for @noteIssue.
  ///
  /// In en, this message translates to:
  /// **'Note issue'**
  String get noteIssue;

  /// No description provided for @issueNoted.
  ///
  /// In en, this message translates to:
  /// **'Issue noted'**
  String get issueNoted;

  /// No description provided for @issueNotSent.
  ///
  /// In en, this message translates to:
  /// **'Saved for this app session only. It was not sent to support.'**
  String get issueNotSent;

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

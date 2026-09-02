// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BikeRent';

  @override
  String get home => 'Home';

  @override
  String get stations => 'Stations';

  @override
  String get bikeSession => 'Bike Session';

  @override
  String get scan => 'Scan';

  @override
  String get history => 'History';

  @override
  String get profile => 'Profile';

  @override
  String get adminManagement => 'Admin management';

  @override
  String get bikeManagement => 'Bike management';

  @override
  String get settings => 'Settings';

  @override
  String get back => 'Back';

  @override
  String get scanQrCode => 'Scan QR code';

  @override
  String get currentRide => 'Current ride';

  @override
  String get rideInProgress => 'Your ride is in progress.';

  @override
  String get stationsDescription =>
      'Dock capacity, nearby stations, and return points.';

  @override
  String get rideHistory => 'Ride history';

  @override
  String get rideHistoryDescription =>
      'Review past rides, fares, and return stations.';

  @override
  String get rideDetails => 'Ride details';

  @override
  String get pastRides => 'Past rides';

  @override
  String get totalRides => 'Total rides';

  @override
  String get totalDistance => 'Total distance';

  @override
  String get totalSpent => 'Total spent';

  @override
  String rideHistoryEntrySemantics(
    String date,
    String time,
    String fromStation,
    String toStation,
    String duration,
    String distance,
    String fare,
  ) {
    return 'Ride on $date at $time, from $fromStation to $toStation, duration $duration, distance $distance, fare $fare. Tap for details.';
  }

  @override
  String get rideCompleted => 'Ride completed';

  @override
  String get journeyDetails => 'Journey details';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String departedAt(String time) {
    return 'Departed at $time';
  }

  @override
  String arrivedAt(String time) {
    return 'Arrived at $time';
  }

  @override
  String get rideSummary => 'Ride summary';

  @override
  String get bikeId => 'Bike ID';

  @override
  String get paymentDetails => 'Payment details';

  @override
  String get depositHeld => 'Deposit held';

  @override
  String get rideFareFromDeposit => 'Ride fare paid from deposit';

  @override
  String get depositRefunded => 'Remaining deposit refunded';

  @override
  String get totalPaid => 'Total paid';

  @override
  String get depositRefund => 'Deposit refund';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get depositPaymentExplanation =>
      'The ride fare was taken from the deposit. The remaining deposit was refunded to the same payment method.';

  @override
  String get profileDescription =>
      'Profile, wallet, permissions, and ride history.';

  @override
  String get fleetDescription =>
      'Fleet health, battery status, and maintenance queue.';

  @override
  String get adminDescription => 'Manage stations, bikes, and users.';

  @override
  String get stationManagement => 'Station management';

  @override
  String get stationManagementDescription =>
      'Stations, dock capacity, and return points';

  @override
  String get bikeManagementDescription =>
      'Fleet health, battery status, and maintenance';

  @override
  String get userManagement => 'User management';

  @override
  String get userManagementDescription =>
      'User profile, wallet, permissions, and ride history';

  @override
  String get appSettings => 'App settings';

  @override
  String get appSettingsDescription =>
      'Manage appearance and ride permissions.';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get locationAccess => 'Location access';

  @override
  String get locationAccessDescription => 'Required while a ride is active';

  @override
  String get rideNotifications => 'Ride notifications';

  @override
  String get rideNotificationsDescription =>
      'Return reminders and payment updates';

  @override
  String get goodAfternoon => 'GOOD AFTERNOON';

  @override
  String get readyToRide => 'Ready to ride?';

  @override
  String bikeAvailability(int bikeCount, int stationCount) {
    return '$bikeCount bikes available across $stationCount stations.';
  }

  @override
  String unlockRate(String unlockFee, String minuteRate) {
    return '$unlockFee unlock fee + $minuteRate per started minute';
  }

  @override
  String get scanBike => 'Scan bike';

  @override
  String get findStation => 'Find station';

  @override
  String get returnStationUnavailable =>
      'No return station is available right now.';

  @override
  String get liveNetwork => 'Live network';

  @override
  String get bikes => 'Bikes';

  @override
  String get openDocks => 'Open docks';

  @override
  String get nearYou => 'Near you';

  @override
  String get viewAll => 'View all';

  @override
  String stationDistance(int distance) {
    return '$distance m away';
  }

  @override
  String bikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bikes',
      one: '1 bike',
    );
    return '$_temp0';
  }

  @override
  String dockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count docks',
      one: '1 dock',
    );
    return '$_temp0';
  }

  @override
  String docksAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count docks available',
      one: '1 dock available',
    );
    return '$_temp0';
  }

  @override
  String get full => 'Full';

  @override
  String get libraryStation => 'Library Station';

  @override
  String get mainGate => 'Main Gate';

  @override
  String get centralStation => 'Central Station';

  @override
  String get riversidePark => 'Riverside Park';

  @override
  String get marketSquare => 'Market Square';

  @override
  String get universityGate => 'University Gate';

  @override
  String get rideConditions => 'Ride conditions';

  @override
  String get currentWeather => 'Current weather';

  @override
  String get partlyCloudy => 'Partly cloudy';

  @override
  String feelsLike(String temperature) {
    return 'Feels like $temperature';
  }

  @override
  String get scatteredThunderstorms => 'Scattered thunderstorms';

  @override
  String rainChance(int chance) {
    return '$chance% rain';
  }

  @override
  String get humidity => 'Humidity';

  @override
  String get airQuality => 'Air quality';

  @override
  String get good => 'Good';

  @override
  String get wind => 'Wind';

  @override
  String nextHour(String condition) {
    return 'Next hour · $condition';
  }

  @override
  String weatherValues(String temperature, String rainChance) {
    return '$temperature · $rainChance';
  }

  @override
  String weatherUpdated(String time, String date) {
    return 'Updated $time · $date';
  }

  @override
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
  ) {
    return 'Ride conditions. Current location, $location. Current weather, $condition, $temperature, $feelsLike. Next hour, $nextCondition, $nextTemperature, $rainChance. Humidity $humidity. Air quality index $airQualityIndex, $airQualityLabel. Wind $wind.';
  }

  @override
  String get scanStep => 'Scan';

  @override
  String get rideStep => 'Ride';

  @override
  String get returnStep => 'Return';

  @override
  String get payStep => 'Pay';

  @override
  String stepSemantics(String label) {
    return '$label step';
  }

  @override
  String get cameraPreviewSemantics =>
      'Camera preview. Tap to scan the bike QR code.';

  @override
  String get cameraReady => 'Camera ready';

  @override
  String get pointCamera => 'Point the camera at the QR code on the bike frame';

  @override
  String get scanInstructions =>
      'Scan the QR code on the bike frame to start your session';

  @override
  String get bikeReady => 'Bike ready';

  @override
  String get bikeReadyDescription =>
      'Check the bike and fare before placing the test hold.';

  @override
  String bikeBatteryLocation(int battery, String location) {
    return '$battery% battery · $location';
  }

  @override
  String get view => 'View';

  @override
  String get brakesSafe => 'Brakes and tyres look safe';

  @override
  String get frameSafe => 'Seat and frame have no visible damage';

  @override
  String get lightsSafe => 'Front and rear lights are working';

  @override
  String get reportBikeIssue => 'Report bike issue';

  @override
  String reportingBike(String bikeCode) {
    return 'Reporting an issue for $bikeCode';
  }

  @override
  String get chooseIssueType => 'What is wrong?';

  @override
  String get chooseIssueTypeError => 'Choose an issue type.';

  @override
  String get issueBrakes => 'Brakes';

  @override
  String get issueTyres => 'Tyres';

  @override
  String get issueLights => 'Lights';

  @override
  String get issueLock => 'Lock';

  @override
  String get issueOther => 'Other';

  @override
  String get issueNoteOptional => 'Note (optional)';

  @override
  String get issueNoteHint => 'Add a short detail that may help.';

  @override
  String get issueSessionOnly =>
      'This note stays in the current app session and is not sent to support.';

  @override
  String get noteIssue => 'Note issue';

  @override
  String get issueNoted => 'Issue noted';

  @override
  String get issueNotSent =>
      'Saved for this app session only. It was not sent to support.';

  @override
  String get change => 'Change';

  @override
  String reviewHold(String amount) {
    return 'Review $amount hold';
  }

  @override
  String get cancelRental => 'Cancel rental';

  @override
  String get holdExplanation =>
      'The hold is not a charge. Unused funds are released after return.';

  @override
  String get authorizeCardHold => 'Authorize test hold';

  @override
  String get authorizeCardHoldDescription =>
      'Simulate approval of the test payment before the bike unlocks.';

  @override
  String get temporaryAuthorizationHold => 'Temporary authorization hold';

  @override
  String authorizeHold(String amount) {
    return 'Authorize $amount hold';
  }

  @override
  String get unlockBikeTitle => 'Unlock the bike';

  @override
  String unlockBikeDescription(String bikeId) {
    return 'Stay beside $bikeId while the rear lock opens.';
  }

  @override
  String get contactingBikeLock => 'Contacting bike lock…';

  @override
  String get cardHoldAuthorized => 'Test hold authorized';

  @override
  String get unlockBike => 'Unlock bike';

  @override
  String get rideActive => 'Ride active';

  @override
  String get rideActiveDescription =>
      'GPS tracks your position along the city route.';

  @override
  String get gpsActive => 'GPS active';

  @override
  String get gpsLost => 'GPS lost';

  @override
  String get restoreGps => 'Restore GPS';

  @override
  String get time => 'Time';

  @override
  String get distance => 'Distance';

  @override
  String get estimated => 'Estimated';

  @override
  String distanceKm(String distance) {
    return '$distance km';
  }

  @override
  String get returnBike => 'Return Bike';

  @override
  String get nearestReturnStation => 'Nearest return station';

  @override
  String get otherNearbyStations => 'Other nearby stations';

  @override
  String get phoneSafety =>
      'Stop safely before using the phone or choosing a station.';

  @override
  String get continueRide => 'Continue ride';

  @override
  String get chooseReturnStation => 'Choose return station';

  @override
  String get chooseReturnStationDescription =>
      'A free dock is required to finish the ride.';

  @override
  String get withinReturnZone => 'Within return zone';

  @override
  String get confirmArrival => 'Confirm arrival';

  @override
  String get continueToDock => 'Continue to dock';

  @override
  String get secureBike => 'Secure the bike';

  @override
  String get secureBikeDescription =>
      'Push the front wheel into an open dock until it locks.';

  @override
  String get confirmBikeDocked => 'Confirm bike is docked';

  @override
  String get rideComplete => 'Ride complete';

  @override
  String get rideCompleteDescription =>
      'The bike is secured. Review the final charge.';

  @override
  String get unlockFee => 'Unlock fee';

  @override
  String startedMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count started minutes',
      one: '1 started minute',
    );
    return '$_temp0';
  }

  @override
  String get rideDuration => 'Ride duration';

  @override
  String get timeFare => 'Time fare';

  @override
  String hourCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String minuteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get finalFare => 'Final fare';

  @override
  String get holdReleased => 'Hold released';

  @override
  String chargeAmount(String amount) {
    return 'Charge $amount';
  }

  @override
  String get ridePaid => 'Ride paid';

  @override
  String get paymentPending => 'Ride ended · Payment pending';

  @override
  String get holdReleasedDescription =>
      'The remaining test hold has been released.';

  @override
  String get paymentPendingDescription =>
      'The bike is returned safely. Retry the simulated charge below.';

  @override
  String get rideId => 'Ride ID';

  @override
  String get duration => 'Duration';

  @override
  String get returnedAt => 'Returned at';

  @override
  String get retryPayment => 'Retry payment';

  @override
  String get retry => 'Retry';

  @override
  String get rentAnotherBike => 'Rent another bike';

  @override
  String get pleaseWait => 'Please wait…';

  @override
  String get timeBasedPricing => 'Time-based pricing';

  @override
  String pricingFormula(String unlockFee, String minuteRate) {
    return '$unlockFee + (started minutes × $minuteRate)';
  }

  @override
  String pricingExample(int minutes) {
    return '$minutes-minute example';
  }

  @override
  String get pricingTimerDescription =>
      'The timer starts after the bike unlocks and stops when the dock confirms the return.';

  @override
  String get choosePaymentMethod => 'Choose payment method';

  @override
  String get personalCard => 'Personal card';

  @override
  String get travelCard => 'Travel card';

  @override
  String get addCardFuture =>
      'Adding a new card belongs to the future User module.';

  @override
  String get paypalSandbox => 'Test payment';

  @override
  String get paypalSandboxDescription => 'Local simulation · No real money';

  @override
  String get paypalAccountSubtitle => 'PayPal Sandbox account';

  @override
  String get paypalCheckoutTitle => 'PayPal Sandbox';

  @override
  String get paypalCheckoutSemantics => 'Secure PayPal Sandbox approval page';

  @override
  String get selected => 'Selected';

  @override
  String get selectable => 'Selectable';

  @override
  String get cityMapSemantics =>
      'City map showing current bike position and return stations';

  @override
  String get errorInvalidQr =>
      'This QR code is not a BikeRent bike. Scan the code on the bike frame.';

  @override
  String errorBikeReserved(String bikeId) {
    return 'Bike $bikeId is already reserved. Choose another bike and scan again.';
  }

  @override
  String errorHoldDeclined(String amount) {
    return 'The $amount test hold was declined. Retry when ready.';
  }

  @override
  String get errorPaymentConfiguration =>
      'The local test payment simulator is unavailable.';

  @override
  String get errorPaymentNetwork =>
      'The local test payment failed. Retry when ready.';

  @override
  String get errorPaymentCancelled =>
      'Test payment approval was cancelled. Retry when ready.';

  @override
  String get errorPaymentAuthorizationFailed =>
      'The test payment could not authorize the hold. Retry when ready.';

  @override
  String get errorPaymentCaptureFailed =>
      'The test payment could not capture the ride fare. The payment remains pending; retry below.';

  @override
  String get errorLockFailed =>
      'The lock did not respond. Stand near the bike and try again.';

  @override
  String get errorGpsLost =>
      'GPS signal lost. Move to an open area and check location access.';

  @override
  String errorStationFull(String station) {
    return '$station has no free docks. Choose another station.';
  }

  @override
  String get errorChooseStation => 'Choose a return station first.';

  @override
  String get errorOutsideReturnZone =>
      'Move within 50 m of the selected station before returning the bike.';

  @override
  String get errorDockNotDetected =>
      'Dock not detected. Push the bike firmly into the dock and retry.';

  @override
  String get errorAuthenticationFailed =>
      'Demo rider sign-in failed. Check Supabase and retry.';

  @override
  String get errorBackendConnection =>
      'The rent service is unavailable. Check the connection and retry.';

  @override
  String get errorActiveRentalExists =>
      'This rider already has an unfinished rental. Resume or finish it first.';

  @override
  String get errorInvalidRentalTransition =>
      'The rental state changed on the server. Retry to restore it.';
}

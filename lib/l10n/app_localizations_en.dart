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
  String get paymentMethod => 'Payment Method';

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
  String get language => 'Language';

  @override
  String get languageDescription => 'Select your preferred app language';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get english => 'English';

  @override
  String get malay => 'Bahasa Melayu';

  @override
  String get simplifiedChinese => '简体中文';

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
  String get cameraNoPermission => 'No Permission';

  @override
  String get cameraPermissionDescription =>
      'Camera permission is required to scan the bike QR code. Tap below to allow access.';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get cameraPermissionSettingsPrompt =>
      'Camera permission is required. Enable camera in device settings.';

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
  String brakesIssueReported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Brakes / tyres: $count issues reported',
      one: 'Brakes / tyres: 1 issue reported',
    );
    return '$_temp0';
  }

  @override
  String get frameSafe => 'Seat and frame have no visible damage';

  @override
  String frameIssueReported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seat / frame: $count issues reported',
      one: 'Seat / frame: 1 issue reported',
    );
    return '$_temp0';
  }

  @override
  String get lightsSafe => 'Front and rear lights are working';

  @override
  String lightsIssueReported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lights / bell: $count issues reported',
      one: 'Lights / bell: 1 issue reported',
    );
    return '$_temp0';
  }

  @override
  String get checkingBikeCondition => 'Checking bike condition reports…';

  @override
  String get reportBikeIssue => 'Report bike issue';

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
  String get scanStationQr => 'Scan station QR';

  @override
  String get scanStationQrDescription =>
      'Scan the QR poster at the station, or enter its code, to verify the return.';

  @override
  String get cameraUnavailable =>
      'Camera unavailable. Enter the station code below instead.';

  @override
  String get stationCodeLabel => 'Station code';

  @override
  String get stationCodeHint => 'e.g. CENTRAL';

  @override
  String get confirm => 'Confirm';

  @override
  String rideDeadlineCountdown(int minutes) {
    return '$minutes min left to return the bike';
  }

  @override
  String get rideOverdueTitle => 'Ride overdue';

  @override
  String get rideOverdueBody =>
      'You passed the maximum ride time. Return the bike now — if it is not returned in time, the rental is closed as lost and the account is suspended.';

  @override
  String extendRide(int count) {
    return 'Extend +60 min ($count left)';
  }

  @override
  String get noExtensionsLeft => 'No extensions left';

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
  String get paypalCheckoutTitle => 'PayPal Payment';

  @override
  String get paypalCheckoutSemantics => 'Secure PayPal Payment approval page';

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
  String errorBikeMaintenance(String bikeId) {
    return 'Bike $bikeId is currently under maintenance and cannot be rented. Choose another bike and scan again.';
  }

  @override
  String errorBikeUnavailable(String bikeId) {
    return 'Bike $bikeId is currently unavailable and cannot be rented. Choose another bike and scan again.';
  }

  @override
  String errorBikeLowBattery(String bikeId, int percent) {
    return 'Bike $bikeId has low battery ($percent%) and cannot be rented. Minimum required is 10%. Choose another bike and scan again.';
  }

  @override
  String get lowBatteryWarningTitle => 'Low Battery Warning';

  @override
  String lowBatteryWarningMessage(String bikeId, int percent) {
    return 'Bike $bikeId battery is at $percent%. Riding distance and motor assist may be limited. Do you want to continue?';
  }

  @override
  String get continueButton => 'Continue';

  @override
  String get bikeCannotBeRentedTitle => 'Bike Cannot Be Rented';

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
      'Move within 250 m of the selected station before returning the bike.';

  @override
  String get errorStationQrMismatch =>
      'That QR does not match the selected station. Scan the QR poster at the station or enter its code.';

  @override
  String get errorMaxExtensionsReached =>
      'No ride extensions left. Return the bike to finish the rental.';

  @override
  String get errorLocationPermissionDenied =>
      'Location permission is needed to verify the return. Enable it and retry.';

  @override
  String get errorAccountSuspended =>
      'Account suspended: a previous bike was not returned. Contact support to restore it.';

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
  String errorStationMaintenance(String station) {
    return 'Station $station is currently under maintenance. You cannot rent or return bikes here.';
  }

  @override
  String errorStationTerminated(String station) {
    return 'Station $station has been terminated. You cannot rent or return bikes here.';
  }

  @override
  String get errorStationMaintenanceGeneral =>
      'This station is currently under maintenance. You cannot rent or return bikes here.';

  @override
  String get errorStationTerminatedGeneral =>
      'This station has been terminated. You cannot rent or return bikes here.';

  @override
  String get stationUnderMaintenance => 'Under Maintenance';

  @override
  String get stationCannotReturnMaintenance =>
      'This station is under maintenance. You cannot return bikes here.';

  @override
  String get errorInvalidRentalTransition =>
      'The rental state changed on the server. Retry to restore it.';

  @override
  String get rideWarningDepositExceededTitle => 'Deposit Time Exceeded';

  @override
  String get rideWarningDepositExceededBody =>
      'You have borrowed the bike longer than the deposit time. Additional rental charges apply.';

  @override
  String get rideWarningLegalActionTitle => 'Legal Action Warning';

  @override
  String get rideWarningLegalActionBody =>
      'Rental duration exceeded 2x the deposit time. Immediate legal action will be initiated if the bike is not returned.';

  @override
  String get rideWarningSuspiciousActivityTitle =>
      'Suspicious Activity Detected';

  @override
  String get rideWarningSuspiciousActivityBody =>
      'Suspicious activity detected: You are unusually far from the pickup station.';

  @override
  String get rideWarningSuspiciousLegalTitle =>
      'Suspicious Activity & Legal Action';

  @override
  String get rideWarningSuspiciousLegalBody =>
      'Suspicious activity detected far from station and deposit time exceeded. Immediate legal action will be taken if the bike is not returned.';

  @override
  String get addBike => 'Add Bike';

  @override
  String get editBike => 'Edit Bike';

  @override
  String get bikeDetail => 'Bike Detail';

  @override
  String get bikeReport => 'Bike Report';

  @override
  String get transferBike => 'Transfer Bike';

  @override
  String get serviceBike => 'Service Bike';

  @override
  String get reportDetail => 'Report Detail';

  @override
  String get pendingReports => 'Pending Reports';

  @override
  String get newReport => 'New Report';

  @override
  String get pendingReportDetails => 'Pending Report Details';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get conditionReports => 'Condition reports';

  @override
  String get reviewAndResolveBikeIssues => 'Review and resolve bike issues.';

  @override
  String get trackSubmittedBikeReports => 'Track your submitted bike reports.';

  @override
  String get searchReportOrBikeId => 'Search report or bike ID';

  @override
  String get pending => 'Pending';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get reports => 'Reports';

  @override
  String get newestFirst => 'Newest first';

  @override
  String get cancelReport => 'Cancel Report';

  @override
  String get cancelReportQuestion => 'Cancel Report?';

  @override
  String get keepReport => 'Keep Report';

  @override
  String cancelReportConfirmation(String reportId) {
    return 'Cancel $reportId? This report will no longer be reviewed by an administrator.';
  }

  @override
  String reportCancelled(String reportId) {
    return '$reportId cancelled.';
  }

  @override
  String failedToCancelReport(String error) {
    return 'Failed to cancel report: $error';
  }

  @override
  String get onlyPendingReportsCanBeCancelled =>
      'Only pending reports can be cancelled.';

  @override
  String allReports(int count) {
    return 'All $count';
  }

  @override
  String pendingReportsCount(int count) {
    return 'Pending $count';
  }

  @override
  String approvedReportsCount(int count) {
    return 'Approved $count';
  }

  @override
  String rejectedReportsCount(int count) {
    return 'Rejected $count';
  }

  @override
  String cancelledReportsCount(int count) {
    return 'Cancelled $count';
  }

  @override
  String get noMatchingReports => 'No matching reports';

  @override
  String get noReportsYet => 'No reports yet';

  @override
  String get tryDifferentSearchTerm => 'Try a different search term.';

  @override
  String get bikeConditionReportsAppearHere =>
      'Bike condition reports will appear here.';

  @override
  String get reported => 'Reported';

  @override
  String get unableToLoadReports => 'Unable to load reports';

  @override
  String get brakeSystem => 'Brake System';

  @override
  String get tyres => 'Tyres';

  @override
  String get chainAndGears => 'Chain & Gears';

  @override
  String get seatAndFrame => 'Seat & Frame';

  @override
  String get bellAndLights => 'Bell & Lights';

  @override
  String get qrLock => 'QR / Lock';

  @override
  String get other => 'Other';

  @override
  String get unableToLoadReport => 'Unable to load report';

  @override
  String get reportNotFound => 'Report not found';

  @override
  String get reportDetails => 'Report details';

  @override
  String get noStationAssigned => 'No station assigned';

  @override
  String get reportInformation => 'Report information';

  @override
  String get problem => 'Problem';

  @override
  String get reportIdLabel => 'Report ID';

  @override
  String get photo => 'Photo';

  @override
  String get photoUnavailable => 'Photo unavailable';

  @override
  String get photoCouldNotBeLoaded => 'The report photo could not be loaded.';

  @override
  String get unableToDisplayPhoto => 'Unable to display photo';

  @override
  String get attachedPhotoCouldNotBeDisplayed =>
      'The attached photo could not be displayed.';

  @override
  String get noPhotoAttached => 'No photo attached';

  @override
  String get reportWithoutPhoto => 'This report was submitted without a photo.';

  @override
  String get issueDescription => 'Issue description';

  @override
  String get pendingReview => 'Pending review';

  @override
  String get pendingReviewDescription =>
      'This report has not been reviewed yet.';

  @override
  String get reportApproved => 'Report approved';

  @override
  String get reportRejected => 'Report rejected';

  @override
  String get reviewed => 'Reviewed';

  @override
  String get reviewNote => 'Review note';

  @override
  String get noReviewNoteProvided => 'No review note provided.';

  @override
  String get reportCancelledStatus => 'Report cancelled';

  @override
  String get reportCancelledDescription =>
      'You cancelled this report before it was reviewed.';

  @override
  String get addNewBike => 'Add new bike';

  @override
  String get step1BasicInformation => 'Step 1 of 3 • Basic information';

  @override
  String get step2QrCode => 'Step 2 of 3 • QR code';

  @override
  String get step3ReviewInformation => 'Step 3 of 3 • Review information';

  @override
  String get bikeCode => 'Bike Code';

  @override
  String get enterBikeCode => 'Enter bike code';

  @override
  String get bikeCodeTooShort => 'Bike code is too short';

  @override
  String get initialStation => 'Initial station';

  @override
  String get pleaseSelectStation => 'Please select a station';

  @override
  String get selectStation => 'Select a station';

  @override
  String get unableToLoadStations => 'Unable to load stations';

  @override
  String get noStationsAvailable => 'No stations are available.';

  @override
  String get noStationSelected => 'No station selected';

  @override
  String get batteryPercentage => 'Battery percentage';

  @override
  String get enterBatteryPercentage => 'Enter battery percentage';

  @override
  String get invalidBatteryPercentage => 'Invalid battery percentage';

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String get batteryRangeError => 'Battery must be between 0 and 100';

  @override
  String get battery => 'Battery';

  @override
  String get initialStatus => 'Initial status';

  @override
  String get status => 'Status';

  @override
  String get available => 'Available';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get retired => 'Retired';

  @override
  String get qrGeneratedAutomatically =>
      'A unique QR token will be generated automatically.';

  @override
  String get qrScanningDescription =>
      'The QR code can later contain this token for bike scanning.';

  @override
  String get bikeQrCode => 'Bike QR Code';

  @override
  String get qrTokenIdentifiesBike =>
      'The following token will identify this bike when scanned.';

  @override
  String get qrToken => 'QR Token';

  @override
  String get qrTokenNotGenerated => 'QR token has not been generated';

  @override
  String get notGenerated => 'Not generated';

  @override
  String get qrPlaceholderDescription =>
      'The visual QR image is currently a placeholder. Later we can generate an actual QR code from this token.';

  @override
  String get generatedQrCode => 'Generated QR Code';

  @override
  String get next => 'Next';

  @override
  String get bikeInformation => 'Bike information';

  @override
  String get notSelected => 'Not selected';

  @override
  String get bikeAddedSuccessfully => 'Bike added successfully';

  @override
  String failedToAddBike(String error) {
    return 'Failed to add bike: $error';
  }

  @override
  String get managePaymentMethodsSubtitle =>
      'Manage credit/debit cards and PayPal';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get termsOfServiceSubtitle =>
      'Rental rules, safety policies, and liabilities';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle =>
      'Data protection, GPS location, and privacy rights';

  @override
  String get logOut => 'Log Out';

  @override
  String get onlineCheckout => 'ONLINE CHECKOUT';

  @override
  String get savedCards => 'SAVED CARDS';

  @override
  String savedCardsCount(int count) {
    return '$count saved';
  }

  @override
  String get noCardsSaved => 'No cards saved yet';

  @override
  String get noCardsSavedDescription =>
      'Add a Visa or Mastercard for quick, seamless one-tap bike rentals.';

  @override
  String get addCard => 'Add Card';

  @override
  String get removeCard => 'Remove Card';

  @override
  String removeCardConfirmation(String brand, String lastFour) {
    return 'Are you sure you want to remove your $brand ending in $lastFour?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get cardRemovedSuccess => 'Card removed successfully';

  @override
  String get failedToRemoveCard => 'Failed to remove card';

  @override
  String cardSetAsDefault(String brand) {
    return '$brand set as default payment method';
  }

  @override
  String get failedToUpdateDefaultCard => 'Failed to update default card';

  @override
  String get editCard => 'Edit Card';

  @override
  String get cardUpdatedSuccess => 'Card updated successfully';

  @override
  String get failedToUpdateCard => 'Failed to update card';

  @override
  String get cardAddedSuccess => 'Card added successfully';

  @override
  String get failedToAddCard => 'Failed to add card';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get cardNumberHint => '4xxx xxxx xxxx xxxx';

  @override
  String get cardholderName => 'Cardholder Name';

  @override
  String get cardholderNameHint => 'e.g. John Doe';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get expiryDateHint => 'MM/YY';

  @override
  String get cvvCvc => 'CVV / CVC';

  @override
  String get cvvHint => '•••';

  @override
  String get setAsDefaultPaymentMethod => 'Set as default payment method';

  @override
  String get automaticallyUseCard =>
      'Automatically use this card for bike rentals';

  @override
  String get updateCard => 'Update Card';

  @override
  String cardExpiry(String month, String year) {
    return 'Exp $month/$year';
  }

  @override
  String get activeCard => 'Active Card';

  @override
  String get defaultBadge => 'DEFAULT';

  @override
  String get cardOptions => 'Card options';

  @override
  String get setAsDefault => 'Set as default';

  @override
  String get editCardMenu => 'Edit card';

  @override
  String get removeCardMenu => 'Remove card';

  @override
  String get payPal => 'PayPal';

  @override
  String get payPalBuiltIn => 'Built-in';

  @override
  String get payPalSubtitle => 'Webview checkout · Always available';

  @override
  String get payPalInformation => 'PayPal information';

  @override
  String get payPalIntegration => 'PayPal Integration';

  @override
  String get payPalAlwaysAvailable => 'Always available payment option';

  @override
  String get payPalDescription =>
      'PayPal checkout is processed on-demand through a secure in-app webview during bike rental authorization. It does not require storing credit or debit card details, so it cannot be edited or removed.';

  @override
  String get gotIt => 'Got it';

  @override
  String get cardholderPreview => 'CARDHOLDER';

  @override
  String get cardholderNamePreview => 'CARDHOLDER NAME';

  @override
  String get expiresPreview => 'EXPIRES';

  @override
  String get agree => 'Agree';

  @override
  String get agreementConfirmation => 'Agreement Confirmation';

  @override
  String agreementNotice(String buttonText, String title) {
    return 'By tapping \"$buttonText\" above or below, you acknowledge that you have reviewed and accept these $title.';
  }

  @override
  String agreeAndContinue(String buttonText) {
    return '$buttonText & Continue';
  }

  @override
  String get contactSupport => 'Questions? Contact support@bikerent.app';

  @override
  String errorLoadingStations(String error) {
    return 'Error loading stations: $error';
  }

  @override
  String get stationA => 'Station A';

  @override
  String get stationB => 'Station B';

  @override
  String get selectOriginStation => 'Select origin station';

  @override
  String get selectDestinationStation => 'Select destination station';

  @override
  String get underMaintenance => 'Under Maintenance';

  @override
  String get selectedStationTooFar => 'Selected Station are too far away';

  @override
  String get etaLabel => 'ETA:';

  @override
  String get estimatedArrivalTime => 'Estimated Arrival Time (ETA)';

  @override
  String durationInMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String totalDistanceKm(String distance) {
    return 'Total Distance: $distance km';
  }

  @override
  String get selectStationsToCalculateRoutePrompt =>
      'Select Station A & Station B to calculate route.';

  @override
  String failedToLoadBikes(String error) {
    return 'Failed to load bikes: $error';
  }

  @override
  String get invalidBikeIdError => 'Unable to open: Invalid Bike ID';

  @override
  String get stationBikes => 'Station Bikes';

  @override
  String get locationCoordinatesNotProvided =>
      'Location coordinates not provided';

  @override
  String get searchBikesCodeOrId => 'Search bikes by code or ID';

  @override
  String get noBikesInStationYet => 'there is no bikes in this station yet';

  @override
  String get noBikesMatchSearch => 'No bikes match your search.';

  @override
  String get unknownStatus => 'Unknown';

  @override
  String bikeStatus(String status) {
    return 'Status: $status';
  }

  @override
  String failedToLoadStations(String error) {
    return 'Failed to load stations: $error';
  }

  @override
  String get searchStationHint => 'Search station code, name or address...';

  @override
  String get longPressMapToAddStation => 'Long-press map to add new station';

  @override
  String get noMatchingStationsFound => 'No matching stations found.';

  @override
  String get unnamedStation => 'Unnamed Station';

  @override
  String get noAddress => 'No address';

  @override
  String get stationNameEmptyError => 'Station name cannot be empty.';

  @override
  String get stationAddressEmptyError => 'Station address cannot be empty.';

  @override
  String get validCapacityError =>
      'Please enter a valid number for max capacity.';

  @override
  String maxCapacityExceededError(int capacity, int bikes) {
    return 'Max capacity ($capacity) cannot be less than current docked bikes ($bikes).';
  }

  @override
  String get stationUpdatedSuccess => 'Station updated successfully!';

  @override
  String get stationAddedSuccess => 'Station added successfully!';

  @override
  String failedToSaveStation(String error) {
    return 'Failed to save station: $error';
  }

  @override
  String get removeStation => 'Remove Station';

  @override
  String get confirmRemoveStationBody =>
      'Are you sure you want to remove this station?';

  @override
  String get stationRemovedSuccess => 'Station removed successfully!';

  @override
  String failedToRemoveStation(String error) {
    return 'Failed to remove station: $error';
  }

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get stationName => 'Station Name';

  @override
  String get enterStationNameHint => 'Enter station name...';

  @override
  String get stationCode => 'Station Code';

  @override
  String get readOnly => 'Read-Only';

  @override
  String get address => 'Address';

  @override
  String get enterStationAddressHint => 'Enter station address...';

  @override
  String get operatingStatus => 'Operating status';

  @override
  String get currentDockedBikes => 'Current Docked Bikes';

  @override
  String get maxBikesPerStation => 'Max bike per station';

  @override
  String get addStation => 'Add Station';

  @override
  String get updateStation => 'Update Station';

  @override
  String get viewBikesAtStation => 'View Bikes at Station';

  @override
  String get noAddressSet => 'No address set';

  @override
  String get noBikesAtStation => 'No bikes at this station.';

  @override
  String stationDeactivatedSuccess(String stationName) {
    return '$stationName deactivated successfully';
  }

  @override
  String get searchStationToRemove => 'Search station to remove...';

  @override
  String get searchStationNameOrAddress => 'Search station name or address...';

  @override
  String get noStationsFound => 'No stations found.';

  @override
  String bikesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bikes',
      one: '1 bike',
    );
    return '$_temp0';
  }

  @override
  String get currentlySelected => 'Currently Selected';

  @override
  String get targetStationToRemove => 'Target Station to Remove';

  @override
  String get closestToYou => 'Closest to you';

  @override
  String get reset => 'Reset';

  @override
  String get allActiveStations => 'All Active Stations';

  @override
  String get nearbyStations => 'Nearby Stations';

  @override
  String stationSummarySubtitle(String address, int count, String distance) {
    return '$address • $count Bikes$distance';
  }

  @override
  String confirmRemoveStationTitle(String stationName) {
    return 'Are you sure to remove\n$stationName?';
  }

  @override
  String get actionIrreversibleWarning =>
      'This action is irreversible, are you sure to continue?';

  @override
  String get removeLocation => 'Remove Location';

  @override
  String get okButton => 'OK';

  @override
  String get scanningLabel => 'Scanning…';

  @override
  String get flashlightTooltip => 'Flashlight';

  @override
  String get invalidQrTitle => 'Invalid QR Code';

  @override
  String reservationExpiresIn(String time) {
    return 'Reservation expires in $time';
  }

  @override
  String get rentalTimedOutTitle => 'Rental Timed Out';

  @override
  String rentalTimedOutBody(int minutes) {
    return 'Your bike reservation timed out after the $minutes-minute limit. The bike has been released.';
  }

  @override
  String get forceEndedTitle => 'Session Ended by Admin';

  @override
  String get rentalEndedTitle => 'Rental Ended';

  @override
  String get rentalEndedBody =>
      'Your rental session has ended. Start a new ride whenever you\'re ready.';

  @override
  String returnAtStation(String station) {
    return 'Return at $station';
  }

  @override
  String get originStation => 'Origin Station';

  @override
  String get tripStartedHere => 'Trip started here';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get yourGpsPosition => 'Your GPS position';

  @override
  String get stationDetailsTooltip => 'Station details';

  @override
  String get addPaymentMethod => 'Add Payment Method';

  @override
  String get lowBatteryFallbackBike => 'this bike';

  @override
  String get errorStationFullGeneral =>
      'Nearby stations have no free docks right now. Please try again shortly.';

  @override
  String get termsNoticePrefix =>
      'By proceeding with the renting process, you are considered to accept and clear the ';

  @override
  String get termsNoticeMiddle => ' and ';

  @override
  String get termsNoticeSuffix => ' of the app.';

  @override
  String get rideHistoryLoadFailed => 'Ride history could not be loaded.';

  @override
  String get noCompletedRides => 'No completed rides yet.';

  @override
  String get weatherConnectionFailedTitle => 'Connection failed';

  @override
  String get weatherConnectionFailedBody =>
      'Unable to connect to the weather service. Please check your internet connection and try again.';

  @override
  String get weatherTimeoutTitle => 'Connection timed out';

  @override
  String get weatherTimeoutBody =>
      'The weather service took too long to respond. Please check your connection and try again.';

  @override
  String get weatherRateLimitTitle => 'Rate limit reached';

  @override
  String get weatherRateLimitBody =>
      'The weather service is temporarily busy. Please wait a moment and try again.';

  @override
  String get weatherLocationTitle => 'Location unavailable';

  @override
  String get weatherLocationBody =>
      'Location access is required to show current weather. Please enable GPS and grant permission.';

  @override
  String get weatherOutsideMalaysiaTitle => 'Outside service area';

  @override
  String get weatherOutsideMalaysiaBody =>
      'Weather forecast is only available for locations in Malaysia.';

  @override
  String get weatherServiceTitle => 'Service unavailable';

  @override
  String get weatherServiceBody =>
      'The weather service is temporarily unavailable. Please try again later.';

  @override
  String get weatherNotFoundTitle => 'Weather unavailable';

  @override
  String get weatherNotFoundBody =>
      'No weather forecast found for this location.';

  @override
  String get weatherGenericTitle => 'Weather unavailable';

  @override
  String get weatherGenericBody =>
      'Unable to load ride conditions right now. Please try again.';

  @override
  String get aqiModerate => 'Moderate';

  @override
  String get aqiUnhealthy => 'Unhealthy';

  @override
  String get aqiVeryUnhealthy => 'Very Unhealthy';

  @override
  String get aqiHazardous => 'Hazardous';

  @override
  String get rideConditionsRateLimitSemantics =>
      'Ride conditions. Rate limit reached.';

  @override
  String rideConditionsErrorSemantics(String title, String message) {
    return 'Ride conditions. $title: $message.';
  }

  @override
  String get pmSessionExpired => 'User session expired. Please log in again.';

  @override
  String get pmCardInUse =>
      'Cannot delete card: it is currently attached to an active or pending rental.';

  @override
  String get pmDuplicateCard =>
      'This card is already registered in your account.';

  @override
  String pmValidationError(String detail) {
    return 'Validation error: $detail';
  }

  @override
  String get pmUnknownError =>
      'An unexpected error occurred. Please try again.';

  @override
  String get cvCardNumberRequired => 'Card number is required';

  @override
  String get cvCardDigitsOnly => 'Enter valid card digits';

  @override
  String get cvCardBrandUnsupported => 'Only Visa and Mastercard are supported';

  @override
  String cvCardNumberLength(int entered) {
    return 'Card number must be 16 digits ($entered/16)';
  }

  @override
  String get cvCardNumberTooLong => 'Card number exceeds 16 digits';

  @override
  String get cvCardChecksumFailed => 'Invalid card number (checksum failed)';

  @override
  String get cvExpiryRequired => 'Expiry date is required';

  @override
  String get cvExpiryFormat => 'Enter expiry date as MM/YY';

  @override
  String get cvExpiryInvalidMonth => 'Invalid month (must be 01–12)';

  @override
  String get cvExpiryInvalidYear => 'Invalid expiry year';

  @override
  String get cvCardExpired => 'Card has expired';

  @override
  String get cvExpiryTooFar => 'Expiry year too far in future';

  @override
  String get cvCvvRequired => 'CVV code is required';

  @override
  String get cvCvvLength => 'CVV must be 3 digits';

  @override
  String get cvNameRequired => 'Cardholder name is required';

  @override
  String get cvNameTooShort => 'Name must be at least 2 characters';

  @override
  String get cvNameTooLong => 'Name cannot exceed 50 characters';

  @override
  String get cvNameInvalidChars =>
      'Only letters, spaces, hyphens, and dots allowed';

  @override
  String get cvNameNeedsTwoParts => 'Please enter first and last name';

  @override
  String get cvNameDuplicate =>
      'Cardholder name is already used by another card';
}

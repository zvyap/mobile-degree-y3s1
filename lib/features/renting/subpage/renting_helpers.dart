part of '../renting_flow_page.dart';

String _stationName(AppLocalizations l10n, ReturnStation station) {
  return station.name;
}

String _paymentMethodLabel(AppLocalizations l10n, RentalPaymentMethod method) {
  return switch (method.id) {
    'paypal' => l10n.paypalAccountSubtitle,
    _ => method.lastFour.isNotEmpty ? '•••• ${method.lastFour}' : method.brand,
  };
}

String _durationWords(AppLocalizations l10n, int minutes) {
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  if (hours == 0) return l10n.minuteCount(mins);
  if (mins == 0) return l10n.hourCount(hours);
  return '${l10n.hourCount(hours)} ${l10n.minuteCount(mins)}';
}

String _rentalError(BuildContext context, RentingController controller) {
  final l10n = context.l10n;
  return switch (controller.error!) {
    RentalError.invalidQr => l10n.errorInvalidQr,
    RentalError.bikeReserved => l10n.errorBikeReserved(controller.bikeCode),
    RentalError.bikeMaintenance =>
      l10n.errorBikeMaintenance(controller.bikeCode),
    RentalError.bikeUnavailable =>
      l10n.errorBikeUnavailable(controller.bikeCode),
    RentalError.stationMaintenance => controller.errorStation != null
        ? l10n.errorStationMaintenance(
            _stationName(l10n, controller.errorStation!),
          )
        : l10n.errorStationMaintenanceGeneral,
    RentalError.stationTerminated => controller.errorStation != null
        ? l10n.errorStationTerminated(
            _stationName(l10n, controller.errorStation!),
          )
        : l10n.errorStationTerminatedGeneral,
    RentalError.holdDeclined => l10n.errorHoldDeclined(
      context.formats.currency(controller.holdAmount),
    ),
    RentalError.paymentConfiguration => l10n.errorPaymentConfiguration,
    RentalError.paymentNetwork => l10n.errorPaymentNetwork,
    RentalError.paymentCancelled => l10n.errorPaymentCancelled,
    RentalError.paymentAuthorizationFailed =>
      l10n.errorPaymentAuthorizationFailed,
    RentalError.paymentCaptureFailed => l10n.errorPaymentCaptureFailed,
    RentalError.lockFailed => l10n.errorLockFailed,
    RentalError.gpsLost => l10n.errorGpsLost,
    RentalError.stationFull => l10n.errorStationFull(
      _stationName(l10n, controller.errorStation!),
    ),
    RentalError.chooseStation => l10n.errorChooseStation,
    RentalError.outsideReturnZone => l10n.errorOutsideReturnZone,
    RentalError.stationQrMismatch => l10n.errorStationQrMismatch,
    RentalError.maxExtensionsReached => l10n.errorMaxExtensionsReached,
    RentalError.locationPermissionDenied =>
      l10n.errorLocationPermissionDenied,
    RentalError.accountSuspended => l10n.errorAccountSuspended,
    RentalError.dockNotDetected => l10n.errorDockNotDetected,
    RentalError.authenticationFailed => l10n.errorAuthenticationFailed,
    RentalError.connectionFailed => l10n.errorBackendConnection,
    RentalError.activeRentalExists => l10n.errorActiveRentalExists,
    RentalError.invalidTransition => l10n.errorInvalidRentalTransition,
  };
}

ButtonStyle _secondaryTextButtonStyle(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return TextButton.styleFrom(
    foregroundColor: scheme.onSurface.withValues(alpha: 0.76),
  );
}

ButtonStyle _dangerTextButtonStyle(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return TextButton.styleFrom(foregroundColor: scheme.error);
}

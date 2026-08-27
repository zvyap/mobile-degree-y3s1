part of '../renting_flow_page.dart';

String _stationName(AppLocalizations l10n, ReturnStation station) {
  return switch (station.id) {
    'central' => l10n.centralStation,
    'riverside' => l10n.riversidePark,
    'market' => l10n.marketSquare,
    'university' => l10n.universityGate,
    _ => station.id,
  };
}

String _paymentMethodLabel(AppLocalizations l10n, RentalPaymentMethod method) {
  return switch (method.id) {
    'paypal-sandbox' => l10n.paypalSandboxDescription,
    _ => method.brand,
  };
}

String _rentalError(BuildContext context, RentingController controller) {
  final l10n = context.l10n;
  return switch (controller.error!) {
    RentalError.invalidQr => l10n.errorInvalidQr,
    RentalError.bikeReserved => l10n.errorBikeReserved(controller.bike.id),
    RentalError.holdDeclined => l10n.errorHoldDeclined(
      context.formats.currency(RentingController.holdAmount),
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
    RentalError.dockNotDetected => l10n.errorDockNotDetected,
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

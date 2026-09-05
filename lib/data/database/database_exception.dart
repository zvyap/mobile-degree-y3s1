enum DatabaseErrorCode {
  notAuthenticated,
  forbidden,
  notFound,
  accountUnavailable,
  bikeUnavailable,
  bikeMaintenance,
  bikeReserved,
  activeRentalExists,
  paymentMethodNotFound,
  rentalPlanUnavailable,
  paymentAuthorizationRequired,
  invalidRentalTransition,
  stationUnavailable,
  stationFull,
  stationQrMismatch,
  outsideReturnZone,
  maxExtensionsReached,
  invalidDistance,
  paymentAlreadyPending,
  invalidPaymentTransition,
  paymentMethodInUse,
  conflict,
  validation,
  unknown,
}

class DatabaseException implements Exception {
  const DatabaseException({
    required this.code,
    required this.message,
    this.cause,
  });

  final DatabaseErrorCode code;
  final String message;
  final Object? cause;

  @override
  String toString() => 'DatabaseException($code, $message)';
}

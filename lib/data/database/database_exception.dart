enum DatabaseErrorCode {
  notAuthenticated,
  forbidden,
  notFound,
  accountUnavailable,
  bikeUnavailable,
  activeRentalExists,
  paymentMethodNotFound,
  rentalPlanUnavailable,
  paymentAuthorizationRequired,
  invalidRentalTransition,
  stationUnavailable,
  stationFull,
  invalidDistance,
  paymentAlreadyPending,
  invalidPaymentTransition,
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

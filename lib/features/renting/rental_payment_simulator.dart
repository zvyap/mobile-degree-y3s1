abstract interface class RentalPaymentSimulator {
  Future<void> authorize(double amount);

  Future<void> capture(double amount);
}

class LocalRentalPaymentSimulator implements RentalPaymentSimulator {
  const LocalRentalPaymentSimulator();

  @override
  Future<void> authorize(double amount) => _delay();

  @override
  Future<void> capture(double amount) => _delay();

  Future<void> _delay() {
    // TODO(payment): Replace this local-only simulator with a server-side
    // payment-provider adapter and webhook-confirmed ledger transitions.
    return Future<void>.delayed(const Duration(milliseconds: 450));
  }
}

class RentalPaymentSimulationException implements Exception {
  const RentalPaymentSimulationException();
}

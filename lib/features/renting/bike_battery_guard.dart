class BikeBatteryGuard {
  const BikeBatteryGuard._();

  static const int minRentalBatteryPercent = 10;
  static const int lowBatteryWarningThreshold = 30;

  static bool isTooLow(int? batteryPercent) =>
      (batteryPercent ?? 0) < minRentalBatteryPercent;

  static bool isWarning(int? batteryPercent) {
    final b = batteryPercent ?? 0;
    return b >= minRentalBatteryPercent && b < lowBatteryWarningThreshold;
  }
}

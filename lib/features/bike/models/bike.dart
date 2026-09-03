class Bike {
  final String id;
  final String code;
  final String qrToken;
  final String? currentStationId;

  final String? stationName;

  final int? batteryPercent;
  final String status;
  final DateTime? lastServiceAt;

  Bike({
    required this.id,
    required this.code,
    required this.qrToken,
    this.currentStationId,
    this.batteryPercent,
    required this.status,
    this.lastServiceAt,
    this.stationName,
  });

  factory Bike.fromJson(Map<String, dynamic> json) {
    return Bike(
      id: json['id'].toString(),
      code: json['code'] ?? '',
      qrToken: json['qr_token'] ?? '',
      currentStationId: json['current_station_id']?.toString(),
      stationName: json['stations']?['name'],
      batteryPercent: json['battery_percent'] as int?,
      status: json['status'] ?? 'unknown',
      lastServiceAt: json['last_service_at'] != null
          ? DateTime.parse(json['last_service_at'])
          : null,
    );
  }


}
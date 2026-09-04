class StationAvailability {
  final int id;
  final String code;
  final String name;
  final String address;
  final int capacity;
  final int availableBikes;
  final int availableDocks;
  final bool isActive;

  const StationAvailability({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.capacity,
    required this.availableBikes,
    required this.availableDocks,
    required this.isActive,
  });

  factory StationAvailability.fromJson(
      Map<String, dynamic> json,
      ) {
    return StationAvailability(
      id: json['id'] as int,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      capacity: json['capacity'] as int,
      availableBikes: json['available_bikes'] as int? ?? 0,
      availableDocks: json['available_docks'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}
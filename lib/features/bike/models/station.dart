class Station {
  final int id;
  final String code;
  final String name;

  const Station({
    required this.id,
    required this.code,
    required this.name,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] as int,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
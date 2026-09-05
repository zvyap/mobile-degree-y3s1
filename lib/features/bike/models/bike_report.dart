class BikeReport {
  final int id;
  final int bikeId;
  final String? reporterId;
  final String category;
  final String description;
  final String status;
  final String? reviewNote;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? stationName;

  // Optional joined bike information
  final String? bikeCode;

  const BikeReport({
    required this.id,
    required this.bikeId,
    this.reporterId,
    required this.category,
    required this.description,
    required this.status,
    this.reviewNote,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
    this.bikeCode,
    this.stationName,
  });

  bool get isActive => status != 'rejected' && status != 'cancelled';

  factory BikeReport.fromJson(Map<String, dynamic> json) {
    return BikeReport(
      id: (json['id'] as num).toInt(),
      bikeId: (json['bike_id'] as num).toInt(),
      reporterId: json['reporter_id']?.toString(),
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      reviewNote: json['review_note'],
      reviewedBy: json['reviewed_by']?.toString(),
      reviewedAt: json['reviewed_at'] == null
          ? null
          : DateTime.parse(json['reviewed_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      bikeCode: json['bikes']?['code'],
      stationName: json['bikes']?['stations']?['name'],
    );
  }
}
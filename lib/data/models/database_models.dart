import 'package:bike_renting_app/data/database/database_data_source.dart';

enum AppUserRole { rider, admin }

enum AccountStatus { active, suspended }

enum BikeDatabaseStatus { available, reserved, inUse, maintenance, retired }

enum RentalDatabaseStatus {
  reserved,
  pendingAuthorization,
  authorized,
  active,
  returning,
  paymentPending,
  paymentFailed,
  completed,
  cancelled,
}

enum RentalPaymentKind { authorization, capture, release, refund }

enum RentalPaymentDatabaseStatus { pending, succeeded, failed, cancelled }

class UserProfileRecord {
  const UserProfileRecord({
    required this.id,
    required this.displayName,
    required this.role,
    required this.accountStatus,
    required this.createdAt,
    required this.updatedAt,
    this.phone,
    this.avatarUrl,
  });

  factory UserProfileRecord.fromJson(JsonMap json) {
    return UserProfileRecord(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: _enumFromDatabase(
        AppUserRole.values,
        json['role'],
        _appUserRoleDatabaseValue,
      ),
      accountStatus: _enumFromDatabase(
        AccountStatus.values,
        json['account_status'],
        (value) => value.name,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String displayName;
  final String? phone;
  final String? avatarUrl;
  final AppUserRole role;
  final AccountStatus accountStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class StationAvailabilityRecord {
  const StationAvailabilityRecord({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.availableBikes,
    required this.availableDocks,
    required this.isActive,
    required this.updatedAt,
  });

  factory StationAvailabilityRecord.fromJson(JsonMap json) {
    return StationAvailabilityRecord(
      id: _asInt(json['id']),
      code: json['code'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      capacity: _asInt(json['capacity']),
      availableBikes: _asInt(json['available_bikes']),
      availableDocks: _asInt(json['available_docks']),
      isActive: json['is_active'] as bool,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final int id;
  final String code;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int capacity;
  final int availableBikes;
  final int availableDocks;
  final bool isActive;
  final DateTime updatedAt;
}

class BikeDatabaseRecord {
  const BikeDatabaseRecord({
    required this.id,
    required this.code,
    required this.qrToken,
    required this.batteryPercent,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.currentStationId,
    this.lastServiceAt,
  });

  factory BikeDatabaseRecord.fromJson(JsonMap json) {
    return BikeDatabaseRecord(
      id: _asInt(json['id']),
      code: json['code'] as String,
      qrToken: json['qr_token'] as String? ?? '',
      currentStationId: _asNullableInt(json['current_station_id']),
      batteryPercent: _asInt(json['battery_percent']),
      status: _enumFromDatabase(
        BikeDatabaseStatus.values,
        json['status'],
        _bikeStatusDatabaseValue,
      ),
      lastServiceAt: _asNullableDateTime(json['last_service_at']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final int id;
  final String code;
  final String qrToken;
  final int? currentStationId;
  final int batteryPercent;
  final BikeDatabaseStatus status;
  final DateTime? lastServiceAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class PaymentMethodRecord {
  const PaymentMethodRecord({
    required this.id,
    required this.userId,
    required this.provider,
    required this.brand,
    required this.lastFour,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    this.expiryMonth,
    this.expiryYear,
  });

  factory PaymentMethodRecord.fromJson(JsonMap json) {
    return PaymentMethodRecord(
      id: _asInt(json['id']),
      userId: json['user_id'] as String,
      provider: json['provider'] as String,
      brand: json['brand'] as String,
      lastFour: json['last_four'] as String,
      expiryMonth: _asNullableInt(json['expiry_month']),
      expiryYear: _asNullableInt(json['expiry_year']),
      isDefault: json['is_default'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final int id;
  final String userId;
  final String provider;
  final String brand;
  final String lastFour;
  final int? expiryMonth;
  final int? expiryYear;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class RentalDatabaseRecord {
  const RentalDatabaseRecord({
    required this.id,
    required this.publicId,
    required this.bikeId,
    required this.rentalPlanId,
    required this.paymentRequired,
    required this.startStationId,
    required this.status,
    required this.currency,
    required this.unlockFee,
    required this.perMinuteRate,
    required this.holdAmount,
    required this.durationSeconds,
    required this.distanceKm,
    required this.chargedMinutes,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.paymentMethodId,
    this.endStationId,
    this.reservationExpiresAt,
    this.authorizedAt,
    this.startedAt,
    this.returnRequestedAt,
    this.endedAt,
    this.cancelledAt,
    this.finalFare,
    this.failureReason,
  });

  factory RentalDatabaseRecord.fromJson(JsonMap json) {
    return RentalDatabaseRecord(
      id: _asInt(json['id']),
      publicId: json['public_id'] as String,
      userId: json['user_id'] as String?,
      bikeId: _asInt(json['bike_id']),
      rentalPlanId: _asInt(json['rental_plan_id']),
      paymentMethodId: _asNullableInt(json['payment_method_id']),
      paymentRequired: json['payment_required'] as bool? ?? true,
      startStationId: _asInt(json['start_station_id']),
      endStationId: _asNullableInt(json['end_station_id']),
      status: _enumFromDatabase(
        RentalDatabaseStatus.values,
        json['status'],
        _rentalStatusDatabaseValue,
      ),
      currency: json['currency'] as String,
      unlockFee: _asDouble(json['unlock_fee']),
      perMinuteRate: _asDouble(json['per_minute_rate']),
      holdAmount: _asDouble(json['hold_amount']),
      reservationExpiresAt: _asNullableDateTime(json['reservation_expires_at']),
      authorizedAt: _asNullableDateTime(json['authorized_at']),
      startedAt: _asNullableDateTime(json['started_at']),
      returnRequestedAt: _asNullableDateTime(json['return_requested_at']),
      endedAt: _asNullableDateTime(json['ended_at']),
      cancelledAt: _asNullableDateTime(json['cancelled_at']),
      durationSeconds: _asInt(json['duration_seconds']),
      distanceKm: _asDouble(json['distance_km']),
      chargedMinutes: _asInt(json['charged_minutes']),
      finalFare: _asNullableDouble(json['final_fare']),
      failureReason: json['failure_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final int id;
  final String publicId;
  final String? userId;
  final int bikeId;
  final int rentalPlanId;
  final int? paymentMethodId;
  final bool paymentRequired;
  final int startStationId;
  final int? endStationId;
  final RentalDatabaseStatus status;
  final String currency;
  final double unlockFee;
  final double perMinuteRate;
  final double holdAmount;
  final DateTime? reservationExpiresAt;
  final DateTime? authorizedAt;
  final DateTime? startedAt;
  final DateTime? returnRequestedAt;
  final DateTime? endedAt;
  final DateTime? cancelledAt;
  final int durationSeconds;
  final double distanceKm;
  final int chargedMinutes;
  final double? finalFare;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class RentalHistoryDatabaseRecord {
  const RentalHistoryDatabaseRecord({
    required this.rental,
    required this.bikeCode,
    required this.startStationName,
    required this.endStationName,
    this.paymentBrand,
    this.paymentLastFour,
  });

  factory RentalHistoryDatabaseRecord.fromJson(JsonMap json) {
    final rental = RentalDatabaseRecord.fromJson(json);
    final bike = _asJsonMap(json['bike'], relationship: 'bike');
    final startStation = _asJsonMap(
      json['start_station'],
      relationship: 'start_station',
    );
    final endStation = _asJsonMap(
      json['end_station'],
      relationship: 'end_station',
    );
    final paymentMethod = json['payment_method'] == null
        ? null
        : _asJsonMap(json['payment_method'], relationship: 'payment_method');

    if (rental.status != RentalDatabaseStatus.completed ||
        rental.startedAt == null ||
        rental.endedAt == null ||
        rental.endStationId == null ||
        rental.finalFare == null) {
      throw const FormatException('Incomplete completed-rental history row');
    }

    return RentalHistoryDatabaseRecord(
      rental: rental,
      bikeCode: bike['code'] as String,
      startStationName: startStation['name'] as String,
      endStationName: endStation['name'] as String,
      paymentBrand: paymentMethod?['brand'] as String?,
      paymentLastFour: paymentMethod?['last_four'] as String?,
    );
  }

  final RentalDatabaseRecord rental;
  final String bikeCode;
  final String startStationName;
  final String endStationName;
  final String? paymentBrand;
  final String? paymentLastFour;
}

class RentalPaymentRecord {
  const RentalPaymentRecord({
    required this.id,
    required this.rentalId,
    required this.kind,
    required this.status,
    required this.amount,
    required this.currency,
    required this.provider,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.providerReference,
    this.failureCode,
    this.failureMessage,
    this.processedAt,
  });

  factory RentalPaymentRecord.fromJson(JsonMap json) {
    return RentalPaymentRecord(
      id: _asInt(json['id']),
      rentalId: _asInt(json['rental_id']),
      userId: json['user_id'] as String?,
      kind: _enumFromDatabase(
        RentalPaymentKind.values,
        json['kind'],
        (value) => value.name,
      ),
      status: _enumFromDatabase(
        RentalPaymentDatabaseStatus.values,
        json['status'],
        (value) => value.name,
      ),
      amount: _asDouble(json['amount']),
      currency: json['currency'] as String,
      provider: json['provider'] as String,
      providerReference: json['provider_reference'] as String?,
      failureCode: json['failure_code'] as String?,
      failureMessage: json['failure_message'] as String?,
      processedAt: _asNullableDateTime(json['processed_at']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final int id;
  final int rentalId;
  final String? userId;
  final RentalPaymentKind kind;
  final RentalPaymentDatabaseStatus status;
  final double amount;
  final String currency;
  final String provider;
  final String? providerReference;
  final String? failureCode;
  final String? failureMessage;
  final DateTime? processedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class RentalEventRecord {
  const RentalEventRecord({
    required this.id,
    required this.rentalId,
    required this.eventType,
    required this.payload,
    required this.createdAt,
    this.userId,
  });

  factory RentalEventRecord.fromJson(JsonMap json) {
    return RentalEventRecord(
      id: _asInt(json['id']),
      rentalId: _asInt(json['rental_id']),
      userId: json['user_id'] as String?,
      eventType: json['event_type'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final int id;
  final int rentalId;
  final String? userId;
  final String eventType;
  final JsonMap payload;
  final DateTime createdAt;
}

T _enumFromDatabase<T extends Enum>(
  List<T> values,
  Object? rawValue,
  String Function(T value) databaseValue,
) {
  final serialized = rawValue as String;
  return values.firstWhere(
    (value) => databaseValue(value) == serialized,
    orElse: () => throw FormatException(
      'Unsupported ${T.toString()} database value: $serialized',
    ),
  );
}

String _appUserRoleDatabaseValue(AppUserRole value) => value.name;

String _bikeStatusDatabaseValue(BikeDatabaseStatus value) => switch (value) {
  BikeDatabaseStatus.inUse => 'in_use',
  _ => value.name,
};

String _rentalStatusDatabaseValue(RentalDatabaseStatus value) {
  return switch (value) {
    RentalDatabaseStatus.pendingAuthorization => 'pending_authorization',
    RentalDatabaseStatus.paymentPending => 'payment_pending',
    RentalDatabaseStatus.paymentFailed => 'payment_failed',
    _ => value.name,
  };
}

int _asInt(Object? value) => switch (value) {
  int number => number,
  num number => number.toInt(),
  String text => int.parse(text),
  _ => throw FormatException('Expected integer, received $value'),
};

int? _asNullableInt(Object? value) => value == null ? null : _asInt(value);

double _asDouble(Object? value) => switch (value) {
  num number => number.toDouble(),
  String text => double.parse(text),
  _ => throw FormatException('Expected decimal, received $value'),
};

double? _asNullableDouble(Object? value) {
  return value == null ? null : _asDouble(value);
}

DateTime? _asNullableDateTime(Object? value) {
  return value == null ? null : DateTime.parse(value as String);
}

JsonMap _asJsonMap(Object? value, {required String relationship}) {
  if (value is Map) return Map<String, dynamic>.from(value);
  throw FormatException('Missing $relationship relationship');
}

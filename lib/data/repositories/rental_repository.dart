import 'package:bike_renting_app/data/database/database_data_source.dart';
import 'package:bike_renting_app/data/database/database_exception.dart';
import 'package:bike_renting_app/data/models/database_models.dart';

class RentalRepository {
  RentalRepository(this._dataSource);

  static const _rentalColumns =
      'id, public_id, user_id, bike_id, rental_plan_id, payment_method_id, '
      'start_station_id, end_station_id, status, currency, unlock_fee, '
      'per_minute_rate, hold_amount, reservation_expires_at, authorized_at, '
      'started_at, return_requested_at, ended_at, cancelled_at, '
      'duration_seconds, distance_km, charged_minutes, final_fare, '
      'failure_reason, created_at, updated_at';

  static const _blockingStatuses = [
    'pending_authorization',
    'authorized',
    'active',
    'returning',
    'payment_pending',
    'payment_failed',
  ];

  final DatabaseDataSource _dataSource;

  Future<RentalDatabaseRecord> reserveBike({
    required String qrToken,
    required int paymentMethodId,
  }) {
    return _callRentalRpc('reserve_bike', {
      'p_qr_token': qrToken,
      'p_payment_method_id': paymentMethodId,
    });
  }

  Future<RentalDatabaseRecord> startRental(int rentalId) {
    return _callRentalRpc('start_rental', {'p_rental_id': rentalId});
  }

  Future<RentalDatabaseRecord> cancelRental(int rentalId) {
    return _callRentalRpc('cancel_rental', {'p_rental_id': rentalId});
  }

  Future<RentalDatabaseRecord> requestReturn({
    required int rentalId,
    required int stationId,
  }) {
    return _callRentalRpc('request_return', {
      'p_rental_id': rentalId,
      'p_station_id': stationId,
    });
  }

  Future<RentalDatabaseRecord> resumeRental(int rentalId) {
    return _callRentalRpc('resume_rental', {'p_rental_id': rentalId});
  }

  Future<RentalDatabaseRecord> completeReturn({
    required int rentalId,
    required double distanceKm,
  }) {
    return _callRentalRpc('complete_return', {
      'p_rental_id': rentalId,
      'p_distance_km': distanceKm,
    });
  }

  Future<RentalDatabaseRecord> requestPaymentRetry(int rentalId) {
    return _callRentalRpc('request_payment_retry', {'p_rental_id': rentalId});
  }

  Future<RentalDatabaseRecord?> getActive() async {
    final userId = _requireUserId();
    final rows = await _dataSource.selectList(
      table: 'rentals',
      columns: _rentalColumns,
      equals: {'user_id': userId},
      includedIn: {'status': _blockingStatuses},
      orderBy: 'created_at',
      ascending: false,
      limit: 1,
    );
    return rows.isEmpty ? null : RentalDatabaseRecord.fromJson(rows.single);
  }

  Future<List<RentalDatabaseRecord>> listHistory({int limit = 50}) async {
    if (limit < 1 || limit > 100) {
      throw const DatabaseException(
        code: DatabaseErrorCode.validation,
        message: 'history_limit_must_be_between_1_and_100',
      );
    }
    final userId = _requireUserId();
    final rows = await _dataSource.selectList(
      table: 'rentals',
      columns: _rentalColumns,
      equals: {'user_id': userId},
      orderBy: 'created_at',
      ascending: false,
      limit: limit,
    );
    return rows.map(RentalDatabaseRecord.fromJson).toList(growable: false);
  }

  Future<RentalDatabaseRecord> _callRentalRpc(
    String functionName,
    JsonMap parameters,
  ) async {
    _requireUserId();
    final json = await _dataSource.rpcSingle(
      functionName,
      parameters: parameters,
    );
    return RentalDatabaseRecord.fromJson(json);
  }

  String _requireUserId() {
    final userId = _dataSource.currentUserId;
    if (userId == null) {
      throw const DatabaseException(
        code: DatabaseErrorCode.notAuthenticated,
        message: 'not_authenticated',
      );
    }
    return userId;
  }
}

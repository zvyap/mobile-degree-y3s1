import 'package:bike_renting_app/data/database/database_data_source.dart';
import 'package:bike_renting_app/data/database/database_exception.dart';
import 'package:bike_renting_app/data/models/admin_rental_session.dart';
import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/data/models/rental_session_snapshot.dart';
import 'package:bike_renting_app/data/repositories/bike_repository.dart';
import 'package:bike_renting_app/data/repositories/profile_repository.dart';
import 'package:bike_renting_app/data/repositories/station_repository.dart';

abstract interface class RentalSessionRepository {
  Future<List<StationAvailabilityRecord>> listReturnStations();

  Future<RentalSessionSnapshot?> restoreActive();

  Future<RentalSessionSnapshot> reserveSession(String qrToken);

  Future<RentalSessionSnapshot> startSession(int rentalId);

  Future<void> cancelSession(int rentalId);

  Future<RentalSessionSnapshot> requestSessionReturn({
    required int rentalId,
    required int stationId,
    required double latitude,
    required double longitude,
    String? stationQrToken,
  });

  Future<RentalSessionSnapshot> resumeSession(int rentalId);

  Future<RentalSessionSnapshot> completeSession({
    required int rentalId,
    required double distanceKm,
  });

  Future<void> sweepDeadlines();

  Future<RentalSessionSnapshot> extendRental(int rentalId);

  Future<BikeDatabaseRecord?> getBike(int bikeId);

  Future<BikeDatabaseRecord?> findBikeByQrToken(String qrToken);

  Future<StationAvailabilityRecord?> getStation(int stationId);

  Future<RentalDatabaseRecord?> getRental(int rentalId);

  Future<List<AdminRentalSession>> listActiveRentals({bool includeEnded = false});

  Future<AdminRentalSession> getRentalSessionDetails(int rentalId);

  Future<RentalDatabaseRecord> adminForceEndRental(int rentalId);
}

/// Debug-only escape hatch for the camera-less debug scan stage. Remove
/// together with the debug bike picker once camera scanning ships.
abstract interface class DebugRentBikeSource {
  Future<List<BikeDatabaseRecord>> listAllBikes();
}

class RentalRepository
    implements RentalSessionRepository, DebugRentBikeSource {
  RentalRepository(this._dataSource)
    : _bikes = BikeRepository(_dataSource),
      _stations = StationRepository(_dataSource),
      _profiles = ProfileRepository(_dataSource);

  static const _rentalColumns =
      'id, public_id, user_id, bike_id, rental_plan_id, payment_method_id, '
      'payment_required, '
      'start_station_id, end_station_id, status, currency, unlock_fee, '
      'per_minute_rate, hold_amount, reservation_expires_at, authorized_at, '
      'started_at, return_requested_at, ended_at, cancelled_at, '
      'duration_seconds, distance_km, charged_minutes, final_fare, '
      'failure_reason, ride_deadline_at, overdue_at, extensions_used, '
      'created_at, updated_at';

  static const _historyColumns =
      '$_rentalColumns, '
      'bike:bikes!rentals_bike_id_fkey(code), '
      'start_station:stations!rentals_start_station_id_fkey(name), '
      'end_station:stations!rentals_end_station_id_fkey(name), '
      'payment_method:payment_methods!rentals_payment_method_id_fkey('
      'brand, last_four)';

  static const _blockingStatuses = [
    'reserved',
    'pending_authorization',
    'authorized',
    'active',
    'returning',
    'payment_pending',
    'payment_failed',
  ];

  final DatabaseDataSource _dataSource;
  final BikeRepository _bikes;
  final StationRepository _stations;
  final ProfileRepository _profiles;

  @override
  Future<StationAvailabilityRecord?> getStation(int stationId) {
    return _stations.findById(stationId);
  }

  @override
  Future<List<StationAvailabilityRecord>> listReturnStations() {
    return _stations.listAvailability();
  }

  @override
  Future<RentalSessionSnapshot?> restoreActive() async {
    final rental = await getActive();
    return rental == null ? null : _hydrate(rental);
  }

  @override
  Future<RentalSessionSnapshot> reserveSession(String qrToken) async {
    final rental = await _callRentalRpc('reserve_rental_session', {
      'p_qr_token': qrToken,
    });
    return _hydrate(rental);
  }

  @override
  Future<RentalSessionSnapshot> startSession(int rentalId) async {
    return _hydrate(await startRental(rentalId));
  }

  @override
  Future<void> cancelSession(int rentalId) async {
    await cancelRental(rentalId);
  }

  @override
  Future<RentalSessionSnapshot> requestSessionReturn({
    required int rentalId,
    required int stationId,
    required double latitude,
    required double longitude,
    String? stationQrToken,
  }) async {
    return _hydrate(
      await requestReturn(
        rentalId: rentalId,
        stationId: stationId,
        latitude: latitude,
        longitude: longitude,
        stationQrToken: stationQrToken,
      ),
    );
  }

  @override
  Future<RentalSessionSnapshot> resumeSession(int rentalId) async {
    return _hydrate(await resumeRental(rentalId));
  }

  @override
  Future<RentalSessionSnapshot> completeSession({
    required int rentalId,
    required double distanceKm,
  }) async {
    return _hydrate(
      await completeReturn(rentalId: rentalId, distanceKm: distanceKm),
    );
  }

  @override
  Future<void> sweepDeadlines() async {
    await _dataSource.rpcSingle('sweep_rental_deadlines');
  }

  @override
  Future<RentalSessionSnapshot> extendRental(int rentalId) async {
    return _hydrate(await _callRentalRpc('extend_rental', {
      'p_rental_id': rentalId,
    }));
  }

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
    required double latitude,
    required double longitude,
    String? stationQrToken,
  }) {
    return _callRentalRpc('request_return', {
      'p_rental_id': rentalId,
      'p_station_id': stationId,
      'p_latitude': latitude,
      'p_longitude': longitude,
      'p_station_qr_token': (stationQrToken != null && stationQrToken.isNotEmpty)
          ? stationQrToken
          : null,
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

  @override
  Future<List<BikeDatabaseRecord>> listAllBikes() => _bikes.listBikes();

  @override
  Future<BikeDatabaseRecord?> getBike(int bikeId) => _bikes.findById(bikeId);

  @override
  Future<BikeDatabaseRecord?> findBikeByQrToken(String qrToken) =>
      _bikes.findByQrToken(qrToken);

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

  Future<List<RentalHistoryDatabaseRecord>> listHistory({
    int limit = 50,
  }) async {
    if (limit < 1 || limit > 100) {
      throw const DatabaseException(
        code: DatabaseErrorCode.validation,
        message: 'history_limit_must_be_between_1_and_100',
      );
    }
    final userId = _requireUserId();
    final rows = await _dataSource.selectList(
      table: 'rentals',
      columns: _historyColumns,
      equals: {'user_id': userId, 'status': 'completed'},
      orderBy: 'created_at',
      ascending: false,
      limit: limit,
    );
    return rows
        .map(RentalHistoryDatabaseRecord.fromJson)
        .toList(growable: false);
  }

  Future<RentalSessionSnapshot> _hydrate(RentalDatabaseRecord rental) async {
    final results = await Future.wait<Object?>([
      _bikes.findById(rental.bikeId),
      _stations.findById(rental.startStationId),
      if (rental.endStationId == null)
        Future<StationAvailabilityRecord?>.value()
      else
        _stations.findById(rental.endStationId!),
    ]);
    final bike = results[0] as BikeDatabaseRecord?;
    final startStation = results[1] as StationAvailabilityRecord?;
    final endStation = results[2] as StationAvailabilityRecord?;

    if (bike == null || startStation == null) {
      throw const DatabaseException(
        code: DatabaseErrorCode.notFound,
        message: 'rental_session_details_not_found',
      );
    }
    return RentalSessionSnapshot(
      rental: rental,
      bike: bike,
      startStation: startStation,
      endStation: endStation,
    );
  }

  @override
  Future<RentalDatabaseRecord?> getRental(int rentalId) async {
    final rows = await _dataSource.selectList(
      table: 'rentals',
      columns: _rentalColumns,
      equals: {'id': rentalId},
      limit: 1,
    );
    return rows.isEmpty ? null : RentalDatabaseRecord.fromJson(rows.single);
  }

  @override
  Future<List<AdminRentalSession>> listActiveRentals({
    bool includeEnded = false,
  }) async {
    final rows = await _dataSource.selectList(
      table: 'rentals',
      columns: _rentalColumns,
      includedIn: includeEnded ? const {} : {'status': _blockingStatuses},
      orderBy: 'created_at',
      ascending: false,
      limit: includeEnded ? 100 : null,
    );
    final rentals = rows.map(RentalDatabaseRecord.fromJson).toList();
    return Future.wait(rentals.map(_hydrateAdminSession));
  }

  @override
  Future<AdminRentalSession> getRentalSessionDetails(int rentalId) async {
    final row = await _dataSource.selectMaybeSingle(
      table: 'rentals',
      columns: _rentalColumns,
      equals: {'id': rentalId},
    );
    if (row == null) {
      throw const DatabaseException(
        code: DatabaseErrorCode.notFound,
        message: 'rental_not_found',
      );
    }
    return _hydrateAdminSession(RentalDatabaseRecord.fromJson(row));
  }

  @override
  Future<RentalDatabaseRecord> adminForceEndRental(int rentalId) async {
    return _callRentalRpc('force_end_rental', {
      'p_rental_id': rentalId,
    });
  }

  Future<AdminRentalSession> _hydrateAdminSession(RentalDatabaseRecord rental) async {
    final results = await Future.wait<Object?>([
      _bikes.findById(rental.bikeId).catchError((_) => null),
      _stations.findById(rental.startStationId).catchError((_) => null),
      if (rental.endStationId == null)
        Future<StationAvailabilityRecord?>.value()
      else
        _stations.findById(rental.endStationId!).catchError((_) => null),
      if (rental.userId == null)
        Future<UserProfileRecord?>.value()
      else
        _profiles.findById(rental.userId!).catchError((_) => null),
    ]);
    return AdminRentalSession(
      rental: rental,
      bike: results[0] as BikeDatabaseRecord?,
      startStation: results[1] as StationAvailabilityRecord?,
      endStation: results[2] as StationAvailabilityRecord?,
      user: results[3] as UserProfileRecord?,
    );
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

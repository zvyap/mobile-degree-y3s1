import 'package:bike_renting_app/data/database/database_data_source.dart';
import 'package:bike_renting_app/data/database/database_exception.dart';
import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/data/repositories/profile_repository.dart';
import 'package:bike_renting_app/data/repositories/rental_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('database models', () {
    test('maps snake case rental values and numeric strings', () {
      final rental = RentalDatabaseRecord.fromJson(
        _rentalJson(status: 'payment_pending'),
      );

      expect(rental.status, RentalDatabaseStatus.paymentPending);
      expect(rental.unlockFee, 0.5);
      expect(rental.distanceKm, 1.25);
      expect(rental.finalFare, 0.7);
    });

    test('rejects unsupported enum values', () {
      expect(
        () => RentalDatabaseRecord.fromJson(
          _rentalJson(status: 'unknown_status'),
        ),
        throwsFormatException,
      );
    });
  });

  group('RentalRepository', () {
    test('sends reserve bike through RPC and maps result', () async {
      final dataSource = _FakeDataSource(
        userId: 'user-1',
        rpcResult: _rentalJson(status: 'pending_authorization'),
      );
      final repository = RentalRepository(dataSource);

      final rental = await repository.reserveBike(
        qrToken: 'bike-token',
        paymentMethodId: 4,
      );

      expect(rental.status, RentalDatabaseStatus.pendingAuthorization);
      expect(dataSource.lastRpcName, 'reserve_bike');
      expect(dataSource.lastRpcParameters, {
        'p_qr_token': 'bike-token',
        'p_payment_method_id': 4,
      });
    });

    test('blocks calls before reaching database when signed out', () async {
      final dataSource = _FakeDataSource(
        rpcResult: _rentalJson(status: 'pending_authorization'),
      );
      final repository = RentalRepository(dataSource);

      await expectLater(
        repository.startRental(1),
        throwsA(
          isA<DatabaseException>().having(
            (error) => error.code,
            'code',
            DatabaseErrorCode.notAuthenticated,
          ),
        ),
      );
      expect(dataSource.lastRpcName, isNull);
    });

    test('validates history page size', () async {
      final repository = RentalRepository(
        _FakeDataSource(userId: 'user-1', rpcResult: const {}),
      );

      await expectLater(
        repository.listHistory(limit: 101),
        throwsA(
          isA<DatabaseException>().having(
            (error) => error.code,
            'code',
            DatabaseErrorCode.validation,
          ),
        ),
      );
    });

    test('returns current blocking rental from filtered query', () async {
      final repository = RentalRepository(
        _FakeDataSource(
          userId: 'user-1',
          rpcResult: const {},
          selectRows: [_rentalJson(status: 'active')],
        ),
      );

      final rental = await repository.getActive();

      expect(rental?.status, RentalDatabaseStatus.active);
    });
  });

  test('ProfileRepository only writes safe profile fields', () async {
    final dataSource = _FakeDataSource(
      userId: 'user-1',
      rpcResult: const {},
      updateResult: {
        'id': 'user-1',
        'display_name': 'Rider',
        'phone': null,
        'avatar_url': null,
        'role': 'rider',
        'account_status': 'active',
        'created_at': '2026-07-31T00:00:00Z',
        'updated_at': '2026-07-31T00:00:00Z',
      },
    );
    final repository = ProfileRepository(dataSource);

    final profile = await repository.updateOwn(displayName: ' Rider ');

    expect(profile.displayName, 'Rider');
    expect(dataSource.lastUpdateValues, {
      'display_name': 'Rider',
      'phone': null,
      'avatar_url': null,
    });
    expect(dataSource.lastUpdateValues, isNot(contains('role')));
  });

  test('ProfileRepository maps current user profile', () async {
    final dataSource = _FakeDataSource(
      userId: 'user-1',
      rpcResult: const {},
      singleResult: {
        'id': 'user-1',
        'display_name': 'Rider',
        'phone': null,
        'avatar_url': null,
        'role': 'rider',
        'account_status': 'active',
        'created_at': '2026-07-31T00:00:00Z',
        'updated_at': '2026-07-31T00:00:00Z',
      },
    );

    final profile = await ProfileRepository(dataSource).getCurrent();

    expect(profile.id, 'user-1');
    expect(profile.role, AppUserRole.rider);
  });
}

JsonMap _rentalJson({required String status}) {
  return {
    'id': 1,
    'public_id': '40000000-0000-4000-8000-000000000004',
    'user_id': 'user-1',
    'bike_id': 2,
    'rental_plan_id': 3,
    'payment_method_id': 4,
    'start_station_id': 5,
    'end_station_id': 6,
    'status': status,
    'currency': 'MYR',
    'unlock_fee': '0.50',
    'per_minute_rate': '0.10',
    'hold_amount': '20.00',
    'reservation_expires_at': null,
    'authorized_at': '2026-07-31T00:00:00Z',
    'started_at': '2026-07-31T00:00:01Z',
    'return_requested_at': '2026-07-31T00:01:00Z',
    'ended_at': '2026-07-31T00:01:02Z',
    'cancelled_at': null,
    'duration_seconds': 61,
    'distance_km': '1.250',
    'charged_minutes': 2,
    'final_fare': '0.70',
    'failure_reason': null,
    'created_at': '2026-07-31T00:00:00Z',
    'updated_at': '2026-07-31T00:01:02Z',
  };
}

class _FakeDataSource implements DatabaseDataSource {
  _FakeDataSource({
    this.userId,
    required this.rpcResult,
    this.updateResult,
    this.selectRows = const [],
    this.singleResult,
  });

  final String? userId;
  final JsonMap rpcResult;
  final JsonMap? updateResult;
  final List<JsonMap> selectRows;
  final JsonMap? singleResult;

  String? lastRpcName;
  JsonMap? lastRpcParameters;
  JsonMap? lastUpdateValues;

  @override
  String? get currentUserId => userId;

  @override
  Future<JsonMap> rpcSingle(
    String functionName, {
    JsonMap parameters = const {},
  }) async {
    lastRpcName = functionName;
    lastRpcParameters = parameters;
    return rpcResult;
  }

  @override
  Future<List<JsonMap>> selectList({
    required String table,
    required String columns,
    Map<String, Object?> equals = const {},
    Map<String, List<Object>> includedIn = const {},
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    return selectRows;
  }

  @override
  Future<JsonMap?> selectMaybeSingle({
    required String table,
    required String columns,
    Map<String, Object?> equals = const {},
  }) async {
    return singleResult;
  }

  @override
  Future<JsonMap> updateSingle({
    required String table,
    required JsonMap values,
    required Map<String, Object?> equals,
    required String columns,
  }) async {
    lastUpdateValues = values;
    return updateResult!;
  }
}

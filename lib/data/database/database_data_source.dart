import 'package:bike_renting_app/data/database/database_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef JsonMap = Map<String, dynamic>;

abstract interface class DatabaseDataSource {
  String? get currentUserId;

  Future<List<JsonMap>> selectList({
    required String table,
    required String columns,
    Map<String, Object?> equals = const {},
    Map<String, List<Object>> includedIn = const {},
    String? orderBy,
    bool ascending = true,
    int? limit,
  });

  Future<JsonMap?> selectMaybeSingle({
    required String table,
    required String columns,
    Map<String, Object?> equals = const {},
  });

  Future<JsonMap> updateSingle({
    required String table,
    required JsonMap values,
    required Map<String, Object?> equals,
    required String columns,
  });

  Future<JsonMap> rpcSingle(
    String functionName, {
    JsonMap parameters = const {},
  });
}

class SupabaseDatabaseDataSource implements DatabaseDataSource {
  SupabaseDatabaseDataSource(this._client);

  final SupabaseClient _client;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

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
    try {
      dynamic query = _client.from(table).select(columns);
      for (final entry in equals.entries) {
        query = query.eq(entry.key, entry.value);
      }
      for (final entry in includedIn.entries) {
        query = query.inFilter(entry.key, entry.value);
      }
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }
      if (limit != null) {
        query = query.limit(limit);
      }
      final response = await query;
      return (response as List<dynamic>).cast<JsonMap>();
    } on PostgrestException catch (error) {
      throw _mapPostgrestError(error);
    }
  }

  @override
  Future<JsonMap?> selectMaybeSingle({
    required String table,
    required String columns,
    Map<String, Object?> equals = const {},
  }) async {
    try {
      dynamic query = _client.from(table).select(columns);
      for (final entry in equals.entries) {
        query = query.eq(entry.key, entry.value);
      }
      final response = await query.maybeSingle();
      return response == null ? null : Map<String, dynamic>.from(response);
    } on PostgrestException catch (error) {
      throw _mapPostgrestError(error);
    }
  }

  @override
  Future<JsonMap> updateSingle({
    required String table,
    required JsonMap values,
    required Map<String, Object?> equals,
    required String columns,
  }) async {
    try {
      dynamic query = _client.from(table).update(values);
      for (final entry in equals.entries) {
        query = query.eq(entry.key, entry.value);
      }
      final response = await query.select(columns).single();
      return Map<String, dynamic>.from(response);
    } on PostgrestException catch (error) {
      throw _mapPostgrestError(error);
    }
  }

  @override
  Future<JsonMap> rpcSingle(
    String functionName, {
    JsonMap parameters = const {},
  }) async {
    try {
      final response = await _client
          .rpc(functionName, params: parameters)
          .single();
      return Map<String, dynamic>.from(response);
    } on PostgrestException catch (error) {
      throw _mapPostgrestError(error);
    }
  }

  DatabaseException _mapPostgrestError(PostgrestException error) {
    final normalized = error.message.trim().toLowerCase();
    final applicationCode = switch (normalized) {
      'not_authenticated' => DatabaseErrorCode.notAuthenticated,
      'account_unavailable' => DatabaseErrorCode.accountUnavailable,
      'bike_not_found' ||
      'rental_not_found' ||
      'payment_not_found' => DatabaseErrorCode.notFound,
      'bike_unavailable' => DatabaseErrorCode.bikeUnavailable,
      'active_rental_exists' => DatabaseErrorCode.activeRentalExists,
      'payment_method_not_found' => DatabaseErrorCode.paymentMethodNotFound,
      'rental_plan_unavailable' => DatabaseErrorCode.rentalPlanUnavailable,
      'payment_authorization_required' =>
        DatabaseErrorCode.paymentAuthorizationRequired,
      'invalid_rental_transition' => DatabaseErrorCode.invalidRentalTransition,
      'station_unavailable' => DatabaseErrorCode.stationUnavailable,
      'station_full' => DatabaseErrorCode.stationFull,
      'invalid_distance' => DatabaseErrorCode.invalidDistance,
      'payment_already_pending' => DatabaseErrorCode.paymentAlreadyPending,
      'invalid_payment_transition' =>
        DatabaseErrorCode.invalidPaymentTransition,
      _ when error.code == '42501' => DatabaseErrorCode.forbidden,
      _ when error.code == '23505' => DatabaseErrorCode.conflict,
      _ when error.code == '23514' || error.code == '22P02' =>
        DatabaseErrorCode.validation,
      _ => DatabaseErrorCode.unknown,
    };
    return DatabaseException(
      code: applicationCode,
      message: error.message,
      cause: error,
    );
  }
}

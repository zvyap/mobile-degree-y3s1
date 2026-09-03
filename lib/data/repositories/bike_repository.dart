import 'package:bike_renting_app/data/database/database_data_source.dart';
import 'package:bike_renting_app/data/models/database_models.dart';

class BikeRepository {
  BikeRepository(this._dataSource);

  static const _columns =
      'id, code, qr_token, current_station_id, battery_percent, status, '
      'last_service_at, created_at, updated_at';
  static const _riderColumns =
      'id, code, current_station_id, battery_percent, status, '
      'last_service_at, created_at, updated_at';

  final DatabaseDataSource _dataSource;

  Future<BikeDatabaseRecord?> findByQrToken(String qrToken) async {
    final json = await _dataSource.selectMaybeSingle(
      table: 'bikes',
      columns: _columns,
      equals: {'qr_token': qrToken},
    );
    return json == null ? null : BikeDatabaseRecord.fromJson(json);
  }

  /// DEBUG ONLY: every bike regardless of status, with qr tokens so the debug
  /// scan picker can reserve the chosen bike through the normal token flow.
  Future<List<BikeDatabaseRecord>> listBikes() async {
    final json = await _dataSource.selectList(
      table: 'bikes',
      columns: _columns,
      orderBy: 'code',
    );
    return json.map(BikeDatabaseRecord.fromJson).toList(growable: false);
  }

  Future<BikeDatabaseRecord?> findById(int id) async {
    final json = await _dataSource.selectMaybeSingle(
      table: 'bikes',
      columns: _riderColumns,
      equals: {'id': id},
    );
    return json == null ? null : BikeDatabaseRecord.fromJson(json);
  }
}

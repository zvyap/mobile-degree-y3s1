import 'package:bike_renting_app/data/database/database_data_source.dart';
import 'package:bike_renting_app/data/models/database_models.dart';

class StationRepository {
  StationRepository(this._dataSource);

  static const _columns =
      'id, code, name, address, latitude, longitude, capacity, qr_token, '
      'available_bikes, available_docks, is_active, updated_at';

  final DatabaseDataSource _dataSource;

  Future<List<StationAvailabilityRecord>> listAvailability({
    bool activeOnly = true,
  }) async {
    final rows = await _dataSource.selectList(
      table: 'station_availability',
      columns: _columns,
      equals: activeOnly ? const {'is_active': true} : const {},
      orderBy: 'name',
    );

    final statusMap = <int, String>{};
    try {
      final stationRows = await _dataSource.selectList(
        table: 'stations',
        columns: 'id, status',
        equals: activeOnly ? const {'is_active': true} : const {},
      );
      for (final r in stationRows) {
        final id = r['id'] as int?;
        final status = r['status'] as String?;
        if (id != null && status != null) {
          statusMap[id] = status;
        }
      }
    } catch (_) {}

    return rows.map((json) {
      final record = StationAvailabilityRecord.fromJson(json);
      if (statusMap.containsKey(record.id)) {
        return record.copyWith(status: statusMap[record.id]);
      }
      return record;
    }).toList(growable: false);
  }

  Future<StationAvailabilityRecord?> findById(int id) async {
    final json = await _dataSource.selectMaybeSingle(
      table: 'station_availability',
      columns: _columns,
      equals: {'id': id},
    );
    if (json == null) return null;
    var record = StationAvailabilityRecord.fromJson(json);
    try {
      final stationJson = await _dataSource.selectMaybeSingle(
        table: 'stations',
        columns: 'id, status',
        equals: {'id': id},
      );
      if (stationJson != null && stationJson['status'] != null) {
        record = record.copyWith(status: stationJson['status'] as String);
      }
    } catch (_) {}
    return record;
  }
}

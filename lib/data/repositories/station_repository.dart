import 'package:bike_renting_app/data/database/database_data_source.dart';
import 'package:bike_renting_app/data/models/database_models.dart';

class StationRepository {
  StationRepository(this._dataSource);

  static const _columns =
      'id, code, name, address, latitude, longitude, capacity, '
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
    return rows.map(StationAvailabilityRecord.fromJson).toList(growable: false);
  }
}

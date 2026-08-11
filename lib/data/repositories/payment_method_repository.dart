import 'package:bike_renting_app/data/database/database_data_source.dart';
import 'package:bike_renting_app/data/database/database_exception.dart';
import 'package:bike_renting_app/data/models/database_models.dart';

class PaymentMethodRepository {
  PaymentMethodRepository(this._dataSource);

  static const _columns =
      'id, user_id, provider, brand, last_four, expiry_month, expiry_year, '
      'is_default, created_at, updated_at';

  final DatabaseDataSource _dataSource;

  Future<List<PaymentMethodRecord>> listOwn() async {
    final userId = _dataSource.currentUserId;
    if (userId == null) {
      throw const DatabaseException(
        code: DatabaseErrorCode.notAuthenticated,
        message: 'not_authenticated',
      );
    }
    final rows = await _dataSource.selectList(
      table: 'payment_methods',
      columns: _columns,
      equals: {'user_id': userId},
      orderBy: 'created_at',
      ascending: false,
    );
    return rows.map(PaymentMethodRecord.fromJson).toList(growable: false);
  }
}

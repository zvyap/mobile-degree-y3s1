import 'package:bike_renting_app/data/database/database_data_source.dart';
import 'package:bike_renting_app/data/database/database_exception.dart';
import 'package:bike_renting_app/data/models/database_models.dart';

class PaymentMethodRepository {
  PaymentMethodRepository(this._dataSource);

  static const _columns =
      'id, user_id, provider, brand, last_four, cardholder_name, expiry_month, expiry_year, '
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

  Future<PaymentMethodRecord> createCard({
    required String brand,
    required String lastFour,
    required int expiryMonth,
    required int expiryYear,
    String? cardholderName,
    bool isDefault = false,
  }) async {
    final userId = _dataSource.currentUserId;
    if (userId == null) {
      throw const DatabaseException(
        code: DatabaseErrorCode.notAuthenticated,
        message: 'not_authenticated',
      );
    }

    final trimmedName = cardholderName?.trim();
    final token = 'pm_${userId.substring(0, userId.length > 8 ? 8 : userId.length)}_${DateTime.now().microsecondsSinceEpoch}';

    final row = await _dataSource.insertSingle(
      table: 'payment_methods',
      columns: _columns,
      values: {
        'user_id': userId,
        'provider': 'card',
        'provider_token': token,
        'brand': brand,
        'last_four': lastFour,
        'cardholder_name': (trimmedName != null && trimmedName.isNotEmpty) ? trimmedName : null,
        'expiry_month': expiryMonth,
        'expiry_year': expiryYear,
        'is_default': isDefault,
      },
    );

    return PaymentMethodRecord.fromJson(row);
  }

  Future<PaymentMethodRecord> updateCard({
    required int id,
    String? cardholderName,
    int? expiryMonth,
    int? expiryYear,
    bool? isDefault,
  }) async {
    final userId = _dataSource.currentUserId;
    if (userId == null) {
      throw const DatabaseException(
        code: DatabaseErrorCode.notAuthenticated,
        message: 'not_authenticated',
      );
    }

    final values = <String, Object?>{};
    if (cardholderName != null) {
      final trimmed = cardholderName.trim();
      values['cardholder_name'] = trimmed.isNotEmpty ? trimmed : null;
    }
    if (expiryMonth != null) {
      values['expiry_month'] = expiryMonth;
    }
    if (expiryYear != null) {
      values['expiry_year'] = expiryYear;
    }
    if (isDefault != null) {
      values['is_default'] = isDefault;
    }

    if (values.isEmpty) {
      throw const DatabaseException(
        code: DatabaseErrorCode.validation,
        message: 'no_fields_to_update',
      );
    }

    final row = await _dataSource.updateSingle(
      table: 'payment_methods',
      columns: _columns,
      values: values,
      equals: {'id': id, 'user_id': userId},
    );

    return PaymentMethodRecord.fromJson(row);
  }

  Future<PaymentMethodRecord> setDefault(int id) async {
    return updateCard(id: id, isDefault: true);
  }

  Future<void> deleteCard(int id) async {
    final userId = _dataSource.currentUserId;
    if (userId == null) {
      throw const DatabaseException(
        code: DatabaseErrorCode.notAuthenticated,
        message: 'not_authenticated',
      );
    }

    await _dataSource.deleteSingle(
      table: 'payment_methods',
      equals: {'id': id, 'user_id': userId},
    );
  }
}

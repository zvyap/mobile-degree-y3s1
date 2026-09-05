import 'package:bike_renting_app/data/database/database_data_source.dart';
import 'package:bike_renting_app/data/database/database_exception.dart';
import 'package:bike_renting_app/data/models/database_models.dart';

class ProfileRepository {
  ProfileRepository(this._dataSource);

  static const _columns =
      'id, display_name, phone, avatar_url, role, account_status, '
      'created_at, updated_at';

  final DatabaseDataSource _dataSource;

  Future<UserProfileRecord> getCurrent() async {
    final userId = _requireUserId();
    final json = await _dataSource.selectMaybeSingle(
      table: 'profiles',
      columns: _columns,
      equals: {'id': userId},
    );
    if (json == null) {
      throw const DatabaseException(
        code: DatabaseErrorCode.notFound,
        message: 'profile_not_found',
      );
    }
    return UserProfileRecord.fromJson(json);
  }

  Future<UserProfileRecord> updateOwn({
    required String displayName,
    String? phone,
    String? avatarUrl,
  }) async {
    final userId = _requireUserId();
    final json = await _dataSource.updateSingle(
      table: 'profiles',
      values: {
        'display_name': displayName.trim(),
        'phone': phone,
        'avatar_url': avatarUrl,
      },
      equals: {'id': userId},
      columns: _columns,
    );
    return UserProfileRecord.fromJson(json);
  }

  Future<UserProfileRecord?> findById(String userId) async {
    final json = await _dataSource.selectMaybeSingle(
      table: 'profiles',
      columns: _columns,
      equals: {'id': userId},
    );
    return json == null ? null : UserProfileRecord.fromJson(json);
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

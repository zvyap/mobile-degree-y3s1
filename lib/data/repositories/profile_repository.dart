import 'package:bike_renting_app/data/database/database_data_source.dart';
import 'package:bike_renting_app/data/database/database_exception.dart';
import 'package:bike_renting_app/data/models/database_models.dart';


class ProfileRepository {
  ProfileRepository(this._dataSource);

  static const _columns =
      'id, display_name, phone, avatar_url, role, account_status, '
      'ic_number, ic_verified, created_at, updated_at';

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
    String? icNumber,
  }) async {
    final userId = _requireUserId();
    final json = await _dataSource.updateSingle(
      table: 'profiles',
      values: {
        'display_name': displayName.trim(),
        'phone': phone,
        'avatar_url': avatarUrl,
        'ic_number': icNumber,
      },
      equals: {'id': userId},
      columns: _columns,
    );
    return UserProfileRecord.fromJson(json);
  }

  Future<UserProfileRecord> verifyIc() async {
    final userId = _requireUserId();

    final json = await _dataSource.updateSingle(
      table: 'profiles',
      values: {
        'ic_verified': true,
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

  // admin methods
  Future<List<UserProfileRecord>> getAllUsers() async {
    final jsonList = await _dataSource.selectList(
      table: 'profiles',
      columns: _columns,
      orderBy: 'created_at',
      ascending: false,
    );

    return jsonList
        .map((json) => UserProfileRecord.fromJson(json))
        .toList();
  }

  Future<UserProfileRecord> updateUser({
    required String userId,
    required String displayName,
    String? phone,
    String? avatarUrl,
    String? icNumber,
    AppUserRole? role,
    AccountStatus? accountStatus,

    // TODO: Add IC fields after database migration.
    // String? icNumber,
    // bool? icVerified,
  }) async {
    final values = <String, dynamic>{
      'display_name': displayName.trim(),
      'phone': phone,
      'ic_number': icNumber,
    };

    if (avatarUrl != null) {
      values['avatar_url'] = avatarUrl;
    }

    if (role != null) {
      values['role'] = role.name;
    }

    if (accountStatus != null) {
      values['account_status'] = accountStatus.name;
    }

    // TODO: Add IC fields after database migration.
    // values['ic_number'] = icNumber;
    // values['ic_verified'] = icVerified;

    final json = await _dataSource.updateSingle(
      table: 'profiles',
      values: values,
      equals: {'id': userId},
      columns: _columns,
    );

    return UserProfileRecord.fromJson(json);
  }

  Future<void> deleteUser(String userId) async {
    await _dataSource.deleteSingle(
      table: 'profiles',
      equals: {'id': userId},
    );
  }

}

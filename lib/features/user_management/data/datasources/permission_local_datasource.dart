import '../../../../core/database/app_database.dart';
import '../models/permission_model.dart';

abstract class PermissionLocalDataSource {
  Future<PermissionModel?> getUserPermission(String userId);
}

class PermissionLocalDataSourceImpl implements PermissionLocalDataSource {
  final AppDatabase db;

  PermissionLocalDataSourceImpl({required this.db});

  @override
  Future<PermissionModel?> getUserPermission(String userId) async {
    final query = db.select(db.permissions)
      ..where((tbl) => tbl.userId.equals(userId));
    final perm = await query.getSingleOrNull();
    if (perm != null) {
      return PermissionModel.fromDrift(perm);
    }
    return null;
  }
}

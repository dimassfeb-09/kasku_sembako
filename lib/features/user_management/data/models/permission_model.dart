import '../../../../core/database/app_database.dart';
import '../../domain/entities/permission_entity.dart';

class PermissionModel extends PermissionEntity {
  const PermissionModel({
    required super.id,
    required super.userId,
    required super.menuProduct,
    required super.menuStock,
    required super.menuReport,
    required super.actionVoid,
  });

  factory PermissionModel.fromDrift(Permission perm) {
    return PermissionModel(
      id: perm.id,
      userId: perm.userId,
      menuProduct: perm.menuProduct,
      menuStock: perm.menuStock,
      menuReport: perm.menuReport,
      actionVoid: perm.actionVoid,
    );
  }
}

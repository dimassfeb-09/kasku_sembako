import 'package:equatable/equatable.dart';

class PermissionEntity extends Equatable {
  final String id;
  final String userId;
  final bool menuProduct;
  final bool menuStock;
  final bool menuReport;
  final bool actionVoid;

  const PermissionEntity({
    required this.id,
    required this.userId,
    required this.menuProduct,
    required this.menuStock,
    required this.menuReport,
    required this.actionVoid,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        menuProduct,
        menuStock,
        menuReport,
        actionVoid,
      ];
}

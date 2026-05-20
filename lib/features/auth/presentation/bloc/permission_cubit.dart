import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/permission_entity.dart';
import '../../domain/usecases/get_user_permission_usecase.dart';

abstract class PermissionState extends Equatable {
  const PermissionState();
  @override
  List<Object?> get props => [];
}

class PermissionInitial extends PermissionState {}

class PermissionLoading extends PermissionState {}

class PermissionLoaded extends PermissionState {
  final PermissionEntity? permission;
  final bool isAdmin;

  const PermissionLoaded({this.permission, required this.isAdmin});

  bool get canVoid => isAdmin || (permission?.actionVoid ?? false);
  bool get canMenuProduct => isAdmin || (permission?.menuProduct ?? false);
  bool get canMenuStock => isAdmin || (permission?.menuStock ?? false);
  bool get canMenuReport => isAdmin || (permission?.menuReport ?? false);

  @override
  List<Object?> get props => [permission, isAdmin];
}

class PermissionError extends PermissionState {
  final String message;
  const PermissionError(this.message);
  @override
  List<Object?> get props => [message];
}

class PermissionCubit extends Cubit<PermissionState> {
  final GetUserPermissionUseCase getUserPermissionUseCase;

  PermissionCubit({required this.getUserPermissionUseCase})
      : super(PermissionInitial());

  Future<void> checkPermissions({
    required String role,
    required String userId,
  }) async {
    emit(PermissionLoading());
    if (role == 'admin') {
      emit(const PermissionLoaded(permission: null, isAdmin: true));
      return;
    }

    final result = await getUserPermissionUseCase(userId);
    result.fold(
      (failure) => emit(PermissionError(failure.message)),
      (permission) => emit(PermissionLoaded(permission: permission, isAdmin: false)),
    );
  }
}

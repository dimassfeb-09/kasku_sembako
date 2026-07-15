import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/cloud_backup_usecases.dart';
import 'backup_event.dart';
import 'backup_state.dart';

/// Handles the new cloud backup/restore actions only. The existing local
/// backup/restore in backup_page.dart intentionally stays as a plain
/// StatefulWidget (see plan: it's a working, destructive flow — not
/// worth risking a refactor of it just for consistency).
class BackupBloc extends Bloc<BackupEvent, BackupState> {
  final UploadCloudBackupUseCase uploadCloudBackupUseCase;
  final DownloadCloudBackupUseCase downloadCloudBackupUseCase;

  BackupBloc({
    required this.uploadCloudBackupUseCase,
    required this.downloadCloudBackupUseCase,
  }) : super(BackupInitial()) {
    on<UploadCloudBackupRequested>(_onUpload);
    on<DownloadCloudBackupRequested>(_onDownload);
  }

  Future<void> _onUpload(
    UploadCloudBackupRequested event,
    Emitter<BackupState> emit,
  ) async {
    emit(CloudBackupUploading());
    final result = await uploadCloudBackupUseCase(event.payload);
    result.fold(
      (failure) => emit(BackupError(failure.message)),
      (_) => emit(CloudBackupUploadSuccess()),
    );
  }

  Future<void> _onDownload(
    DownloadCloudBackupRequested event,
    Emitter<BackupState> emit,
  ) async {
    emit(CloudBackupDownloading());
    final result = await downloadCloudBackupUseCase();
    result.fold(
      (failure) => emit(BackupError(failure.message)),
      (payload) => emit(CloudBackupDownloadSuccess(payload)),
    );
  }
}

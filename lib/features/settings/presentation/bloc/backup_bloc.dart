import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/cloud_backup_repository.dart';
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
  final DownloadBackupByIdUseCase downloadBackupByIdUseCase;
  final ListBackupsUseCase listBackupsUseCase;

  BackupBloc({
    required this.uploadCloudBackupUseCase,
    required this.downloadCloudBackupUseCase,
    required this.downloadBackupByIdUseCase,
    required this.listBackupsUseCase,
  }) : super(BackupInitial()) {
    on<UploadCloudBackupRequested>(_onUpload);
    on<DownloadCloudBackupRequested>(_onDownload);
    on<ListCloudBackupsRequested>(_onListBackups);
    on<DownloadCloudBackupByIdRequested>(_onDownloadById);
  }

  Future<void> _onUpload(
    UploadCloudBackupRequested event,
    Emitter<BackupState> emit,
  ) async {
    emit(CloudBackupUploading());
    final result = await uploadCloudBackupUseCase(event.payload);
    result.fold(
      (failure) => emit(BackupError(failure.message)),
      (outcome) => emit(
        outcome == UploadOutcome.skippedUnchanged
            ? CloudBackupUploadSkipped()
            : CloudBackupUploadSuccess(),
      ),
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

  Future<void> _onListBackups(
    ListCloudBackupsRequested event,
    Emitter<BackupState> emit,
  ) async {
    emit(BackupsListLoading());
    final result = await listBackupsUseCase();
    result.fold(
      (failure) => emit(BackupError(failure.message)),
      (backups) => emit(BackupsListLoaded(backups)),
    );
  }

  Future<void> _onDownloadById(
    DownloadCloudBackupByIdRequested event,
    Emitter<BackupState> emit,
  ) async {
    emit(CloudBackupDownloading());
    final result = await downloadBackupByIdUseCase(event.id);
    result.fold(
      (failure) => emit(BackupError(failure.message)),
      (payload) => emit(CloudBackupDownloadSuccess(payload)),
    );
  }
}

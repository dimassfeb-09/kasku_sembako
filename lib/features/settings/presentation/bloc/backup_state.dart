import 'package:equatable/equatable.dart';
import '../../domain/repositories/cloud_backup_repository.dart';

abstract class BackupState extends Equatable {
  const BackupState();
  @override
  List<Object?> get props => [];
}

class BackupInitial extends BackupState {}

class CloudBackupUploading extends BackupState {}

class CloudBackupUploadSuccess extends BackupState {}

/// The payload's content hash matched the last successful upload, so
/// nothing was sent - this is the bandwidth-saving skip path, not an error.
class CloudBackupUploadSkipped extends BackupState {}

class CloudBackupDownloading extends BackupState {}

class CloudBackupDownloadSuccess extends BackupState {
  final Map<String, dynamic> payload;
  const CloudBackupDownloadSuccess(this.payload);
  @override
  List<Object?> get props => [payload];
}

class BackupsListLoading extends BackupState {}

class BackupsListLoaded extends BackupState {
  final List<CloudBackupSummary> backups;
  const BackupsListLoaded(this.backups);
  @override
  List<Object?> get props => [backups];
}

class BackupError extends BackupState {
  final String message;
  const BackupError(this.message);
  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';

abstract class BackupState extends Equatable {
  const BackupState();
  @override
  List<Object?> get props => [];
}

class BackupInitial extends BackupState {}

class CloudBackupUploading extends BackupState {}

class CloudBackupUploadSuccess extends BackupState {}

class CloudBackupDownloading extends BackupState {}

class CloudBackupDownloadSuccess extends BackupState {
  final Map<String, dynamic> payload;
  const CloudBackupDownloadSuccess(this.payload);
  @override
  List<Object?> get props => [payload];
}

class BackupError extends BackupState {
  final String message;
  const BackupError(this.message);
  @override
  List<Object?> get props => [message];
}

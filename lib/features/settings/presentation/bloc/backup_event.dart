import 'package:equatable/equatable.dart';

abstract class BackupEvent extends Equatable {
  const BackupEvent();
  @override
  List<Object> get props => [];
}

class UploadCloudBackupRequested extends BackupEvent {
  final Map<String, dynamic> payload;
  const UploadCloudBackupRequested(this.payload);
  @override
  List<Object> get props => [payload];
}

class DownloadCloudBackupRequested extends BackupEvent {}

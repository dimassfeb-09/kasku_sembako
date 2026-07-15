import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kasirku_sembako/core/error/failures.dart';
import 'package:kasirku_sembako/features/settings/domain/usecases/cloud_backup_usecases.dart';
import 'package:kasirku_sembako/features/settings/presentation/bloc/backup_bloc.dart';
import 'package:kasirku_sembako/features/settings/presentation/bloc/backup_event.dart';
import 'package:kasirku_sembako/features/settings/presentation/bloc/backup_state.dart';

class MockUploadCloudBackupUseCase extends Mock
    implements UploadCloudBackupUseCase {}

class MockDownloadCloudBackupUseCase extends Mock
    implements DownloadCloudBackupUseCase {}

void main() {
  late MockUploadCloudBackupUseCase uploadUseCase;
  late MockDownloadCloudBackupUseCase downloadUseCase;

  final testPayload = {
    'schemaVersion': 4,
    'exportedAt': '2026-01-01T00:00:00.000',
    'tables': {'users': []},
  };

  BackupBloc buildBloc() => BackupBloc(
    uploadCloudBackupUseCase: uploadUseCase,
    downloadCloudBackupUseCase: downloadUseCase,
  );

  setUp(() {
    uploadUseCase = MockUploadCloudBackupUseCase();
    downloadUseCase = MockDownloadCloudBackupUseCase();
  });

  test('initial state is BackupInitial', () {
    expect(buildBloc().state, isA<BackupInitial>());
  });

  group('UploadCloudBackupRequested', () {
    blocTest<BackupBloc, BackupState>(
      'emits [Uploading, UploadSuccess] on success',
      build: () {
        when(
          () => uploadUseCase(testPayload),
        ).thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(UploadCloudBackupRequested(testPayload)),
      expect: () => [
        isA<CloudBackupUploading>(),
        isA<CloudBackupUploadSuccess>(),
      ],
    );

    blocTest<BackupBloc, BackupState>(
      'emits [Uploading, Error] when not entitled to Pro',
      build: () {
        when(() => uploadUseCase(any())).thenAnswer(
          (_) async => const Left(
            ServerFailure('Fitur ini khusus untuk pelanggan Pro.'),
          ),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(UploadCloudBackupRequested(testPayload)),
      expect: () => [
        isA<CloudBackupUploading>(),
        const BackupError('Fitur ini khusus untuk pelanggan Pro.'),
      ],
    );
  });

  group('DownloadCloudBackupRequested', () {
    blocTest<BackupBloc, BackupState>(
      'emits [Downloading, DownloadSuccess(payload)] on success',
      build: () {
        when(
          () => downloadUseCase(),
        ).thenAnswer((_) async => Right(testPayload));
        return buildBloc();
      },
      act: (bloc) => bloc.add(DownloadCloudBackupRequested()),
      expect: () => [
        isA<CloudBackupDownloading>(),
        CloudBackupDownloadSuccess(testPayload),
      ],
    );

    blocTest<BackupBloc, BackupState>(
      'emits [Downloading, Error] when there is no cloud backup yet',
      build: () {
        when(() => downloadUseCase()).thenAnswer(
          (_) async =>
              const Left(ServerFailure('Belum ada cadangan cloud tersimpan.')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(DownloadCloudBackupRequested()),
      expect: () => [
        isA<CloudBackupDownloading>(),
        const BackupError('Belum ada cadangan cloud tersimpan.'),
      ],
    );
  });
}

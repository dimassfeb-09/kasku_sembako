import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kasirku_sembako/core/error/failures.dart';
import 'package:kasirku_sembako/features/settings/domain/repositories/cloud_backup_repository.dart';
import 'package:kasirku_sembako/features/settings/domain/usecases/cloud_backup_usecases.dart';
import 'package:kasirku_sembako/features/settings/presentation/bloc/backup_bloc.dart';
import 'package:kasirku_sembako/features/settings/presentation/bloc/backup_event.dart';
import 'package:kasirku_sembako/features/settings/presentation/bloc/backup_state.dart';

class MockUploadCloudBackupUseCase extends Mock
    implements UploadCloudBackupUseCase {}

class MockDownloadCloudBackupUseCase extends Mock
    implements DownloadCloudBackupUseCase {}

class MockDownloadBackupByIdUseCase extends Mock
    implements DownloadBackupByIdUseCase {}

class MockListBackupsUseCase extends Mock implements ListBackupsUseCase {}

void main() {
  late MockUploadCloudBackupUseCase uploadUseCase;
  late MockDownloadCloudBackupUseCase downloadUseCase;
  late MockDownloadBackupByIdUseCase downloadByIdUseCase;
  late MockListBackupsUseCase listBackupsUseCase;

  final testPayload = {
    'schemaVersion': 4,
    'exportedAt': '2026-01-01T00:00:00.000',
    'tables': {'users': []},
  };

  BackupBloc buildBloc() => BackupBloc(
    uploadCloudBackupUseCase: uploadUseCase,
    downloadCloudBackupUseCase: downloadUseCase,
    downloadBackupByIdUseCase: downloadByIdUseCase,
    listBackupsUseCase: listBackupsUseCase,
  );

  setUp(() {
    uploadUseCase = MockUploadCloudBackupUseCase();
    downloadUseCase = MockDownloadCloudBackupUseCase();
    downloadByIdUseCase = MockDownloadBackupByIdUseCase();
    listBackupsUseCase = MockListBackupsUseCase();
  });

  test('initial state is BackupInitial', () {
    expect(buildBloc().state, isA<BackupInitial>());
  });

  group('UploadCloudBackupRequested', () {
    blocTest<BackupBloc, BackupState>(
      'emits [Uploading, UploadSuccess] when content was uploaded',
      build: () {
        when(
          () => uploadUseCase(testPayload),
        ).thenAnswer((_) async => const Right(UploadOutcome.uploaded));
        return buildBloc();
      },
      act: (bloc) => bloc.add(UploadCloudBackupRequested(testPayload)),
      expect: () => [
        isA<CloudBackupUploading>(),
        isA<CloudBackupUploadSuccess>(),
      ],
    );

    blocTest<BackupBloc, BackupState>(
      'emits [Uploading, UploadSkipped] when content is unchanged',
      build: () {
        when(
          () => uploadUseCase(testPayload),
        ).thenAnswer((_) async => const Right(UploadOutcome.skippedUnchanged));
        return buildBloc();
      },
      act: (bloc) => bloc.add(UploadCloudBackupRequested(testPayload)),
      expect: () => [
        isA<CloudBackupUploading>(),
        isA<CloudBackupUploadSkipped>(),
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

  group('ListCloudBackupsRequested', () {
    blocTest<BackupBloc, BackupState>(
      'emits [BackupsListLoading, BackupsListLoaded] on success',
      build: () {
        when(() => listBackupsUseCase()).thenAnswer(
          (_) async => Right([
            CloudBackupSummary(
              id: 'b1',
              createdAt: _kDate,
              sizeBytes: 1024,
              deviceId: 'device-1',
            ),
          ]),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(ListCloudBackupsRequested()),
      expect: () => [isA<BackupsListLoading>(), isA<BackupsListLoaded>()],
    );

    blocTest<BackupBloc, BackupState>(
      'emits [BackupsListLoading, Error] on failure',
      build: () {
        when(() => listBackupsUseCase()).thenAnswer(
          (_) async =>
              const Left(ServerFailure('Gagal mengambil daftar cadangan.')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(ListCloudBackupsRequested()),
      expect: () => [
        isA<BackupsListLoading>(),
        const BackupError('Gagal mengambil daftar cadangan.'),
      ],
    );
  });

  group('DownloadCloudBackupByIdRequested', () {
    blocTest<BackupBloc, BackupState>(
      'emits [Downloading, DownloadSuccess(payload)] on success',
      build: () {
        when(
          () => downloadByIdUseCase('b1'),
        ).thenAnswer((_) async => Right(testPayload));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DownloadCloudBackupByIdRequested('b1')),
      expect: () => [
        isA<CloudBackupDownloading>(),
        CloudBackupDownloadSuccess(testPayload),
      ],
    );
  });
}

final _kDate = DateTime.utc(2026, 1, 1);

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kasirku_sembako/core/error/exceptions.dart';
import 'package:kasirku_sembako/core/error/failures.dart';
import 'package:kasirku_sembako/core/services/backup_payload_util.dart';
import 'package:kasirku_sembako/features/settings/data/datasources/backup_schedule_local_datasource.dart';
import 'package:kasirku_sembako/features/settings/data/datasources/cloud_backup_remote_datasource.dart';
import 'package:kasirku_sembako/features/settings/data/repositories/cloud_backup_repository_impl.dart';
import 'package:kasirku_sembako/features/settings/domain/repositories/cloud_backup_repository.dart';

class MockCloudBackupRemoteDataSource extends Mock
    implements CloudBackupRemoteDataSource {}

class MockBackupScheduleLocalDataSource extends Mock
    implements BackupScheduleLocalDataSource {}

void main() {
  late MockCloudBackupRemoteDataSource remoteDataSource;
  late MockBackupScheduleLocalDataSource localDataSource;
  late CloudBackupRepositoryImpl repository;

  final testPayload = {
    'schemaVersion': 4,
    'exportedAt': '2026-01-01T00:00:00.000',
    'tables': {'users': []},
  };
  final compressed = BackupPayloadUtil.compress(testPayload);

  setUpAll(() {
    registerFallbackValue(<int>[]);
  });

  setUp(() {
    remoteDataSource = MockCloudBackupRemoteDataSource();
    localDataSource = MockBackupScheduleLocalDataSource();
    repository = CloudBackupRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );
  });

  group('uploadBackup', () {
    test('uploads and saves the hash when content changed', () async {
      when(
        () => localDataSource.readLastUploadedHash(),
      ).thenAnswer((_) async => 'different-hash');
      when(
        () => localDataSource.readOrCreateDeviceId(),
      ).thenAnswer((_) async => 'device-1');
      when(
        () => remoteDataSource.uploadBackup(
          gzipBytes: any(named: 'gzipBytes'),
          contentHash: any(named: 'contentHash'),
          deviceId: any(named: 'deviceId'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => localDataSource.saveLastUploadedHash(any()),
      ).thenAnswer((_) async {});

      final result = await repository.uploadBackup(testPayload);

      expect(
        result,
        const Right<Failure, UploadOutcome>(UploadOutcome.uploaded),
      );
      verify(
        () => remoteDataSource.uploadBackup(
          gzipBytes: any(named: 'gzipBytes'),
          contentHash: compressed.contentHash,
          deviceId: 'device-1',
        ),
      ).called(1);
      verify(
        () => localDataSource.saveLastUploadedHash(compressed.contentHash),
      ).called(1);
    });

    test('skips the upload when the content hash is unchanged', () async {
      when(
        () => localDataSource.readLastUploadedHash(),
      ).thenAnswer((_) async => compressed.contentHash);

      final result = await repository.uploadBackup(testPayload);

      expect(
        result,
        const Right<Failure, UploadOutcome>(UploadOutcome.skippedUnchanged),
      );
      verifyNever(
        () => remoteDataSource.uploadBackup(
          gzipBytes: any(named: 'gzipBytes'),
          contentHash: any(named: 'contentHash'),
          deviceId: any(named: 'deviceId'),
        ),
      );
    });

    test('maps NetworkException to NetworkFailure', () async {
      when(
        () => localDataSource.readLastUploadedHash(),
      ).thenAnswer((_) async => null);
      when(
        () => localDataSource.readOrCreateDeviceId(),
      ).thenAnswer((_) async => 'device-1');
      when(
        () => remoteDataSource.uploadBackup(
          gzipBytes: any(named: 'gzipBytes'),
          contentHash: any(named: 'contentHash'),
          deviceId: any(named: 'deviceId'),
        ),
      ).thenThrow(const NetworkException('Tidak dapat terhubung ke server.'));

      final result = await repository.uploadBackup(testPayload);

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected a Left'),
      );
    });

    test('maps ServerException (e.g. not Pro) to ServerFailure', () async {
      when(
        () => localDataSource.readLastUploadedHash(),
      ).thenAnswer((_) async => null);
      when(
        () => localDataSource.readOrCreateDeviceId(),
      ).thenAnswer((_) async => 'device-1');
      when(
        () => remoteDataSource.uploadBackup(
          gzipBytes: any(named: 'gzipBytes'),
          contentHash: any(named: 'contentHash'),
          deviceId: any(named: 'deviceId'),
        ),
      ).thenThrow(
        const ServerException('Fitur ini khusus untuk pelanggan Pro.'),
      );

      final result = await repository.uploadBackup(testPayload);

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected a Left'),
      );
    });
  });

  group('downloadLatestBackup', () {
    test('returns Right(payload) when the hash matches', () async {
      when(() => remoteDataSource.downloadLatestBackup()).thenAnswer(
        (_) async => BackupBytesPayload(
          bytes: BackupPayloadUtil.compress(testPayload).gzipBytes,
          contentEncoding: 'gzip',
          contentHash: BackupPayloadUtil.hashOf(testPayload),
        ),
      );

      final result = await repository.downloadLatestBackup();

      // Deep equality, not Right's == (reference-equal Map comparison):
      // the payload here is freshly gzip-decoded/decoded JSON, a distinct
      // Map instance that's structurally - not identically - equal to
      // testPayload.
      result.fold(
        (failure) => fail('expected a Right, got $failure'),
        (payload) => expect(payload, equals(testPayload)),
      );
    });

    test(
      'returns ServerFailure when the downloaded hash does not match',
      () async {
        when(() => remoteDataSource.downloadLatestBackup()).thenAnswer(
          (_) async => BackupBytesPayload(
            bytes: BackupPayloadUtil.compress(testPayload).gzipBytes,
            contentEncoding: 'gzip',
            contentHash: 'tampered-hash',
          ),
        );

        final result = await repository.downloadLatestBackup();

        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('expected a Left'),
        );
      },
    );

    test('maps a 404 ServerException to ServerFailure', () async {
      when(
        () => remoteDataSource.downloadLatestBackup(),
      ).thenThrow(const ServerException('Belum ada cadangan cloud tersimpan.'));

      final result = await repository.downloadLatestBackup();

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected a Left'),
      );
    });
  });

  group('listBackups', () {
    test('maps raw JSON entries to CloudBackupSummary objects', () async {
      when(() => remoteDataSource.listBackups()).thenAnswer(
        (_) async => [
          {
            'id': 'b1',
            'createdAt': '2026-01-01T00:00:00.000Z',
            'sizeBytes': 1024,
            'deviceId': 'device-1',
          },
          {
            'id': 'b2',
            'createdAt': '2026-01-02T00:00:00.000Z',
            'sizeBytes': 2048,
            'deviceId': 'device-2',
          },
        ],
      );

      final result = await repository.listBackups();

      result.fold((failure) => fail('expected a Right, got $failure'), (
        summaries,
      ) {
        expect(summaries, hasLength(2));
        expect(summaries[0].id, 'b1');
        expect(summaries[0].sizeBytes, 1024);
        expect(summaries[0].deviceId, 'device-1');
        expect(summaries[1].id, 'b2');
      });
    });

    test('returns an empty list when there are no backups', () async {
      when(() => remoteDataSource.listBackups()).thenAnswer((_) async => []);

      final result = await repository.listBackups();

      result.fold(
        (failure) => fail('expected a Right, got $failure'),
        (summaries) => expect(summaries, isEmpty),
      );
    });
  });

  group('deleteBackup', () {
    test('returns Right(null) on success', () async {
      when(() => remoteDataSource.deleteBackup('b1')).thenAnswer((_) async {});

      final result = await repository.deleteBackup('b1');

      expect(result, const Right<Failure, void>(null));
    });

    test('maps a 404 ServerException to ServerFailure', () async {
      when(
        () => remoteDataSource.deleteBackup(any()),
      ).thenThrow(const ServerException('Backup not found.'));

      final result = await repository.deleteBackup('missing');

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected a Left'),
      );
    });
  });
}

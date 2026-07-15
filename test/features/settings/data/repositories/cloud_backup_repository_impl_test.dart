import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kasirku_sembako/core/error/exceptions.dart';
import 'package:kasirku_sembako/core/error/failures.dart';
import 'package:kasirku_sembako/features/settings/data/datasources/cloud_backup_remote_datasource.dart';
import 'package:kasirku_sembako/features/settings/data/repositories/cloud_backup_repository_impl.dart';

class MockCloudBackupRemoteDataSource extends Mock
    implements CloudBackupRemoteDataSource {}

void main() {
  late MockCloudBackupRemoteDataSource remoteDataSource;
  late CloudBackupRepositoryImpl repository;

  final testPayload = {
    'schemaVersion': 4,
    'exportedAt': '2026-01-01T00:00:00.000',
    'tables': {'users': []},
  };

  setUp(() {
    remoteDataSource = MockCloudBackupRemoteDataSource();
    repository = CloudBackupRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  group('uploadBackup', () {
    test('returns Right(null) on success', () async {
      when(
        () => remoteDataSource.uploadBackup(testPayload),
      ).thenAnswer((_) async {});

      final result = await repository.uploadBackup(testPayload);

      expect(result, const Right<Failure, void>(null));
    });

    test('maps NetworkException to NetworkFailure', () async {
      when(
        () => remoteDataSource.uploadBackup(any()),
      ).thenThrow(const NetworkException('Tidak dapat terhubung ke server.'));

      final result = await repository.uploadBackup(testPayload);

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected a Left'),
      );
    });

    test('maps ServerException (e.g. not Pro) to ServerFailure', () async {
      when(() => remoteDataSource.uploadBackup(any())).thenThrow(
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
    test('returns Right(payload) on success', () async {
      when(
        () => remoteDataSource.downloadLatestBackup(),
      ).thenAnswer((_) async => testPayload);

      final result = await repository.downloadLatestBackup();

      expect(result, Right<Failure, dynamic>(testPayload));
    });

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
          },
          {
            'id': 'b2',
            'createdAt': '2026-01-02T00:00:00.000Z',
            'sizeBytes': 2048,
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

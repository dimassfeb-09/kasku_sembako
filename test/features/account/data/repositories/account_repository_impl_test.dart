import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kasirku_sembako/core/constants/app_constants.dart';
import 'package:kasirku_sembako/core/error/exceptions.dart';
import 'package:kasirku_sembako/core/error/failures.dart';
import 'package:kasirku_sembako/features/account/data/datasources/account_remote_datasource.dart';
import 'package:kasirku_sembako/features/account/data/models/account_model.dart';
import 'package:kasirku_sembako/features/account/data/repositories/account_repository_impl.dart';

class MockAccountRemoteDataSource extends Mock
    implements AccountRemoteDataSource {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockAccountRemoteDataSource remoteDataSource;
  late MockFlutterSecureStorage secureStorage;
  late AccountRepositoryImpl repository;

  final testAccount = AccountModel(
    id: 'acc-1',
    email: 'owner@example.com',
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    remoteDataSource = MockAccountRemoteDataSource();
    secureStorage = MockFlutterSecureStorage();
    repository = AccountRepositoryImpl(
      remoteDataSource: remoteDataSource,
      secureStorage: secureStorage,
    );
  });

  group('register', () {
    test('returns Right(account) on success', () async {
      when(
        () => remoteDataSource.register(
          'Toko Makmur',
          'owner@example.com',
          'password123',
          '08123456789',
        ),
      ).thenAnswer((_) async => testAccount);

      final result = await repository.register(
        'Toko Makmur',
        'owner@example.com',
        'password123',
        '08123456789',
      );

      expect(result, Right<Failure, dynamic>(testAccount));
    });

    test('maps NetworkException to NetworkFailure', () async {
      when(
        () => remoteDataSource.register(any(), any(), any(), any()),
      ).thenThrow(const NetworkException('Tidak dapat terhubung ke server.'));

      final result = await repository.register(
        'Toko Makmur',
        'owner@example.com',
        'password123',
        '08123456789',
      );

      expect(result, isA<Left<Failure, dynamic>>());
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected a Left'),
      );
    });

    test('maps ServerException to ServerFailure', () async {
      when(
        () => remoteDataSource.register(any(), any(), any(), any()),
      ).thenThrow(const ServerException('Email sudah terdaftar.'));

      final result = await repository.register(
        'Toko Makmur',
        'owner@example.com',
        'password123',
        '08123456789',
      );

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected a Left'),
      );
    });
  });

  group('login', () {
    test('returns Right(account) on success', () async {
      when(
        () => remoteDataSource.login('owner@example.com', 'password123'),
      ).thenAnswer((_) async => testAccount);

      final result = await repository.login('owner@example.com', 'password123');

      expect(result, Right<Failure, dynamic>(testAccount));
    });

    test('maps ServerException (wrong credentials) to ServerFailure', () async {
      when(
        () => remoteDataSource.login(any(), any()),
      ).thenThrow(const ServerException('Email atau kata sandi salah.'));

      final result = await repository.login('owner@example.com', 'wrong');

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected a Left'),
      );
    });
  });

  group('logout', () {
    setUp(() {
      when(() => remoteDataSource.logout()).thenAnswer((_) async {});
    });

    test('clears all cached account keys and returns Right(null)', () async {
      when(
        () => secureStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result, const Right<Failure, void>(null));
      verify(
        () => secureStorage.delete(key: AppConstants.accountAccessTokenKey),
      ).called(1);
      verify(
        () => secureStorage.delete(key: AppConstants.accountRefreshTokenKey),
      ).called(1);
      verify(
        () => secureStorage.delete(key: AppConstants.accountIdKey),
      ).called(1);
      verify(
        () => secureStorage.delete(key: AppConstants.accountEmailKey),
      ).called(1);
      verify(
        () => secureStorage.delete(key: AppConstants.accountCreatedAtKey),
      ).called(1);
    });

    test('returns a CacheFailure if secure storage throws', () async {
      when(
        () => secureStorage.delete(key: any(named: 'key')),
      ).thenThrow(Exception('storage error'));

      final result = await repository.logout();

      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('expected a Left'),
      );
    });
  });

  group('getCachedAccount', () {
    test('returns Right(null) when no token is cached', () async {
      when(
        () => secureStorage.read(key: AppConstants.accountAccessTokenKey),
      ).thenAnswer((_) async => null);

      final result = await repository.getCachedAccount();

      expect(result, const Right<Failure, dynamic>(null));
    });

    test('returns Right(account) when all cached fields are present', () async {
      when(
        () => secureStorage.read(key: AppConstants.accountAccessTokenKey),
      ).thenAnswer((_) async => 'a-jwt-token');
      when(
        () => secureStorage.read(key: AppConstants.accountIdKey),
      ).thenAnswer((_) async => 'acc-1');
      when(
        () => secureStorage.read(key: AppConstants.accountEmailKey),
      ).thenAnswer((_) async => 'owner@example.com');
      when(
        () => secureStorage.read(key: AppConstants.accountCreatedAtKey),
      ).thenAnswer((_) async => DateTime(2026, 1, 1).toIso8601String());

      final result = await repository.getCachedAccount();

      result.fold((failure) => fail('expected a Right, got $failure'), (
        account,
      ) {
        expect(account, isNotNull);
        expect(account!.id, 'acc-1');
        expect(account.email, 'owner@example.com');
      });
    });

    test(
      'returns Right(null) when token is present but other fields are missing',
      () async {
        when(
          () => secureStorage.read(key: AppConstants.accountAccessTokenKey),
        ).thenAnswer((_) async => 'a-jwt-token');
        when(
          () => secureStorage.read(key: AppConstants.accountIdKey),
        ).thenAnswer((_) async => null);
        when(
          () => secureStorage.read(key: AppConstants.accountEmailKey),
        ).thenAnswer((_) async => 'owner@example.com');
        when(
          () => secureStorage.read(key: AppConstants.accountCreatedAtKey),
        ).thenAnswer((_) async => DateTime(2026, 1, 1).toIso8601String());

        final result = await repository.getCachedAccount();

        expect(result, const Right<Failure, dynamic>(null));
      },
    );
  });
}

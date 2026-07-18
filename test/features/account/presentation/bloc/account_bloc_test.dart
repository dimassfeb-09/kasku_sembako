import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kasirku_sembako/core/error/failures.dart';
import 'package:kasirku_sembako/features/account/domain/entities/account_entity.dart';
import 'package:kasirku_sembako/features/account/domain/usecases/account_usecases.dart';
import 'package:kasirku_sembako/features/account/presentation/bloc/account_bloc.dart';
import 'package:kasirku_sembako/features/account/presentation/bloc/account_event.dart';
import 'package:kasirku_sembako/features/account/presentation/bloc/account_state.dart';

class MockRegisterAccountUseCase extends Mock
    implements RegisterAccountUseCase {}

class MockLoginAccountUseCase extends Mock implements LoginAccountUseCase {}

class MockLogoutAccountUseCase extends Mock implements LogoutAccountUseCase {}

class MockGetCachedAccountUseCase extends Mock
    implements GetCachedAccountUseCase {}

void main() {
  late MockRegisterAccountUseCase registerUseCase;
  late MockLoginAccountUseCase loginUseCase;
  late MockLogoutAccountUseCase logoutUseCase;
  late MockGetCachedAccountUseCase getCachedAccountUseCase;

  final testAccount = AccountEntity(
    id: 'acc-1',
    email: 'owner@example.com',
    createdAt: DateTime(2026, 1, 1),
  );

  AccountBloc buildBloc() => AccountBloc(
    registerAccountUseCase: registerUseCase,
    loginAccountUseCase: loginUseCase,
    logoutAccountUseCase: logoutUseCase,
    getCachedAccountUseCase: getCachedAccountUseCase,
  );

  setUp(() {
    registerUseCase = MockRegisterAccountUseCase();
    loginUseCase = MockLoginAccountUseCase();
    logoutUseCase = MockLogoutAccountUseCase();
    getCachedAccountUseCase = MockGetCachedAccountUseCase();
  });

  test('initial state is AccountInitial', () {
    expect(buildBloc().state, isA<AccountInitial>());
  });

  group('CheckAccountSessionEvent', () {
    blocTest<AccountBloc, AccountState>(
      'emits [Loading, SignedIn] when a cached account exists',
      build: () {
        when(
          () => getCachedAccountUseCase(),
        ).thenAnswer((_) async => Right(testAccount));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CheckAccountSessionEvent()),
      expect: () => [isA<AccountLoading>(), AccountSignedIn(testAccount)],
    );

    blocTest<AccountBloc, AccountState>(
      'emits [Loading, SignedOut] when no cached account exists',
      build: () {
        when(
          () => getCachedAccountUseCase(),
        ).thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CheckAccountSessionEvent()),
      expect: () => [isA<AccountLoading>(), isA<AccountSignedOut>()],
    );

    blocTest<AccountBloc, AccountState>(
      'emits [Loading, SignedOut] when the cache lookup fails',
      build: () {
        when(
          () => getCachedAccountUseCase(),
        ).thenAnswer((_) async => const Left(CacheFailure('failed')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CheckAccountSessionEvent()),
      expect: () => [isA<AccountLoading>(), isA<AccountSignedOut>()],
    );
  });

  group('RegisterSubmittedEvent', () {
    blocTest<AccountBloc, AccountState>(
      'emits [Loading, SignedIn] on successful registration',
      build: () {
        when(
          () => registerUseCase(
            'Toko Makmur',
            'owner@example.com',
            'password123',
            '08123456789',
          ),
        ).thenAnswer((_) async => Right(testAccount));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const RegisterSubmittedEvent(
          'Toko Makmur',
          'owner@example.com',
          'password123',
          '08123456789',
        ),
      ),
      expect: () => [isA<AccountLoading>(), AccountSignedIn(testAccount)],
    );

    blocTest<AccountBloc, AccountState>(
      'emits [Loading, Error] when the email is already taken',
      build: () {
        when(() => registerUseCase(any(), any(), any(), any())).thenAnswer(
          (_) async => const Left(ServerFailure('Email sudah terdaftar.')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const RegisterSubmittedEvent(
          'Toko Makmur',
          'owner@example.com',
          'password123',
          '08123456789',
        ),
      ),
      expect: () => [
        isA<AccountLoading>(),
        const AccountError('Email sudah terdaftar.'),
      ],
    );
  });

  group('LoginSubmittedEvent', () {
    blocTest<AccountBloc, AccountState>(
      'emits [Loading, SignedIn] on successful login',
      build: () {
        when(
          () => loginUseCase('owner@example.com', 'password123'),
        ).thenAnswer((_) async => Right(testAccount));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const LoginSubmittedEvent('owner@example.com', 'password123'),
      ),
      expect: () => [isA<AccountLoading>(), AccountSignedIn(testAccount)],
    );

    blocTest<AccountBloc, AccountState>(
      'emits [Loading, Error] on wrong credentials',
      build: () {
        when(() => loginUseCase(any(), any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure('Email atau kata sandi salah.')),
        );
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoginSubmittedEvent('owner@example.com', 'wrong')),
      expect: () => [
        isA<AccountLoading>(),
        const AccountError('Email atau kata sandi salah.'),
      ],
    );
  });

  group('LogoutEvent', () {
    blocTest<AccountBloc, AccountState>(
      'emits [Loading, SignedOut] on successful logout',
      build: () {
        when(() => logoutUseCase()).thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LogoutEvent()),
      expect: () => [isA<AccountLoading>(), isA<AccountSignedOut>()],
    );
  });
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/account_usecases.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final RegisterAccountUseCase registerAccountUseCase;
  final LoginAccountUseCase loginAccountUseCase;
  final LogoutAccountUseCase logoutAccountUseCase;
  final GetCachedAccountUseCase getCachedAccountUseCase;

  AccountBloc({
    required this.registerAccountUseCase,
    required this.loginAccountUseCase,
    required this.logoutAccountUseCase,
    required this.getCachedAccountUseCase,
  }) : super(AccountInitial()) {
    on<CheckAccountSessionEvent>(_onCheckSession);
    on<RegisterSubmittedEvent>(_onRegisterSubmitted);
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckSession(
    CheckAccountSessionEvent event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    final result = await getCachedAccountUseCase();
    result.fold(
      (failure) => emit(AccountSignedOut()),
      (account) =>
          emit(account != null ? AccountSignedIn(account) : AccountSignedOut()),
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmittedEvent event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    final result = await registerAccountUseCase(
      event.name,
      event.email,
      event.password,
      event.whatsapp,
    );
    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (account) => emit(AccountSignedIn(account)),
    );
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    final result = await loginAccountUseCase(event.email, event.password);
    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (account) => emit(AccountSignedIn(account)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    final result = await logoutAccountUseCase();
    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (_) => emit(AccountSignedOut()),
    );
  }
}

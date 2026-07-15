import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetSessionUseCase getSessionUseCase;
  final HasUsersUseCase hasUsersUseCase;
  final RegisterFirstAdminUseCase registerFirstAdminUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getSessionUseCase,
    required this.hasUsersUseCase,
    required this.registerFirstAdminUseCase,
  }) : super(AuthInitial()) {
    on<CheckSessionEvent>(_onCheckSession);
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<LogoutEvent>(_onLogout);
    on<RegisterFirstAdminEvent>(_onRegisterFirstAdmin);
  }

  Future<void> _onCheckSession(
    CheckSessionEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Cek apakah database kosong
    final hasUsersResult = await hasUsersUseCase();
    bool databaseHasUsers = true;
    hasUsersResult.fold(
      (failure) {}, // Abaikan error atau asumsikan ada user
      (hasUsers) => databaseHasUsers = hasUsers,
    );

    if (!databaseHasUsers) {
      emit(SetupRequired());
      return;
    }

    final result = await getSessionUseCase();
    result.fold((failure) => emit(Unauthenticated()), (user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUseCase(event.username, event.pin);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await logoutUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> _onRegisterFirstAdmin(
    RegisterFirstAdminEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await registerFirstAdminUseCase(event.username, event.pin);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }
}

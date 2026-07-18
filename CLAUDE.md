# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`kasirku_sembako` — a Flutter/Dart point-of-sale app for a sembako (grocery) shop. All in-app UI strings and error messages are in **Indonesian** — follow that convention for any new user-facing text.

The repo holds three pieces:

- **Flutter app** (`lib/`) — the POS itself. Shop data (products, transactions, customers, debts) is local-first: SQLite via Drift.
- **Go backend** (`backend/`) — Fiber + Postgres. Serves account auth, password reset, subscriptions, cloud backup, and store profile. Config via `backend/.env` (copy from `backend/.env.example`); `docker-compose up` brings up the DB.
- **Admin web** (`admin-web/`) — Vite/React admin console against the same backend.

The Flutter app talks to the backend over Dio (`lib/core/network/dio_client.dart`). The base URL comes from a compile-time define, **not** a `.env`:

```
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

It defaults to `http://localhost:8080` so `flutter run` works out of the box; a release build that doesn't pass an `https://` URL fails loudly at startup (`AppConstants.isApiBaseUrlSafeForRelease`).

## Commands

- Install deps: `flutter pub get`
- Run (primary dev target is Android): `flutter run -d <android-device>`
- Lint: `flutter analyze`
- Test: `flutter test` (11 test files, ~83 tests — mostly bloc/usecase unit tests via `bloc_test`/`mocktail`. There is no widget or integration coverage of page wiring, so provider/routing regressions are not caught here.)
- Format: `dart format .`
- Codegen (required after editing Drift tables in `lib/core/database/tables.dart`): `dart run build_runner build --delete-conflicting-outputs`

No CI is configured — `flutter analyze`/`flutter test` are not enforced automatically. `flutter analyze` currently reports ~90 pre-existing infos/warnings and no errors; don't read a clean exit as the bar.

Backend:

- Start DB: `docker-compose up -d`
- Run API: `cd backend && go run cmd/api/main.go` (listens on `:8080`, health at `/healthz`)
- Test: `cd backend && go test ./...`

## Architecture

Feature-first, clean architecture. Each feature under `lib/features/<name>/` has three layers:

```
<feature>/
  data/datasources/<feature>_local_datasource.dart   # talks to Drift AppDatabase directly
  data/datasources/<feature>_remote_datasource.dart  # backend-backed features only; Dio -> Go API
  data/models/<feature>_model.dart                    # maps DB rows <-> entity
  data/repositories/<feature>_repository_impl.dart    # implements domain repo, wraps in try/catch -> Either<Failure,T>
  domain/entities/<feature>_entity.dart               # pure Equatable entity, no framework deps
  domain/repositories/<feature>_repository.dart        # abstract interface
  domain/usecases/<feature>_usecases.dart             # one class per use case
  presentation/bloc/<feature>_bloc.dart (+ event/state, or a Cubit for simpler transient state)
  presentation/pages/, presentation/widgets/
```

- **Error handling**: repositories return `dartz`'s `Either<Failure, T>`; Blocs consume it via `.fold(...)`. Failures live in `lib/core/error/failures.dart`, exceptions in `lib/core/error/exceptions.dart`.
- **DI is 100% manual**, centralized in `lib/di/injection.dart` (get_it). When adding a feature you must hand-register datasource → repository → usecases → bloc/cubit there yourself — nothing is auto-discovered.
- **Routing**: single `GoRouter` in `lib/core/router/app_router.dart`. Auth/role guards (e.g. admin-only routes `/users`, `/reports`, `/backup`, `/logs`) are enforced centrally in the router's `redirect` callback, not per-page.
- **Passing data between routes**: use GoRouter's `extra` (`context.push('/x', extra: value)`) and unpack it in the route `builder` via the `_safeRoute<T>` helper in `app_router.dart`, which renders an error page instead of throwing on a bad/missing value. `ModalRoute.of(context)?.settings.arguments` does **not** work under GoRouter — it is always null, and reading it fails silently rather than loudly.
- **Providing blocs**: app-wide blocs are registered in `lib/di/injection.dart` (all `registerFactory`) and provided once in `MultiBlocProvider` in `lib/app/app.dart`. Page-scoped blocs are provided at their use site instead (`BackupBloc` in `backup_page.dart`, `QuickCustomerCubit` in `customer_selection_dialog.dart`) or, for a bloc shared across several routes of one flow, by a `ShellRoute` in the router (`PasswordResetBloc`, `PosSetupCubit`). Registering in DI is not enough — a bloc consumed without a matching `BlocProvider` throws `ProviderNotFoundException` at runtime, and nothing in the test suite catches it.
- **Database**: `lib/core/database/app_database.dart` (Drift/SQLite, `schemaVersion` currently 4). Any table schema change requires bumping `schemaVersion` and adding an explicit `MigrationStrategy.onUpgrade` step, or existing installs break.
- `freezed`/`json_serializable` are declared dependencies but currently unused anywhere in the codebase — don't assume any file uses them.

## UI/design

`DESIGN.md` is the authoritative source for UI decisions (colors, typography, spacing, component specs, in Indonesian) — reference it for any UI work.

## Workflow

- Commit directly to `main` — no branching/PR convention in use yet.

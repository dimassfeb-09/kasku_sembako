# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`kasirku_sembako` — a Flutter/Dart point-of-sale app for a sembako (grocery) shop. Local-only, no backend/API (no `.env`, no HTTP client deps); all persistence is SQLite via Drift. All in-app UI strings and error messages are in **Indonesian** — follow that convention for any new user-facing text.

## Commands

- Install deps: `flutter pub get`
- Run (primary dev target is Android): `flutter run -d <android-device>`
- Lint: `flutter analyze`
- Test: `flutter test` (note: only a trivial smoke test exists today — don't assume this suite catches regressions)
- Format: `dart format .`
- Codegen (required after editing Drift tables in `lib/core/database/tables.dart`): `dart run build_runner build --delete-conflicting-outputs`

No CI is configured — `flutter analyze`/`flutter test` are not enforced automatically.

## Architecture

Feature-first, clean architecture. Each feature under `lib/features/<name>/` has three layers:

```
<feature>/
  data/datasources/<feature>_local_datasource.dart   # talks to Drift AppDatabase directly
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
- **Database**: `lib/core/database/app_database.dart` (Drift/SQLite, `schemaVersion` currently 3). Any table schema change requires bumping `schemaVersion` and adding an explicit `MigrationStrategy.onUpgrade` step, or existing installs break.
- `freezed`/`json_serializable` are declared dependencies but currently unused anywhere in the codebase — don't assume any file uses them.

## UI/design

`DESIGN.md` is the authoritative source for UI decisions (colors, typography, spacing, component specs, in Indonesian) — reference it for any UI work.

## Workflow

- Commit directly to `main` — no branching/PR convention in use yet.

# bloc_clean_arch_flutter

A Flutter app built with Clean Architecture and the BLoC pattern: a login
flow against a real API, with token refresh, session expiry, and routing
driven by auth state.

## Running

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Retrofit + Drift codegen
flutter run
flutter test
flutter analyze
```

Re-run `build_runner` after changing any `@RestApi`, `@DriftDatabase` or
`@DriftAccessor` class.

## Architecture

Each feature under `lib/features/<name>/` is split into three layers.
Dependencies point inward only: presentation → domain ← data.

| Layer | Contains | Knows about |
| --- | --- | --- |
| `domain/` | Entities, repository interfaces, use cases | Nothing outside itself (no Flutter, no Dio) |
| `data/` | Models (`fromJson`), data sources, repository implementations | Domain, plus Dio/Retrofit/storage |
| `presentation/` | Blocs, pages, widgets | Domain use cases and entities only |

Errors cross the layers in one direction: data sources throw app
exceptions (`core/error/exceptions.dart`), repositories turn them into
`Failure` values (`Either<Failure, T>` from `fpdart`), and blocs turn
failures into user-facing text.

`lib/injection_container.dart` wires everything with `get_it`. Concrete
classes are registered against domain interfaces, so no layer above data
ever names an implementation.

### Auth flow

- **`AuthBloc`** (app-wide) holds the auth status: `unknown`,
  `authenticated` or `unauthenticated`. `MyApp` creates it once. On startup
  it checks for an existing session, then follows the repository's
  `authStateChanges` stream.
- **`LoginBloc`** (one per login screen) only submits the form. On
  success the repository announces the user on that stream, and `AuthBloc`
  picks it up.
- **Routing** (`core/router/routes.dart`): `go_router`'s top-level
  `redirect` maps the auth status to a page, and `refreshListenable`
  re-runs it on every `AuthBloc` change. No page navigates after login or
  logout. Startup, login, logout and session expiry all go through the
  same redirect.
- **Networking** (`core/network/`): `EnvelopeInterceptor` unwraps the API's
  `{code, message, data}` envelope. `AuthInterceptor` attaches the bearer
  token, refreshes on 401, and on a failed refresh signals
  `SessionExpiredNotifier`, which the repository turns into a logout.

In debug builds, `AppBlocObserver` logs every bloc transition and error.

## Tests

`test/` mirrors `lib/`. Use cases and repositories are tested with
`mocktail`, blocs with `bloc_test`'s `blocTest`, and pages as widget tests
against a `MockBloc`.

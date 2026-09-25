# Login / Auth feature — progress tracker

Status snapshot of the login feature build. Update this as work lands —
don't let it go stale.

Last updated: 2026-09-24. Branch: `dev`.

---

## Done

### Core (`lib/core/`)
- **error/** — `ServerException`, `NetworkException`, `CacheException`;
  `ServerFailure`, `NetworkFailure`, `CacheFailure`,
  `InvalidCredentialsFailure`, `InvalidInputFailure`.
- **storage/** — `BaseSecureStorage` (contract) + `SecureStorage`
  (`flutter_secure_storage` impl): `saveTokens`, `getAccessToken`,
  `getRefreshToken`, `clear`. Has a real test:
  `test/core/stroage/secure_storage_test.dart`.
- **network/**
  - `api_endpoint.dart` — base URL + login/refresh/profile paths.
  - `dio_client.dart` — `createMain` (token-attaching + refresh, used by
    every API service) and `createPlain` (refresh-only, no auth
    interceptor, so a failing refresh can't loop).
  - `auth_interceptor.dart` — `QueuedInterceptorsWrapper`. Attaches
    `Authorization: Bearer <token>`, refreshes on 401 (recognizes both a
    real HTTP 401 *and* a wrapped `code: 401`, since this API doesn't
    consistently use real HTTP status — see note below), retries the
    original request, clears tokens + notifies on unrecoverable failure.
  - `envelope_interceptor.dart` — **new today.** Unwraps this API's
    `{code, message, data}` envelope in one place. Non-200 `code` →
    rejected as a real `DioException`; 200 → `response.data` becomes just
    `data`. Wired into both `createMain` and `createPlain`.
  - `safe_api_call.dart` — **new today.** Shared `DioException` → app
    exception mapper (`safeApiCall<T>(() => ...)`), replacing what would
    otherwise be copy-pasted into every feature's data source.
  - `session_expired_notifier.dart` — broadcast stream so the interceptor
    can signal "log the user out" without importing the bloc layer.

### Domain (`features/login/domain/`)
- `entities/user.dart` — `User` (id, name, mobile, email, photo, birthday,
  profession, education, institution, address, gender, hasReward,
  pendingRewardProof). Matches the real API's `/auth/v1/profile` response.
- `repositories/auth_repository.dart` — `login`, `getCurrentUser`,
  `logout`, all returning `Either<Failure, T>`.
- `usecases/login.dart` — validates mobile non-empty and password ≥ 6
  chars *before* touching the repository (real domain-level business
  rule, testable without mocks).
- `usecases/get_current_user.dart`, `usecases/logout.dart` — done, correct
  types (`Unit` for logout), no leftover copy-paste bugs.

### Data (`features/login/data/`)
- `models/user_model.dart`, `models/auth_tokens_model.dart` — hand-written
  `fromJson`; `UserModel.toEntity()` converts to the domain `User`.
  `AuthTokensModel` deliberately has no domain equivalent — tokens never
  leave the data layer.
- `models/login_request_model.dart` — typed login request body (mobile +
  password), replacing a raw `Map`.
- `datasources/auth_api_service.dart` — **rebuilt today as real Retrofit.**
  `@RestApi()` interface, `@POST`/`@GET` return `AuthTokensModel`/
  `UserModel` directly (Retrofit calls their `fromJson` — no
  `json_serializable` needed for this to work).
- `datasources/auth_remote_data_source.dart` — thin wrapper: each method
  is one line, `safeApiCall(() => _api...)`. No parsing, no error-mapping
  logic left in this file.
- `repositories/auth_repository_impl.dart` — `login()` saves tokens then
  fetches the profile, clearing tokens if the profile fetch fails (no
  half-logged-in state). `getCurrentUser()` treats a 401 as session-expired
  and clears tokens. `logout()` clears storage. Exceptions mapped to
  specific failures (422 → `InvalidCredentialsFailure`, etc).

### Presentation (`features/login/presentation/`)
- `login_bloc.dart` / `login_event.dart` / `login_state.dart` — one event
  (`LoginSubmitted`), four states (`Initial`/`InProgress`/`Success`/
  `Failure`), `droppable()` transformer so double-tapping the button can't
  fire two logins.
- `login_page.dart` — `LoginPage` (provides the bloc via `sl`) +
  `LoginView` (mobile/password `TextEditingController`s, spinner while
  loading, snackbar on failure, welcome snackbar on success).

### DI (`injection_container.dart`)
- `_initAuth()` registers datasource, repository (under the `AuthRepository`
  interface), all three usecases, and `LoginBloc` — same shape as
  `_initCounter()`.

### Bugs found and fixed along the way
1. **422 shown as generic "Something went wrong."** Root cause: this API
   always answers HTTP 200 — the real result is the body's `code` field.
   Fixed by `EnvelopeInterceptor` + `safeApiCall`'s error mapper reading
   `code` from the body first, falling back to the real HTTP status.
2. **Refresh envelope/key mismatch.** Interceptor was posting
   `refreshToken`/reading `accessToken` (camelCase, unwrapped) against an
   API that uses `refresh_token`/`access_token` (snake_case, wrapped).
   Fixed, then simplified further once `EnvelopeInterceptor` took over
   the unwrapping.
3. **Retrofit codegen compile error.** Declaring a Retrofit method's
   return type as `HttpResponse<Map<String, dynamic>>` makes
   `retrofit_generator` emit `dynamic.fromJson(...)`, which doesn't
   compile. Fixed by returning the real models directly.
4. **`Logout` usecase bug.** Copy-pasted from `Login`; body called
   `_repository.getCurrentUser()` instead of `_repository.logout()`, and
   was typed to return `User` instead of `Unit`. Fixed.
5. **Private named constructor param.** `AuthRepositoryImpl` used
   `required this._tokenStorage` as a *named* parameter, making the
   external call-site label the private name `_tokenStorage`. Legal Dart,
   bad practice — renamed to a public param name.

---

### App-wide auth + routing (added 2026-09-24, second pass)
- **`AuthBloc`**. App-wide, created once in `MyApp`. States: `unknown` /
  `authenticated(user)` / `unauthenticated` (a single `AuthState` class
  with an `AuthStatus` enum). Events: `AuthSubscriptionRequested` (startup
  session check, then follows auth changes via `emit.onEach`) and
  `AuthLogoutRequested`. Follows the pattern from the bloc library's own
  login tutorial.
- **Repository as the single source of truth.** `AuthRepository` gained
  `Stream<User?> authStateChanges` (used through the `WatchAuthState` use
  case). `AuthRepositoryImpl` emits the user on login and `null` on logout.
  It also subscribes to `SessionExpiredNotifier`, so a failed token refresh
  now actually logs the user out. `LoginBloc` stays screen-scoped and
  never talks to `AuthBloc` directly.
- **`getCurrentUser()`** returns the new `UnauthenticatedFailure` without
  any network call when no token is stored. A 401 also maps to
  `UnauthenticatedFailure`, where it used to map to
  `InvalidCredentialsFailure`.
- **Routing decision: kept `go_router`.** It's driven by auth state: a
  top-level `redirect` (`AppRouter.redirectFor`) plus `refreshListenable`
  via `GoRouterRefreshStream(authBloc.stream)`. Routes: `/` splash,
  `/login`, `/home`. Pages never navigate on login or logout.
- **`HomePage`** (`features/home/`). Shows the user from `AuthBloc` with
  `context.select`, an avatar through `cached_network_image` (falls back to
  an initial), and a logout button.
- **`LoginPage` form.** `Form` + `TextFormField` with validators that
  mirror the `Login` use case's rules (`Login.minPasswordLength`). Submits
  on keyboard "done". The success snackbar is gone because the router
  handles it.
- **`AppBlocObserver`** (`core/bloc/`). Logs transitions and errors, debug
  builds only.
- **Tests.** 40 passing, including new ones for the `Login` use case,
  `AuthRepositoryImpl`, `LoginBloc`, `AuthBloc`, the redirect rules and
  `LoginView` (widget test with `MockBloc`).
- **README** rewritten: run instructions, layer rules, auth flow.

## Still open

- **Token-expiry response shape unconfirmed.** `AuthInterceptor` checks
  both a real HTTP 401 and a wrapped `code: 401`. Nobody has hit
  `/auth/v1/profile` with an expired token in Postman yet to see which one
  this API returns.
- **Offline startup.** `getCurrentUser()` always hits the network. Opening
  the app offline with valid tokens lands on the login screen (tokens are
  kept, so logging in again isn't needed once back online). Fixing this
  needs the local user cache below.
- **Local cache (Drift).** Not started. Blocked on a decision:
  `features/todo_app/` (untracked, in progress) already defines its own
  `AppDatabase`. A `Users` table either goes into a shared database moved
  to `core/` or into a second database.
- **Analytics.** No `AnalyticsService`. It needs a provider chosen
  (Firebase, etc.). `AppBlocObserver` is the natural place to hook
  `login_success`/`login_failure` in.
- **Never run on a device** after these changes. There was no emulator
  available when they landed. Analyzer and tests are clean.

## Git & housekeeping

- The first login pass was committed in `2268e8d`. The second pass above
  is not committed yet.
- No GitHub Actions / CI.
- Minor, low-priority: `core/stroage/` (folder + file names) is a
  long-standing typo for "storage." Harmless, but a rename would touch
  every file that imports it.
- The `features/login/` folder now holds app-wide auth as well as the
  login screen. Renaming it to `features/auth/` would be more accurate
  (a mechanical import change).

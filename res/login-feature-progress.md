# Login / Auth feature — progress tracker

Status snapshot of the login feature build. Update this as work lands —
don't let it go stale.

Last updated: 2026-09-24. Branch: `dev` (all of this is currently
**uncommitted** — see [Git & housekeeping](#git--housekeeping)).

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

## Partial / needs a decision

- **Bloc scope.** Built as a screen-scoped `LoginBloc` (just
  `LoginSubmitted` → success/failure). No `AuthCheckRequested`,
  `AuthLogoutRequested`, `AuthSessionExpired`, or `AuthUnauthenticated`
  state — so nothing currently listens to `SessionExpiredNotifier`, and
  there's no app-wide "am I logged in" state. **Recommendation:** promote
  to a single app-wide `AuthBloc`, per the plan you pasted — needed before
  auto-login or forced-logout-on-session-expiry can work at all.
- **`go_router` vs. manual switch.** `core/router/routes.dart` already
  wires up `go_router` (`MaterialApp.router` in `main.dart`), but the
  step-by-step plan explicitly recommends *not* using it (root widget
  switches between `LoginPage`/`HomePage` off bloc state instead). Nobody
  has picked one — needs a decision before building the app root.
- **`LoginPage` form.** Plain `TextField`s, no `Form`/`TextFormField`/
  validators. Validation currently only happens usecase-side (after
  submit), not inline in the UI.
- **Token-expiry response shape unconfirmed.** `AuthInterceptor` now
  checks both a real HTTP 401 and a wrapped `code: 401`, defensively —
  but nobody has actually hit `/auth/v1/profile` with an expired/invalid
  token in Postman to see which one this API actually returns. Worth
  doing once, for certainty.

## Not started

- **App root wiring.** `main.dart` still just renders `LoginPage` directly
  via the router. No `BlocProvider` at the root, no auto-login check on
  launch, no branching between a login screen and a home screen.
- **`HomePage`.** Doesn't exist. Nothing to land on after a successful
  login besides a snackbar.
- **Local cache (Drift).** No `AppDatabase`, no `Users` table, no offline
  story. `getCurrentUser()` always hits the network; there's no fallback
  to a cached user when offline. Packages (`drift`, `drift_flutter`,
  `drift_dev`) are installed but unused.
- **Analytics + `BlocObserver`.** No `AnalyticsService`, no debug-print
  implementation, no `login_success`/`login_failure` events, no
  `AppBlocObserver` logging transitions.
- **Tests beyond secure storage.** No `Login` usecase test (validation
  rejects bad input without calling the repo), no `AuthRepositoryImpl`
  test (401 → `InvalidCredentialsFailure`, etc.), no `LoginBloc`
  `blocTest`. `bloc_test`/`mocktail` are installed and already proven to
  work (used in the storage test) — just not applied here yet.
- **`cached_network_image`.** Installed, unused — relevant once `HomePage`
  needs to show the user's avatar (`photo` field on `User`).

## Git & housekeeping

- Still on branch `dev`. Everything in this doc past "Step 0" is
  **uncommitted** (modified + untracked files) — nothing has been
  committed since `2be02ea sdhfsdof`.
- `README.md` is still Flutter's default boilerplate — no run
  instructions, no architecture summary, no test credentials.
- No GitHub Actions / CI.
- Minor, low-priority: `core/stroage/` (folder + file names) is a
  long-standing typo for "storage." Harmless, but a rename would touch
  every file that imports it.

---

## Suggested next order of work

1. Decide `go_router` vs. manual switch, and `LoginBloc` → `AuthBloc`
   promotion (both block app-root wiring).
2. Build `AuthBloc` (or extend `LoginBloc`) with the missing events/states,
   wire `SessionExpiredNotifier` into it.
3. Build `HomePage`, wire the app root (auto-login check + branching).
4. Add `Form`/validators to the login screen.
5. Write the three pending tests (usecase, repository, bloc).
6. Commit what's here in small, real commits; update `README.md`.
7. Drift local cache + analytics — lowest priority, cut first if time is
   short (per the original plan's own advice).

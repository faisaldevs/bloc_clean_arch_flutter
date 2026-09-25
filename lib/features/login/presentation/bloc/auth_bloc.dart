import 'package:bloc_clean_arch_flutter/core/usecases/usecase.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/entities/user.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/usecases/get_current_user.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/usecases/logout.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/usecases/watch_auth_state.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// App-wide "who is logged in" state. Provided once at the app root and
/// read by the router to decide which screen to show.
///
/// It never logs anyone in itself — [LoginBloc] does that through the
/// repository, and this bloc hears about it from [WatchAuthState]. That
/// keeps the repository the single source of truth for login, logout and
/// session expiry alike.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this._getCurrentUser,
    required this._watchAuthState,
    required this._logout,
  }) : super(const AuthState.unknown()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthLogoutRequested>(_onLogoutRequested, transformer: droppable());
  }

  final GetCurrentUser _getCurrentUser;
  final WatchAuthState _watchAuthState;
  final Logout _logout;

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    // 1. Where are we at launch? Any failure — no token, expired session,
    //    offline — lands on the login screen.
    final result = await _getCurrentUser(const NoParams());
    emit(
      result.fold(
        (_) => const AuthState.unauthenticated(),
        AuthState.authenticated,
      ),
    );

    // 2. Follow every change after that. `emit.onEach` cancels the
    //    subscription when the bloc closes.
    await emit.onEach<User?>(
      _watchAuthState(),
      onData: (user) => emit(
        user == null
            ? const AuthState.unauthenticated()
            : AuthState.authenticated(user),
      ),
      onError: addError,
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // The repository also reports this on the stream; emitting here too
    // means logout works even before the subscription is running. Equal
    // states are deduplicated, so the UI sees it once.
    await _logout(const NoParams());
    emit(const AuthState.unauthenticated());
  }
}

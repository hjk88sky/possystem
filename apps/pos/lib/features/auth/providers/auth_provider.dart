import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../models/login_request.dart';
import '../models/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copyWith({AuthStatus? status, User? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final hasToken = await _repository.hasToken();
      if (!hasToken) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }
      final user = await _repository.me();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(LoginRequest request) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final response = await _repository.login(request);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
      );
    } catch (e) {
      String message = '로그인에 실패했습니다.';
      if (e is Exception) {
        message = e.toString().replaceFirst('Exception: ', '');
      }
      state = state.copyWith(
        status: AuthStatus.error,
        error: message,
      );
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final notifier = AuthNotifier(repository);
  notifier.checkAuth();
  return notifier;
});

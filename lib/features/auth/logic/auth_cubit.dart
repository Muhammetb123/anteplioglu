import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/token_storage.dart';
import '../data/auth_repository.dart';
import '../models/user.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repo;
  final TokenStorage tokenStorage;

  AuthCubit({required this.repo, required this.tokenStorage}) : super(const AuthUnknown());

  @override
  void emit(AuthState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> bootstrap() async {
    final token = tokenStorage.accessToken;
    if (token == null || token.isEmpty) {
      emit(const AuthUnauthenticated());
      return;
    }

    try {
      final user = await repo.me().timeout(const Duration(seconds: 10));
      emit(AuthAuthenticated(user));
    } catch (_) {
      await tokenStorage.clear();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> signOut() async {
    await repo.signOut();
    emit(const AuthUnauthenticated());
  }

  /// Rol/birim PATCH sonrası gibi durumlarda güncel kullanıcıyı sunucudan çeker.
  Future<void> refreshUser() async {
    final token = tokenStorage.accessToken;
    if (token == null || token.isEmpty) return;

    try {
      final user = await repo.me();
      emit(AuthAuthenticated(user));
    } catch (_) {
      // Oturumu koru; üst katman PATCH'in başarılı olduğunu zaten biliyor.
    }
  }

  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    final res = await repo.signIn(email: email, password: password);
    emit(AuthAuthenticated(res.user));
    return res.user;
  }
}


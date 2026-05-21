import 'package:dio/dio.dart';

import 'package:core/core.dart';
import '../models/signin_response.dart';
import '../models/user.dart';

class AuthRepository {
  final ApiService api;
  final TokenStorage tokenStorage;

  AuthRepository({required this.api, required this.tokenStorage});

  Future<SignInResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await api.post(
        'auth/signin',
        data: {'email': email, 'password': password},
      );
      if (res.data is! Map) {
        throw ApiError(message: 'Sunucudan gecersiz giris yaniti alindi');
      }

      final raw = (res.data as Map).cast<String, dynamic>();
      final data = (raw['data'] is Map ? raw['data'] as Map : raw)
          .cast<String, dynamic>();
      final parsed = SignInResponse.fromJson(data);
      if (parsed.accessToken.isEmpty || parsed.refreshToken.isEmpty) {
        throw ApiError(
          message: 'Giris bilgileri alinmadi, lutfen tekrar deneyin',
        );
      }
      await tokenStorage.saveAccessToken(parsed.accessToken);
      await tokenStorage.saveRefreshToken(parsed.refreshToken);
      return parsed;
    } on ApiError {
      rethrow;
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<User> me() async {
    try {
      final res = await api.get('auth/me');
      final data = (res.data as Map).cast<String, dynamic>();
      return User.fromJson(data);
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<User> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final res = await api.post(
        'auth/signup',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      );
      final data = (res.data as Map).cast<String, dynamic>();
      return User.fromJson(data);
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<void> verifyEmail({required String code}) async {
    try {
      await api.post('auth/verify-email', data: {'code': code});
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<String> forgetPassword({required String email}) async {
    try {
      final res = await api.post(
        'admin/forget-password',
        data: {'email': email},
      );
      final raw = res.data;
      if (raw is Map) {
        final data = raw.cast<String, dynamic>();
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
      return 'If the email exists, a password reset link has been sent';
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  Future<void> signOut() async {
    await tokenStorage.clear();
  }
}

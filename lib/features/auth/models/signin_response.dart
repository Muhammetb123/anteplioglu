import 'user.dart';

class SignInResponse {
  final String accessToken;
  final String refreshToken;
  final int refreshExpiresIn;
  final User user;

  SignInResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.refreshExpiresIn,
    required this.user,
  });

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      accessToken: (json['accessToken'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      refreshExpiresIn: (json['refreshExpiresIn'] ?? 0) is int
          ? (json['refreshExpiresIn'] as int)
          : int.tryParse((json['refreshExpiresIn'] ?? '0').toString()) ?? 0,
      user: User.fromJson((json['user'] as Map).cast<String, dynamic>()),
    );
  }
}


import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _kAccessToken = 'auth.accessToken';
  static const _kRefreshToken = 'auth.refreshToken';

  final SharedPreferences _prefs;

  TokenStorage(this._prefs);

  String? get accessToken => _prefs.getString(_kAccessToken);
  String? get refreshToken => _prefs.getString(_kRefreshToken);

  Future<void> saveAccessToken(String token) async {
    await _prefs.setString(_kAccessToken, token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(_kRefreshToken, token);
  }

  Future<void> clear() async {
    await _prefs.remove(_kAccessToken);
    await _prefs.remove(_kRefreshToken);
  }
}

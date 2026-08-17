import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static final TokenStorage _instance = TokenStorage._internal();
  factory TokenStorage() => _instance;
  TokenStorage._internal();

  static const _accessTokenKey = 'homefix.access_token';
  static const _refreshTokenKey = 'homefix.refresh_token';
  static const _userIdKey = 'homefix.user_id';
  static const _userRoleKey = 'homefix.user_role';
  static const _userEmailKey = 'homefix.user_email';
  static const _userFullNameKey = 'homefix.user_full_name';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _accessToken;
  String? _refreshToken;
  int? _userId;
  String? _userRole;
  String? _userEmail;
  String? _userFullName;
  bool _initialized = false;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  int? get userId => _userId;
  String? get userRole => _userRole;
  String? get userEmail => _userEmail;
  String? get userFullName => _userFullName;
  bool get isInitialized => _initialized;
  bool get hasToken => _accessToken?.isNotEmpty == true;

  Future<void> initialize() async {
    if (_initialized) return;

    _accessToken = await _storage.read(key: _accessTokenKey);
    _refreshToken = await _storage.read(key: _refreshTokenKey);
    final userIdValue = await _storage.read(key: _userIdKey);
    _userId = int.tryParse(userIdValue ?? '');
    _userRole = await _storage.read(key: _userRoleKey);
    _userEmail = await _storage.read(key: _userEmailKey);
    _userFullName = await _storage.read(key: _userFullNameKey);
    _initialized = true;
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    int? userId,
    String? userRole,
    String? userEmail,
    String? userFullName,
  }) async {
    _accessToken = accessToken;
    if (refreshToken != null) _refreshToken = refreshToken;
    if (userId != null) _userId = userId;
    if (userRole != null) _userRole = userRole;
    if (userEmail != null) _userEmail = userEmail;
    if (userFullName != null) _userFullName = userFullName;

    await _storage.write(key: _accessTokenKey, value: _accessToken);
    await _writeOptional(_refreshTokenKey, _refreshToken);
    await _writeOptional(_userIdKey, _userId?.toString());
    await _writeOptional(_userRoleKey, _userRole);
    await _writeOptional(_userEmailKey, _userEmail);
    await _writeOptional(_userFullNameKey, _userFullName);
  }

  Future<void> updateAccessToken(String newAccessToken) async {
    _accessToken = newAccessToken;
    await _storage.write(key: _accessTokenKey, value: newAccessToken);
  }

  Future<void> updateRefreshToken(String newRefreshToken) async {
    _refreshToken = newRefreshToken;
    await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _userRole = null;
    _userEmail = null;
    _userFullName = null;

    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _userRoleKey),
      _storage.delete(key: _userEmailKey),
      _storage.delete(key: _userFullNameKey),
    ]);
  }

  Future<void> _writeOptional(String key, String? value) async {
    if (value == null || value.isEmpty) {
      await _storage.delete(key: key);
      return;
    }
    await _storage.write(key: key, value: value);
  }
}

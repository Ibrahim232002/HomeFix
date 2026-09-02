import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static final TokenStorage _instance = TokenStorage._internal();
  factory TokenStorage() => _instance;
  TokenStorage._internal();

  static const _accessTokenKey = 'homefix.accessToken';
  static const _refreshTokenKey = 'homefix.refreshToken';
  static const _userIdKey = 'homefix.userId';
  static const _userRoleKey = 'homefix.userRole';
  static const _userEmailKey = 'homefix.userEmail';
  static const _userFullNameKey = 'homefix.userFullName';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _accessToken;
  String? _refreshToken;
  int? _userId;
  String? _userRole;
  String? _userEmail;
  String? _userFullName;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  int? get userId => _userId;
  String? get userRole => _userRole;
  String? get userEmail => _userEmail;
  String? get userFullName => _userFullName;

  bool get hasToken => _accessToken != null && _accessToken!.isNotEmpty;
  bool get hasRefreshToken => _refreshToken != null && _refreshToken!.isNotEmpty;

  Future<void> restore() async {
    _accessToken = await _secureStorage.read(key: _accessTokenKey);
    _refreshToken = await _secureStorage.read(key: _refreshTokenKey);

    final userId = await _secureStorage.read(key: _userIdKey);
    _userId = int.tryParse(userId ?? '');
    _userRole = await _secureStorage.read(key: _userRoleKey);
    _userEmail = await _secureStorage.read(key: _userEmailKey);
    _userFullName = await _secureStorage.read(key: _userFullNameKey);
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
    _refreshToken = refreshToken;
    if (userId != null) _userId = userId;
    if (userRole != null) _userRole = userRole;
    if (userEmail != null) _userEmail = userEmail;
    if (userFullName != null) _userFullName = userFullName;

    await _secureStorage.write(key: _accessTokenKey, value: _accessToken);
    if (_refreshToken == null) {
      await _secureStorage.delete(key: _refreshTokenKey);
    } else {
      await _secureStorage.write(key: _refreshTokenKey, value: _refreshToken);
    }
    if (_userId != null) {
      await _secureStorage.write(key: _userIdKey, value: _userId.toString());
    }
    if (_userRole != null) {
      await _secureStorage.write(key: _userRoleKey, value: _userRole);
    }
    if (_userEmail != null) {
      await _secureStorage.write(key: _userEmailKey, value: _userEmail);
    }
    if (_userFullName != null) {
      await _secureStorage.write(key: _userFullNameKey, value: _userFullName);
    }
  }

  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> updateAccessToken(String newAccessToken) async {
    _accessToken = newAccessToken;
    await _secureStorage.write(key: _accessTokenKey, value: newAccessToken);
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _userRole = null;
    _userEmail = null;
    _userFullName = null;

    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _userIdKey),
      _secureStorage.delete(key: _userRoleKey),
      _secureStorage.delete(key: _userEmailKey),
      _secureStorage.delete(key: _userFullNameKey),
    ]);
  }
}

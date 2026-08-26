class TokenStorage {
  static final TokenStorage _instance = TokenStorage._internal();
  factory TokenStorage() => _instance;
  TokenStorage._internal();

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

  void saveTokens({
    required String accessToken,
    String? refreshToken,
    int? userId,
    String? userRole,
    String? userEmail,
    String? userFullName,
  }) {
    _accessToken = accessToken;
    if (refreshToken != null) _refreshToken = refreshToken;
    if (userId != null) _userId = userId;
    if (userRole != null) _userRole = userRole;
    if (userEmail != null) _userEmail = userEmail;
    if (userFullName != null) _userFullName = userFullName;
  }

  void updateTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  void updateAccessToken(String newAccessToken) {
    _accessToken = newAccessToken;
  }

  void clear() {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _userRole = null;
    _userEmail = null;
    _userFullName = null;
  }
}

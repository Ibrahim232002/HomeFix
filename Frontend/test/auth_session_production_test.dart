import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../lib/auth/auth_session_provider.dart';
import '../lib/core/constants/api_constants.dart';
import '../lib/core/network/api_client.dart';
import '../lib/core/storage/token_storage.dart';
import '../lib/models/api_dtos.dart';

class FakeStorage implements IAuthSessionStorage {
  String? _accessToken;
  String? _refreshToken;
  int? _userId;
  String? _role;
  String? _email;
  String? _name;
  bool initialized = false;
  int clearCalls = 0;

  @override
  String? get accessToken => _accessToken;
  @override
  String? get refreshToken => _refreshToken;
  @override
  int? get userId => _userId;
  @override
  String? get userRole => _role;
  @override
  String? get userEmail => _email;
  @override
  String? get userFullName => _name;
  @override
  bool get isInitialized => initialized;
  @override
  bool get hasToken => _accessToken?.isNotEmpty == true;

  void seed({String? accessToken, String? refreshToken, int? userId, String? role, String? email, String? name}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userId = userId;
    _role = role;
    _email = email;
    _name = name;
  }

  @override
  Future<void> initialize() async => initialized = true;

  @override
  Future<void> saveTokens({required String accessToken, String? refreshToken, int? userId, String? userRole, String? userEmail, String? userFullName}) async {
    _accessToken = accessToken;
    if (refreshToken != null) _refreshToken = refreshToken;
    if (userId != null) _userId = userId;
    if (userRole != null) _role = userRole;
    if (userEmail != null) _email = userEmail;
    if (userFullName != null) _name = userFullName;
  }

  @override
  Future<void> updateAccessToken(String newAccessToken) async => _accessToken = newAccessToken;

  @override
  Future<void> updateRefreshToken(String newRefreshToken) async => _refreshToken = newRefreshToken;

  @override
  Future<void> clear() async {
    clearCalls++;
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _role = null;
    _email = null;
    _name = null;
  }
}

class FakeAuthRepository implements IAuthRepository {
  AuthResponseDto loginResponse = AuthResponseDto(accessToken: 'access', refreshToken: 'refresh', userId: 7, email: 'customer@example.com', fullName: 'Customer', role: 'Customer');
  bool refreshResult = true;
  int refreshCalls = 0;
  Map<String, dynamic>? currentUser;

  @override
  Future<dynamic> register(RegisterRequest request) async => {'requiresEmailVerification': true};

  @override
  Future<AuthResponseDto> login(LoginRequest request) async => loginResponse;

  @override
  Future<void> logout() async {}

  @override
  Future<bool> refreshToken() async {
    refreshCalls++;
    return refreshResult;
  }

  @override
  Future<dynamic> getCurrentUser() async => currentUser ?? {'userId': 7, 'name': 'Customer', 'email': 'customer@example.com', 'role': 'Customer'};
}

class RefreshTestHttpClient extends http.BaseClient {
  int protectedCalls = 0;
  int refreshCalls = 0;
  bool refreshSucceeds = true;
  final FakeStorage storage;

  RefreshTestHttpClient(this.storage);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final path = request.url.path;
    if (path == ApiConstants.refresh) {
      refreshCalls++;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      if (!refreshSucceeds) {
        return http.StreamedResponse(Stream.value(utf8.encode('{"message":"refresh failed"}')), 401);
      }
      return http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode({'accessToken': 'rotated-access', 'refreshToken': 'rotated-refresh'}))),
        200,
      );
    }

    if (path == '/api/protected') {
      protectedCalls++;
      if (storage.accessToken != 'rotated-access') {
        return http.StreamedResponse(Stream.value(utf8.encode('{"message":"expired"}')), 401);
      }
      return http.StreamedResponse(Stream.value(utf8.encode('{"ok":true}')), 200);
    }

    return http.StreamedResponse(Stream.value(utf8.encode('{"message":"unexpected"}')), 500);
  }
}

void main() {
  test('startup restore uses persisted session and reaches authenticated', () async {
    final storage = FakeStorage()..seed(accessToken: 'access', refreshToken: 'refresh', userId: 7, role: 'Customer');
    final auth = FakeAuthRepository();
    final provider = AuthSessionProvider(authRepository: auth, tokenStorage: storage, apiClient: ApiClient());

    expect(provider.status, AuthSessionStatus.restoringSession);
    await provider.restoreSession();

    expect(provider.status, AuthSessionStatus.authenticated);
    expect(provider.user?.id, '7');
    expect(provider.role.nameStr, 'Customer');
  });

  test('refresh updates session state and preserves rotated tokens', () async {
    final storage = FakeStorage()..seed(accessToken: 'expired-access', refreshToken: 'old-refresh', userId: 7, role: 'Customer');
    final auth = FakeAuthRepository()..currentUser = {'userId': 7, 'name': 'Customer', 'email': 'customer@example.com', 'role': 'Customer'};
    final provider = AuthSessionProvider(authRepository: auth, tokenStorage: storage, apiClient: ApiClient());

    final success = await provider.refreshSession();

    expect(success, isTrue);
    expect(provider.status, AuthSessionStatus.authenticated);
    expect(storage.refreshToken, 'old-refresh');
    expect(auth.refreshCalls, 1);
  });

  test('refresh failure clears the local session', () async {
    final storage = FakeStorage()..seed(accessToken: 'expired', refreshToken: 'refresh');
    final auth = FakeAuthRepository()..refreshResult = false;
    final provider = AuthSessionProvider(authRepository: auth, tokenStorage: storage, apiClient: ApiClient());

    final success = await provider.refreshSession();

    expect(success, isFalse);
    expect(provider.status, AuthSessionStatus.unauthenticated);
    expect(storage.hasToken, isFalse);
    expect(storage.refreshToken, isNull);
    expect(storage.clearCalls, greaterThan(0));
  });

  test('logout clears local session even when repository logout is invoked', () async {
    final storage = FakeStorage()..seed(accessToken: 'access', refreshToken: 'refresh');
    final auth = FakeAuthRepository();
    final provider = AuthSessionProvider(authRepository: auth, tokenStorage: storage, apiClient: ApiClient());

    await provider.logout();

    expect(provider.status, AuthSessionStatus.unauthenticated);
    expect(storage.hasToken, isFalse);
    expect(storage.refreshToken, isNull);
  });

  test('concurrent expired requests share exactly one refresh request and rotate both tokens', () async {
    final storage = FakeStorage()..seed(accessToken: 'expired-access', refreshToken: 'old-refresh');
    final client = RefreshTestHttpClient(storage);
    final api = ApiClient.testing(httpClient: client, tokenStorage: storage);

    final results = await Future.wait([
      api.get('/api/protected'),
      api.get('/api/protected'),
      api.get('/api/protected'),
    ]);

    expect(results, everyElement({'ok': true}));
    expect(client.refreshCalls, 1);
    expect(storage.accessToken, 'rotated-access');
    expect(storage.refreshToken, 'rotated-refresh');
  });

  test('Auth endpoints never recursively trigger token refresh', () async {
    final storage = FakeStorage()..seed(accessToken: 'expired-access', refreshToken: 'old-refresh');
    final client = RefreshTestHttpClient(storage);
    final api = ApiClient.testing(httpClient: client, tokenStorage: storage);

    await expectLater(api.get('/api/Auth/me'), throwsA(isA<UnauthorizedException>()));

    expect(client.refreshCalls, 0);
    expect(storage.refreshToken, 'old-refresh');
  });
}

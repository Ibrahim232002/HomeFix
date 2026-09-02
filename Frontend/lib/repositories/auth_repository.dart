import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/api_dtos.dart';
import '../models/user_model.dart';

abstract class IAuthRepository {
  Future<dynamic> register(RegisterRequest request);
  Future<AuthResponseDto> login(LoginRequest request);
  Future<void> logout();
  Future<bool> refreshToken();
  Future<UserModel?> restoreSession();
  Future<dynamic> getCurrentUser();
}

class AuthRepository implements IAuthRepository {
  final ApiClient _client = ApiClient();
  final TokenStorage _tokenStorage = TokenStorage();

  @override
  Future<dynamic> register(RegisterRequest request) async {
    final response = await _client.post(
      ApiConstants.register,
      body: request.toJson(),
      includeAuth: false,
    );
    return response;
  }

  @override
  Future<AuthResponseDto> login(LoginRequest request) async {
    final response = await _client.post(
      ApiConstants.login,
      body: request.toJson(),
      includeAuth: false,
    );

    if (response is Map<String, dynamic>) {
      final authDto = AuthResponseDto.fromJson(response);
      await _tokenStorage.saveTokens(
        accessToken: authDto.accessToken,
        refreshToken: authDto.refreshToken,
        userId: authDto.userId,
        userRole: authDto.role,
        userEmail: authDto.email ?? request.email,
        userFullName: authDto.fullName,
      );
      return authDto;
    }
    throw Exception('استجابة تسجيل الدخول غير صالحة');
  }

  @override
  Future<void> logout() async {
    final refreshToken = _tokenStorage.refreshToken;
    if (refreshToken != null) {
      try {
        await _client.post(
          ApiConstants.logout,
          body: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
        );
      } catch (_) {
        // Local session is cleared even if the server-side revoke fails.
      }
    }
    await _tokenStorage.clear();
  }

  @override
  Future<bool> refreshToken() async {
    final refreshToken = _tokenStorage.refreshToken;
    if (refreshToken == null) return false;

    try {
      final response = await _client.post(
        ApiConstants.refresh,
        body: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
        includeAuth: false,
      );

      if (response is Map<String, dynamic>) {
        final accessToken = response['accessToken'] ?? response['token'];
        final newRefreshToken = response['refreshToken'];
        if (accessToken != null && newRefreshToken != null) {
          await _tokenStorage.updateTokens(
            accessToken: accessToken.toString(),
            refreshToken: newRefreshToken.toString(),
          );
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<UserModel?> restoreSession() async {
    await _tokenStorage.restore();
    if (!_tokenStorage.hasRefreshToken) {
      await _tokenStorage.clear();
      return null;
    }

    final refreshed = await refreshToken();
    if (!refreshed) {
      await _tokenStorage.clear();
      return null;
    }

    try {
      final response = await getCurrentUser();
      if (response is! Map<String, dynamic>) {
        await _tokenStorage.clear();
        return null;
      }

      final userId = int.tryParse(response['userId']?.toString() ?? '');
      final roleValue = response['role']?.toString();
      if (userId == null || userId <= 0 || roleValue == null || roleValue.isEmpty) {
        await _tokenStorage.clear();
        return null;
      }

      final fullName = response['name']?.toString() ?? _tokenStorage.userFullName ?? 'المستخدم';
      final email = response['email']?.toString() ?? _tokenStorage.userEmail ?? '';
      final role = UserRole.fromString(roleValue);

      await _tokenStorage.saveTokens(
        accessToken: _tokenStorage.accessToken!,
        refreshToken: _tokenStorage.refreshToken,
        userId: userId,
        userRole: role.nameStr,
        userEmail: email,
        userFullName: fullName,
      );

      return UserModel(
        id: userId.toString(),
        fullName: fullName,
        email: email,
        phoneNumber: '',
        role: role,
        createdAt: '',
      );
    } catch (_) {
      await _tokenStorage.clear();
      return null;
    }
  }

  @override
  Future<dynamic> getCurrentUser() async {
    return _client.get(ApiConstants.me);
  }
}

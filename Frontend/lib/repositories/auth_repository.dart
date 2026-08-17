import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/api_dtos.dart';

abstract class IAuthRepository {
  Future<dynamic> register(RegisterRequest request);
  Future<AuthResponseDto> login(LoginRequest request);
  Future<void> logout();
  Future<bool> refreshToken();
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
      if (authDto.accessToken.isEmpty) {
        throw Exception('استجابة تسجيل الدخول لا تحتوي على رمز وصول صالح');
      }
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
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _client.post(
          ApiConstants.logout,
          body: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
        );
      }
    } finally {
      await _tokenStorage.clear();
    }
  }

  @override
  Future<bool> refreshToken() async {
    final refreshToken = _tokenStorage.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokenStorage.clear();
      return false;
    }

    try {
      final response = await _client.post(
        ApiConstants.refresh,
        body: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
        includeAuth: false,
        allowAutoRefresh: false,
      );

      if (response is Map<String, dynamic>) {
        final newAccessToken = response['accessToken'] ?? response['token'];
        final newRefreshToken = response['refreshToken'];
        if (newAccessToken != null && newRefreshToken != null) {
          await _tokenStorage.saveTokens(
            accessToken: newAccessToken.toString(),
            refreshToken: newRefreshToken.toString(),
          );
          return true;
        }
      }
    } catch (_) {
      // A failed refresh invalidates the local session.
    }

    await _tokenStorage.clear();
    return false;
  }

  @override
  Future<dynamic> getCurrentUser() async {
    return _client.get(ApiConstants.me);
  }
}

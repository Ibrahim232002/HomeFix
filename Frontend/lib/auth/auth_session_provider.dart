import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/api_dtos.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

enum AuthSessionStatus {
  restoringSession,
  unauthenticated,
  authenticated,
  refreshing,
}

class AuthSessionProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final TokenStorage _tokenStorage = TokenStorage();
  final ApiClient _apiClient = ApiClient();

  AuthSessionStatus _status = AuthSessionStatus.restoringSession;
  UserModel? _user;
  String? _errorMessage;
  String? _infoMessage;
  bool _disposed = false;

  AuthSessionProvider() {
    _apiClient.refreshInProgress.addListener(_handleRefreshStateChanged);
    _apiClient.onSessionExpired = _handleSessionExpired;
  }

  AuthSessionStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;
  bool get isRestoringSession => _status == AuthSessionStatus.restoringSession;
  bool get isAuthenticated => _status == AuthSessionStatus.authenticated ||
      _status == AuthSessionStatus.refreshing;
  bool get isRefreshing => _status == AuthSessionStatus.refreshing;
  UserRole get role => _user?.role ?? UserRole.customer;

  Future<void> restoreSession() async {
    if (_status != AuthSessionStatus.restoringSession) return;

    try {
      await _tokenStorage.initialize();
      if (!_tokenStorage.hasToken &&
          (_tokenStorage.refreshToken == null || _tokenStorage.refreshToken!.isEmpty)) {
        _setUnauthenticated();
        return;
      }

      final currentUser = await _loadCurrentUser();
      if (currentUser != null) {
        _user = currentUser;
        _setStatus(AuthSessionStatus.authenticated);
      } else {
        await _tokenStorage.clear();
        _setUnauthenticated();
      }
    } catch (e) {
      _errorMessage = _safeMessage(e);
      await _tokenStorage.clear();
      _setUnauthenticated(notify: false);
      _notify();
    }
  }

  Future<bool> login(String email, String password) async {
    _clearMessages();
    _setStatus(AuthSessionStatus.unauthenticated);

    try {
      final response = await _authRepository.login(
        LoginRequest(email: email.trim(), password: password),
      );
      _user = _userFromAuthResponse(response);
      _setStatus(AuthSessionStatus.authenticated);
      return true;
    } catch (e) {
      _errorMessage = _safeMessage(e);
      _setStatus(AuthSessionStatus.unauthenticated);
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required UserRole role,
  }) async {
    _clearMessages();

    try {
      final response = await _authRepository.register(
        RegisterRequest(
          fullName: fullName.trim(),
          email: email.trim(),
          phoneNumber: phoneNumber.trim(),
          password: password,
          role: role.nameStr,
        ),
      );

      final requiresVerification = response is Map<String, dynamic>
          ? response['requiresEmailVerification'] == true
          : false;

      _infoMessage = requiresVerification
          ? 'تم إنشاء الحساب. يرجى تأكيد البريد الإلكتروني ثم تسجيل الدخول.'
          : 'تم إنشاء الحساب. يمكنك تسجيل الدخول الآن.';
      _setStatus(AuthSessionStatus.unauthenticated);
      return true;
    } catch (e) {
      _errorMessage = _safeMessage(e);
      _setStatus(AuthSessionStatus.unauthenticated);
      return false;
    }
  }

  Future<bool> verifyEmail({required String email, required String code}) async {
    _clearMessages();
    try {
      await _apiClient.post(
        ApiConstants.verifyEmail,
        body: VerifyCodeRequest(email: email.trim(), code: code.trim()).toJson(),
        includeAuth: false,
      );
      _infoMessage = 'تم تأكيد البريد الإلكتروني. يمكنك تسجيل الدخول الآن.';
      _notify();
      return true;
    } catch (e) {
      _errorMessage = _safeMessage(e);
      _notify();
      return false;
    }
  }

  Future<void> logout() async {
    _clearMessages();
    try {
      await _authRepository.logout();
    } catch (e) {
      _errorMessage = _safeMessage(e);
    } finally {
      await _tokenStorage.clear();
      _user = null;
      _setUnauthenticated();
    }
  }

  Future<bool> refreshSession() async {
    final refreshToken = _tokenStorage.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokenStorage.clear();
      _setUnauthenticated();
      return false;
    }

    _clearMessages();
    _setStatus(AuthSessionStatus.refreshing);
    final success = await _authRepository.refreshToken();
    if (!success) {
      _user = null;
      _setUnauthenticated();
      return false;
    }

    final refreshedUser = await _loadCurrentUser();
    if (refreshedUser == null) {
      await _tokenStorage.clear();
      _user = null;
      _setUnauthenticated();
      return false;
    }

    _user = refreshedUser;
    _setStatus(AuthSessionStatus.authenticated);
    return true;
  }

  Future<UserModel?> _loadCurrentUser() async {
    final response = await _authRepository.getCurrentUser();
    if (response is! Map<String, dynamic>) return null;

    final id = response['userId']?.toString();
    if (id == null || id.isEmpty) return null;

    final role = UserRole.fromString(response['role']?.toString() ?? 'Customer');
    await _tokenStorage.saveTokens(
      accessToken: _tokenStorage.accessToken ?? '',
      userId: int.tryParse(id),
      userRole: role.nameStr,
      userEmail: response['email']?.toString(),
      userFullName: response['name']?.toString(),
    );

    return UserModel(
      id: id,
      fullName: response['name']?.toString() ?? _tokenStorage.userFullName ?? '',
      email: response['email']?.toString() ?? _tokenStorage.userEmail ?? '',
      phoneNumber: '',
      role: role,
      createdAt: '',
    );
  }

  UserModel _userFromAuthResponse(AuthResponseDto response) {
    return UserModel(
      id: (response.userId ?? _tokenStorage.userId ?? 0).toString(),
      fullName: response.fullName ?? _tokenStorage.userFullName ?? '',
      email: response.email ?? _tokenStorage.userEmail ?? '',
      phoneNumber: '',
      role: UserRole.fromString(response.role ?? 'Customer'),
      createdAt: '',
    );
  }

  void _handleRefreshStateChanged() {
    if (_apiClient.refreshInProgress.value) {
      if (_status == AuthSessionStatus.authenticated) {
        _setStatus(AuthSessionStatus.refreshing);
      }
      return;
    }

    if (_status == AuthSessionStatus.refreshing && _tokenStorage.hasToken) {
      _setStatus(AuthSessionStatus.authenticated);
    }
  }

  void _handleSessionExpired() {
    _user = null;
    _setStatus(AuthSessionStatus.unauthenticated);
  }

  void _setStatus(AuthSessionStatus status, {bool notify = true}) {
    _status = status;
    if (notify) _notify();
  }

  void _setUnauthenticated({bool notify = true}) {
    _status = AuthSessionStatus.unauthenticated;
    if (notify) _notify();
  }

  void _clearMessages() {
    _errorMessage = null;
    _infoMessage = null;
  }

  String _safeMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    return message.isEmpty ? 'حدث خطأ غير متوقع.' : message;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _apiClient.refreshInProgress.removeListener(_handleRefreshStateChanged);
    if (identical(_apiClient.onSessionExpired, _handleSessionExpired)) {
      _apiClient.onSessionExpired = null;
    }
    super.dispose();
  }
}

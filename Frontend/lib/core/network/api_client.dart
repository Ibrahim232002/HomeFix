import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _httpClient = http.Client();
  final TokenStorage _tokenStorage = TokenStorage();
  final ValueNotifier<bool> refreshInProgress = ValueNotifier<bool>(false);

  Future<bool>? _refreshOperation;
  VoidCallback? onSessionExpired;

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final uri = Uri.parse('${ApiConstants.baseUrl}$cleanEndpoint');
    if (queryParameters == null || queryParameters.isEmpty) return uri;

    final stringParams = queryParameters.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );
    return uri.replace(queryParameters: stringParams);
  }

  Map<String, String> _buildHeaders({
    bool includeAuth = true,
    Map<String, String>? customHeaders,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _tokenStorage.hasToken) {
      headers['Authorization'] = 'Bearer ${_tokenStorage.accessToken}';
    }
    if (customHeaders != null) headers.addAll(customHeaders);
    return headers;
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
    bool allowAutoRefresh = true,
  }) {
    return _sendRequest(
      () async {
        final response = await _httpClient
            .get(
              _buildUri(endpoint, queryParameters),
              headers: _buildHeaders(includeAuth: includeAuth),
            )
            .timeout(ApiConstants.timeoutDuration);
        return _handleResponse(response);
      },
      endpoint: endpoint,
      allowAutoRefresh: allowAutoRefresh,
    );
  }

  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
    bool allowAutoRefresh = true,
  }) {
    return _sendRequest(
      () async {
        final response = await _httpClient
            .post(
              _buildUri(endpoint, queryParameters),
              headers: _buildHeaders(includeAuth: includeAuth),
              body: body == null ? null : jsonEncode(body),
            )
            .timeout(ApiConstants.timeoutDuration);
        return _handleResponse(response);
      },
      endpoint: endpoint,
      allowAutoRefresh: allowAutoRefresh,
    );
  }

  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
    bool allowAutoRefresh = true,
  }) {
    return _sendRequest(
      () async {
        final response = await _httpClient
            .put(
              _buildUri(endpoint, queryParameters),
              headers: _buildHeaders(includeAuth: includeAuth),
              body: body == null ? null : jsonEncode(body),
            )
            .timeout(ApiConstants.timeoutDuration);
        return _handleResponse(response);
      },
      endpoint: endpoint,
      allowAutoRefresh: allowAutoRefresh,
    );
  }

  Future<dynamic> delete(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
    bool allowAutoRefresh = true,
  }) {
    return _sendRequest(
      () async {
        final response = await _httpClient
            .delete(
              _buildUri(endpoint, queryParameters),
              headers: _buildHeaders(includeAuth: includeAuth),
              body: body == null ? null : jsonEncode(body),
            )
            .timeout(ApiConstants.timeoutDuration);
        return _handleResponse(response);
      },
      endpoint: endpoint,
      allowAutoRefresh: allowAutoRefresh,
    );
  }

  Future<dynamic> _sendRequest(
    Future<dynamic> Function() requestFn, {
    required String endpoint,
    required bool allowAutoRefresh,
  }) async {
    try {
      return await requestFn();
    } on UnauthorizedException {
      final isAuthEndpoint = endpoint.startsWith('/api/Auth/');
      if (!allowAutoRefresh || isAuthEndpoint || _tokenStorage.refreshToken == null) {
        rethrow;
      }

      final refreshed = await _tryRefreshToken();
      if (!refreshed) {
        await _expireLocalSession();
        rethrow;
      }

      try {
        return await requestFn();
      } on UnauthorizedException {
        await _expireLocalSession();
        rethrow;
      }
    } on SocketException catch (e) {
      throw NetworkException('تعذر الاتصال بالخادم: ${e.message}');
    } on TimeoutException {
      throw TimeoutException('انتهت مهلة الطلب، يرجى المحاولة مرة أخرى');
    } on FormatException catch (e) {
      throw ApiException('خطأ في معالجة بيانات الخادم: ${e.message}');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('حدث خطأ غير متوقع: $e');
    }
  }

  Future<bool> _tryRefreshToken() {
    final inFlight = _refreshOperation;
    if (inFlight != null) return inFlight;

    final operation = _refreshTokenInternal();
    _refreshOperation = operation;
    operation.whenComplete(() {
      if (identical(_refreshOperation, operation)) _refreshOperation = null;
    });
    return operation;
  }

  Future<bool> _refreshTokenInternal() async {
    final refreshToken = _tokenStorage.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return false;

    refreshInProgress.value = true;
    try {
      final response = await _httpClient
          .post(
            _buildUri(ApiConstants.refresh),
            headers: _buildHeaders(includeAuth: false),
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(ApiConstants.timeoutDuration);

      if (response.statusCode != 200) return false;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return false;

      final newAccessToken = decoded['accessToken'] ?? decoded['token'];
      final newRefreshToken = decoded['refreshToken'];
      if (newAccessToken == null || newRefreshToken == null) return false;

      await _tokenStorage.saveTokens(
        accessToken: newAccessToken.toString(),
        refreshToken: newRefreshToken.toString(),
      );
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('HomeFix session refresh failed: ${e.runtimeType}');
      return false;
    } finally {
      refreshInProgress.value = false;
    }
  }

  Future<void> _expireLocalSession() async {
    await _tokenStorage.clear();
    onSessionExpired?.call();
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body.trim();
    dynamic decodedData;

    if (body.isNotEmpty) {
      try {
        decodedData = jsonDecode(body);
      } catch (_) {
        decodedData = body;
      }
    }

    if (statusCode >= 200 && statusCode < 300) return decodedData;

    String errorMessage = 'حدث خطأ في الخادم';
    Map<String, dynamic>? validationErrors;

    if (decodedData is Map<String, dynamic>) {
      if (decodedData['message'] != null) {
        errorMessage = decodedData['message'].toString();
      } else if (decodedData['title'] != null) {
        errorMessage = decodedData['title'].toString();
      } else if (decodedData['errors'] is Map) {
        validationErrors = Map<String, dynamic>.from(decodedData['errors'] as Map);
        final firstError = validationErrors.values.whereType<List>().expand((e) => e).firstOrNull;
        if (firstError != null) errorMessage = firstError.toString();
      }
    } else if (decodedData is String && decodedData.isNotEmpty) {
      errorMessage = decodedData;
    }

    switch (statusCode) {
      case 400:
        throw BadRequestException(errorMessage, data: decodedData, validationErrors: validationErrors);
      case 401:
        throw UnauthorizedException(errorMessage);
      case 403:
        throw ForbiddenException(errorMessage);
      case 404:
        throw NotFoundException(errorMessage);
      default:
        throw ServerException(errorMessage.isNotEmpty ? errorMessage : 'خطأ في الخادم ($statusCode)');
    }
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

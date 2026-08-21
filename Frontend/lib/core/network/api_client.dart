import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
  bool _isRefreshingToken = false;

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullUrl = '${ApiConstants.baseUrl}$cleanEndpoint';
    final uri = Uri.parse(fullUrl);
    
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final stringParams = queryParameters.map((key, value) => MapEntry(key, value?.toString() ?? ''));
      return uri.replace(queryParameters: stringParams);
    }
    return uri;
  }

  Map<String, String> _buildHeaders({bool includeAuth = true, Map<String, String>? customHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _tokenStorage.hasToken) {
      headers['Authorization'] = 'Bearer ${_tokenStorage.accessToken}';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
  }) async {
    return _sendRequest(() async {
      final uri = _buildUri(endpoint, queryParameters);
      final headers = _buildHeaders(includeAuth: includeAuth);
      final response = await _httpClient
          .get(uri, headers: headers)
          .timeout(ApiConstants.timeoutDuration);
      _logHttpTransaction(method: 'GET', uri: uri, body: null, response: response);
      return _handleResponse(response);
    }, endpoint: endpoint);
  }

  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
  }) async {
    return _sendRequest(() async {
      final uri = _buildUri(endpoint, queryParameters);
      final headers = _buildHeaders(includeAuth: includeAuth);
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _httpClient
          .post(uri, headers: headers, body: encodedBody)
          .timeout(ApiConstants.timeoutDuration);
      _logHttpTransaction(method: 'POST', uri: uri, body: body, response: response);
      return _handleResponse(response);
    }, endpoint: endpoint);
  }

  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
  }) async {
    return _sendRequest(() async {
      final uri = _buildUri(endpoint, queryParameters);
      final headers = _buildHeaders(includeAuth: includeAuth);
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _httpClient
          .put(uri, headers: headers, body: encodedBody)
          .timeout(ApiConstants.timeoutDuration);
      _logHttpTransaction(method: 'PUT', uri: uri, body: body, response: response);
      return _handleResponse(response);
    }, endpoint: endpoint);
  }

  Future<dynamic> delete(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
  }) async {
    return _sendRequest(() async {
      final uri = _buildUri(endpoint, queryParameters);
      final headers = _buildHeaders(includeAuth: includeAuth);
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _httpClient
          .delete(uri, headers: headers, body: encodedBody)
          .timeout(ApiConstants.timeoutDuration);
      _logHttpTransaction(method: 'DELETE', uri: uri, body: body, response: response);
      return _handleResponse(response);
    }, endpoint: endpoint);
  }

  void _logHttpTransaction({
    required String method,
    required Uri uri,
    required dynamic body,
    required http.Response response,
  }) {
    final safeBody = _sanitizeDiagnosticBody(body);
    print('[HTTP]');
    print('METHOD: $method');
    print('URL: $uri');
    print('BODY: ${safeBody ?? 'null'}');
    print('STATUS: ${response.statusCode}');
    print('RESPONSE: ${response.body}');
  }

  dynamic _sanitizeDiagnosticBody(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return value.map((key, item) {
        final normalizedKey = key.toString().toLowerCase();
        const sensitiveKeys = {
          'authorization',
          'password',
          'refreshpassword',
          'refreshtoken',
          'accesstoken',
          'token',
          'secret',
          'code',
        };
        return MapEntry(
          key,
          sensitiveKeys.contains(normalizedKey) ? '***REDACTED***' : _sanitizeDiagnosticBody(item),
        );
      });
    }
    if (value is Iterable) {
      return value.map(_sanitizeDiagnosticBody).toList();
    }
    return value;
  }

  Future<dynamic> _sendRequest(Future<dynamic> Function() requestFn, {required String endpoint}) async {
    try {
      return await requestFn();
    } on UnauthorizedException {
      // Attempt token refresh if refresh token is present
      if (_tokenStorage.refreshToken != null && !_isRefreshingToken && !endpoint.contains('/api/Auth/')) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          // Retry original request once
          return await requestFn();
        }
      }
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException('تعذر الاتصال بالخادم: ${e.message}');
    } on TimeoutException catch (_) {
      throw TimeoutException('انتهت مهلة الطلب، يرجى المحاولة مرة أخرى');
    } on FormatException catch (e) {
      throw ApiException('خطأ في معالجة بيانات الخادم: ${e.message}');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('حدث خطأ غير متوقع: $e');
    }
  }

  Future<bool> _tryRefreshToken() async {
    if (_tokenStorage.refreshToken == null) return false;
    _isRefreshingToken = true;
    try {
      final uri = _buildUri(ApiConstants.refresh);
      final headers = _buildHeaders(includeAuth: false);
      final body = jsonEncode({'refreshToken': _tokenStorage.refreshToken});
      
      final response = await _httpClient.post(uri, headers: headers, body: body);
      _logHttpTransaction(method: 'POST', uri: uri, body: {'refreshToken': '***REDACTED***'}, response: response);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('token')) {
          _tokenStorage.updateAccessToken(data['token']);
          return true;
        } else if (data is Map<String, dynamic> && data.containsKey('accessToken')) {
          _tokenStorage.updateAccessToken(data['accessToken']);
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshingToken = false;
    }
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

    if (statusCode >= 200 && statusCode < 300) {
      return decodedData;
    }

    // Extract error message if present in response
    String errorMessage = 'حدث خطأ في الخادم';
    Map<String, dynamic>? validationErrors;

    if (decodedData is Map<String, dynamic>) {
      if (decodedData.containsKey('message') && decodedData['message'] != null) {
        errorMessage = decodedData['message'].toString();
      } else if (decodedData.containsKey('title') && decodedData['title'] != null) {
        errorMessage = decodedData['title'].toString();
      } else if (decodedData.containsKey('errors') && decodedData['errors'] is Map) {
        validationErrors = Map<String, dynamic>.from(decodedData['errors'] as Map);
        final firstError = validationErrors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          errorMessage = firstError.first.toString();
        }
      }
    } else if (decodedData is String && decodedData.isNotEmpty) {
      errorMessage = decodedData;
    }

    switch (statusCode) {
      case 400:
        throw BadRequestException(
          errorMessage.isNotEmpty ? errorMessage : 'بيانات الطلب غير صحيحة',
          data: decodedData,
          validationErrors: validationErrors,
        );
      case 401:
        throw UnauthorizedException(
          errorMessage.isNotEmpty ? errorMessage : 'انتهت صلاحية الجلسة أو يجب تسجيل الدخول',
        );
      case 403:
        throw ForbiddenException(
          errorMessage.isNotEmpty ? errorMessage : 'ليس لديك الصلاحية للوصول لهذا المورد',
        );
      case 404:
        throw NotFoundException(
          errorMessage.isNotEmpty ? errorMessage : 'المورد المطلوب غير موجود',
        );
      case 500:
      default:
        throw ServerException(
          errorMessage.isNotEmpty ? errorMessage : 'خطأ في الخادم ($statusCode)',
        );
    }
  }
}

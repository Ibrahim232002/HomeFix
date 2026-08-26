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
      return _handleResponse(response);
    }, endpoint: endpoint);
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
      final currentRefreshToken = _tokenStorage.refreshToken;
      if (currentRefreshToken == null) return false;
      final body = jsonEncode({'refreshToken': currentRefreshToken});
      
      final response = await _httpClient.post(uri, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final accessToken = data['accessToken'] ?? data['token'];
          final newRefreshToken = data['refreshToken'];
          if (accessToken != null && newRefreshToken != null) {
            _tokenStorage.updateTokens(
              accessToken: accessToken.toString(),
              refreshToken: newRefreshToken.toString(),
            );
            return true;
          }
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

import 'api_exception.dart';

enum ApiStatus { initial, loading, success, error }

class ApiResponse<T> {
  final ApiStatus status;
  final T? data;
  final ApiException? error;
  final String? message;

  ApiResponse._({
    required this.status,
    this.data,
    this.error,
    this.message,
  });

  factory ApiResponse.initial() => ApiResponse._(status: ApiStatus.initial);

  factory ApiResponse.loading([String? message]) => ApiResponse._(
        status: ApiStatus.loading,
        message: message,
      );

  factory ApiResponse.success(T data, [String? message]) => ApiResponse._(
        status: ApiStatus.success,
        data: data,
        message: message,
      );

  factory ApiResponse.error(ApiException error) => ApiResponse._(
        status: ApiStatus.error,
        error: error,
        message: error.message,
      );

  bool get isInitial => status == ApiStatus.initial;
  bool get isLoading => status == ApiStatus.loading;
  bool get isSuccess => status == ApiStatus.success;
  bool get isError => status == ApiStatus.error;
}

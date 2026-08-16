class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException(status: $statusCode, message: $message)';
}

class BadRequestException extends ApiException {
  final Map<String, dynamic>? validationErrors;
  
  BadRequestException(String message, {dynamic data, this.validationErrors})
      : super(message, statusCode: 400, data: data);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'انتهت صلاحية الجلسة أو يجب تسجيل الدخول'])
      : super(message, statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException([String message = 'ليس لديك الصلاحية للوصول إلى هذا المورد'])
      : super(message, statusCode: 403);
}

class NotFoundException extends ApiException {
  NotFoundException([String message = 'المورد المطلوب غير موجود'])
      : super(message, statusCode: 404);
}

class ServerException extends ApiException {
  ServerException([String message = 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً'])
      : super(message, statusCode: 500);
}

class NetworkException extends ApiException {
  NetworkException([String message = 'تعذر الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت'])
      : super(message, statusCode: 0);
}

class TimeoutException extends ApiException {
  TimeoutException([String message = 'استغرقت الاستجابة وقتاً أطول من المتوقع، يرجى إعادة المحاولة'])
      : super(message, statusCode: 408);
}

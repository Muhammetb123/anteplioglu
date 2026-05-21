import 'package:dio/dio.dart';

class ApiError implements Exception {
  final int? statusCode;
  final String message;

  ApiError({required this.message, this.statusCode});

  static String? _extractMessage(dynamic data) {
    if (data is String) {
      final trimmed = data.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    if (data is List) {
      for (final item in data) {
        final msg = _extractMessage(item);
        if (msg != null) return msg;
      }
      return null;
    }

    if (data is Map) {
      final map = data.cast<dynamic, dynamic>();
      const preferredKeys = [
        'message',
        'error',
        'msg',
        'detail',
        'description',
        'title',
      ];
      for (final key in preferredKeys) {
        final msg = _extractMessage(map[key]);
        if (msg != null) return msg;
      }

      final nested = map['data'] ?? map['errors'];
      final nestedMsg = _extractMessage(nested);
      if (nestedMsg != null) return nestedMsg;
    }

    return null;
  }

  factory ApiError.fromDio(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final fallback = e.message?.trim();
    final innerError = e.error?.toString().trim();
    final detailedFallback = [
      if (fallback != null && fallback.isNotEmpty) fallback,
      if (innerError != null && innerError.isNotEmpty) innerError,
    ].join(' | ');
    final statusFallback = statusCode != null
        ? 'Istek basarisiz (HTTP $statusCode)'
        : null;
    String? typeFallback;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        typeFallback = 'Baglanti zaman asimina ugradi, lutfen tekrar deneyin';
        break;
      case DioExceptionType.badCertificate:
        typeFallback = 'SSL sertifika hatasi olustu';
        break;
      case DioExceptionType.connectionError:
        typeFallback = detailedFallback.isNotEmpty
            ? 'Sunucuya baglanilamadi: $detailedFallback'
            : 'Sunucuya baglanilamadi, internetinizi kontrol edin';
        break;
      case DioExceptionType.cancel:
        typeFallback = 'Istek iptal edildi';
        break;
      case DioExceptionType.badResponse:
        typeFallback = statusFallback;
        break;
      case DioExceptionType.unknown:
        typeFallback = detailedFallback.isNotEmpty
            ? 'Beklenmeyen baglanti hatasi: $detailedFallback'
            : 'Beklenmeyen baglanti hatasi olustu';
        break;
    }
    final msg =
        _extractMessage(data) ??
        typeFallback ??
        (detailedFallback.isNotEmpty
            ? detailedFallback
            : (statusFallback ?? 'Bir hata oluştu'));

    return ApiError(message: msg, statusCode: statusCode);
  }

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiError(statusCode: $statusCode, message: $message)';
    }
    return 'ApiError(message: $message)';
  }
}

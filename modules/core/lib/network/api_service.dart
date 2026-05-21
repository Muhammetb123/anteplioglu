import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../storage/token_storage.dart';

abstract class IApiService {
  Future<Response> get(
    String path, {
    String? token,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });

  Future<Response> post(
    String path, {
    dynamic data,
    String? token,
    Map<String, dynamic>? headers,
  });

  Future<Response> put(
    String path,
    dynamic data, {
    String? token,
    Map<String, dynamic>? headers,
  });

  Future<Response> patch(
    String path,
    dynamic data, {
    String? token,
    Map<String, dynamic>? headers,
  });

  Future<Response> delete(
    String path, {
    String? token,
    Object? data,
    Map<String, dynamic>? headers,
  });

  Future<Response> uploadImage(
    String path,
    String filePath, {
    String? token,
    Map<String, dynamic>? headers,
  });

  Future<Response> uploadMultiImages(
    String path,
    List<String> filePaths,
    String token, {
    Map<String, dynamic>? headers,
  });

  /// Chat ekleri: multipart alan adı `files` (en fazla 10 dosya, çağıран sınırlar).
  Future<Response> uploadChatAttachments(
    String path,
    List<String> filePaths, {
    String? token,
    Map<String, dynamic>? headers,
  });

  /// Belge yükleme: multipart with [filePath] as 'document' ve [fields] (ör. type: personal|organization).
  Future<Response> uploadDocument(
    String path,
    String filePath,
    Map<String, String> fields, {
    String? token,
    Map<String, dynamic>? headers,
    void Function(int sent, int total)? onSendProgress,
  });
}

class ApiService implements IApiService {
  final Dio _dio;
  Completer<String?>? _refreshCompleter;
  late final Dio _refreshDio;
  final TokenStorage _tokenStorage;
  static String _resolveBaseUrl() {
    final raw = dotenv.env['BASE_URL']?.trim();
    if (raw == null || raw.isEmpty || raw == 'BASE_URL') {
      throw StateError(
        'BASE_URL tanimli degil. Lutfen .env dosyasinda BASE_URL degerini kontrol edin.',
      );
    }
    return raw;
  }

  ApiService({Dio? dio, required TokenStorage tokenStorage})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _resolveBaseUrl(),
              connectTimeout: const Duration(seconds: 40),
              receiveTimeout: const Duration(seconds: 40),
            ),
          ),
      _tokenStorage = tokenStorage {
    final resolvedBaseUrl = _resolveBaseUrl();
    if (_dio.options.baseUrl.isEmpty) {
      _dio.options.baseUrl = resolvedBaseUrl;
    }
    _dio.options.connectTimeout ??= const Duration(seconds: 40);
    _dio.options.receiveTimeout ??= const Duration(seconds: 40);

    _refreshDio = Dio(
      BaseOptions(
        baseUrl: _dio.options.baseUrl,
        connectTimeout: _dio.options.connectTimeout,
        receiveTimeout: _dio.options.receiveTimeout,
        responseType: _dio.options.responseType,
      ),
    );
    _dio.interceptors.add(_authInterceptor());
  }

  bool _isTokenExpiredResponse(dynamic responseData) {
    if (responseData is! Map) return false;

    final dynamic topLevelCode = responseData['code'] ?? responseData['error'];
    if (topLevelCode?.toString() == 'TOKEN_EXPIRED') return true;

    final dynamic message = responseData['message'];
    if (message is Map) {
      final dynamic nestedCode = message['code'] ?? message['error'];
      if (nestedCode?.toString() == 'TOKEN_EXPIRED') return true;
      final nestedMessage = message['message']?.toString().toLowerCase();
      if (nestedMessage != null && nestedMessage.contains('token expired')) {
        return true;
      }
      return false;
    }

    final messageText = message?.toString().toLowerCase();
    return messageText != null &&
        (messageText.contains('token expired') ||
            messageText.contains('token_expired'));
  }

  Future<String?> _refreshAccessTokenIfPossible() async {
    // If another request already kicked off the refresh, await it.
    if (_refreshCompleter != null) return _refreshCompleter!.future;

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final refreshToken = _tokenStorage.refreshToken;

      if (refreshToken == null || refreshToken.isEmpty) {
        completer.complete(null);
        return null;
      }

      final refreshResponse = await _refreshDio.post(
        'auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: const {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (refreshResponse.statusCode != 200) {
        completer.complete(null);
        return null;
      }

      final rrData = refreshResponse.data;
      final dynamic newAccessToken = rrData is Map
          ? (rrData['accessToken'] ??
                rrData['token'] ??
                rrData['data']?['accessToken'])
          : null;
      final dynamic newRefreshToken = rrData is Map
          ? (rrData['refreshToken'] ?? rrData['data']?['refreshToken'])
          : null;

      if (newAccessToken is! String || newAccessToken.isEmpty) {
        completer.complete(null);
        return null;
      }

      await _tokenStorage.saveAccessToken(newAccessToken);
      if (newRefreshToken is String && newRefreshToken.isNotEmpty) {
        await _tokenStorage.saveRefreshToken(newRefreshToken);
      }

      completer.complete(newAccessToken);
      return newAccessToken;
    } catch (_) {
      completer.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  Interceptor _authInterceptor() {
    return QueuedInterceptorsWrapper(
      onRequest:
          (RequestOptions options, RequestInterceptorHandler handler) async {
            final token = _tokenStorage.accessToken;
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        final responseData = error.response?.data;
        final isTokenExpired =
            _isTokenExpiredResponse(responseData) ||
            error.response?.statusCode == 401;
        final alreadyRetried =
            error.requestOptions.extra['__retry_after_refresh'] == true;

        if (isTokenExpired && !alreadyRetried) {
          // If a refresh is already in progress, wait for it and retry.
          final newAccessToken = await _refreshAccessTokenIfPossible();

          if (newAccessToken is String && newAccessToken.isNotEmpty) {
            try {
              final opts = error.requestOptions;
              opts.extra['__retry_after_refresh'] = true;
              opts.headers['Authorization'] = 'Bearer $newAccessToken';
              final retryResponse = await _dio.fetch(opts);
              return handler.resolve(retryResponse);
            } catch (_) {
              // If retry fails, fall through to propagate original error.
            }
          } else {
            // Refresh not possible or failed. Clear auth.
            await _tokenStorage.clear();
          }
        }

        return handler.next(error);
      },
    );
  }

  /// Merge default headers (JSON, authorization) with any extras passed by
  /// caller. Caller-provided values override defaults.
  Map<String, dynamic> _mergeHeaders({
    String? token,
    Map<String, dynamic>? extras,
  }) {
    final headers = <String, dynamic>{
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (extras != null) {
      if (extras.isEmpty) {
        headers.remove('accept');
        headers.remove('Content-Type');
      } else {
        headers.addAll(extras);
      }
    }

    return headers;
  }

  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    String? token,
  }) async {
    final response = await _dio.get(
      path,
      queryParameters: queryParameters,
      options: Options(
        headers: _mergeHeaders(token: token, extras: headers),
      ),
    );
    return response;
  }

  @override
  Future<Response> post(
    String path, {
    dynamic data,
    String? token,
    Map<String, dynamic>? headers,
  }) async {
    final merged = _mergeHeaders(token: token, extras: headers);
    final Response response = await _dio.post(
      path,
      data: data,
      options: Options(headers: merged),
      onSendProgress: (sent, total) {
        if (kDebugMode) {
          debugPrint('Yüklenen: $sent / Toplam: $total');
        }
      },
    );
    return response;
  }

  @override
  Future<Response> put(
    String path,
    dynamic data, {
    String? token,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final merged = _mergeHeaders(token: token, extras: headers);
      final Response response = await _dio.put(
        path,
        data: data,
        options: Options(headers: merged),
      );
      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('API PUT DioException: ${e.response?.data}');
      }
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: e.response?.statusCode ?? 500,
        data: e.response?.data ?? {'error': e.message},
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('API PUT Hatası: $e');
      }
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 500,
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<Response> patch(
    String path,
    dynamic data, {
    String? token,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final merged = _mergeHeaders(token: token, extras: headers);
      final Response response = await _dio.patch(
        path,
        data: data,
        options: Options(headers: merged),
      );
      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('API PATCH DioException: ${e.response?.data}');
      }
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: e.response?.statusCode ?? 500,
        data: e.response?.data ?? {'error': e.message},
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('API PATCH Hatası: $e');
      }
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 500,
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<Response> delete(
    String path, {
    String? token,
    Object? data,
    Map<String, dynamic>? headers,
  }) async {
    final merged = _mergeHeaders(token: token, extras: headers);
    return await _dio.delete(
      path,
      data: data,
      options: Options(headers: merged),
    );
  }

  @override
  Future<Response> uploadImage(
    String path,
    String filePath, {
    String? token,
    Map<String, dynamic>? headers,
  }) async {
    final date = DateTime.now();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: '${date.millisecondsSinceEpoch}_image.png',
      ),
    });

    final merged = _mergeHeaders(
      token: token,
      extras: {'Content-Type': 'multipart/form-data', ...?headers},
    );

    return await _dio.post(
      path,
      data: formData,
      options: Options(headers: merged),
    );
  }

  @override
  Future<Response> uploadMultiImages(
    String path,
    List<String> filePaths,
    String token, {
    Map<String, dynamic>? headers,
  }) async {
    final date = DateTime.now();
    List<MultipartFile> multipartFiles = await Future.wait(
      filePaths.map(
        (path) async => await MultipartFile.fromFile(
          path,
          filename: '${date.millisecondsSinceEpoch}_image.png',
        ),
      ),
    );

    FormData formData = FormData.fromMap({'files': multipartFiles});

    final merged = _mergeHeaders(
      token: token,
      extras: {'Content-Type': 'multipart/form-data', ...?headers},
    );

    final response = await _dio.post(
      path,
      data: formData,
      options: Options(headers: merged),
    );
    return response;
  }

  @override
  Future<Response> uploadChatAttachments(
    String path,
    List<String> filePaths, {
    String? token,
    Map<String, dynamic>? headers,
  }) async {
    final multipartFiles = <MultipartFile>[];
    for (final fp in filePaths) {
      final name = fp.split(RegExp(r'[/\\]')).last;
      multipartFiles.add(
        await MultipartFile.fromFile(
          fp,
          filename: name.isEmpty ? 'file' : name,
        ),
      );
    }
    final formData = FormData.fromMap({'files': multipartFiles});
    final merged = _mergeHeaders(
      token: token,
      extras: {'Content-Type': 'multipart/form-data', ...?headers},
    );
    return _dio.post(
      path,
      data: formData,
      options: Options(headers: merged),
    );
  }

  @override
  Future<Response> uploadDocument(
    String path,
    String filePath,
    Map<String, String> fields, {
    String? token,
    Map<String, dynamic>? headers,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final name = filePath.split('/').last;
    final file = await MultipartFile.fromFile(filePath, filename: name);
    final map = <String, dynamic>{'document': file};
    for (final e in fields.entries) {
      map[e.key] = e.value;
    }
    final formData = FormData.fromMap(map);
    final merged = _mergeHeaders(
      token: token,
      extras: {'Content-Type': 'multipart/form-data', ...?headers},
    );
    return await _dio.post(
      path,
      data: formData,
      options: Options(headers: merged),
      onSendProgress: onSendProgress,
    );
  }
}

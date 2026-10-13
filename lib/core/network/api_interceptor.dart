import 'package:dio/dio.dart';
import '../logging/app_logger.dart';

typedef TokenProvider = Future<String?> Function();

class ApiInterceptor extends Interceptor {
  ApiInterceptor({this.tokenProvider});
  final TokenProvider? tokenProvider;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await tokenProvider?.call();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      // Log method/status only; paths, query, headers and bodies may contain PII.
      AppLogger.instance.d('HTTP ${options.method} started');
      handler.next(options);
    } catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    AppLogger.instance.d(
      'HTTP ${response.requestOptions.method}: ${response.statusCode}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.instance.w(
      'HTTP ${err.requestOptions.method}: ${err.type.name} (${err.response?.statusCode})',
    );
    handler.next(err);
  }
}

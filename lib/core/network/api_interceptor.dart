import 'package:dio/dio.dart';
import '../logging/app_logger.dart';

typedef TokenProvider = Future<String?> Function();

class ApiInterceptor extends Interceptor {
  ApiInterceptor({this.tokenProvider});
  final TokenProvider? tokenProvider;

  String _endpoint(RequestOptions options) =>
      options.uri.replace(query: '', fragment: '').toString();

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
      AppLogger.instance.i('HTTP ${options.method} ${_endpoint(options)}');
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
    AppLogger.instance.i(
      'HTTP ${response.requestOptions.method} ${_endpoint(response.requestOptions)} '
      '-> ${response.statusCode}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.instance.w(
      'HTTP ${err.requestOptions.method} ${_endpoint(err.requestOptions)} '
      '-> ${err.type.name} (${err.response?.statusCode})',
    );
    handler.next(err);
  }
}

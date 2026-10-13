import 'package:dio/dio.dart';
import '../errors/app_failure.dart';
import 'api_interceptor.dart';

class ApiClient {
  ApiClient({required String baseUrl, TokenProvider? tokenProvider, Dio? dio})
    : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    );
    _dio.interceptors.add(ApiInterceptor(tokenProvider: tokenProvider));
  }
  final Dio _dio;

  Future<T?> get<T>(
    String path, {
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.get<T>(path, queryParameters: query, cancelToken: cancelToken),
  );
  Future<T?> post<T>(String path, {Object? data, CancelToken? cancelToken}) =>
      _request(() => _dio.post<T>(path, data: data, cancelToken: cancelToken));
  Future<T?> put<T>(String path, {Object? data, CancelToken? cancelToken}) =>
      _request(() => _dio.put<T>(path, data: data, cancelToken: cancelToken));
  Future<T?> patch<T>(String path, {Object? data, CancelToken? cancelToken}) =>
      _request(() => _dio.patch<T>(path, data: data, cancelToken: cancelToken));
  Future<T?> delete<T>(String path, {Object? data, CancelToken? cancelToken}) =>
      _request(
        () => _dio.delete<T>(path, data: data, cancelToken: cancelToken),
      );

  Future<T?> _request<T>(Future<Response<T>> Function() request) async {
    try {
      return (await request()).data;
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  void close() => _dio.close();
}

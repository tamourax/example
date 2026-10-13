import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:example/core/errors/app_failure.dart';
import 'package:example/core/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

class _Adapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  int status = 200;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{"id":1}',
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'CRUD verbs, payload, query and authorization reach the transport',
    () async {
      final adapter = _Adapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final client = ApiClient(
        baseUrl: 'https://api.example.test',
        dio: dio,
        tokenProvider: () async => 'test-token',
      );
      addTearDown(client.close);
      expect(
        await client.get<Map<String, dynamic>>('/items', query: {'page': 2}),
        {'id': 1},
      );
      await client.post('/items', data: {'title': 'new'});
      await client.put('/items/1', data: {'title': 'replace'});
      await client.patch('/items/1', data: {'title': 'update'});
      await client.delete('/items/1');
      expect(adapter.requests.map((r) => r.method), [
        'GET',
        'POST',
        'PUT',
        'PATCH',
        'DELETE',
      ]);
      expect(adapter.requests.first.queryParameters, {'page': 2});
      expect(adapter.requests[1].data, {'title': 'new'});
      expect(
        adapter.requests.first.headers['Authorization'],
        'Bearer test-token',
      );
      adapter.status = 403;
      await expectLater(
        client.get('/items'),
        throwsA(isA<AppFailure>().having((e) => e.statusCode, 'status', 403)),
      );
    },
  );
}

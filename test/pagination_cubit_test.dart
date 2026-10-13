import 'dart:async';
import 'package:example/core/pagination/pagination_cubit.dart';
import 'package:example/core/pagination/pagination_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('failed next page retains items and retries the same page', () async {
    final requests = <int>[];
    var fail = true;
    final cubit = PaginationCubit<int>(
      loadPage: (page, size) async {
        requests.add(page);
        if (page == 2 && fail) throw StateError('offline');
        return PageResult(items: [page], hasMore: page < 2);
      },
    );
    addTearDown(cubit.close);
    await cubit.loadNextPage();
    await cubit.loadNextPage();
    expect(cubit.state.items, [1]);
    expect(cubit.state.failure, isNotNull);
    fail = false;
    await cubit.loadNextPage();
    await cubit.loadNextPage();
    expect(requests, [1, 2, 2]);
    expect(cubit.state.items, [1, 2]);
    expect(cubit.state.hasMore, isFalse);
  });

  test(
    'refresh ignores stale response and duplicate load is ignored',
    () async {
      final old = Completer<PageResult<int>>();
      var requests = 0;
      final cubit = PaginationCubit<int>(
        loadPage: (page, size) {
          requests++;
          return requests == 1
              ? old.future
              : Future.value(const PageResult(items: [99], hasMore: false));
        },
      );
      addTearDown(cubit.close);
      final pending = cubit.loadNextPage();
      await cubit.loadNextPage();
      expect(requests, 1);
      await cubit.refresh();
      old.complete(const PageResult(items: [1], hasMore: true));
      await pending;
      expect(cubit.state.items, [99]);
    },
  );

  test('closing during a request does not emit after close', () async {
    final response = Completer<PageResult<int>>();
    final cubit = PaginationCubit<int>(loadPage: (_, _) => response.future);
    final pending = cubit.loadNextPage();
    await cubit.close();
    response.complete(const PageResult(items: [1], hasMore: false));
    await pending;
  });
}

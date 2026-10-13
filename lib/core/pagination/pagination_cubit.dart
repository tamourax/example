import 'package:flutter_bloc/flutter_bloc.dart';
import '../errors/app_failure.dart';
import 'pagination_state.dart';

typedef PageLoader<T> = Future<PageResult<T>> Function(int page, int pageSize);

class PaginationCubit<T> extends Cubit<PaginationState<T>> {
  PaginationCubit({required PageLoader<T> loadPage, this.pageSize = 20})
    : assert(pageSize > 0),
      _loadPage = loadPage,
      super(PaginationState<T>());
  final PageLoader<T> _loadPage;
  final int pageSize;
  int _generation = 0;

  Future<void> loadNextPage() async {
    if (isClosed || state.isLoading || !state.hasMore) return;
    await _fetch(_generation, state);
  }

  Future<void> refresh() async {
    if (isClosed) return;
    final generation = ++_generation;
    await _fetch(generation, PaginationState<T>());
  }

  Future<void> _fetch(int generation, PaginationState<T> previous) async {
    emit(
      PaginationState(
        items: previous.items,
        nextPage: previous.nextPage,
        hasMore: previous.hasMore,
        isLoading: true,
      ),
    );
    try {
      final page = await _loadPage(previous.nextPage, pageSize);
      if (isClosed || generation != _generation) return;
      emit(
        PaginationState(
          items: [...previous.items, ...page.items],
          nextPage: previous.nextPage + 1,
          hasMore: page.hasMore && page.items.isNotEmpty,
        ),
      );
    } catch (error) {
      if (isClosed || generation != _generation) return;
      emit(
        PaginationState(
          items: previous.items,
          nextPage: previous.nextPage,
          hasMore: previous.hasMore,
          failure: AppFailure.from(error),
        ),
      );
    }
  }
}

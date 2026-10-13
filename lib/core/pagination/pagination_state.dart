import 'package:equatable/equatable.dart';
import '../errors/app_failure.dart';

class PageResult<T> {
  const PageResult({required this.items, required this.hasMore});
  final List<T> items;
  final bool hasMore;
}

class PaginationState<T> extends Equatable {
  PaginationState({
    List<T> items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.nextPage = 1,
    this.failure,
  }) : items = List.unmodifiable(items);
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final int nextPage;
  final AppFailure? failure;

  @override
  List<Object?> get props => [items, isLoading, hasMore, nextPage, failure];
}

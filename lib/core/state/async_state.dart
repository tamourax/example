import 'package:equatable/equatable.dart';
import '../errors/app_failure.dart';

enum AsyncStatus { initial, loading, success, failure }

/// A reusable state for non-paginated Cubits (forms, details, CRUD actions).
class AsyncState<T> extends Equatable {
  const AsyncState({
    this.status = AsyncStatus.initial,
    this.data,
    this.failure,
  });
  const AsyncState.loading() : this(status: AsyncStatus.loading);
  const AsyncState.success(T data)
    : this(status: AsyncStatus.success, data: data);
  const AsyncState.failure(AppFailure failure)
    : this(status: AsyncStatus.failure, failure: failure);
  final AsyncStatus status;
  final T? data;
  final AppFailure? failure;

  @override
  List<Object?> get props => [status, data, failure];
}

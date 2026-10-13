import 'package:flutter_bloc/flutter_bloc.dart';
import '../errors/app_failure.dart';
import 'async_state.dart';

/// Extend for details, submit actions, or a Firestore CRUD operation.
/// The latest request wins; results after close are ignored.
class AsyncCubit<T> extends Cubit<AsyncState<T>> {
  AsyncCubit() : super(const AsyncState());
  int _generation = 0;

  Future<void> execute(Future<T> Function() operation) async {
    if (isClosed) return;
    final generation = ++_generation;
    emit(AsyncState<T>.loading());
    try {
      final data = await operation();
      if (!isClosed && generation == _generation) {
        emit(AsyncState.success(data));
      }
    } catch (error) {
      if (!isClosed && generation == _generation) {
        emit(AsyncState.failure(AppFailure.from(error)));
      }
    }
  }
}

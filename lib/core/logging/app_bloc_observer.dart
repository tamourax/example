import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    // Do not log state, credentials, or exception payloads.
    AppLogger.instance.e('${bloc.runtimeType}: ${error.runtimeType}');
    super.onError(bloc, error, stackTrace);
  }
}

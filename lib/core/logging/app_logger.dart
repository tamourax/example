import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

abstract final class AppLogger {
  static final instance = Logger(
    // Endpoint requests are logged at info level in every build mode.
    level: kDebugMode ? Level.debug : Level.info,
    printer: PrettyPrinter(methodCount: 0),
  );
}

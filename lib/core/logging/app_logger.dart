import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

abstract final class AppLogger {
  static final instance = Logger(
    level: kDebugMode ? Level.debug : Level.off,
    printer: PrettyPrinter(methodCount: 0),
  );
}

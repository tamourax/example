import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';

/// Use [code] to choose a localized UI message; keep details out of the UI.
class AppFailure implements Exception {
  const AppFailure(this.code, {this.statusCode});
  final String code;
  final int? statusCode;

  factory AppFailure.from(Object error) {
    if (error is AppFailure) return error;
    if (error is FirebaseException) return AppFailure(error.code);
    if (error is DioException) {
      return AppFailure(
        error.type.name,
        statusCode: error.response?.statusCode,
      );
    }
    return const AppFailure('unknown');
  }

  @override
  String toString() => 'AppFailure($code, status: $statusCode)';
}

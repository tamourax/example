// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get appTitle => 'App Starter';

  @override
  String get welcome => 'Your foundation is ready';

  @override
  String get description =>
      'Reusable widgets, localization, Cubit, REST and Firebase services.';

  @override
  String get primaryAction => 'Primary button';

  @override
  String get secondaryAction => 'Change language';

  @override
  String get emptyList => 'Nothing here yet';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get retry => 'Try again';

  @override
  String itemTitle(int number) {
    return 'Item $number';
  }

  @override
  String get listTitle => 'List widget preview';

  @override
  String get firebaseUnavailable =>
      'Firebase is unavailable. Check configuration and restart.';

  @override
  String get restart => 'Retry setup';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get componentReady => 'The shared components are ready to use.';
}

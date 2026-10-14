// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get trackingTime => 'Tracking Time';

  @override
  String get creatingLocation => 'Creating New Location';

  @override
  String get locationDescription => 'Location Description';

  @override
  String get locationName => 'Location Name';

  @override
  String get googleMapsLocation => 'Location at Google Maps';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get allowGeofence => 'Allow Geofence';

  @override
  String get country => 'Country';

  @override
  String get stateProvince => 'State or Province';

  @override
  String get city => 'City';

  @override
  String get postalCode => 'Postal Code';

  @override
  String get locationSetting => 'Location Setting';

  @override
  String get allowBreaks => 'Allow Breaks in Attendance';

  @override
  String get allowPause => 'Allow Pause';

  @override
  String get discard => 'Discard';

  @override
  String get create => 'Create';

  @override
  String get textHere => 'Text Here';

  @override
  String get invalidCoordinate => 'Enter a valid coordinate within range';

  @override
  String get invalidMapsUrl => 'Enter a valid Google Maps HTTPS URL';

  @override
  String get locationReady => 'Location details are ready.';

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

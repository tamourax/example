// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get requests => 'Requests';

  @override
  String get submit => 'Submit';

  @override
  String get creatingRequestType => 'Creating New Request Type';

  @override
  String get creatingRequest => 'Creating Request';

  @override
  String get confirmNewRequest =>
      'Are You Sure You Want To Create This Request ?';

  @override
  String get requestSubmitted => 'Your Request Has Been Successfully Submitted';

  @override
  String get requestType => 'Request Type';

  @override
  String get requestDescription => 'Request Description';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get allDay => 'All Day';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get requestAttachments => 'Request Attachments';

  @override
  String get upload => 'Upload';

  @override
  String get addingAttachment => 'Adding Attachment';

  @override
  String get dragDropFiles => 'Drag & Drop files here';

  @override
  String get or => 'Or';

  @override
  String get browseFiles => 'Browse Files';

  @override
  String get attachmentLimits => 'Images or PDF • Up to 5 files, 10 MB each';

  @override
  String get attachmentTooLarge => 'Each attachment must be 10 MB or smaller.';

  @override
  String get attachmentTooMany => 'You can attach up to 5 files per request.';

  @override
  String get attachmentUnsupported =>
      'Choose a valid image (PNG, JPG, GIF, WebP, BMP) or PDF file.';

  @override
  String get attachmentReadFailed =>
      'Could not read the selected file. Please try again.';

  @override
  String get attachmentOpenFailed =>
      'Could not open this attachment. Please try again.';

  @override
  String get removeAttachment => 'Remove attachment';

  @override
  String get chooseDate => 'Choose date';

  @override
  String get chooseTime => 'Choose time';

  @override
  String get invalidRequestDate => 'Enter a valid date as YYYY-MM-DD';

  @override
  String get endDateBeforeStart => 'End Date must be on or after Start Date';

  @override
  String get invalidRequestTime => 'Enter a valid time as HH:mm (24-hour)';

  @override
  String get endTimeBeforeStart =>
      'End Time must be on or after Start Time for the same day';

  @override
  String get noRequests =>
      'No requests yet. Select Submit to create a request.';

  @override
  String get requestsLoadFailed => 'Could not load requests. Please try again.';

  @override
  String get requestSaveFailed =>
      'Could not submit the request. Check your connection and try again.';

  @override
  String get requestSaveDenied =>
      'You do not have permission to submit requests or upload attachments.';

  @override
  String get requestStorageUnavailable =>
      'Attachment storage is unavailable. Try again or submit without attachments.';

  @override
  String get locations => 'Locations';

  @override
  String get creatingLocations => 'Creating New Locations';

  @override
  String get confirmNewLocation =>
      'Are You Sure You Want To Add New Location ?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get successful => 'Successful';

  @override
  String get locationAdded => 'You Successfully Added New Locations';

  @override
  String get noLocations => 'No locations yet. Create your first location.';

  @override
  String get locationsLoadFailed =>
      'Could not load locations. Please try again.';

  @override
  String get locationSaveFailed =>
      'Could not save this location. Check your connection and try again.';

  @override
  String get locationSaveDenied =>
      'You do not have permission to add locations.';

  @override
  String get useDeviceLocation => 'Use device location';

  @override
  String get selectOnMap => 'Select on map';

  @override
  String get tapMapToSelect =>
      'Tap the map to select a location. You can zoom and drag the map.';

  @override
  String get useSelectedLocation => 'Use selected location';

  @override
  String get locationPermissionDenied =>
      'Location permission was denied. Enter coordinates manually or select on the map.';

  @override
  String get locationPermissionPermanent =>
      'Location permission is blocked. Enable it in device or browser settings, enter coordinates manually, or select on the map.';

  @override
  String get locationServicesDisabled =>
      'Location services are off. Enable them, enter coordinates manually, or select on the map.';

  @override
  String get deviceLocationUnavailable =>
      'Device location is unavailable. Enter coordinates manually or select on the map.';

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

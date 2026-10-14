import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @creatingRequestType.
  ///
  /// In en, this message translates to:
  /// **'Creating New Request Type'**
  String get creatingRequestType;

  /// No description provided for @creatingRequest.
  ///
  /// In en, this message translates to:
  /// **'Creating Request'**
  String get creatingRequest;

  /// No description provided for @confirmNewRequest.
  ///
  /// In en, this message translates to:
  /// **'Are You Sure You Want To Create This Request ?'**
  String get confirmNewRequest;

  /// No description provided for @requestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your Request Has Been Successfully Submitted'**
  String get requestSubmitted;

  /// No description provided for @requestType.
  ///
  /// In en, this message translates to:
  /// **'Request Type'**
  String get requestType;

  /// No description provided for @requestDescription.
  ///
  /// In en, this message translates to:
  /// **'Request Description'**
  String get requestDescription;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @allDay.
  ///
  /// In en, this message translates to:
  /// **'All Day'**
  String get allDay;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @requestAttachments.
  ///
  /// In en, this message translates to:
  /// **'Request Attachments'**
  String get requestAttachments;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @addingAttachment.
  ///
  /// In en, this message translates to:
  /// **'Adding Attachment'**
  String get addingAttachment;

  /// No description provided for @dragDropFiles.
  ///
  /// In en, this message translates to:
  /// **'Drag & Drop files here'**
  String get dragDropFiles;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @browseFiles.
  ///
  /// In en, this message translates to:
  /// **'Browse Files'**
  String get browseFiles;

  /// No description provided for @attachmentLimits.
  ///
  /// In en, this message translates to:
  /// **'Images or PDF • Up to 5 files, 10 MB each'**
  String get attachmentLimits;

  /// No description provided for @attachmentTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Each attachment must be 10 MB or smaller.'**
  String get attachmentTooLarge;

  /// No description provided for @attachmentTooMany.
  ///
  /// In en, this message translates to:
  /// **'You can attach up to 5 files per request.'**
  String get attachmentTooMany;

  /// No description provided for @attachmentUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid image (PNG, JPG, GIF, WebP, BMP) or PDF file.'**
  String get attachmentUnsupported;

  /// No description provided for @attachmentReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the selected file. Please try again.'**
  String get attachmentReadFailed;

  /// No description provided for @attachmentOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open this attachment. Please try again.'**
  String get attachmentOpenFailed;

  /// No description provided for @removeAttachment.
  ///
  /// In en, this message translates to:
  /// **'Remove attachment'**
  String get removeAttachment;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get chooseDate;

  /// No description provided for @chooseTime.
  ///
  /// In en, this message translates to:
  /// **'Choose time'**
  String get chooseTime;

  /// No description provided for @invalidRequestDate.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid date as YYYY-MM-DD'**
  String get invalidRequestDate;

  /// No description provided for @endDateBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End Date must be on or after Start Date'**
  String get endDateBeforeStart;

  /// No description provided for @invalidRequestTime.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid time as HH:mm (24-hour)'**
  String get invalidRequestTime;

  /// No description provided for @endTimeBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End Time must be on or after Start Time for the same day'**
  String get endTimeBeforeStart;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests yet. Select Submit to create a request.'**
  String get noRequests;

  /// No description provided for @requestsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load requests. Please try again.'**
  String get requestsLoadFailed;

  /// No description provided for @requestSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not submit the request. Check your connection and try again.'**
  String get requestSaveFailed;

  /// No description provided for @requestSaveDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to submit requests or upload attachments.'**
  String get requestSaveDenied;

  /// No description provided for @requestStorageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Attachment storage is unavailable. Try again or submit without attachments.'**
  String get requestStorageUnavailable;

  /// No description provided for @locations.
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get locations;

  /// No description provided for @creatingLocations.
  ///
  /// In en, this message translates to:
  /// **'Creating New Locations'**
  String get creatingLocations;

  /// No description provided for @confirmNewLocation.
  ///
  /// In en, this message translates to:
  /// **'Are You Sure You Want To Add New Location ?'**
  String get confirmNewLocation;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @successful.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get successful;

  /// No description provided for @locationAdded.
  ///
  /// In en, this message translates to:
  /// **'You Successfully Added New Locations'**
  String get locationAdded;

  /// No description provided for @noLocations.
  ///
  /// In en, this message translates to:
  /// **'No locations yet. Create your first location.'**
  String get noLocations;

  /// No description provided for @locationsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load locations. Please try again.'**
  String get locationsLoadFailed;

  /// No description provided for @locationSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save this location. Check your connection and try again.'**
  String get locationSaveFailed;

  /// No description provided for @locationSaveDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to add locations.'**
  String get locationSaveDenied;

  /// No description provided for @useDeviceLocation.
  ///
  /// In en, this message translates to:
  /// **'Use device location'**
  String get useDeviceLocation;

  /// No description provided for @selectOnMap.
  ///
  /// In en, this message translates to:
  /// **'Select on map'**
  String get selectOnMap;

  /// No description provided for @tapMapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to select a location. You can zoom and drag the map.'**
  String get tapMapToSelect;

  /// No description provided for @useSelectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Use selected location'**
  String get useSelectedLocation;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. Enter coordinates manually or select on the map.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionPermanent.
  ///
  /// In en, this message translates to:
  /// **'Location permission is blocked. Enable it in device or browser settings, enter coordinates manually, or select on the map.'**
  String get locationPermissionPermanent;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are off. Enable them, enter coordinates manually, or select on the map.'**
  String get locationServicesDisabled;

  /// No description provided for @deviceLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Device location is unavailable. Enter coordinates manually or select on the map.'**
  String get deviceLocationUnavailable;

  /// No description provided for @trackingTime.
  ///
  /// In en, this message translates to:
  /// **'Tracking Time'**
  String get trackingTime;

  /// No description provided for @creatingLocation.
  ///
  /// In en, this message translates to:
  /// **'Creating New Location'**
  String get creatingLocation;

  /// No description provided for @locationDescription.
  ///
  /// In en, this message translates to:
  /// **'Location Description'**
  String get locationDescription;

  /// No description provided for @locationName.
  ///
  /// In en, this message translates to:
  /// **'Location Name'**
  String get locationName;

  /// No description provided for @googleMapsLocation.
  ///
  /// In en, this message translates to:
  /// **'Location at Google Maps'**
  String get googleMapsLocation;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @allowGeofence.
  ///
  /// In en, this message translates to:
  /// **'Allow Geofence'**
  String get allowGeofence;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @stateProvince.
  ///
  /// In en, this message translates to:
  /// **'State or Province'**
  String get stateProvince;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get postalCode;

  /// No description provided for @locationSetting.
  ///
  /// In en, this message translates to:
  /// **'Location Setting'**
  String get locationSetting;

  /// No description provided for @allowBreaks.
  ///
  /// In en, this message translates to:
  /// **'Allow Breaks in Attendance'**
  String get allowBreaks;

  /// No description provided for @allowPause.
  ///
  /// In en, this message translates to:
  /// **'Allow Pause'**
  String get allowPause;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @textHere.
  ///
  /// In en, this message translates to:
  /// **'Text Here'**
  String get textHere;

  /// No description provided for @invalidCoordinate.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid coordinate within range'**
  String get invalidCoordinate;

  /// No description provided for @invalidMapsUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Google Maps HTTPS URL'**
  String get invalidMapsUrl;

  /// No description provided for @locationReady.
  ///
  /// In en, this message translates to:
  /// **'Location details are ready.'**
  String get locationReady;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'App Starter'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Your foundation is ready'**
  String get welcome;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Reusable widgets, localization, Cubit, REST and Firebase services.'**
  String get description;

  /// No description provided for @primaryAction.
  ///
  /// In en, this message translates to:
  /// **'Primary button'**
  String get primaryAction;

  /// No description provided for @secondaryAction.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get secondaryAction;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyList;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @itemTitle.
  ///
  /// In en, this message translates to:
  /// **'Item {number}'**
  String itemTitle(int number);

  /// No description provided for @listTitle.
  ///
  /// In en, this message translates to:
  /// **'List widget preview'**
  String get listTitle;

  /// No description provided for @firebaseUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Firebase is unavailable. Check configuration and restart.'**
  String get firebaseUnavailable;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Retry setup'**
  String get restart;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @componentReady.
  ///
  /// In en, this message translates to:
  /// **'The shared components are ready to use.'**
  String get componentReady;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

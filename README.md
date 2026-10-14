# Flutter application foundation

A reusable Flutter starter/template, currently named `example` (version
`1.0.0+1`). It includes shared widgets, English/Arabic ARB localization with RTL,
Material 3 light and dark themes, Cubits, Dio REST networking, and Firebase Auth
and Firestore services.

The home screen shows a live Locations list. “Creating New Locations” opens the
responsive bilingual form. Create validates required English/Arabic addresses,
the location name, Google Maps URL and coordinate ranges, then opens `AppDialog`
with No/Yes actions. Yes saves through `FirestoreLocationsRepository`. Once the
write completes, the form closes and `AppSuccess` uses the uploaded success SVG.
Failed writes keep the form values and allow retry; saves disable duplicate
submissions. Discard clears fields and switches. Arabic location name is optional.

Opening the form requests device coordinates through Geolocator. Denied or
unavailable location leaves fields editable and offers a flutter_map picker.
Tap the map and choose “Use selected location” to fill coordinates. The picker
uses OpenStreetMap tiles with attribution; it needs an internet connection.
Device geolocation on deployed web apps requires HTTPS.

Android includes coarse/fine location permissions, iOS includes the when-in-use
usage description, and macOS includes the usage description and location
entitlements. This project uses Swift Package Manager on Apple platforms. Build
iOS with `BYPASS_PERMISSION_LOCATION_ALWAYS=1` in the build environment to keep
Geolocator's permission handling limited to when-in-use (for example,
`BYPASS_PERMISSION_LOCATION_ALWAYS=1 flutter build ios` on macOS).

Firestore uses the configured project's **(default)** database and creates new
documents under `locations`, storing `id`, `createdAt`, `nameEn`, `nameAr`,
`mapsUrl`, numeric `latitude`/`longitude`, English/Arabic `country`, `state`,
`city`, `postalCode` fields with `En`/`Ar` suffixes, and boolean `allowGeofence`,
`allowBreaks`, `allowPause`. Existing documents are not overwritten. The supplied
document ID `AtnulzbusAjAwCUXrFGW` has no confirmed collection path/schema yet.
To use another collection (or nested collection path), run:

```sh
flutter run --dart-define=LOCATIONS_COLLECTION=your_collection_path
```

Firestore rules must permit reads and creates for the current user. The app
does not change rules or sign users in automatically. `const App()` without
services renders a preview; saving requires initialized Firebase services.

Normal startup initializes Firebase before showing the home screen. A loading
indicator appears during setup, and initialization failures show a localized
retry screen. Tests can render `const App()` directly without Firebase.

## Requests (task two)

Requests is an independent feature, accessible from the **Requests** navigation
tab or the `/requests` named route (web: `/#/requests`). The existing Locations
feature remains accessible from its own tab and `/locations` route.

On the Requests page, **Submit** opens a dialog with required type, description,
Start Date and End Date. Enter dates as `YYYY-MM-DD` or use the calendar buttons.
End Date must be on or after Start Date. All Day defaults to off; enabling it
hides both time fields and stores null times. With All Day off, both times are
required in 24-hour `HH:mm` format (time pickers are also available). On the same
day, End Time must be on or after Start Time. Description is limited to 500
characters, matching the supplied design. Discard clears the current form.

**Upload** opens the attachment dialog. Browse or drag/drop images or PDFs,
then remove individual selections before submitting. Supported images are PNG,
JPG/JPEG, GIF, WebP and BMP. The limit is five attachments of 10 MB each; file
headers and extensions are checked before accepting them. Uploads happen only
after the final No/Yes confirmation. The form stays open with its values and
selected files if upload or save fails. It disables duplicate submissions while
saving, closes after a successful save, and shows the request success dialog.
The list refreshes through Firestore snapshots and includes attachment links.

Records are created in the default Firestore database's `requests` collection.
Change it with `--dart-define=REQUESTS_COLLECTION=your_collection_path`.
The schema is `id`, `requestType`, `description`, `startDate`, `endDate`,
`allDay`, `startTime`, `endTime`, `status: submitted`, `createdAt`, `attachments`.
Dates are date-only values stored as UTC-midnight Firestore timestamps; times
are wall-clock `HH:mm` strings. Each attachment contains `name`, `url`,
`storagePath`, `contentType`, and byte `size`.

Attachments use the configured Firebase Storage bucket under
`request-attachments/<request-id>/`. Firestore stores metadata and download
links, rather than file bytes. The bucket must be enabled, and its rules must
allow uploads, downloads and cleanup deletes for the current user. Firestore
rules must allow request reads and creates. The app uses the existing Firebase
configuration and does not deploy rules or enable billing/buckets automatically.
Newly uploaded files are cleaned up on a failed request create when deletion
permissions and connectivity allow it. Existing files/requests are unaffected.
Requests without attachments only require Firestore. No automatic sign-in or
request approval workflow is included.

## Structure

```text
lib/
  main.dart                 Firebase bootstrap with retry on startup failure
  app/                      Root app, explicit service injection, settings Cubit
  core/
    constants/              Asset paths
    errors/                 Common AppFailure
    firebase/               Firestore CRUD, streams and cursor pagination
    localization/           context.l10n extension
    logging/                Logger and Bloc observer
    network/                Dio client, auth interceptor, endpoint logging
    pagination/             Generic PaginationCubit and PaginationState
    state/                  AsyncCubit and initial/loading/success/failure state
    theme/                  AppColors, AppTypography, AppStyles, AppTheme
    widgets/                Shared UI components
  features/home/            Live Locations list
  features/locations/       Firestore repository, device location, form and map dialogs
  l10n/                     English/Arabic ARBs and generated Dart
  firebase_options.dart     FlutterFire-generated configuration
assets/images/              PNG, JPG and WebP assets
assets/icons/               SVG assets
assets/font/cairo/          Registered Cairo TTF font weights
test/                      API transport, pagination and widget tests
```

## Run and validate

Install Flutter with a bundled Dart SDK compatible with `^3.11.5`
(`>=3.11.5 <4.0.0`) and the tooling for your chosen target. Run commands from
the directory containing `pubspec.yaml`:

```sh
flutter pub get
flutter gen-l10n
flutter devices
flutter run
```

Select a device with `flutter run -d <device-id>`, for example
`flutter run -d chrome` for web. Firebase configuration is included for Android,
iOS, web, Windows, and macOS; Linux startup is currently unsupported. Included
platform folders do not imply that all native builds have been verified.

Validate changes with:

```sh
flutter analyze
flutter test
```

The existing tests cover REST verbs/query/body/auth headers and HTTP error
mapping, pagination retries/stale responses/close handling, Arabic RTL, and
disabled loading buttons. Field tests cover required/custom validation, Arabic
RTL layout and external errors. They do not exercise a live backend or Firebase.

To enable REST, provide your actual backend URL:

```sh
flutter run --dart-define=API_BASE_URL=https://your-api.example.com/
```

Without this value `AppServices.api` is null; Firebase initialization and Firestore helpers remain available.
`AppServices` is injected above the app via `RepositoryProvider`.
Keep data operations in feature repositories and inject those into Cubits.
Add `domain/` inside a feature when business rules need their own layer.

## Localization and shared widgets

Add matching keys to `lib/l10n/app_en.arb` and `app_ar.arb`, then run
`flutter gen-l10n`. Import `core/localization/l10n_extension.dart`:

```dart
CustomText(context.l10n.welcome);
CustomText(context.l10n.itemTitle(1));
CustomAppBar(title: context.l10n.appTitle);
CustomMainButton(label: context.l10n.primaryAction, onPressed: save);
CustomSecondaryButton(label: context.l10n.retry, onPressed: retry);
const AppImage(AppAssets.appMark, width: 48, height: 48);
// AppAssets.appMark currently needs its SVG restored; see review notes below.
const AppImage('assets/icons/locationHeader.svg', width: 80, height: 80);
```

`AppImage` supports asset/network SVG and raster files, sizing, semantics and
error fallbacks. Place your PNG files in the registered images directory.
Both buttons support loading/disabled states and optional icons.
`CustomMainButton` uses `AppColors.grey`; `CustomSecondaryButton` uses
`AppColors.lightGrey`. Both have filled backgrounds, 8 px corners, and Cairo
labels at 18 px / weight 500 in `AppColors.black`.
`CustomMainCard` and `CustomSecondaryCard` provide filled/outlined cards with
optional tap callbacks and configurable padding, margin, colors, and elevation.
`CustomListView<T>` supports empty/loading/error, separators and pull to refresh.
`CustomPaginatedListView<T>` handles scroll loading, refresh, footer retry and
filling an initially short viewport. Its parent owns and closes the Cubit:

```dart
BlocProvider(
  create: (_) => PaginationCubit<MyModel>(loadPage: repository.getPage)
    ..loadNextPage(),
  child: MyPage(),
);
// In MyPage:
CustomPaginatedListView<MyModel>(
  cubit: context.read<PaginationCubit<MyModel>>(),
  itemBuilder: (context, item, index) => MyTile(item: item),
);
```

`repository.getPage(int page, int pageSize)` returns `PageResult<MyModel>` with
`items` and `hasMore` from your API. Failed pages preserve loaded items and can
be retried. Refresh invalidates old responses. Use `AsyncCubit<T>.execute` for
single operations and `BlocBuilder`/`BlocListener` for state and side effects.

`CustomTextField` provides an external Cairo label (14 px, weight 500), an 8 px
gap, a filled `#F5F5F5` input with 4 px corners, and red validation borders and
error text. Labels and input follow the current locale's text direction.

```dart
// Place inside Form(key: formKey, child: ...).
CustomTextField(
  label: 'Country', // Pass a localized label in application screens.
  hintText: 'Text Here',
  controller: countryController,
  isRequired: true,
);
// On submit: if (formKey.currentState!.validate()) { ... }
```

Required validation trims whitespace and runs before an optional `validator`.
`requiredErrorText` overrides the localized default. Use `errorText` for server
errors and clear it in the parent on edits. Validation starts on user interaction;
change `autovalidateMode` to control this. The caller owns controllers/focus nodes.

Change colors, spacing, and typography centrally in `core/theme`. Cairo weights
200 through 900 are registered from `assets/font/cairo/` and used by the field.
The rest of the theme continues to use system fonts until a font family is set.

`AppSettingsCubit` supports English/Arabic and theme changes in memory:

```dart
context.read<AppSettingsCubit>().setLocale(const Locale('ar'));
context.read<AppSettingsCubit>().setThemeMode(ThemeMode.dark);
```

The app starts in light mode and uses the device locale when supported, falling
back to English. The location form displays both language columns; global locale
and theme changes are available programmatically. Preferences are not persisted
across restarts.

## REST

```dart
final api = context.read<AppServices>().api!; // Requires API_BASE_URL.
final data = await api.get<Map<String, dynamic>>('users', query: {'page': 1});
await api.post('users', data: {'name': 'Sara'});
await api.put('users/123', data: {'name': 'Sara'});
await api.patch('users/123', data: {'name': 'Mona'});
await api.delete('users/123');
```

Responses are JSON data; decode them into feature models in your repository.
Requests support Dio `CancelToken` and bounded timeouts. Errors become
`AppFailure` with code/status for localized UI handling. The interceptor logs
method and endpoint URL for each request, response, and failure; query parameters,
headers and bodies are omitted. Logs currently use the logger package's default
development filter, so they are suppressed in release builds despite the
configured info level. No automatic retries are applied.

Authentication headers are opt-in; `AppServices.initialize()` does not attach a
token provider. If your backend verifies Firebase ID tokens, wire the following
client into `AppServices`:

```dart
ApiClient(
  baseUrl: 'https://your-api.example.com/',
  tokenProvider: () async => FirebaseAuth.instance.currentUser?.getIdToken(),
);
```

Connection timeout is 20 seconds; send and receive timeouts are 30 seconds.

## Firebase project appy-d6c72

FlutterFire configuration completed for Android, iOS, web, Windows and macOS
using the existing `com.example.example` identifiers. Linux is not configured.
iOS targets 15.0 to match the installed Firebase plugin requirement. Native Apple
builds require macOS/Xcode and have not been built in this Windows workspace.
If app identifiers or supported platforms change, rerun:

```sh
flutterfire configure --project=appy-d6c72
```

When reusing this template for another app, configure your own Firebase project
and update the application identifiers first. The command requires Firebase CLI
and FlutterFire CLI installation and access to the selected Firebase project.

Initialization uses generated `DefaultFirebaseOptions`. Firebase Auth is exposed
as `AppServices.auth`; enable your chosen sign-in provider in Firebase Console.
Firestore service usage after initialization:

```dart
final db = context.read<AppServices>().firestore;
final id = await db.post('users', {'name': 'Sara'}); // Create with auto ID.
// Alternative: also store the generated document ID in an `id` field.
final idWithField = await db.postWithId('users', {'name': 'Mona'});
final user = await db.get('users', id);
final users = await db.list('users', limit: 20);
await db.put('users', id, {'name': 'Mona'}); // Full replacement/create.
await db.patch('users', id, {'name': 'Sara'}); // Update existing fields.
await db.delete('users', id);
final stream = db.watch('users', id);
final first = await db.page('users', pageSize: 20);
if (first.hasMore) {
  final next = await db.page('users', pageSize: 20, after: first.cursor);
  // Map next.documents into your feature models.
}
```

Firestore uses SDK operations rather than HTTP verbs; the service provides
equivalent get/post/put/patch/delete methods. Cursor pages expose document IDs,
`hasMore` and the last document cursor. Use the same ordering for subsequent
pages, and reset the cursor on refresh. Ordered fields must exist in documents;
custom queries may need indexes. Map snapshots to your own models.
`get` returns document data or null, while `list` and paginated `documents`
return snapshots with IDs. Future-based operations map backend errors into
`AppFailure`; `watch` exposes the SDK stream directly, including its errors.

`PaginationCubit` uses page numbers starting at 1; Firestore uses document
cursors. A feature repository must retain/reset cursors if it adapts Firestore
pages to the generic Cubit.

FlutterFire initializes the configured project. The Locations repository uses
collection snapshots for automatic list refresh and `postWithId` to create
locations. Reads and writes require deployed rules to allow them; the app does
not seed or clear database data automatically.
Manage the database in [Firebase Console](https://console.firebase.google.com/project/appy-d6c72/firestore).
Firebase setup reference: [official Flutter guide](https://firebase.google.com/docs/flutter/setup).

## Adding a feature

1. Create `lib/features/<feature>/data/` for models and repositories, and
   `presentation/` for screens and Cubits. Add `domain/` when business rules need
   a separate layer.
2. Inject the API or Firestore service into the repository, then inject that
   repository into the feature Cubit using providers.
3. Use `AsyncCubit<T>` for single operations or `PaginationCubit<T>` for lists.
   Map `AppFailure.code` and `statusCode` to localized UI messages.
4. Add matching ARB keys, regenerate localization, and reuse the shared theme
   and widgets.
5. Add tests for feature behavior, then run the analyzer and existing tests.

## Template review notes

Reviewed on 14 October 2026. `flutter analyze` reported no issues and all six
existing tests passed. Platform builds and live Firebase operations were not
verified in this review.

| Area | Current limitation / next step |
| --- | --- |
| Home image | The location form uses the existing `Map Point.svg`. The unused `AppAssets.appMark` constant still points to a missing asset; restore it before using that constant elsewhere. |
| Fonts | Cairo weights are registered and used by `CustomTextField`; set a theme font family if Cairo should apply throughout the app. |
| Release logging | `AppLogger` keeps the default development filter, which suppresses release logs. Configure a production filter if release endpoint logging is required. |
| Settings | Locale/theme changes are held in memory; add persistence if needed. |
| Firebase platforms | Linux throws `UnsupportedError` during initialization. Apple builds require macOS/Xcode; iOS deployment target is 15.0. |
| Android release | Application ID is still `com.example.example`, and release builds use debug signing. Set the app ID and release signing before distribution. |
| Test coverage | No live Firestore/Auth integration tests or tests for startup retry, dark theme, async state, or paginated widget scrolling are included. |

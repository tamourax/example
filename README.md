# Flutter application foundation

This existing project now has shared widgets, English/Arabic ARB localization
(including RTL), a Material 3 light theme, Cubits, REST networking and Firebase.
The home screen is a clean component showcase. It does not read, seed, or modify
Firestore data. Firebase initialization and reusable database helpers remain
available for feature repositories when you add application logic.

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
  features/home/            Starter screen built from shared widgets
  l10n/                     English/Arabic ARBs and generated Dart
  firebase_options.dart     FlutterFire-generated configuration
assets/images/              PNG, JPG and WebP assets
assets/icons/               SVG assets
```

## Run and validate

```sh
flutter pub get
flutter gen-l10n
flutter run
flutter analyze
flutter test
```

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
const AppImage('assets/images/photo.png', width: 80, height: 80);
```

`AppImage` supports asset/network SVG and raster files, sizing, semantics and
error fallbacks. Place your PNG files in the registered images directory.
Both buttons support loading/disabled states and optional icons.
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

Change colors/spacing/type centrally in `core/theme`. Arabic uses system font
fallback; register your own Arabic/Latin font in pubspec before setting a family.
Settings support English/Arabic and theme switching in memory. The app starts in
light mode; preferences are not persisted across restarts.

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
headers and bodies are omitted. No automatic retries are applied to mutations. If your backend verifies Firebase ID tokens, construct
`ApiClient` with `tokenProvider: () async => FirebaseAuth.instance.currentUser?.getIdToken()`.

## Firebase project appy-d6c72

FlutterFire configuration completed for Android, iOS, web, Windows and macOS
using the existing `com.example.example` identifiers. Linux is not configured.
iOS targets 15.0 to match the installed Firebase plugin requirement. Native Apple
builds require macOS/Xcode and have not been built in this Windows workspace.
If app identifiers or supported platforms change, rerun:

```sh
flutterfire configure --project=appy-d6c72
```

Initialization uses generated `DefaultFirebaseOptions`. Firebase Auth is exposed
as `AppServices.auth`; enable your chosen sign-in provider in Firebase Console.
Firestore service usage after initialization:

```dart
final db = context.read<AppServices>().firestore;
final id = await db.post('users', {'name': 'Sara'}); // Create with auto ID.
final user = await db.get('users', id);
final users = await db.list('users', limit: 20);
await db.put('users', id, {'name': 'Mona'}); // Full replacement/create.
await db.patch('users', id, {'name': 'Sara'}); // Update existing fields.
await db.delete('users', id);
final stream = db.watch('users', id);
final first = await db.page('users', pageSize: 20);
final next = await db.page('users', pageSize: 20, after: first.cursor);
```

Firestore uses SDK operations rather than HTTP verbs; the service provides
equivalent get/post/put/patch/delete methods. Cursor pages expose document IDs,
`hasMore` and the last document cursor. Use the same ordering for subsequent
pages, and reset the cursor on refresh. Ordered fields must exist in documents;
custom queries may need indexes. Map snapshots to your own models.

FlutterFire initializes the configured project, while the starter home screen
does not read, create, or delete Firestore records. Use the generic CRUD and
stream helpers from a feature repository when you add app logic. Reads and writes
require deployed rules to allow them; the app does not seed or clear database data automatically.
Manage the database in [Firebase Console](https://console.firebase.google.com/project/appy-d6c72/firestore).
Firebase setup reference: [official Flutter guide](https://firebase.google.com/docs/flutter/setup).

import 'dart:async';
import 'package:example/core/errors/app_failure.dart';
import 'package:example/core/widgets/custom_buttons.dart';
import 'package:example/core/widgets/custom_switch.dart';
import 'package:example/features/home/presentation/home_page.dart';
import 'package:example/features/locations/data/device_location_service.dart';
import 'package:example/features/locations/data/locations_repository.dart';
import 'package:example/features/locations/presentation/location_form_dialog.dart';
import 'package:example/features/locations/presentation/location_map_dialog.dart';
import 'package:example/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

class TestDeviceLocation implements DeviceLocationService {
  TestDeviceLocation({this.failure, this.pending});
  final DeviceLocationFailure? failure;
  final Completer<LatLng>? pending;
  @override
  Future<LatLng> currentPosition() async {
    if (failure != null) throw failure!;
    return pending == null ? const LatLng(30.0444, 31.2357) : pending!.future;
  }
}

class TestLocationsRepository implements LocationsRepository {
  final updates = StreamController<List<LocationRecord>>.broadcast();
  final records = <LocationRecord>[];
  Completer<void>? pending;
  Object? failure;
  int calls = 0;
  Map<String, Object?>? submitted;
  @override
  Stream<List<LocationRecord>> watch() async* {
    yield List.of(records);
    yield* updates.stream;
  }

  @override
  Future<void> create(Map<String, Object?> fields) async {
    calls++;
    submitted = fields;
    if (pending != null) await pending!.future;
    if (failure != null) throw failure!;
    records.add(LocationRecord(id: 'test-id', fields: fields));
    updates.add(List.of(records));
  }
}

Finder input(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(TextFormField),
);

Future<void> openForm(
  WidgetTester tester, {
  TestLocationsRepository? repository,
  DeviceLocationService? device,
  Size size = const Size(1200, 1400),
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomePage(
        repository: repository,
        deviceLocation: device ?? TestDeviceLocation(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byType(CustomMainButton));
  if (device is TestDeviceLocation && device.pending != null) {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  } else {
    await tester.pumpAndSettle();
  }
}

Future<void> fillForm(WidgetTester tester) async {
  final fields = {
    'nameEn': 'Cairo Office',
    'countryEn': 'Egypt',
    'countryAr': 'مصر',
    'stateEn': 'Cairo',
    'stateAr': 'القاهرة',
    'cityEn': 'Cairo',
    'cityAr': 'القاهرة',
    'postalCodeEn': '11511',
    'postalCodeAr': '١١٥١١',
  };
  for (final entry in fields.entries) {
    await tester.ensureVisible(input(entry.key));
    await tester.enterText(input(entry.key), entry.value);
  }
}

Future<void> submit(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Create'));
  await tester.tap(find.text('Create'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('all required fields validate and device coordinates autofill', (
    tester,
  ) async {
    await openForm(tester);
    expect(
      tester.widget<TextFormField>(input('latitude')).controller!.text,
      '30.044400',
    );
    expect(
      tester.widget<TextFormField>(input('longitude')).controller!.text,
      '31.235700',
    );
    expect(
      Directionality.of(tester.element(input('countryAr'))),
      TextDirection.rtl,
    );
    await submit(tester);
    expect(find.text('This field is required'), findsNWidgets(5));
    expect(find.text('هذا الحقل مطلوب'), findsNWidgets(4));
    expect(find.text('Yes'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'No keeps form; Yes waits for save then shows success and live list',
    (tester) async {
      final repository = TestLocationsRepository()..pending = Completer<void>();
      addTearDown(repository.updates.close);
      await openForm(tester, repository: repository);
      await fillForm(tester);
      await submit(tester);
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      expect(repository.calls, 0);
      expect(find.byType(LocationFormDialog), findsOneWidget);
      await submit(tester);
      await tester.tap(find.text('Yes'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(repository.calls, 1);
      expect(find.text('Successful'), findsNothing);
      final create = tester.widget<CustomMainButton>(
        find.widgetWithText(CustomMainButton, 'Create'),
      );
      expect(create.isLoading, isTrue);
      await tester.tap(find.text('Create'));
      expect(repository.calls, 1);
      repository.pending!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Successful'), findsOneWidget);
      expect(find.byType(LocationFormDialog), findsNothing);
      expect(repository.submitted?['latitude'], 30.0444);
      expect(repository.submitted?['countryAr'], 'مصر');
      expect(repository.submitted?['allowGeofence'], false);
      expect(repository.submitted?['allowBreaks'], false);
      expect(repository.submitted?['allowPause'], false);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Cairo Office'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('failed save keeps values, shows error and allows retry', (
    tester,
  ) async {
    final repository = TestLocationsRepository()
      ..failure = const AppFailure('permission-denied');
    addTearDown(repository.updates.close);
    await openForm(tester, repository: repository);
    await fillForm(tester);
    await submit(tester);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(
      find.text('You do not have permission to add locations.'),
      findsOneWidget,
    );
    expect(find.text('Successful'), findsNothing);
    expect(
      tester.widget<TextFormField>(input('nameEn')).controller!.text,
      'Cairo Office',
    );
    repository.failure = null;
    await submit(tester);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(find.text('Successful'), findsOneWidget);
    expect(repository.calls, 2);
  });

  testWidgets('mobile denial allows manual coordinates and map selection', (
    tester,
  ) async {
    await openForm(
      tester,
      size: const Size(390, 844),
      device: TestDeviceLocation(failure: DeviceLocationFailure.denied),
    );
    expect(
      tester.getTopLeft(input('nameAr')).dy,
      greaterThan(tester.getBottomLeft(input('nameEn')).dy),
    );
    expect(
      find.textContaining('Location permission was denied.'),
      findsOneWidget,
    );
    await tester.ensureVisible(input('latitude'));
    await tester.enterText(input('latitude'), '91');
    await submit(tester);
    expect(find.text('Enter a valid coordinate within range'), findsOneWidget);
    await tester.ensureVisible(find.text('Select on map'));
    await tester.tap(find.text('Select on map'));
    await tester.pumpAndSettle();
    expect(find.byType(LocationMapDialog), findsOneWidget);
    final map = tester.widget<FlutterMap>(find.byType(FlutterMap));
    map.options.onTap!(
      const TapPosition(Offset.zero, Offset.zero),
      const LatLng(25.1, 32.2),
    );
    await tester.pump();
    await tester.tap(find.text('Use selected location'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(input('latitude')).controller!.text,
      '25.100000',
    );
    expect(
      tester.widget<TextFormField>(input('longitude')).controller!.text,
      '32.200000',
    );
    expect(
      tester.widget<TextFormField>(input('mapsUrl')).controller!.text,
      contains('25.1,32.2'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('delayed GPS never overwrites manual input', (tester) async {
    final pending = Completer<LatLng>();
    await openForm(tester, device: TestDeviceLocation(pending: pending));
    await tester.enterText(input('latitude'), '12.5');
    await tester.enterText(input('longitude'), '40.5');
    pending.complete(const LatLng(30, 31));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(input('latitude')).controller!.text,
      '12.5',
    );
    expect(
      tester.widget<TextFormField>(input('longitude')).controller!.text,
      '40.5',
    );
  });

  testWidgets('discard clears fields and switch values', (tester) async {
    await openForm(tester);
    await fillForm(tester);
    await tester.ensureVisible(find.byType(CustomSwitch).first);
    await tester.tap(
      find.descendant(
        of: find.byType(CustomSwitch).first,
        matching: find.byType(InkWell),
      ),
    );
    await tester.ensureVisible(find.text('Discard'));
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(input('nameEn')).controller!.text,
      isEmpty,
    );
    expect(
      tester.widget<CustomSwitch>(find.byType(CustomSwitch).first).value,
      isFalse,
    );
    expect(find.text('This field is required'), findsNothing);
  });

  testWidgets('Arabic mobile form renders without overflow', (tester) async {
    await openForm(
      tester,
      size: const Size(390, 844),
      locale: const Locale('ar'),
    );
    expect(find.text('إنشاء موقع جديد'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading primary button prevents duplicate submits', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomMainButton(
            label: 'Save',
            isLoading: true,
            onPressed: () => calls++,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Save'));
    expect(calls, 0);
  });
}

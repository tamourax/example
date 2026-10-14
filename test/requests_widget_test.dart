import 'dart:async';
import 'dart:typed_data';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:example/app/app.dart';
import 'package:example/core/errors/app_failure.dart';
import 'package:example/core/widgets/custom_buttons.dart';
import 'package:example/core/widgets/custom_switch.dart';
import 'package:example/features/requests/data/request_models.dart';
import 'package:example/features/requests/presentation/attachment_upload_dialog.dart';
import 'package:example/features/requests/presentation/request_form_dialog.dart';
import 'package:example/features/requests/presentation/requests_page.dart';
import 'package:example/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'requests_test_support.dart';

class _DroppedPdf extends DropItemFile {
  _DroppedPdf() : super.fromData(pdfAttachment().bytes);
  @override
  String get name => 'dropped.pdf';
}

Finder _input(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(TextFormField),
);
Finder _submit() => find.descendant(
  of: find.byType(RequestFormDialog),
  matching: find.widgetWithText(CustomMainButton, 'Submit'),
);

Future<void> _open(
  WidgetTester tester, {
  TestRequestsRepository? repository,
  TestRequestPicker? picker,
  Size size = const Size(1100, 1000),
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
      home: RequestsPage(
        repository: repository,
        attachmentPicker: picker ?? TestRequestPicker(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byType(CustomMainButton));
  await tester.pumpAndSettle();
}

Future<void> _fill(WidgetTester tester) async {
  for (final entry in {
    'requestType': 'Sick Leave',
    'description': 'Medical appointment',
    'startDate': '2026-10-14',
    'endDate': '2026-10-14',
    'startTime': '09:00',
    'endTime': '10:00',
  }.entries) {
    await tester.ensureVisible(_input(entry.key));
    await tester.enterText(_input(entry.key), entry.value);
  }
}

Future<void> _send(WidgetTester tester) async {
  await tester.ensureVisible(_submit());
  await tester.tap(_submit());
  await tester.pumpAndSettle();
}

Future<void> _toggleAllDay(WidgetTester tester) async {
  final toggle = find.descendant(
    of: find.byKey(const ValueKey('allDay')),
    matching: find.byType(InkWell),
  );
  await tester.ensureVisible(toggle);
  await tester.tap(toggle);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty form validates all six required text fields', (
    tester,
  ) async {
    await _open(tester);
    await _send(tester);
    expect(find.text('This field is required'), findsNWidgets(6));
    expect(find.text('Yes'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid dates and same-day time order block submission', (
    tester,
  ) async {
    await _open(tester);
    await _fill(tester);
    await tester.enterText(_input('endDate'), '2026-10-13');
    await _send(tester);
    expect(
      find.text('End Date must be on or after Start Date'),
      findsOneWidget,
    );
    await tester.enterText(_input('endDate'), '2026-10-14');
    await tester.enterText(_input('endTime'), '08:59');
    await _send(tester);
    expect(
      find.text('End Time must be on or after Start Time for the same day'),
      findsOneWidget,
    );
    expect(find.text('Yes'), findsNothing);
  });

  testWidgets('All Day hides times and submits null times with equal dates', (
    tester,
  ) async {
    final repository = TestRequestsRepository();
    addTearDown(repository.updates.close);
    await _open(tester, repository: repository);
    await _fill(tester);
    await tester.enterText(_input('startTime'), 'invalid');
    await _toggleAllDay(tester);
    expect(_input('startTime'), findsNothing);
    expect(_input('endTime'), findsNothing);
    await _send(tester);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(repository.submitted?.allDay, true);
    expect(repository.submitted?.startTime, isNull);
    expect(
      find.text('Your Request Has Been Successfully Submitted'),
      findsOneWidget,
    );
    expect(find.byType(RequestFormDialog), findsNothing);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(find.text('Sick Leave'), findsOneWidget);
    expect(find.text('All Day'), findsOneWidget);
  });

  testWidgets(
    'No preserves form, pending save blocks duplicates, failure permits retry',
    (tester) async {
      final repository = TestRequestsRepository()..pending = Completer<void>();
      addTearDown(repository.updates.close);
      await _open(tester, repository: repository);
      await _fill(tester);
      await _send(tester);
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      expect(repository.calls, 0);
      expect(
        tester.widget<TextFormField>(_input('description')).controller!.text,
        'Medical appointment',
      );
      await _send(tester);
      await tester.tap(find.text('Yes'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Successful'), findsNothing);
      expect(tester.widget<CustomMainButton>(_submit()).isLoading, true);
      await tester.tap(_submit());
      expect(repository.calls, 1);
      repository.failure = const AppFailure('permission-denied');
      repository.pending!.complete();
      await tester.pumpAndSettle();
      expect(
        find.text(
          'You do not have permission to submit requests or upload attachments.',
        ),
        findsOneWidget,
      );
      expect(find.byType(RequestFormDialog), findsOneWidget);
      repository.failure = null;
      repository.pending = null;
      await _send(tester);
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      expect(repository.calls, 2);
      expect(find.text('Successful'), findsOneWidget);
    },
  );

  testWidgets(
    'attachments can be browsed, removed and saved with the request',
    (tester) async {
      final repository = TestRequestsRepository();
      addTearDown(repository.updates.close);
      await _open(tester, repository: repository);
      await _fill(tester);
      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Browse Files'));
      await tester.pumpAndSettle();
      expect(find.text('document.pdf'), findsOneWidget);
      await tester.tap(find.byTooltip('Remove attachment'));
      await tester.pumpAndSettle();
      expect(find.text('document.pdf'), findsNothing);
      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Browse Files'));
      await tester.pumpAndSettle();
      await _send(tester);
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      expect(
        repository.submitted?.attachments.single.contentType,
        'application/pdf',
      );
    },
  );

  testWidgets('upload rejects invalid files and accepts a dropped PDF', (
    tester,
  ) async {
    final picker = TestRequestPicker()..failure = AttachmentFailure.unsupported;
    await _open(tester, picker: picker);
    await tester.tap(find.text('Upload'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Browse Files'));
    await tester.pumpAndSettle();
    expect(
      find.text('Choose a valid image (PNG, JPG, GIF, WebP, BMP) or PDF file.'),
      findsOneWidget,
    );
    final target = tester.widget<DropTarget>(find.byType(DropTarget));
    target.onDragDone!(
      DropDoneDetails(
        files: [_DroppedPdf()],
        localPosition: Offset.zero,
        globalPosition: Offset.zero,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('dropped.pdf'), findsOneWidget);
    expect(find.byType(AttachmentUploadDialog), findsNothing);
  });

  test(
    'attachment validation checks file content, size and immutable bytes',
    () {
      expect(
        () => RequestAttachment.fromBytes(
          'fake.pdf',
          Uint8List.fromList([1, 2, 3]),
        ),
        throwsA(AttachmentFailure.unsupported),
      );
      expect(
        () => RequestAttachment.fromBytes('file.exe', pdfAttachment().bytes),
        throwsA(AttachmentFailure.unsupported),
      );
      expect(
        () => RequestAttachment.fromBytes('empty.pdf', Uint8List(0)),
        throwsA(AttachmentFailure.empty),
      );
      expect(
        () => RequestAttachment.fromBytes(
          'big.pdf',
          Uint8List(RequestAttachment.maxBytes + 1),
        ),
        throwsA(AttachmentFailure.tooLarge),
      );
      expect(() => pdfAttachment().bytes[0] = 0, throwsUnsupportedError);
    },
  );

  testWidgets('mobile Arabic layout and All Day toggle do not overflow', (
    tester,
  ) async {
    await _open(tester, size: const Size(390, 844), locale: const Locale('ar'));
    expect(find.text('إنشاء طلب جديد'), findsOneWidget);
    await _toggleAllDay(tester);
    expect(_input('startTime'), findsNothing);
    expect(tester.widget<CustomSwitch>(find.byType(CustomSwitch)).value, true);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Requests navigation is independent of Locations', (
    tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    expect(find.text('Creating New Locations'), findsOneWidget);
    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();
    expect(find.byType(RequestsPage), findsOneWidget);
    expect(find.text('Creating New Locations'), findsNothing);
    await tester.tap(find.text('Locations'));
    await tester.pumpAndSettle();
    expect(find.text('Creating New Locations'), findsOneWidget);
  });
}

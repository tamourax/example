import 'dart:io';
import 'dart:ui' as ui;
import 'package:example/features/requests/presentation/request_form_dialog.dart';
import 'package:example/features/requests/presentation/requests_page.dart';
import 'package:example/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'requests_test_support.dart';

void main() {
  testWidgets(
    'render request form, attachment, confirmation and success previews',
    (tester) async {
      tester.view.physicalSize = const Size(1100, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fonts = FontLoader('Cairo');
      for (final weight in ['Regular', 'Medium', 'SemiBold']) {
        fonts.addFont(rootBundle.load('assets/font/cairo/Cairo-$weight.ttf'));
      }
      await fonts.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      final repository = TestRequestsRepository();
      addTearDown(repository.updates.close);
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            locale: const Locale('en'),
            theme: ThemeData(fontFamily: 'Cairo'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: RequestsPage(
              repository: repository,
              attachmentPicker: TestRequestPicker(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      Future<void> capture(String name) async {
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1.5);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final directory = Directory(
            '${Directory.current.path}/build/request-previews',
          );
          await directory.create(recursive: true);
          await File(
            '${directory.path}/$name.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capture('request-form');
      for (final entry in {
        'requestType': 'Sick Leave',
        'description': 'Medical appointment',
        'startDate': '2026-10-14',
        'endDate': '2026-10-14',
        'startTime': '09:00',
        'endTime': '10:00',
      }.entries) {
        final field = find.descendant(
          of: find.byKey(ValueKey(entry.key)),
          matching: find.byType(TextFormField),
        );
        await tester.ensureVisible(field);
        await tester.enterText(field, entry.value);
      }
      await tester.ensureVisible(find.text('Upload'));
      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
      await capture('request-attachment');
      await tester.tap(find.text('Browse Files'));
      await tester.pumpAndSettle();
      await capture('request-filled');
      final submit = find.descendant(
        of: find.byType(RequestFormDialog),
        matching: find.text('Submit'),
      );
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      await capture('request-confirm');
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      await capture('request-success');
      expect(tester.takeException(), isNull);
    },
  );
}

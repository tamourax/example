import 'package:example/app/app.dart';
import 'package:example/core/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starter home has no sample records and supports Arabic RTL', (
    tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    expect(find.text('Your foundation is ready'), findsOneWidget);
    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.text('Item 1'), findsNothing);
    await tester.tap(find.byTooltip('Change language'));
    await tester.pumpAndSettle();
    final arabicWelcome = String.fromCharCodes([
      0x0623,
      0x0633,
      0x0627,
      0x0633,
      0x0020,
      0x062a,
      0x0637,
      0x0628,
      0x064a,
      0x0642,
      0x0643,
      0x0020,
      0x062c,
      0x0627,
      0x0647,
      0x0632,
    ]);
    expect(find.text(arabicWelcome), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text(arabicWelcome))),
      TextDirection.rtl,
    );
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

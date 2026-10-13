import 'package:example/app/app.dart';
import 'package:example/core/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('demo loads, switches to Arabic RTL, and paginates to the end', (
    tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    expect(find.text('Your foundation is ready'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    await tester.tap(find.text('Change language'));
    await tester.pumpAndSettle();
    expect(find.text('أساس تطبيقك جاهز'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('أساس تطبيقك جاهز'))),
      TextDirection.rtl,
    );
    for (var i = 0; i < 30; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
    }
    expect(find.text('العنصر 53'), findsOneWidget);
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

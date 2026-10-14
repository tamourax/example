import 'package:example/core/widgets/custom_text_field.dart';
import 'package:example/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('required validation rejects whitespace and clears after input', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      _app(
        Form(
          key: formKey,
          child: CustomTextField(
            label: 'Country',
            isRequired: true,
            validator: (value) => value == 'invalid' ? 'Invalid country' : null,
          ),
        ),
      ),
    );
    expect(find.text('This field is required'), findsNothing);
    await tester.enterText(find.byType(TextFormField), '   ');
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'invalid');
    await tester.pump();
    expect(find.text('Invalid country'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Egypt');
    await tester.pump();
    expect(formKey.currentState!.validate(), isTrue);
    expect(find.text('This field is required'), findsNothing);
    expect(find.text('Invalid country'), findsNothing);
  });

  testWidgets('Arabic label, spacing and required error follow RTL', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      _app(
        Form(
          key: formKey,
          child: const CustomTextField(label: 'دولة', isRequired: true),
        ),
        locale: const Locale('ar'),
      ),
    );
    final label = find.text('دولة');
    final field = find.byType(TextFormField);
    expect(Directionality.of(tester.element(field)), TextDirection.rtl);
    expect(tester.getTopLeft(field).dy - tester.getBottomLeft(label).dy, 8);
    formKey.currentState!.validate();
    await tester.pump();
    expect(find.text('هذا الحقل مطلوب'), findsOneWidget);
  });

  testWidgets('external error can be shown and cleared by the parent', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const CustomTextField(label: 'Country', errorText: 'Server error')),
    );
    expect(find.text('Server error'), findsOneWidget);
    await tester.pumpWidget(_app(const CustomTextField(label: 'Country')));
    await tester.pump();
    expect(find.text('Server error'), findsNothing);
  });
}

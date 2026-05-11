// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:antepli/main.dart';

void main() {
  testWidgets('App starts with localized title', (WidgetTester tester) async {
    await EasyLocalization.ensureInitialized();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('tr'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('tr'),
        child: const AntepliApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Anteplioglu ERP'), findsOneWidget);
  });
}

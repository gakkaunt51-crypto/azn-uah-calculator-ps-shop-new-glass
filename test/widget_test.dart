import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:azn_uah_calculator/main.dart';

void main() {
  testWidgets('Mini calculator evaluates a simple expression',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: MiniCalcDialog(onAdd: (_) {})),
    );

    expect(find.text('Калькулятор'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '2'));
    await tester.tap(find.widgetWithText(FilledButton, '+'));
    await tester.tap(find.widgetWithText(FilledButton, '3'));
    await tester.tap(find.widgetWithText(FilledButton, '='));
    await tester.pump();

    expect(find.text('5'), findsOneWidget);
  });
}

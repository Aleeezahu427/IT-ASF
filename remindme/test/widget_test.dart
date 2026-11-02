// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remindme/demo.dart';

void main() {
  testWidgets(
    'Child demo completes task and updates progress and points once',
    (tester) async {
      await tester.binding.setSurfaceSize(
        const Size(900, 1600),
      );

      addTearDown(
        () => tester.binding.setSurfaceSize(null),
      );

      await tester.pumpWidget(const DemoApp());

      expect(find.text('Hi, Alex! 👋'), findsOneWidget);
      expect(find.text('70 points'), findsOneWidget);
      expect(find.text('60% finished'), findsOneWidget);

      await tester.tap(find.text('Start task'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mark complete'));
      await tester.pumpAndSettle();

      expect(find.text('70% finished'), findsOneWidget);
      expect(find.text('7/10 tasks completed'), findsOneWidget);
      expect(find.text('80 points'), findsOneWidget);
      expect(find.text('80/100 points'), findsOneWidget);

      final completedButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Completed'),
      );

      expect(completedButton.onPressed, isNull);

      await tester.tap(find.byTooltip('Reset demo'));
      await tester.pumpAndSettle();

      expect(find.text('60% finished'), findsOneWidget);
    },
  );

  testWidgets(
    'Bottom navigation opens placeholder and returns home',
    (tester) async {
      await tester.pumpWidget(const DemoApp());

      await tester.tap(find.text('Routines'));
      await tester.pumpAndSettle();

      expect(
        find.text('Routines page coming soon'),
        findsOneWidget,
      );

      await tester.tap(find.text('Back to Home'));
      await tester.pumpAndSettle();

      expect(find.text('Hi, Alex! 👋'), findsOneWidget);
    },
  );
}

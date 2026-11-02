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
  Future<void> mobile(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const DemoApp());
  }

  testWidgets('Chooser opens child; completion updates points; role switch works', (tester) async {
    await mobile(tester);
    await tester.tap(find.text('I’m a child'));
    await tester.pumpAndSettle();
    expect(find.text('Hi, Alex! 👋'), findsOneWidget);
    expect(find.text('60% finished'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Start task'), 150);
    await tester.tap(find.text('Start task'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Mark complete'));
    await tester.tap(find.text('Mark complete'));
    await tester.pumpAndSettle();
    expect(find.text('80 points'), findsOneWidget);
    await tester.tap(find.text('Switch role'));
    await tester.pumpAndSettle();
    expect(find.text('Who’s using the app?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Parent assigns a demo task inside mobile viewport', (tester) async {
    await mobile(tester);
    await tester.tap(find.text('I’m a parent'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Create task'), 120);
    await tester.tap(find.text('Create task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Read for 15 minutes');
    await tester.tap(find.text('Assign task'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Alex: Read for 15 minutes'), 120);
    expect(find.text('Alex: Read for 15 minutes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Wide browser displays chooser in phone frame', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const DemoApp());
    expect(find.byType(FittedBox), findsOneWidget);
    await tester.tap(find.text('I’m a parent'));
    await tester.pumpAndSettle();
    expect(find.text('Hi, Falis! 👋'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}


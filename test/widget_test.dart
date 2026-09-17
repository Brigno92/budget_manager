import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_manager/main.dart';
import 'package:budget_manager/FE/routing/app_routes.dart';

void main() {
  testWidgets('AppShell shows the menu, the initial page and the FAB', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byIcon(Icons.add), findsOneWidget);
    for (final page in AppRoutes.pages) {
      expect(find.text(page.label), findsWidgets);
    }
  });

  testWidgets('Selecting a menu entry navigates the content area', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Initial page: "Home" is shown in the rail and the app bar; the content
    // area renders the real Home page (data-driven) rather than a label stub.
    expect(find.text('Home'), findsNWidgets(2));

    await tester.tap(find.text('Registro').last);
    await tester.pumpAndSettle();

    // After navigating, "Home" remains only as a rail label.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Registro'), findsNWidgets(3));
  });

  testWidgets('Pressing the FAB opens the register-transaction dialog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('Registra transazione'), findsOneWidget);

    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    expect(find.text('Registra transazione'), findsNothing);
  });
}

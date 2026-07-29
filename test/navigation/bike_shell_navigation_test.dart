import 'package:bike_renting_app/app/bike_renting_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bottom navigation replaces root route', (tester) async {
    await tester.pumpWidget(const BikeRentingApp());
    await tester.pumpAndSettle();

    expect(_headerTitle('Home'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('top-back')), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('nav-stations')));
    await tester.pumpAndSettle();

    expect(_headerTitle('Stations'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('top-back')), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('nav-profile')));
    await tester.pumpAndSettle();

    expect(_headerTitle('Profile'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('top-back')), findsNothing);
  });

  testWidgets('settings route returns to selected root', (tester) async {
    await tester.pumpWidget(const BikeRentingApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('nav-history')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('top-settings')));
    await tester.pumpAndSettle();

    expect(_headerTitle('Settings'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('settings-page')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('top-back')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('top-back')));
    await tester.pumpAndSettle();

    expect(_headerTitle('History'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('top-back')), findsNothing);
  });

  testWidgets('admin child route pops back to admin', (tester) async {
    await tester.pumpWidget(const BikeRentingApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('top-admin')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('admin-bikes')));
    await tester.pumpAndSettle();

    expect(_headerTitle('Bike management'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('bike-management-page')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey<String>('top-back')));
    await tester.pumpAndSettle();

    expect(_headerTitle('Admin management'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('admin-page')), findsOneWidget);
  });
}

Finder _headerTitle(String title) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.key == const ValueKey<String>('top-page-title') &&
        widget.data == title,
  );
}

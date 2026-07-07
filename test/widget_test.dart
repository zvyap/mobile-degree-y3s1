import 'package:bike_renting_app/app/bike_renting_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home shell renders and supports theme/nav actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BikeRentingApp());

    expect(find.text('BikeRent'), findsOneWidget);
    expect(find.text('Rent a bike in seconds'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.byTooltip('Switch to dark theme'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Switch to light theme'), findsOneWidget);

    await tester.tap(find.byTooltip('Start ride'));
    await tester.pumpAndSettle();

    expect(find.text('Renting'), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner_rounded), findsWidgets);
  });

  testWidgets('home layout supports compact phone viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BikeRentingApp());

    expect(find.text('Rent a bike in seconds'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Modules'),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Modules'), findsOneWidget);
  });
}

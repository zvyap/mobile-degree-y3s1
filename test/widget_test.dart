import 'package:bike_renting_app/app/bike_renting_app.dart';
import 'package:bike_renting_app/features/qr/qr_scan_page.dart';
import 'package:bike_renting_app/features/renting/renting_demo_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home shell renders and supports theme/nav actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BikeRentingApp());

    expect(find.text('BikeRent'), findsOneWidget);
    expect(find.text('Ready to ride?'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Modules'), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('top-settings')));
    await tester.pumpAndSettle();
    expect(find.text('App settings'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('settings-theme')));
    await tester.pumpAndSettle();
    expect(find.text('On'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('top-back')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('nav-scan')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('rent-camera-preview')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey<String>('rent-journey')), findsNothing);
    expect(find.byKey(const ValueKey<String>('top-back')), findsNothing);
    expect(find.text('Bike Session'), findsOneWidget);
    expect(find.byKey(const ValueKey('rent-scan-success')), findsNothing);
    expect(find.byIcon(Icons.qr_code_scanner_rounded), findsWidgets);

    await tester.tap(find.byKey(const ValueKey<String>('nav-home')));
    await tester.pumpAndSettle();

    expect(find.text('Ready to ride?'), findsOneWidget);
  });

  testWidgets('home stays compact and routes through rider actions', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BikeRentingApp());

    expect(find.text('Ready to ride?'), findsOneWidget);
    expect(find.text('Live network'), findsOneWidget);
    expect(find.text('Ride conditions'), findsOneWidget);
    expect(find.text('Demo data'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Near you'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Near you'), findsOneWidget);
    expect(find.text('Modules'), findsNothing);
    expect(find.byKey(const ValueKey<String>('home-content')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey<String>('home-view-stations')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey<String>('top-page-title')))
          .data,
      'Stations',
    );
  });

  testWidgets('home shows wrapping demo ride conditions', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const BikeRentingApp());
    await tester.tap(find.byKey(const ValueKey<String>('top-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('settings-theme')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('top-back')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('Updated'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Ride conditions'), findsOneWidget);
    expect(find.text('Demo data'), findsNothing);
    expect(find.text('Current weather'), findsOneWidget);
    expect(find.text('Partly cloudy'), findsOneWidget);
    expect(find.text('30°C'), findsOneWidget);
    expect(find.text('Feels like 34°C'), findsOneWidget);
    expect(find.text('Next hour · Scattered thunderstorms'), findsOneWidget);
    expect(find.text('29°C · 65% rain'), findsOneWidget);
    expect(find.text('78%'), findsOneWidget);
    expect(find.text('Humidity'), findsOneWidget);
    expect(find.text('42 Good'), findsOneWidget);
    expect(find.text('Air quality'), findsOneWidget);
    expect(find.text('9 km/h SW'), findsOneWidget);
    expect(find.text('Wind'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Humidity')).dy,
      lessThan(
        tester.getTopLeft(find.text('Next hour · Scattered thunderstorms')).dy,
      ),
    );
    expect(
      find.text('Jalan Sultan Ismail, Bukit Bintang, Kuala Lumpur'),
      findsOneWidget,
    );
    expect(find.textContaining('Updated'), findsOneWidget);
    expect(find.textContaining('Planned source:'), findsNothing);
    expect(find.textContaining('Delay your ride'), findsNothing);
    expect(
      Theme.of(tester.element(find.text('Ride conditions'))).brightness,
      Brightness.dark,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'admin page opens from the header and navigates to module pages',
    (WidgetTester tester) async {
      await tester.pumpWidget(const BikeRentingApp());

      expect(find.text('Admin quick actions'), findsNothing);
      await tester.tap(find.byKey(const ValueKey<String>('top-admin')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('admin-page')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('admin-stations')));
      await tester.pumpAndSettle();

      expect(find.text('Stations'), findsWidgets);
      expect(
        find.text('Dock capacity, nearby stations, and return points.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('top bar follows all five navigation destinations', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BikeRentingApp());

    const destinations = [
      ('home', 'Home', Icons.home_rounded),
      ('stations', 'Stations', Icons.map_rounded),
      ('scan', 'Bike Session', Icons.qr_code_scanner_rounded),
      ('history', 'History', Icons.history_rounded),
      ('profile', 'Profile', Icons.person_rounded),
    ];

    for (final (nav, title, icon) in destinations) {
      await tester.tap(find.byKey(ValueKey<String>('nav-$nav')));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey<String>('top-page-title')))
            .data,
        title,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('top-page-icon')),
          matching: find.byIcon(icon),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey<String>('top-back')), findsNothing);
    }
  });

  testWidgets('bottom navigation keeps full labels and floating scan button', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BikeRentingApp());

    for (final label in ['Home', 'History', 'Stations', 'Profile']) {
      final navLabel = find.descendant(
        of: find.byKey(ValueKey<String>('nav-${label.toLowerCase()}')),
        matching: find.text(label),
      );
      expect(navLabel, findsOneWidget);
      final text = tester.widget<Text>(navLabel);
      expect(text.overflow, isNull);
      expect(text.style?.fontSize, 10.5);
    }
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('nav-scan')),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is SizedBox && widget.width == 72 && widget.height == 72,
        ),
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Scan QR code'), findsOneWidget);
    expect(
      tester.getCenter(find.byKey(const ValueKey<String>('nav-stations'))).dx,
      lessThan(
        tester.getCenter(find.byKey(const ValueKey<String>('nav-scan'))).dx,
      ),
    );
    expect(
      tester.getCenter(find.byKey(const ValueKey<String>('nav-history'))).dx,
      greaterThan(
        tester.getCenter(find.byKey(const ValueKey<String>('nav-scan'))).dx,
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('admin bike management stays separate from ride history', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BikeRentingApp());

    await tester.tap(find.byKey(const ValueKey<String>('nav-history')));
    await tester.pumpAndSettle();
    expect(find.text('Ride history'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('top-admin')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('admin-bikes')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('bike-management-page')),
      findsOneWidget,
    );
    expect(find.text('Bike management'), findsWidgets);
    expect(find.text('Ride history'), findsNothing);
  });

  testWidgets('renting journey runs from QR scan to paid receipt', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BikeRentingApp());
    await tester.tap(find.byKey(const ValueKey<String>('nav-scan')));
    await tester.pumpAndSettle();

    await _tapAfterScroll(
      tester,
      find.byKey(const ValueKey<String>('rent-camera-preview')),
    );
    expect(find.text('Bike ready'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('rent-journey')), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('rent-bike-view')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('rent-report-issue-bike-check')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey<String>('rent-bike-view')));
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey<String>('rent-report-issue-bike-check')),
    );
    await tester.pump();
    expect(find.text('Bike ready'), findsOneWidget);
    expect(find.text('Time-based pricing'), findsOneWidget);
    expect(find.text('RM0.50 + (started minutes × RM0.10)'), findsOneWidget);
    expect(find.text('RM1.50'), findsOneWidget);

    await _tapAfterScroll(
      tester,
      find.byKey(const ValueKey('rent-review-hold')),
    );
    expect(find.text('Authorize card hold'), findsOneWidget);

    await _tapAfterScroll(tester, find.byKey(const ValueKey('rent-authorize')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Unlock the bike'), findsOneWidget);

    await _tapAfterScroll(tester, find.byKey(const ValueKey('rent-unlock')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Ride active'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('nav-home')), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('rent-nearest-station')),
      findsOneWidget,
    );
    expect(find.text('Central Station'), findsOneWidget);
    expect(find.text('120 m away'), findsOneWidget);
    expect(find.text('Other nearby stations'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('rent-nearby-station-riverside')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('rent-nearby-station-market')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('rent-nearby-station-university')),
      findsOneWidget,
    );
    expect(find.text('Return Bike'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('rent-report-issue-active')),
      findsOneWidget,
    );
    await _tapAfterScroll(
      tester,
      find.byKey(const ValueKey<String>('rent-report-issue-active')),
    );
    expect(find.text('Ride active'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('nav-home')));
    await tester.pumpAndSettle();
    expect(find.text('Ready to ride?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('nav-scan')));
    await tester.pumpAndSettle();
    expect(find.text('Ride active'), findsOneWidget);

    await _tapAfterScroll(
      tester,
      find.byKey(const ValueKey('rent-find-station')),
    );
    expect(find.text('Choose return station'), findsOneWidget);
    expect(find.text('Selectable'), findsOneWidget);
    expect(find.text('8 docks'), findsOneWidget);

    await _tapAfterScroll(
      tester,
      find.byKey(const ValueKey<String>('rent-station-central')),
    );
    await _tapAfterScroll(
      tester,
      find.byKey(const ValueKey('rent-simulate-arrival')),
    );
    await _tapAfterScroll(
      tester,
      find.byKey(const ValueKey('rent-begin-return')),
    );
    expect(find.text('Secure the bike'), findsOneWidget);

    await _tapAfterScroll(
      tester,
      find.byKey(const ValueKey('rent-confirm-dock')),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Ride complete'), findsOneWidget);

    await _tapAfterScroll(tester, find.byKey(const ValueKey('rent-charge')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Ride paid'), findsOneWidget);
    expect(find.text('Final fare'), findsOneWidget);
    expect(find.text('Hold released'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('nav-home')), findsOneWidget);

    await _tapAfterScroll(tester, find.byKey(const ValueKey('rent-reset')));
    expect(
      find.byKey(const ValueKey<String>('rent-camera-preview')),
      findsOneWidget,
    );
  });

  testWidgets('renting scanner announces recoverable QR errors', (
    WidgetTester tester,
  ) async {
    final controller = RentingDemoController(
      enableClock: false,
      demoDelay: Duration.zero,
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: QrScanPage(controller: controller)),
      ),
    );

    controller.scanBike(invalid: true);
    await tester.pump();

    expect(find.textContaining('not a BikeRent bike'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('not a BikeRent bike')),
      findsOneWidget,
    );
  });

  testWidgets('renting top back and cancel remain available before ride', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BikeRentingApp());
    await tester.tap(find.byKey(const ValueKey<String>('nav-scan')));
    await tester.pumpAndSettle();

    await _tapAfterScroll(
      tester,
      find.byKey(const ValueKey<String>('rent-camera-preview')),
    );
    expect(find.text('Bike ready'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('top-back')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('top-back')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('rent-camera-preview')),
      findsOneWidget,
    );

    await _tapAfterScroll(
      tester,
      find.byKey(const ValueKey<String>('rent-camera-preview')),
    );
    await _tapAfterScroll(
      tester,
      find.byKey(const ValueKey('rent-review-hold')),
    );
    expect(find.text('Authorize card hold'), findsOneWidget);

    await _tapAfterScroll(tester, find.byKey(const ValueKey('rent-cancel')));
    expect(
      find.byKey(const ValueKey<String>('rent-camera-preview')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey<String>('nav-home')), findsOneWidget);
  });

  testWidgets(
    'renting layout supports large text, reduced motion, and tablet',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(reduceMotion: true);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

      await tester.pumpWidget(const BikeRentingApp());
      await tester.tap(find.byKey(const ValueKey<String>('nav-scan')));
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('rent-camera-preview')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(800, 1024);
      tester.platformDispatcher.textScaleFactorTestValue = 1;
      await tester.pumpWidget(const BikeRentingApp());
      await tester.tap(find.byKey(const ValueKey<String>('nav-scan')));
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('rent-camera-preview')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _tapAfterScroll(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

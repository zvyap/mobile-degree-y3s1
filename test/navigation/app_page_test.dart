import 'package:bike_renting_app/navigation/app_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('navigation pages keep stable order and route mapping', () {
    expect(AppPage.navigationPages, [
      AppPage.home,
      AppPage.stations,
      AppPage.scan,
      AppPage.history,
      AppPage.profile,
    ]);

    for (final page in AppPage.values) {
      expect(AppPage.fromRouteName(page.routeName), page);
    }

    expect(AppPage.fromRouteName('/missing'), isNull);
    expect(AppPage.admin.navigationIndex, isNull);
    expect(AppPage.scan.navigationIndex, 2);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_ease/app_router.dart';

void main() {
  group('AppRouter', () {
    test('route path constants are stable', () {
      expect(AppRouter.screen1, '/screen_1');
      expect(AppRouter.screen2, '/screen_2');
      expect(AppRouter.screen3, '/screen_3');
      expect(AppRouter.profile, '/profile_screen');
    });

    test('createRouter registers four named GoRoutes', () {
      final router = AppRouter.createRouter();
      final routes = router.configuration.routes;
      expect(routes.length, 4);

      final names = <String>[];
      for (final r in routes) {
        if (r is GoRoute && r.name != null) {
          names.add(r.name!);
        }
      }
      expect(names, containsAll(['screen_1', 'screen_2', 'screen_3', 'profile']));
    });

    test('initial location is login screen', () {
      final router = AppRouter.createRouter();
      expect(router.routeInformationProvider.value.uri.path, AppRouter.screen1);
    });
  });
}

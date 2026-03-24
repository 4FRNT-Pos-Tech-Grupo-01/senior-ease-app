import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/src/pigeon/mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_ease/app.dart';
import 'package:senior_ease/firebase_options.dart';
import 'package:senior_ease/services/app_settings_controller.dart';
import 'package:senior_ease/services/auth_refresh_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    setupFirebaseCoreMocks();
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') rethrow;
    }
  });

  testWidgets('App loads and shows Senior Ease', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = AppSettingsController();
    await settings.load();
    final authRefresh = AuthRefreshNotifier();
    addTearDown(authRefresh.dispose);

    await tester.pumpWidget(
      SeniorEaseApp(
        settings: settings,
        authRefreshNotifier: authRefresh,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Senior Ease'), findsOneWidget);
  });
}

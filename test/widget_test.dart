import 'package:flutter_test/flutter_test.dart';
import 'package:senior_ease/app.dart';
import 'package:senior_ease/services/app_settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App loads and shows Senior Ease', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final settings = AppSettingsController();
    await settings.load();
    await tester.pumpWidget(SeniorEaseApp(settings: settings));
    await tester.pumpAndSettle();
    expect(find.text('Senior Ease'), findsOneWidget);
  });
}

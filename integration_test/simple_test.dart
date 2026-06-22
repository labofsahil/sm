import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';
import 'package:my_app/src/rust/frb_generated.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await RustLib.init());
  testWidgets('Can load Sendme Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const SendmeApp());
    await tester.pumpAndSettle();
    expect(find.text('SENDME'), findsOneWidget);
    expect(find.text('Share Files'), findsOneWidget);
  });
}

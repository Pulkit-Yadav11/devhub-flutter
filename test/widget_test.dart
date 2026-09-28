import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_app/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DevHubApp(isDark: false));
    expect(find.text('DevHub'), findsWidgets);
  });
}

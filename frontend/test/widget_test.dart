import 'package:flutter_test/flutter_test.dart';
import 'package:jobconnect/main.dart';

void main() {
  testWidgets('JobConnect app shows the splash screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const JobConnectApp());

    // The splash screen is visible right away.
    expect(find.text('JobConnect'), findsOneWidget);

    // Let the splash screen's 2-second timer fire so no timers are left pending.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
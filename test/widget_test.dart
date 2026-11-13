import 'package:flutter_test/flutter_test.dart';
import 'package:eventpulse/main.dart';

void main() {
  testWidgets('Live Review app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LiveReviewApp());

    // Verify that welcome screen title is present.
    expect(find.text('Live Review'), findsOneWidget);
    expect(find.text('Join as Participant'), findsOneWidget);
  });
}

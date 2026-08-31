import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zemen_calendar/main.dart';

void main() {
  testWidgets('Zemen app loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ZemenApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Zemen'), findsOneWidget);
  });
}

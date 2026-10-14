import 'package:flutter_test/flutter_test.dart';
import 'package:uee_project/main.dart';

void main() {
  testWidgets('splash opens login when tapped', (tester) async {
    await tester.pumpWidget(const RootlyApp());
    expect(find.text('Explore Culture. Learn new things...'), findsOneWidget);
    await tester.tap(find.text('Explore Culture. Learn new things...'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back...'), findsOneWidget);
  });
}

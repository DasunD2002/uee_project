import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uee_project/features/home/presentation/home_screen.dart';
import 'package:uee_project/features/notifications/presentation/notifications_screen.dart';

void main() {
  testWidgets('NotificationsScreen displays all sections and notifications',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: NotificationsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Mark all as read'), findsOneWidget);

    // Verify sections
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);

    // Verify notification titles
    expect(
      find.text('Kumari Devi added a photo to the Family Capsule'),
      findsOneWidget,
    );
    expect(
      find.text('System: Weekly Digest is ready'),
      findsOneWidget,
    );
    expect(
      find.text("Saman Kumara left an audio note on Grandson's 18th Birthday"),
      findsOneWidget,
    );
    expect(
      find.text('Vault Update: Security Check Completed'),
      findsOneWidget,
    );

    // Verify timestamps
    expect(find.text('2h ago'), findsOneWidget);
    expect(find.text('5h ago'), findsOneWidget);
    expect(find.text('Yesterday'), findsNWidgets(2));

    // Tap Mark all as read
    await tester.tap(find.text('Mark all as read'));
    await tester.pump();

    expect(find.text('All notifications marked as read'), findsOneWidget);
  });

  testWidgets('HomeScreen notification bell icon navigates to /notifications',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/home',
        routes: {
          '/home': (_) => const HomeScreen(),
          '/notifications': (_) => const NotificationsScreen(),
        },
      ),
    );
    await tester.pumpAndSettle();

    final notificationBell = find.byTooltip('Notifications');
    expect(notificationBell, findsOneWidget);

    await tester.tap(notificationBell);
    await tester.pumpAndSettle();

    expect(find.byType(NotificationsScreen), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
  });
}

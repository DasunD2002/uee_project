import 'package:uee_project/features/Profile/domain/social_store.dart';
import 'package:uee_project/features/notifications/presentation/widgets/notification_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uee_project/features/home/presentation/home_screen.dart';
import 'package:uee_project/features/notifications/presentation/notifications_screen.dart';

void main() {
  setUp(() {
    SocialStore.instance.notifications
      ..clear()
      ..addAll(const [
        NotificationItemData(
          id: '1',
          title: 'Kumari Devi added a photo to the Family Capsule',
          subtitle: 'Test',
          timeAgo: '2h ago',
          isUnread: true,
        ),
        NotificationItemData(
          id: '2',
          title: 'System: Weekly Digest is ready',
          subtitle: 'Test',
          timeAgo: '5h ago',
        ),
        NotificationItemData(
          id: '3',
          title: "Saman Kumara left an audio note on Grandson's 18th Birthday",
          subtitle: 'Test',
          timeAgo: 'Yesterday',
        ),
        NotificationItemData(
          id: '4',
          title: 'Vault Update: Security Check Completed',
          subtitle: 'Test',
          timeAgo: 'Yesterday',
        ),
      ]);
  });
  testWidgets('NotificationsScreen displays all sections and notifications', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: NotificationsScreen()));
    await tester.pumpAndSettle();

    // Verify header
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Mark all as read'), findsOneWidget);

    // Verify sections
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsNWidgets(3));

    // Verify notification titles
    expect(
      find.text('Kumari Devi added a photo to the Family Capsule'),
      findsOneWidget,
    );
    expect(find.text('System: Weekly Digest is ready'), findsOneWidget);
    expect(
      find.text("Saman Kumara left an audio note on Grandson's 18th Birthday"),
      findsOneWidget,
    );
    expect(find.text('Vault Update: Security Check Completed'), findsOneWidget);

    // Verify timestamps
    expect(find.text('2h ago'), findsOneWidget);
    expect(find.text('5h ago'), findsOneWidget);
    expect(find.text('Yesterday'), findsNWidgets(3));

    // Tap Mark all as read
    await tester.tap(find.text('Mark all as read'));
    await tester.pump();

    expect(find.text('All notifications marked as read'), findsOneWidget);
  });

  testWidgets('HomeScreen notification bell icon navigates to /notifications', (
    tester,
  ) async {
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
    await tester.pump(const Duration(seconds: 1));

    final notificationBell = find.byTooltip('Notifications');
    expect(notificationBell, findsOneWidget);

    await tester.tap(notificationBell);
    await tester.pumpAndSettle();

    expect(find.byType(NotificationsScreen), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
  });
}

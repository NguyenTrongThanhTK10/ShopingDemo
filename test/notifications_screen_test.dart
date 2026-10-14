import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/app/theme/design_tokens.dart';
import 'package:shopingdemo/main.dart';
import 'package:shopingdemo/features/notifications/presentation/notifications_screen.dart';
import 'package:shopingdemo/features/notifications/presentation/providers/notification_read_provider.dart';

void main() {
  testWidgets(
    'sample notifications filter, open destination and mark as read',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: NotificationsScreen()),
        ),
      );

      expect(find.text('3 chưa đọc'), findsOneWidget);
      expect(find.text('Melo Studio đang live'), findsOneWidget);
      expect(find.text('Chưa có thông báo nào'), findsNothing);
      await tester.tap(find.text('Đơn hàng'));
      await tester.pumpAndSettle();
      expect(find.text('Theo dõi đơn mua của bạn'), findsOneWidget);
      expect(find.text('Melo Studio đang live'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('notification-orders')));
      await tester.pumpAndSettle();
      expect(find.text('Đơn mua'), findsOneWidget);
      expect(
        container.read(notificationReadProvider).contains('orders'),
        isTrue,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('2 chưa đọc'), findsOneWidget);
      await tester.tap(find.text('Đọc tất cả'));
      await tester.pumpAndSettle();
      expect(find.text('2 chưa đọc'), findsNothing);
      expect(find.text('Đọc tất cả'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('notification tab badge follows unread count', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: LumiMarketApp()));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('notification-tab-badge')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(NavigationBar), matching: find.text('3')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Thông báo'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('notification-tab-badge-selected')),
      findsOneWidget,
    );
    expect(
      tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
      AppColors.profileHeaderLight,
    );
    await tester.tap(find.byTooltip('Mở giỏ hàng'));
    await tester.pumpAndSettle();
    expect(find.text('Giỏ hàng (0)'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mở lịch sử chat'));
    await tester.pumpAndSettle();
    expect(find.text('Lịch sử chat'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đọc tất cả'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('notification-tab-badge-selected')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}

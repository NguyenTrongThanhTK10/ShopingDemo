import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/main.dart';

void main() {
  testWidgets(
    'compact home header keeps search, chat, and cart available while scrolling',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const ProviderScope(child: LumiMarketApp()));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      final cartButton = find.byTooltip('Mở giỏ hàng');
      final chatButton = find.byTooltip('Mở lịch sử chat');
      final searchButton = find.byTooltip('Tìm kiếm sản phẩm');
      final header = find.byKey(const ValueKey('home-search-header'));
      final headerRect = tester.getRect(header);
      final searchRect = tester.getRect(
        find.byKey(const ValueKey('home-search')),
      );
      final cartRect = tester.getRect(cartButton);
      final chatRect = tester.getRect(chatButton);
      expect(headerRect.height, lessThanOrEqualTo(64));
      expect(chatRect.left, greaterThan(searchRect.right));
      expect(cartRect.left, greaterThan(searchRect.right));
      expect(chatRect.overlaps(cartRect), isFalse);
      expect(chatRect.center.dy, closeTo(searchRect.center.dy, 1));
      expect(cartRect.center.dy, closeTo(searchRect.center.dy, 1));
      await tester.drag(
        find.byKey(const ValueKey('home-feed')),
        const Offset(0, -650),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(header), headerRect);
      expect(cartButton.hitTestable(), findsOneWidget);
      expect(chatButton.hitTestable(), findsOneWidget);
      expect(searchButton.hitTestable(), findsOneWidget);
      expect(cartButton, findsOneWidget);
      await tester.tap(chatButton);
      await tester.pumpAndSettle();
      expect(find.text('Lịch sử chat'), findsOneWidget);
      expect(find.text('Chưa có lịch sử chat'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(tester.getRect(header), headerRect);
      await tester.tap(cartButton);
      await tester.pumpAndSettle();

      expect(find.text('Giỏ hàng (0)'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      final shopNowButton = find.widgetWithText(FilledButton, 'Mua sắm ngay');
      expect(shopNowButton.hitTestable(), findsOneWidget);
      await tester.tap(shopNowButton);
      await tester.pumpAndSettle();
      expect(find.text('Khám phá sản phẩm'), findsOneWidget);
      expect(find.text('Giỏ hàng (0)'), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byTooltip('Mở giỏ hàng'), findsOneWidget);
      expect(tester.getRect(header), headerRect);
      await tester.tap(searchButton);
      await tester.pumpAndSettle();
      expect(find.text('Khám phá sản phẩm'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'ca phe');
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(
          const ValueKey('search-suggestion-Cà phê hạt rang mộc 250g'),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(GridView),
          matching: find.text('Cà phê hạt rang mộc 250g'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [320.0, 390.0, 900.0]) {
    testWidgets('bottom bar has five tabs at ${width.toInt()}px', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const ProviderScope(child: LumiMarketApp()));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      final bar = find.byType(NavigationBar);
      expect(bar, findsOneWidget);
      final navigationBar = tester.widget<NavigationBar>(bar);
      expect(navigationBar.destinations, hasLength(5));
      for (final label in [
        'Trang chủ',
        'Danh mục',
        'Live & Video',
        'Thông báo',
        'Tôi',
      ]) {
        expect(
          find.descendant(of: bar, matching: find.text(label)),
          findsOneWidget,
        );
      }
      expect(
        find.descendant(of: bar, matching: find.text('Giỏ hàng')),
        findsNothing,
      );
      expect(
        tester
            .getSize(
              find.descendant(
                of: bar,
                matching: find.byIcon(Icons.live_tv_outlined),
              ),
            )
            .width,
        greaterThanOrEqualTo(28),
      );
      await tester.tap(
        find.descendant(of: bar, matching: find.text('Live & Video')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Phiên live mẫu'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('demo-live-melo-studio')),
        findsOneWidget,
      );
      await tester.tap(find.text('Video').last);
      await tester.pumpAndSettle();
      expect(find.text('Chưa có video mới'), findsOneWidget);
      if (width == 320) {
        final recommendedProduct = find.text('Tai nghe không dây Melo Air');
        await tester.ensureVisible(recommendedProduct);
        await tester.tap(recommendedProduct);
        await tester.pumpAndSettle();
        expect(find.text('Chọn phân loại'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
      await tester.tap(find.descendant(of: bar, matching: find.text('Tôi')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xem tất cả'));
      await tester.pumpAndSettle();
      expect(find.text('Tất cả'), findsOneWidget);
      expect(find.text('Chưa có đơn hàng'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

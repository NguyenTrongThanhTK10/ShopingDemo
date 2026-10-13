import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/main.dart';

void main() {
  testWidgets('home header cart opens a separate cart page', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: LumiMarketApp()));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    final cartButton = find.byTooltip('Mở giỏ hàng');
    expect(cartButton, findsOneWidget);
    await tester.tap(cartButton);
    await tester.pumpAndSettle();

    expect(find.text('Giỏ hàng (0)'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Mở giỏ hàng'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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
        'Đơn mua',
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
      await tester.tap(
        find.descendant(of: bar, matching: find.text('Đơn mua')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tất cả'), findsOneWidget);
      expect(find.text('Chưa có đơn hàng'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

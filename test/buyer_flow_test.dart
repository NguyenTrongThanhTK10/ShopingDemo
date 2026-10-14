import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/main.dart';

void main() {
  testWidgets('home and product detail fit a narrow phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: LumiMarketApp()));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'narrow home layout');

    final firstProduct = find.text('Tai nghe không dây Melo Air');
    await tester.scrollUntilVisible(
      firstProduct,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(firstProduct.first);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'narrow detail layout');
  });

  testWidgets('buyer can browse, add to cart, and place a demo COD order', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: LumiMarketApp()));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'home layout');

    expect(find.text('Được yêu thích'), findsOneWidget);
    final firstProduct = find.text('Tai nghe không dây Melo Air');
    await tester.scrollUntilVisible(
      firstProduct,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(firstProduct.first);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'product detail layout');

    expect(find.text('Chọn phân loại'), findsOneWidget);
    await tester.tap(find.text('Thêm vào giỏ'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-product-selection')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byTooltip('Mở giỏ hàng').hitTestable(), findsOneWidget);
    await tester.tap(find.byTooltip('Mở giỏ hàng'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'cart layout');
    expect(find.text('Giỏ hàng (1)'), findsOneWidget);

    // Let the product-detail confirmation toast clear the checkout action.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Thanh toán'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'checkout layout');
    final codOption = find.text('Thanh toán khi nhận hàng (COD)');
    await tester.scrollUntilVisible(
      codOption,
      260,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(codOption);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, 900));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đặt hàng (COD)'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'checkout validation');
    expect(find.text('Nhập tên người nhận.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Nguyễn Lan');
    await tester.enterText(find.byType(TextFormField).at(1), '0900000000');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      '12 Đường Mẫu, Hà Nội',
    );
    await tester.tap(find.text('Đặt hàng (COD)'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'success layout');

    expect(find.text('Đã tạo đơn hàng mẫu!'), findsOneWidget);
    expect(find.text('Mã đơn DEMO-0001'), findsOneWidget);
    await tester.tap(find.text('Xem đơn hàng'));
    await tester.pumpAndSettle();
    expect(find.text('DEMO-0001'), findsOneWidget);
    expect(find.text('Tất cả'), findsOneWidget);
  });
}

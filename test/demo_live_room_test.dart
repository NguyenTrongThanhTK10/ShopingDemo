import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/features/cart/presentation/providers/cart_provider.dart';
import 'package:shopingdemo/main.dart';

void main() {
  testWidgets('demo live showcases products, comments and cart at 320px', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const LumiMarketApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    final bottomBar = find.byType(NavigationBar);
    await tester.tap(
      find.descendant(of: bottomBar, matching: find.text('Live & Video')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('demo-live-melo-studio')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('demo-live-room')), findsOneWidget);
    expect(find.text('LIVE MẪU'), findsOneWidget);
    expect(find.text('Phiên quảng bá sản phẩm mô phỏng'), findsOneWidget);
    expect(find.text('Tai nghe không dây Melo Air'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('live-next-product')));
    await tester.pumpAndSettle();
    expect(find.text('Bàn phím cơ Mini 68'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('live-comment-field')),
      '  Cho xem bàn phím  ',
    );
    await tester.tap(find.byKey(const ValueKey('live-comment-send')));
    await tester.pumpAndSettle();
    expect(find.text('Bạn: Cho xem bàn phím'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('live-add-to-cart')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-product-selection')));
    await tester.pumpAndSettle();
    expect(container.read(cartProvider).totalQuantity, 1);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('live-products-button')));
    await tester.pumpAndSettle();
    expect(find.text('Sản phẩm trong live mẫu'), findsOneWidget);
    expect(find.text('Tai nghe không dây Melo Air'), findsOneWidget);
    await tester.tap(find.byTooltip('Đóng danh sách'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('live-cart-button')));
    await tester.pumpAndSettle();
    expect(find.text('Giỏ hàng (1)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

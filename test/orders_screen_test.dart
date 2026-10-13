import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/features/cart/domain/cart_line.dart';
import 'package:shopingdemo/features/catalog/domain/product.dart';
import 'package:shopingdemo/features/orders/presentation/orders_screen.dart';
import 'package:shopingdemo/features/orders/presentation/providers/orders_provider.dart';
import 'package:shopingdemo/features/payment/domain/payment_types.dart';

void main() {
  const variant = ProductVariant(
    id: 'sku-a',
    label: 'Màu kem',
    price: 125000,
    stock: 3,
  );
  const product = Product(
    id: 'product-a',
    name: 'Sản phẩm mẫu',
    description: 'Mô tả',
    shopId: 'shop-a',
    shopName: 'Cửa hàng mẫu',
    categoryId: 'home',
    price: 125000,
    rating: 4.8,
    soldCount: 10,
    emoji: '🏠',
    variants: [variant],
  );
  const items = [CartLine(product: product, variant: variant, quantity: 1)];

  testWidgets('status tabs filter orders and react to payment updates', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(ordersProvider.notifier);
    final cod = notifier.placeOrder(
      items: items,
      recipient: 'Lan',
      phone: '0900000000',
      address: 'Hà Nội',
    );
    final online = notifier.placeOrder(
      items: items,
      recipient: 'Minh',
      phone: '0900000001',
      address: 'Hà Nội',
      paymentMethod: PaymentMethod.vnpay,
    );
    final completed = notifier.placeOrder(
      items: items,
      recipient: 'Hoa',
      phone: '0900000002',
      address: 'Hà Nội',
      status: 'Hoàn thành',
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: OrdersScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final tabs = find.byType(TabBar);
    Future<void> selectTab(String label) async {
      final tab = find.descendant(of: tabs, matching: find.text(label));
      await tester.ensureVisible(tab);
      await tester.pumpAndSettle();
      await tester.tap(tab);
      await tester.pumpAndSettle();
    }

    expect(tester.widget<TabBar>(tabs).tabs, hasLength(7));
    expect(find.text(cod.id), findsOneWidget);
    expect(find.text(online.id), findsOneWidget);
    expect(find.text(completed.id), findsOneWidget);

    await selectTab('Chờ thanh toán');
    expect(find.text(online.id), findsOneWidget);
    expect(find.text(cod.id), findsNothing);
    expect(find.text(completed.id), findsNothing);

    notifier.updateOrderPaymentStatus(
      orderId: online.id,
      paymentStatus: PaymentStatus.paid,
      orderStatus: 'Đã thanh toán qua VNPAY',
    );
    await tester.pumpAndSettle();
    expect(find.text('Chưa có đơn chờ thanh toán'), findsOneWidget);

    await selectTab('Chờ xác nhận');
    expect(find.text(online.id), findsOneWidget);
    expect(find.text(cod.id), findsOneWidget);
    expect(find.text(completed.id), findsNothing);

    await selectTab('Hoàn thành');
    expect(find.text(completed.id), findsOneWidget);
    expect(find.text(cod.id), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending payment card fits a narrow phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final order = container.read(ordersProvider.notifier).placeOrder(
      items: items,
      recipient: 'Lan',
      phone: '0900000000',
      address: 'Hà Nội',
      paymentMethod: PaymentMethod.vietQr,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: OrdersScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(order.id));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

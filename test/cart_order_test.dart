import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopingdemo/core/utils/money_formatter.dart';
import 'package:shopingdemo/features/cart/presentation/providers/cart_provider.dart';
import 'package:shopingdemo/features/catalog/domain/product.dart';
import 'package:shopingdemo/features/orders/presentation/providers/orders_provider.dart';

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

  test('cart caps quantity at stock and totals selected whole-dong prices', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(cartProvider.notifier);

    notifier.add(product, variant, quantity: 2);
    notifier.add(product, variant, quantity: 2);
    expect(container.read(cartProvider).items.single.quantity, 3);
    expect(container.read(cartProvider).selectedSubtotal, 375000);

    notifier.toggleSelected(variant.id, false);
    expect(container.read(cartProvider).selectedSubtotal, 0);
    notifier.toggleSelected(variant.id, true);
    notifier.updateQuantity(variant.id, 1);
    expect(container.read(cartProvider).selectedSubtotal, 125000);
  });

  test('demo order keeps a cart snapshot and clearSelected removes purchased lines', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(cartProvider.notifier).add(product, variant, quantity: 2);

    final order = container
        .read(ordersProvider.notifier)
        .placeOrder(
          items: container.read(cartProvider).selectedLines,
          recipient: 'Lan',
          phone: '0900000000',
          address: '12 Đường Mẫu, Hà Nội',
        );
    container.read(cartProvider.notifier).clearSelected();

    expect(order.id, 'DEMO-0001');
    expect(order.total, 250000);
    expect(order.items.single.quantity, 2);
    expect(container.read(cartProvider).isEmpty, isTrue);
    expect(container.read(ordersProvider).single.id, order.id);
  });

  test('Vietnamese currency uses dot thousands separators', () {
    expect(formatVnd(1250000), '1.250.000 ₫');
    expect(formatVnd(0), '0 ₫');
  });
}

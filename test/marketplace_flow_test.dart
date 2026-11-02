import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/app/theme/app_theme.dart';
import 'package:shopingdemo/features/cart/domain/cart_line.dart';
import 'package:shopingdemo/features/cart/presentation/cart_screen.dart';
import 'package:shopingdemo/features/cart/presentation/providers/cart_provider.dart';
import 'package:shopingdemo/features/catalog/data/datasources/mock_catalog_data_source.dart';
import 'package:shopingdemo/features/catalog/domain/filter_products.dart';
import 'package:shopingdemo/features/catalog/presentation/product_list_screen.dart';
import 'package:shopingdemo/features/catalog/presentation/widgets/product_card.dart';
import 'package:shopingdemo/features/checkout/presentation/checkout_screen.dart';
import 'package:shopingdemo/features/orders/presentation/providers/orders_provider.dart';
import 'package:shopingdemo/features/payment/domain/payment_types.dart';
import 'package:shopingdemo/features/payment/presentation/providers/payment_preferences_provider.dart';
import 'package:shopingdemo/features/profile/domain/delivery_details.dart';
import 'package:shopingdemo/features/profile/presentation/providers/delivery_details_provider.dart';

void main() {
  final products = MockCatalogDataSource.products
      .map((p) => p.toEntity())
      .toList();

  Future<void> mount(
    WidgetTester tester,
    ProviderContainer container,
    Widget screen,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: screen),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  }

  testWidgets('shop and global selection control the checkout amount', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final cart = container.read(cartProvider.notifier);
    final first = products.first;
    final other = products.firstWhere((p) => p.shopId != first.shopId);
    cart.add(first, first.variants.first);
    cart.add(other, other.variants.first);
    await mount(tester, container, const CartScreen());
    await tester.tap(find.byKey(const ValueKey('select-all-cart')));
    await tester.pumpAndSettle();
    expect(container.read(cartProvider).selectedSubtotal, 0);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Thanh toán'))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(ValueKey('select-shop-${first.shopId}')));
    await tester.pumpAndSettle();
    expect(
      container.read(cartProvider).selectedLines.single.product.id,
      first.id,
    );
    expect(
      container.read(cartProvider).selectedSubtotal,
      first.variants.first.price,
    );
    await tester.tap(find.text('Thanh toán'));
    await tester.pumpAndSettle();
    expect(find.text('Sản phẩm (1)'), findsOneWidget);
    expect(find.text(other.name), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'buy-now order preserves existing cart quantities and selection',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final product = products.first;
      final variant = product.variants.first;
      final cart = container.read(cartProvider.notifier);
      cart.add(product, variant, quantity: 3);
      cart.toggleSelected(variant.id, false);
      container
          .read(preferredPaymentMethodProvider.notifier)
          .select(PaymentMethod.cod);
      container
          .read(deliveryDetailsProvider.notifier)
          .save(
            const DeliveryDetails(
              recipient: 'Nguyễn Lan',
              phone: '0901234567',
              address: '12 Nguyễn Huệ, TP Hồ Chí Minh',
            ),
          );
      await mount(
        tester,
        container,
        CheckoutScreen(
          buyNowItems: [
            CartLine(product: product, variant: variant, quantity: 2),
          ],
        ),
      );
      await tester.tap(find.text('Đặt hàng (COD)'));
      await tester.pumpAndSettle();
      expect(container.read(ordersProvider).single.items.single.quantity, 2);
      expect(container.read(ordersProvider).single.total, variant.price * 2);
      expect(container.read(cartProvider).items.single.quantity, 3);
      expect(container.read(cartProvider).items.single.selected, isFalse);
      expect(find.text('Đã tạo đơn hàng mẫu!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'checkout consumption retains newly added quantities and unrelated lines',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final cart = container.read(cartProvider.notifier);
      final first = products.first;
      final other = products[1];
      cart.add(first, first.variants.first);
      final snapshot = container.read(cartProvider).selectedLines;
      cart.add(first, first.variants.first, quantity: 2);
      cart.add(other, other.variants.first);
      cart.removePurchased(snapshot);
      expect(container.read(cartProvider).items.first.quantity, 2);
      expect(container.read(cartProvider).items.last.product.id, other.id);
      expect(snapshot.single.quantity, 1);
    },
  );

  test(
    'filters combine variant price, availability and updated review rating',
    () {
      final serum = products.firstWhere((p) => p.id == 'serum');
      expect(
        filterProducts(
          [serum],
          minimumPrice: 250000,
          maximumPrice: 300000,
          inStockOnly: true,
          minimumRating: 4.5,
          ratingOverrides: {serum.id: 4.8},
        ),
        [serum],
      );
      expect(
        filterProducts(
          [serum],
          minimumPrice: 250000,
          maximumPrice: 300000,
          minimumRating: 4.5,
          ratingOverrides: {serum.id: 3.0},
        ),
        isEmpty,
      );
      expect(filterProducts([serum], minimumPrice: 300000), isEmpty);
      final shirt = products.firstWhere((p) => p.id == 'linen-shirt');
      expect(
        filterProducts(
          [serum, shirt],
          minimumPrice: 250000,
          maximumPrice: 300000,
          sortOrder: ProductSort.priceAsc,
        ).map((p) => p.id),
        ['linen-shirt', 'serum'],
      );
    },
  );

  testWidgets('invalid delivery details cannot be submitted after scrolling', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final product = products.first;
    container.read(cartProvider.notifier).add(product, product.variants.first);
    container
        .read(preferredPaymentMethodProvider.notifier)
        .select(PaymentMethod.cod);
    await mount(tester, container, const CheckoutScreen());
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Họ và tên'),
      'L',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Số điện thoại'),
      '123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Địa chỉ nhận hàng'),
      'abc',
    );
    await tester.scrollUntilVisible(
      find.text('Ghi chú cho đơn hàng'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đặt hàng (COD)'));
    await tester.pumpAndSettle();
    expect(container.read(ordersProvider), isEmpty);
    expect(find.text('Nhập tên người nhận.'), findsOneWidget);
    expect(find.text('Nhập số điện thoại Việt Nam hợp lệ.'), findsOneWidget);
    expect(container.read(cartProvider).totalQuantity, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filtered card and detail use the matching variant price', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await mount(
      tester,
      container,
      const ProductListScreen(initialQuery: 'serum'),
    );
    await tester.tap(find.byTooltip('Bộ lọc tìm kiếm'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('filter-min-price')),
      '250000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('filter-max-price')),
      '300000',
    );
    await tester.tap(find.text('Áp dụng'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(ProductCard),
        matching: find.text('269.000 ₫'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byType(ProductCard));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('50 ml · Số lượng: 1'), findsOneWidget);
    expect(find.text('269.000 ₫'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filter sheet validates price range and supports reset', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await mount(tester, container, const ProductListScreen());
    final initialCount = find.byType(ProductCard).evaluate().length;
    await tester.tap(find.byTooltip('Bộ lọc tìm kiếm'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('filter-min-price')),
      '300000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('filter-max-price')),
      '100000',
    );
    await tester.tap(find.text('Áp dụng'));
    await tester.pumpAndSettle();
    expect(find.text('Thấp hơn giá tối thiểu'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('filter-max-price')),
      '500000',
    );
    await tester.tap(find.text('Áp dụng'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductCard).evaluate().length, lessThan(initialCount));
    await tester.tap(find.byTooltip('Bộ lọc tìm kiếm'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thiết lập lại'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Áp dụng'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductCard).evaluate().length, initialCount);
    expect(tester.takeException(), isNull);
  });
}

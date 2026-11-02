import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/app/theme/app_theme.dart';
import 'package:shopingdemo/features/cart/domain/cart_line.dart';
import 'package:shopingdemo/features/cart/presentation/providers/cart_provider.dart';
import 'package:shopingdemo/features/catalog/data/datasources/mock_catalog_data_source.dart';
import 'package:shopingdemo/features/catalog/data/repositories/mock_catalog_repository.dart';
import 'package:shopingdemo/features/catalog/domain/product.dart';
import 'package:shopingdemo/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:shopingdemo/features/checkout/domain/checkout_quote.dart';
import 'package:shopingdemo/features/checkout/presentation/checkout_screen.dart';
import 'package:shopingdemo/features/orders/domain/demo_order.dart';
import 'package:shopingdemo/features/orders/presentation/orders_screen.dart';
import 'package:shopingdemo/features/orders/presentation/providers/orders_provider.dart';
import 'package:shopingdemo/features/payment/domain/payment_types.dart';
import 'package:shopingdemo/features/payment/presentation/providers/payment_preferences_provider.dart';
import 'package:shopingdemo/features/profile/domain/delivery_details.dart';
import 'package:shopingdemo/features/profile/presentation/providers/delivery_details_provider.dart';
import 'package:shopingdemo/features/reviews/presentation/my_reviews_screen.dart';
import 'package:shopingdemo/features/reviews/presentation/providers/review_providers.dart';
import 'package:shopingdemo/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:shopingdemo/features/wishlist/presentation/wishlist_screen.dart';

Future<void> mount(
  WidgetTester tester,
  ProviderContainer container,
  Widget screen, {
  bool dark = false,
}) async {
  await tester.binding.setSurfaceSize(const Size(320, 720));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: screen,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

Future<void> reveal(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    180,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  final product = MockCatalogDataSource.products.first.toEntity();

  testWidgets('express delivery, voucher and note reach the placed order', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(cartProvider.notifier).add(product, product.variants.first);
    container
        .read(preferredPaymentMethodProvider.notifier)
        .select(PaymentMethod.cod);
    container
        .read(deliveryDetailsProvider.notifier)
        .save(
          const DeliveryDetails(
            recipient: 'Nguyễn Lan',
            phone: '0900000000',
            address: '12 Nguyễn Huệ, TP HCM',
          ),
        );
    await mount(tester, container, const CheckoutScreen());
    await reveal(tester, find.text('Giao nhanh'));
    await tester.tap(find.text('Giao nhanh'));
    await tester.pumpAndSettle();
    await reveal(tester, find.text('Chọn mã ưu đãi'));
    await tester.tap(find.text('Chọn mã ưu đãi'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'khong-ton-tai');
    await tester.tap(find.byTooltip('Áp dụng mã'));
    await tester.pumpAndSettle();
    expect(find.text('Mã ưu đãi không tồn tại.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), ' lumi10 ');
    await tester.tap(find.byTooltip('Áp dụng mã'));
    await tester.pumpAndSettle();
    final note = find.widgetWithText(TextFormField, 'Ghi chú cho đơn hàng');
    await reveal(tester, note);
    await tester.enterText(note, 'Gọi trước khi giao');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('389.100 ₫'), findsNWidgets(2));
    await tester.tap(find.text('Đặt hàng (COD)'));
    await tester.pumpAndSettle();
    final order = container.read(ordersProvider).single;
    expect(order.delivery, DeliveryOption.express);
    expect(order.total, 389100);
    expect(order.discount, 39900);
    expect(order.note, 'Gọi trước khi giao');
    expect(container.read(cartProvider).isEmpty, isTrue);
    expect(find.text('Đã tạo đơn hàng mẫu!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    testWidgets(
      'favorites stay synchronized after leaving detail, dark=$dark',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        container.read(wishlistProvider.notifier).toggle(product.id);
        await mount(tester, container, const WishlistScreen(), dark: dark);
        await tester.tap(find.text(product.name));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Bỏ yêu thích'));
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text('Lưu lại những món bạn thích'), findsOneWidget);
        expect(container.read(wishlistProvider), isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'buyer searches, cancels with a reason and reorders at current stock',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final order = container
          .read(ordersProvider.notifier)
          .placeOrder(
            items: [
              CartLine(
                product: product,
                variant: product.variants.first,
                quantity: 2,
              ),
            ],
            recipient: 'Lan',
            phone: '0900000000',
            address: 'Hà Nội',
          );
      await mount(tester, container, const OrdersScreen());
      await tester.tap(find.byTooltip('Tìm đơn hàng'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'khong-khop');
      await tester.pumpAndSettle();
      expect(find.text('Không tìm thấy đơn phù hợp'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'tai nghe');
      await tester.pumpAndSettle();
      expect(find.text(order.id), findsOneWidget);
      await tester.tap(find.byTooltip('Đóng tìm kiếm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(order.id));
      await tester.pumpAndSettle();
      await reveal(tester, find.text('Hủy đơn'));
      await tester.tap(find.text('Hủy đơn'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Xác nhận hủy đơn'),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Không còn nhu cầu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xác nhận hủy đơn'));
      await tester.pumpAndSettle();
      expect(container.read(ordersProvider).single.stage, OrderStage.canceled);
      await reveal(tester, find.text('Mua lại'));
      await tester.tap(find.text('Mua lại'));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      expect(container.read(cartProvider).totalQuantity, 2);
      expect(find.text('Giỏ hàng (2)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('review dashboard moves purchased items to submitted reviews', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(ordersProvider.notifier);
    final order = notifier.placeOrder(
      items: [
        CartLine(
          product: product,
          variant: product.variants.first,
          quantity: 1,
        ),
      ],
      recipient: 'Lan',
      phone: '0900000000',
      address: 'Hà Nội',
    );
    notifier.completeDemoOrder(order.id);
    await mount(tester, container, const MyReviewsScreen());
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('Viết đánh giá'), findsOneWidget);
    await tester.runAsync(
      () => container
          .read(reviewSubmissionProvider.notifier)
          .submit(
            orderId: order.id,
            variantId: product.variants.first.id,
            rating: 5,
            comment: 'Sản phẩm tốt, giao hàng cẩn thận và đúng mô tả.',
          ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có sản phẩm chờ đánh giá'), findsOneWidget);
    await tester.tap(find.text('Đã đánh giá'));
    await tester.pumpAndSettle();
    expect(
      find.text('Sản phẩm tốt, giao hàng cẩn thận và đúng mô tả.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final stock in [0, 2]) {
    testWidgets('reorder rechecks changed price and stock=$stock', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          catalogRepositoryProvider.overrideWithValue(_ChangedCatalog(stock)),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(ordersProvider.notifier);
      final order = notifier.placeOrder(
        items: [
          CartLine(
            product: product,
            variant: product.variants.first,
            quantity: 3,
          ),
        ],
        recipient: 'Lan',
        phone: '0900000000',
        address: 'Hà Nội',
      );
      notifier.completeDemoOrder(order.id);
      if (stock > 0) {
        container
            .read(cartProvider.notifier)
            .add(product, product.variants.first);
      }
      await mount(tester, container, const OrdersScreen());
      await tester.tap(find.text(order.id));
      await tester.pumpAndSettle();
      await reveal(tester, find.text('Mua lại'));
      await tester.tap(find.text('Mua lại'));
      await tester.pumpAndSettle();
      final cart = container.read(cartProvider);
      if (stock == 0) {
        expect(cart.isEmpty, isTrue);
        expect(
          find.text(
            'Sản phẩm đã hết hàng hoặc giỏ hàng đã đạt số lượng tối đa.',
          ),
          findsOneWidget,
        );
      } else {
        expect(cart.totalQuantity, 2);
        expect(cart.items.single.variant.price, 459000);
        expect(cart.selectedSubtotal, 918000);
      }
      expect(container.read(ordersProvider).single.total, 1197000);
      expect(tester.takeException(), isNull);
    });
  }
}

class _ChangedCatalog extends MockCatalogRepository {
  _ChangedCatalog(this.stock) : super(MockCatalogDataSource());
  final int stock;

  @override
  Future<Product?> getProductById(String id) async {
    final original = MockCatalogDataSource.products.first.toEntity();
    return Product(
      id: original.id,
      name: original.name,
      description: original.description,
      shopId: original.shopId,
      shopName: original.shopName,
      categoryId: original.categoryId,
      price: 459000,
      rating: original.rating,
      soldCount: original.soldCount,
      emoji: original.emoji,
      imagePaths: original.imagePaths,
      variants: [
        ProductVariant(
          id: original.variants.first.id,
          label: 'Kem sữa',
          price: 459000,
          stock: stock,
        ),
      ],
    );
  }
}

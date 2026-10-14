import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/app/theme/app_theme.dart';
import 'package:shopingdemo/features/cart/presentation/providers/cart_provider.dart';
import 'package:shopingdemo/features/catalog/domain/product.dart';
import 'package:shopingdemo/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:shopingdemo/features/catalog/presentation/product_detail_screen.dart';
import 'package:shopingdemo/features/catalog/presentation/widgets/quantity_stepper.dart';

Future<void> pumpProduct(
  WidgetTester tester,
  String productId,
  Size size,
) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: ProductDetailScreen(productId: productId),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

Future<void> openSelection(WidgetTester tester) async {
  final row = find.byKey(const ValueKey('open-product-selection'));
  await tester.ensureVisible(row);
  await tester.pumpAndSettle();
  await tester.tap(row);
  await tester.pumpAndSettle();
}

Future<void> confirmSelection(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('confirm-product-selection')));
  await tester.pumpAndSettle();
}

Finder quantityInput() => find.descendant(
  of: find.byType(QuantityStepper),
  matching: find.byType(TextField),
);

void main() {
  testWidgets('confirmed variant, photos, and quantity stay in sync', (
    tester,
  ) async {
    await pumpProduct(tester, 'earbuds', const Size(320, 720));

    expect(find.text('1/2'), findsOneWidget);
    await tester.tap(find.byTooltip('Xem ảnh 2'));
    await tester.pumpAndSettle();
    expect(find.text('2/2'), findsOneWidget);

    await tester.tap(find.byTooltip('Phóng to ảnh sản phẩm'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Đóng ảnh'), findsOneWidget);
    await tester.tap(find.byTooltip('Đóng ảnh'));
    await tester.pumpAndSettle();

    await openSelection(tester);
    expect(find.text('Đã chọn: Đen nhám'), findsOneWidget);
    await tester.tap(find.text('Kem sữa'));
    await tester.pumpAndSettle();
    await confirmSelection(tester);
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('Kem sữa · Số lượng: 1'), findsOneWidget);

    await openSelection(tester);
    await tester.tap(find.text('Đen nhám'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tăng số lượng'));
    await tester.pumpAndSettle();
    expect(find.text('798.000 ₫'), findsOneWidget);
    await confirmSelection(tester);
    expect(find.text('2/2'), findsOneWidget);
    expect(find.text('Đen nhám · Số lượng: 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing a priced variant resets the selected quantity', (
    tester,
  ) async {
    await pumpProduct(tester, 'serum', const Size(390, 844));
    await openSelection(tester);

    await tester.tap(find.byTooltip('Tăng số lượng'));
    await tester.pumpAndSettle();
    expect(find.text('378.000 ₫'), findsOneWidget);

    await tester.tap(find.text('50 ml'));
    await tester.pumpAndSettle();
    expect(find.text('Đã chọn: 50 ml'), findsOneWidget);
    expect(tester.widget<TextField>(quantityInput()).controller!.text, '1');
    expect(find.text('378.000 ₫'), findsNothing);
    expect(find.text('Kho: 18'), findsOneWidget);
    await confirmSelection(tester);
    expect(find.text('50 ml · Số lượng: 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('buy now confirms quantity before selecting the cart line', (
    tester,
  ) async {
    await pumpProduct(tester, 'serum', const Size(320, 720));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProductDetailScreen)),
    );
    final product = (await container.read(
      productByIdProvider('serum').future,
    ))!;
    final largeVariant = product.variants.firstWhere(
      (variant) => variant.id == 'serum-50',
    );
    final cart = container.read(cartProvider.notifier);
    cart.add(product, largeVariant);
    cart.toggleSelected(largeVariant.id, false);

    await tester.tap(find.text('Mua ngay'));
    await tester.pumpAndSettle();
    expect(container.read(cartProvider).items.single.quantity, 1);
    expect(container.read(cartProvider).items.single.selected, isFalse);
    await tester.tap(find.text('50 ml'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tăng số lượng'));
    await tester.pumpAndSettle();
    expect(find.text('538.000 ₫'), findsOneWidget);

    await confirmSelection(tester);
    expect(find.text('Giỏ hàng (3)'), findsOneWidget);
    expect(find.text('50 ml'), findsOneWidget);
    expect(find.text('Đã chọn 1'), findsOneWidget);
    expect(find.text('807.000 ₫'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(container.read(cartProvider).items.single.selected, isTrue);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Mua ngay'), findsOneWidget);
    expect(find.text('50 ml · Số lượng: 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'quantity input respects stock and dismissed choices do not change the cart',
    (tester) async {
      await pumpProduct(tester, 'earbuds', const Size(320, 720));
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ProductDetailScreen)),
      );
      await tester.tap(find.text('Thêm vào giỏ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đen nhám'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Tăng số lượng'));
      await tester.pumpAndSettle();
      expect(container.read(cartProvider).isEmpty, isTrue);
      await tester.tap(find.byTooltip('Đóng lựa chọn'));
      await tester.pumpAndSettle();
      expect(find.text('Kem sữa · Số lượng: 1'), findsOneWidget);
      expect(container.read(cartProvider).isEmpty, isTrue);

      await tester.tap(find.text('Thêm vào giỏ'));
      await tester.pumpAndSettle();
      await tester.enterText(quantityInput(), '999');
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(quantityInput()).controller!.text, '28');
      await tester.tap(find.byTooltip('Tăng số lượng'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(quantityInput()).controller!.text, '28');
      await tester.enterText(quantityInput(), '0');
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(quantityInput()).controller!.text, '1');
      await tester.enterText(quantityInput(), '3');
      await tester.pumpAndSettle();

      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'selection sheet with keyboard',
      );
      tester.view.resetViewInsets();
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await confirmSelection(tester);
      expect(container.read(cartProvider).items.single.quantity, 3);
      expect(
        container.read(cartProvider).items.single.variant.id,
        'earbuds-cream',
      );
      expect(find.text('Đã thêm 3 sản phẩm vào giỏ hàng'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('out of stock products cannot be confirmed', (tester) async {
    const product = Product(
      id: 'sold-out',
      name: 'Sản phẩm hết hàng',
      description: 'Mô tả',
      shopId: 'shop',
      shopName: 'Shop mẫu',
      categoryId: 'tech',
      price: 100000,
      rating: 4.8,
      soldCount: 10,
      emoji: '🎧',
      variants: [
        ProductVariant(
          id: 'empty',
          label: 'Màu trắng',
          price: 100000,
          stock: 0,
        ),
      ],
    );
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productByIdProvider('sold-out').overrideWith((ref) async => product),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ProductDetailScreen(productId: 'sold-out'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await openSelection(tester);
    final button = tester.widget<FilledButton>(
      find.byKey(const ValueKey('confirm-product-selection')),
    );
    expect(button.onPressed, isNull);
    expect(find.text('Màu trắng · Hết hàng'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

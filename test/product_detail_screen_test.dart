import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/app/theme/app_theme.dart';
import 'package:shopingdemo/features/cart/presentation/providers/cart_provider.dart';
import 'package:shopingdemo/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:shopingdemo/features/catalog/presentation/product_detail_screen.dart';

void main() {
  testWidgets('product photos, variant, and quantity stay in sync', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ProductDetailScreen(productId: 'earbuds'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('1/2'), findsOneWidget);
    await tester.tap(find.byTooltip('Xem ảnh 2'));
    await tester.pumpAndSettle();
    expect(find.text('2/2'), findsOneWidget);
    expect(find.text('Đã chọn: Đen nhám'), findsOneWidget);

    await tester.tap(find.byTooltip('Phóng to ảnh sản phẩm'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Đóng ảnh'), findsOneWidget);
    await tester.tap(find.byTooltip('Đóng ảnh'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Kem sữa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kem sữa'));
    await tester.pumpAndSettle();
    expect(find.text('1/2'), findsOneWidget);

    await tester.ensureVisible(find.text('Đen nhám'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đen nhám'));
    await tester.pumpAndSettle();
    expect(find.text('Đã chọn: Đen nhám'), findsOneWidget);
    expect(find.text('2/2'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Tăng số lượng'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tăng số lượng'));
    await tester.pumpAndSettle();
    expect(find.text('798.000 ₫'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing a priced variant resets the selected quantity', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ProductDetailScreen(productId: 'serum'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byTooltip('Tăng số lượng'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tăng số lượng'));
    await tester.pumpAndSettle();
    expect(find.text('378.000 ₫'), findsOneWidget);

    await tester.ensureVisible(find.text('50 ml'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('50 ml'));
    await tester.pumpAndSettle();
    expect(find.text('Đã chọn: 50 ml'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('378.000 ₫'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('buy now selects the chosen variant and opens the cart', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ProductDetailScreen(productId: 'serum'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

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

    await tester.ensureVisible(find.text('50 ml'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('50 ml'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Tăng số lượng'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tăng số lượng'));
    await tester.pumpAndSettle();
    expect(find.text('538.000 ₫'), findsOneWidget);

    await tester.tap(find.text('Mua ngay'));
    await tester.pumpAndSettle();
    expect(find.text('Giỏ hàng (3)'), findsOneWidget);
    expect(find.text('50 ml'), findsOneWidget);
    expect(find.text('Đã chọn 1'), findsOneWidget);
    expect(find.text('807.000 ₫'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(container.read(cartProvider).items.single.selected, isTrue);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Mua ngay'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/app/theme/app_theme.dart';
import 'package:shopingdemo/features/cart/presentation/cart_screen.dart';
import 'package:shopingdemo/features/cart/presentation/providers/cart_provider.dart';
import 'package:shopingdemo/features/catalog/domain/product.dart';

void main() {
  testWidgets('cart fits narrow phone widths', (tester) async {
    const variant = ProductVariant(
      id: 'variant',
      label: 'Màu kem, cỡ tiêu chuẩn',
      price: 1490000,
      stock: 5,
    );
    const product = Product(
      id: 'product',
      name: 'Tai nghe không dây Melo Air phiên bản đặc biệt',
      description: 'Mô tả',
      shopId: 'shop',
      shopName: 'Lumi Audio Official',
      categoryId: 'audio',
      price: 1490000,
      rating: 4.9,
      soldCount: 120,
      emoji: '🎧',
      variants: [variant],
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(cartProvider.notifier).add(product, variant);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final width in [390.0, 320.0]) {
      await tester.binding.setSurfaceSize(Size(width, 844));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(theme: AppTheme.light, home: const CartScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'cart at $width px');
      expect(find.text('Giỏ hàng (1)'), findsOneWidget);
    }
  });
}

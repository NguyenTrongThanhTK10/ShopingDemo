import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/app/theme/app_theme.dart';
import 'package:shopingdemo/features/cart/presentation/providers/cart_provider.dart';
import 'package:shopingdemo/features/catalog/domain/product.dart';
import 'package:shopingdemo/features/checkout/presentation/checkout_screen.dart';
import 'package:shopingdemo/features/payment/domain/payment_types.dart';

void main() {
  const variant = ProductVariant(
    id: 'sample-variant',
    label: 'Màu kem',
    price: 125000,
    stock: 3,
  );
  const product = Product(
    id: 'sample-product',
    name: 'Sản phẩm mẫu',
    description: 'Mô tả',
    shopId: 'sample-shop',
    shopName: 'Cửa hàng mẫu',
    categoryId: 'home',
    price: 125000,
    rating: 4.8,
    soldCount: 10,
    emoji: '🏠',
    variants: [variant],
  );

  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets('VNPAY note is readable at 320px in ${brightness.name} mode', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(cartProvider.notifier).add(product, variant);
      final theme = brightness == Brightness.light
          ? AppTheme.light
          : AppTheme.dark;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(theme: theme, home: const CheckoutScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final note = find.text(PaymentMethod.vnpay.subtitle);
      await tester.scrollUntilVisible(
        note,
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(note, findsOneWidget);
      expect(
        tester.widget<Text>(note).style?.color,
        theme.colorScheme.onSurface,
      );
      final bounds = tester.getRect(note);
      expect(bounds.left, greaterThanOrEqualTo(0));
      expect(bounds.right, lessThanOrEqualTo(320));
      expect(tester.takeException(), isNull);
    });
  }
}

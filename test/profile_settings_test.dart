// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/app/theme/app_theme.dart';
import 'package:shopingdemo/features/cart/presentation/providers/cart_provider.dart';
import 'package:shopingdemo/features/catalog/domain/product.dart';
import 'package:shopingdemo/features/checkout/presentation/checkout_screen.dart';
import 'package:shopingdemo/features/orders/domain/demo_order.dart';
import 'package:shopingdemo/features/orders/presentation/orders_screen.dart';
import 'package:shopingdemo/features/payment/domain/payment_types.dart';
import 'package:shopingdemo/features/payment/presentation/providers/payment_preferences_provider.dart';
import 'package:shopingdemo/features/profile/presentation/profile_screen.dart';
import 'package:shopingdemo/features/profile/presentation/providers/delivery_details_provider.dart';
import 'package:shopingdemo/features/profile/presentation/providers/demo_account_provider.dart';

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

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('profile header fits 320px in ${theme.brightness.name} mode', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(theme: theme, home: const ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final header = tester.getRect(
        find.byKey(const ValueKey('profile-account-button')),
      );
      final title = tester.getRect(find.text('Chưa đăng nhập'));
      final subtitle = tester.getRect(find.text('Tài khoản khách'));
      final chat = tester.getRect(find.byTooltip('Mở lịch sử chat'));
      final notifications = tester.getRect(find.byTooltip('Mở thông báo'));
      final appBar = tester.widget<AppBar>(find.byType(AppBar).first);
      final expectedHeaderColor = theme.brightness == Brightness.dark
          ? const Color(0xFFC74526)
          : const Color(0xFFF26540);
      expect(appBar.backgroundColor, expectedHeaderColor);
      expect(title.left, greaterThanOrEqualTo(header.left));
      expect(title.right, lessThanOrEqualTo(header.right));
      expect(subtitle.top, greaterThan(title.top));
      expect(subtitle.right, lessThanOrEqualTo(header.right));
      expect(chat.overlaps(notifications), isFalse);
      expect(chat.right, lessThanOrEqualTo(320));
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Mở lịch sử chat'));
      await tester.pumpAndSettle();
      expect(find.text('Lịch sử chat'), findsOneWidget);
    });
  }

  testWidgets('guest registers a demo account and header shows its name', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const ProfileScreen()),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('profile-account-button')));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có tài khoản'), findsOneWidget);
    await tester.tap(find.text('Đăng ký tài khoản mẫu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng ký tài khoản mẫu'));
    await tester.pumpAndSettle();
    expect(find.text('Nhập tên từ 2 ký tự'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tên tài khoản'),
      'Lan Anh',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Số điện thoại'),
      '0900000000',
    );
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Đăng ký tài khoản mẫu'),
    );
    await tester.tap(
      find.widgetWithText(FilledButton, 'Đăng ký tài khoản mẫu'),
    );
    await tester.pumpAndSettle();
    expect(container.read(demoAccountProvider)?.name, 'Lan Anh');
    expect(find.text('Chỉnh sửa thông tin'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Lan Anh'), findsOneWidget);
    expect(find.text('0900000000'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile settings prefill checkout on a narrow phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final paymentTile = find.text('Cài đặt thanh toán');
    await tester.ensureVisible(paymentTile);
    await tester.tap(paymentTile);
    await tester.pumpAndSettle();
    expect(find.text('Phương thức ưu tiên'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('preferred-payment-cod')));
    await tester.pumpAndSettle();
    expect(container.read(preferredPaymentMethodProvider), PaymentMethod.cod);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Ưu tiên: ${PaymentMethod.cod.title}'), findsOneWidget);

    final addressTile = find.text('Địa chỉ nhận hàng');
    await tester.ensureVisible(addressTile);
    await tester.tap(addressTile);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Họ và tên'),
      'Lan',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Số điện thoại'),
      '0900000000',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Địa chỉ nhận hàng'),
      '12 Nguyễn Huệ, Quận 1, TP HCM',
    );
    await tester.ensureVisible(find.text('Lưu địa chỉ'));
    await tester.tap(find.text('Lưu địa chỉ'));
    await tester.pumpAndSettle();
    expect(container.read(deliveryDetailsProvider)?.recipient, 'Lan');
    expect(find.textContaining('Lan · 12 Nguyễn Huệ'), findsOneWidget);

    container.read(cartProvider.notifier).add(product, variant);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const CheckoutScreen()),
      ),
    );
    await tester.pumpAndSettle();
    final fields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();
    expect(fields[0].controller?.text, 'Lan');
    expect(fields[1].controller?.text, '0900000000');
    expect(fields[2].controller?.text, '12 Nguyễn Huệ, Quận 1, TP HCM');
    await tester.scrollUntilVisible(
      find.text(PaymentMethod.cod.title),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    final radios = tester.widgetList<Radio<PaymentMethod>>(
      find.byType(Radio<PaymentMethod>),
    );
    expect(
      radios.firstWhere((radio) => radio.value == PaymentMethod.cod).groupValue,
      PaymentMethod.cod,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('order shortcut opens the matching status tab', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.light, home: const ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('profile-order-awaitingPayment')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(OrdersScreen), findsOneWidget);
    expect(
      DefaultTabController.of(tester.element(find.byType(TabBar))).index,
      OrderStage.values.indexOf(OrderStage.awaitingPayment) + 1,
    );
    expect(find.text('Chưa có đơn chờ thanh toán'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

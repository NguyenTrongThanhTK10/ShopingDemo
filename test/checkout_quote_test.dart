import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/features/cart/domain/cart_line.dart';
import 'package:shopingdemo/features/catalog/domain/product.dart';
import 'package:shopingdemo/features/checkout/domain/checkout_quote.dart';
import 'package:shopingdemo/features/orders/domain/demo_order.dart';
import 'package:shopingdemo/features/orders/presentation/providers/orders_provider.dart';
import 'package:shopingdemo/features/payment/domain/payment_types.dart';

const variant = ProductVariant(
  id: 'sku',
  label: 'Kem',
  price: 125000,
  stock: 10,
);
const product = Product(
  id: 'product',
  name: 'Sản phẩm',
  description: 'Mô tả',
  shopId: 'shop',
  shopName: 'Lumi',
  categoryId: 'home',
  price: 125000,
  rating: 5,
  soldCount: 10,
  emoji: '🏠',
  variants: [variant],
);

void main() {
  test(
    'discount honors threshold, normalization, cap and whole-dong rounding',
    () {
      expect(
        () => CheckoutQuote(subtotal: 199999, voucherCode: 'LUMI10'),
        throwsArgumentError,
      );
      expect(
        () => CheckoutQuote(subtotal: 300000, voucherCode: 'unknown'),
        throwsArgumentError,
      );
      expect(() => CheckoutQuote(subtotal: -1), throwsArgumentError);
      expect(
        CheckoutQuote(subtotal: 200009, voucherCode: ' lumi10 ').discount,
        20000,
      );
      expect(
        CheckoutQuote(subtotal: 1000000, voucherCode: 'LUMI10').discount,
        50000,
      );
      final quote = CheckoutQuote(
        subtotal: 300000,
        voucherCode: 'LUMI30',
        delivery: DeliveryOption.express,
      );
      expect(quote.shippingFee, 30000);
      expect(quote.discount, 30000);
      expect(quote.total, 300000);
      expect(CheckoutQuote(subtotal: 0).total, 0);
    },
  );

  test('order snapshots quote and retains it after status updates', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(ordersProvider.notifier);
    final order = notifier.placeOrder(
      items: [const CartLine(product: product, variant: variant, quantity: 4)],
      recipient: 'Lan',
      phone: '0900000000',
      address: 'Hà Nội',
      delivery: DeliveryOption.express,
      voucherCode: 'lumi10',
      note: ' Gọi trước ',
    );
    expect(order.subtotal, 500000);
    expect(order.discount, 50000);
    expect(order.shippingFee, 30000);
    expect(order.total, 480000);
    expect(order.voucherCode, 'LUMI10');
    expect(order.note, 'Gọi trước');
    notifier.advanceDemoOrder(order.id);
    notifier.advanceDemoOrder(order.id);
    final shipping = container.read(ordersProvider).single;
    expect(shipping.stage, OrderStage.shipping);
    expect(shipping.total, order.total);
    expect(shipping.note, order.note);
    expect(shipping.canCancel, isFalse);
    expect(
      () => notifier.cancelOrder(order.id, reason: 'Đổi ý'),
      throwsStateError,
    );
    notifier.completeDemoOrder(order.id);
    notifier.completeDemoOrder(order.id);
    final completed = container.read(ordersProvider).single;
    expect(completed.stage, OrderStage.completed);
    expect(completed.paymentStatus, PaymentStatus.paid);
    expect(completed.events.map((event) => event.label), [
      'Đã đặt đơn hàng',
      'Chờ lấy hàng',
      'Đang giao',
      'Đã nhận hàng',
    ]);
  });

  test(
    'cancellation requires a reason and prevents delivery and late payment',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(ordersProvider.notifier);
      final order = notifier.placeOrder(
        items: [
          const CartLine(product: product, variant: variant, quantity: 1),
        ],
        recipient: 'Lan',
        phone: '0900000000',
        address: 'Hà Nội',
        paymentMethod: PaymentMethod.vnpay,
      );
      expect(() => notifier.advanceDemoOrder(order.id), throwsStateError);
      expect(
        () => notifier.cancelOrder(order.id, reason: ' '),
        throwsArgumentError,
      );
      notifier.cancelOrder(order.id, reason: 'Không còn nhu cầu');
      final canceled = container.read(ordersProvider).single;
      expect(canceled.stage, OrderStage.canceled);
      expect(canceled.cancellationReason, 'Không còn nhu cầu');
      expect(() => notifier.completeDemoOrder(order.id), throwsStateError);
      expect(
        () => notifier.updateOrderPaymentStatus(
          orderId: order.id,
          paymentStatus: PaymentStatus.paid,
        ),
        throwsStateError,
      );
      expect(
        container.read(ordersProvider).single.paymentStatus,
        PaymentStatus.pending,
      );
    },
  );

  test(
    'failed online payment can retry; paid orders cannot regress or cancel',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(ordersProvider.notifier);
      final order = notifier.placeOrder(
        items: [
          const CartLine(product: product, variant: variant, quantity: 1),
        ],
        recipient: 'Lan',
        phone: '0900000000',
        address: 'Hà Nội',
        paymentMethod: PaymentMethod.vietQr,
      );
      notifier.updateOrderPaymentStatus(
        orderId: order.id,
        paymentStatus: PaymentStatus.failed,
      );
      expect(
        container.read(ordersProvider).single.stage,
        OrderStage.awaitingPayment,
      );
      notifier.updateOrderPaymentStatus(
        orderId: order.id,
        paymentStatus: PaymentStatus.paid,
      );
      notifier.updateOrderPaymentStatus(
        orderId: order.id,
        paymentStatus: PaymentStatus.pending,
      );
      expect(
        container.read(ordersProvider).single.paymentStatus,
        PaymentStatus.paid,
      );
      expect(
        () => notifier.cancelOrder(order.id, reason: 'Đổi ý'),
        throwsStateError,
      );
    },
  );

  test(
    'invalid quantity or voucher does not create an order or consume an ID',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(ordersProvider.notifier);
      expect(
        () => notifier.placeOrder(
          items: [
            const CartLine(product: product, variant: variant, quantity: 11),
          ],
          recipient: 'Lan',
          phone: '0900000000',
          address: 'Hà Nội',
        ),
        throwsArgumentError,
      );
      expect(
        () => notifier.placeOrder(
          items: [
            const CartLine(product: product, variant: variant, quantity: 1),
          ],
          recipient: 'Lan',
          phone: '0900000000',
          address: 'Hà Nội',
          voucherCode: 'LUMI10',
        ),
        throwsArgumentError,
      );
      expect(container.read(ordersProvider), isEmpty);
      final order = notifier.placeOrder(
        items: [
          const CartLine(product: product, variant: variant, quantity: 1),
        ],
        recipient: 'Lan',
        phone: '0900000000',
        address: 'Hà Nội',
      );
      expect(order.id, 'DEMO-0001');
    },
  );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopingdemo/features/cart/domain/cart_line.dart';
import 'package:shopingdemo/features/payment/domain/payment_types.dart';

import '../../domain/demo_order.dart';

final ordersProvider = NotifierProvider<OrdersNotifier, List<DemoOrder>>(
  OrdersNotifier.new,
);

/// Stores example orders only for the current app session.
class OrdersNotifier extends Notifier<List<DemoOrder>> {
  int _nextNumber = 1;

  @override
  List<DemoOrder> build() => const [];

  DemoOrder placeOrder({
    required List<CartLine> items,
    required String recipient,
    required String phone,
    required String address,
    PaymentMethod paymentMethod = PaymentMethod.cod,
    PaymentStatus paymentStatus = PaymentStatus.pending,
    String? status,
  }) {
    if (items.isEmpty) throw StateError('No products selected');
    if (recipient.trim().isEmpty ||
        phone.trim().isEmpty ||
        address.trim().isEmpty) {
      throw ArgumentError('Delivery details are required');
    }
    final snapshot = List<CartLine>.unmodifiable(items);
    final order = DemoOrder(
      id: 'DEMO-${_nextNumber.toString().padLeft(4, '0')}',
      items: snapshot,
      total: snapshot.fold(0, (sum, line) => sum + line.subtotal),
      recipient: recipient.trim(),
      phone: phone.trim(),
      address: address.trim(),
      createdAt: DateTime.now(),
      status:
          status ??
          (paymentMethod == PaymentMethod.cod
              ? 'Chờ xác nhận'
              : 'Chờ thanh toán'),
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
    );
    _nextNumber++;
    state = [order, ...state];
    return order;
  }

  void updateOrderPaymentStatus({
    required String orderId,
    required PaymentStatus paymentStatus,
    String? orderStatus,
  }) {
    state = [
      for (final o in state)
        if (o.id == orderId)
          o.copyWith(
            paymentStatus: paymentStatus,
            status:
                orderStatus ??
                (paymentStatus == PaymentStatus.paid
                    ? 'Đã thanh toán'
                    : o.status),
          )
        else
          o,
    ];
  }
}

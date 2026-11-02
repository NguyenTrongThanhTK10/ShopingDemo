import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopingdemo/features/cart/domain/cart_line.dart';
import 'package:shopingdemo/features/payment/domain/payment_types.dart';

import '../../domain/demo_order.dart';
import '../../../checkout/domain/checkout_quote.dart';

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
    DeliveryOption delivery = DeliveryOption.standard,
    String? voucherCode,
    String note = '',
  }) {
    if (items.isEmpty) throw StateError('No products selected');
    if (recipient.trim().isEmpty ||
        phone.trim().isEmpty ||
        address.trim().isEmpty) {
      throw ArgumentError('Delivery details are required');
    }
    if (items.any(
      (line) => line.quantity < 1 || line.quantity > line.variant.stock,
    )) {
      throw ArgumentError('Số lượng sản phẩm không hợp lệ.');
    }
    if (note.trim().length > 300) throw ArgumentError('Ghi chú quá dài.');
    final snapshot = List<CartLine>.unmodifiable(items);
    final quote = CheckoutQuote(
      subtotal: snapshot.fold(0, (sum, line) => sum + line.subtotal),
      delivery: delivery,
      voucherCode: voucherCode,
    );
    final now = DateTime.now();
    final order = DemoOrder(
      id: 'DEMO-${_nextNumber.toString().padLeft(4, '0')}',
      items: snapshot,
      total: quote.total,
      recipient: recipient.trim(),
      phone: phone.trim(),
      address: address.trim(),
      createdAt: now,
      delivery: delivery,
      shippingFee: quote.shippingFee,
      discount: quote.discount,
      voucherCode: quote.voucher?.code,
      note: note.trim(),
      events: List.unmodifiable([
        OrderEvent(label: 'Đã đặt đơn hàng', at: now),
      ]),
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
    final order = _find(orderId);
    if (order.stage == OrderStage.canceled ||
        order.stage == OrderStage.completed) {
      throw StateError('Không thể thanh toán đơn đã kết thúc.');
    }
    if (order.paymentStatus == PaymentStatus.paid) return;
    state = [
      for (final o in state)
        if (o.id == orderId)
          o.copyWith(
            paymentStatus: paymentStatus,
            events: List.unmodifiable([
              ...o.events,
              OrderEvent(label: paymentStatus.label, at: DateTime.now()),
            ]),
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

  DemoOrder _find(String id) => state.firstWhere(
    (order) => order.id == id,
    orElse: () => throw StateError('Không tìm thấy đơn hàng.'),
  );

  void cancelOrder(String orderId, {required String reason}) {
    final order = _find(orderId);
    if (!order.canCancel) {
      throw StateError('Đơn hàng không thể hủy ở trạng thái này.');
    }
    if (reason.trim().isEmpty) throw ArgumentError('Vui lòng chọn lý do hủy.');
    _replace(
      order.copyWith(
        status: 'Đã hủy',
        cancellationReason: reason.trim(),
        events: List.unmodifiable([
          ...order.events,
          OrderEvent(label: 'Đã hủy đơn hàng', at: DateTime.now()),
        ]),
      ),
    );
  }

  void advanceDemoOrder(String orderId) {
    final order = _find(orderId);
    final next = switch (order.stage) {
      OrderStage.awaitingConfirmation => OrderStage.awaitingPickup,
      OrderStage.awaitingPickup => OrderStage.shipping,
      _ => throw StateError('Đơn hàng chưa thể chuyển bước.'),
    };
    _replace(
      order.copyWith(
        status: next.label,
        events: List.unmodifiable([
          ...order.events,
          OrderEvent(label: next.label, at: DateTime.now()),
        ]),
      ),
    );
  }

  void _replace(DemoOrder order) {
    state = [
      for (final item in state)
        if (item.id == order.id) order else item,
    ];
  }

  /// Simulates delivery for the local demo so completed orders can be reviewed.
  void completeDemoOrder(String orderId) {
    final matching = state.where((order) => order.id == orderId);
    if (matching.isEmpty) throw StateError('Order not found');
    final order = matching.first;
    if (order.stage == OrderStage.completed) return;
    if (order.stage == OrderStage.canceled ||
        (order.paymentMethod != PaymentMethod.cod &&
            order.paymentStatus != PaymentStatus.paid)) {
      throw StateError('Order is not eligible for demo delivery');
    }
    state = [
      for (final item in state)
        if (item.id == orderId)
          item.copyWith(
            status: 'Hoàn thành',
            paymentStatus: PaymentStatus.paid,
            events: List.unmodifiable([
              ...item.events,
              OrderEvent(label: 'Đã nhận hàng', at: DateTime.now()),
            ]),
          )
        else
          item,
    ];
  }
}

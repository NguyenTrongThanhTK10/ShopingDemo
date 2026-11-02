import '../../cart/domain/cart_line.dart';
import '../../payment/domain/payment_types.dart';
import '../../checkout/domain/checkout_quote.dart';

class OrderEvent {
  const OrderEvent({required this.label, required this.at});
  final String label;
  final DateTime at;
}

enum OrderStage {
  awaitingPayment('Chờ thanh toán'),
  awaitingConfirmation('Chờ xác nhận'),
  awaitingPickup('Chờ lấy hàng'),
  shipping('Đang giao'),
  completed('Hoàn thành'),
  canceled('Đã hủy');

  const OrderStage(this.label);

  final String label;
}

class DemoOrder {
  const DemoOrder({
    required this.id,
    required this.items,
    required this.total,
    required this.recipient,
    required this.phone,
    required this.address,
    required this.createdAt,
    required this.status,
    this.paymentMethod = PaymentMethod.cod,
    this.paymentStatus = PaymentStatus.pending,
    this.delivery = DeliveryOption.standard,
    this.shippingFee = 0,
    this.discount = 0,
    this.voucherCode,
    this.note = '',
    this.cancellationReason,
    this.events = const [],
  });

  final String id;
  final List<CartLine> items;
  final int total;
  final String recipient;
  final String phone;
  final String address;
  final DateTime createdAt;
  final String status;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final DeliveryOption delivery;
  final int shippingFee;
  final int discount;
  final String? voucherCode;
  final String note;
  final String? cancellationReason;
  final List<OrderEvent> events;

  int get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  // Paid-order refunds require a backend and are outside this local demo.
  bool get canCancel =>
      paymentStatus != PaymentStatus.paid &&
      (stage == OrderStage.awaitingPayment ||
          stage == OrderStage.awaitingConfirmation);

  /// Payment completion still leaves the order waiting for confirmation.
  OrderStage get stage {
    if (status == 'Đã hủy') return OrderStage.canceled;
    if (status == 'Hoàn thành' || status == 'Đã giao') {
      return OrderStage.completed;
    }
    if (status == 'Đang giao' ||
        status == 'Chờ giao hàng' ||
        status == 'Vận chuyển') {
      return OrderStage.shipping;
    }
    if (status == 'Chờ lấy hàng' || status == 'Đang chuẩn bị hàng') {
      return OrderStage.awaitingPickup;
    }
    if (status == 'Chờ thanh toán' && paymentStatus != PaymentStatus.paid) {
      return OrderStage.awaitingPayment;
    }
    if (status == 'Chờ xác nhận' || paymentStatus == PaymentStatus.paid) {
      return OrderStage.awaitingConfirmation;
    }
    return paymentMethod == PaymentMethod.cod
        ? OrderStage.awaitingConfirmation
        : OrderStage.awaitingPayment;
  }

  DemoOrder copyWith({
    String? id,
    List<CartLine>? items,
    int? total,
    String? recipient,
    String? phone,
    String? address,
    DateTime? createdAt,
    String? status,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    String? cancellationReason,
    List<OrderEvent>? events,
  }) {
    return DemoOrder(
      id: id ?? this.id,
      items: items ?? this.items,
      total: total ?? this.total,
      recipient: recipient ?? this.recipient,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      delivery: delivery,
      shippingFee: shippingFee,
      discount: discount,
      voucherCode: voucherCode,
      note: note,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      events: events ?? this.events,
    );
  }
}

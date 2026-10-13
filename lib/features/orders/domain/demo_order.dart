import '../../cart/domain/cart_line.dart';
import '../../payment/domain/payment_types.dart';

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
    );
  }
}

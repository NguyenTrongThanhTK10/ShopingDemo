/// Illustrative delivery and promotion rules for the local demo.
enum DeliveryOption {
  standard('Tiêu chuẩn', 'Dự kiến 3–5 ngày', 0),
  express('Giao nhanh', 'Dự kiến 1–2 ngày', 30000);

  const DeliveryOption(this.label, this.estimate, this.fee);
  final String label;
  final String estimate;
  final int fee;
}

class DemoVoucher {
  const DemoVoucher({
    required this.code,
    required this.description,
    required this.minimumSpend,
    this.percent = 0,
    this.amount = 0,
    this.maximumDiscount = 50000,
  });

  final String code;
  final String description;
  final int minimumSpend;
  final int percent;
  final int amount;
  final int maximumDiscount;

  static const available = [
    DemoVoucher(
      code: 'LUMI10',
      description: 'Giảm 10%, tối đa 50.000 ₫',
      minimumSpend: 200000,
      percent: 10,
    ),
    DemoVoucher(
      code: 'LUMI30',
      description: 'Giảm 30.000 ₫',
      minimumSpend: 300000,
      amount: 30000,
    ),
  ];

  static DemoVoucher? find(String code) {
    final normalized = code.trim().toUpperCase();
    for (final voucher in available) {
      if (voucher.code == normalized) return voucher;
    }
    return null;
  }

  int discountFor(int subtotal) {
    if (subtotal < minimumSpend) return 0;
    return (amount + subtotal * percent ~/ 100)
        .clamp(0, maximumDiscount)
        .clamp(0, subtotal);
  }
}

class CheckoutQuote {
  CheckoutQuote({
    required this.subtotal,
    this.delivery = DeliveryOption.standard,
    String? voucherCode,
  }) : voucher = voucherCode == null ? null : DemoVoucher.find(voucherCode) {
    if (subtotal < 0) throw ArgumentError('Subtotal must not be negative');
    if (voucherCode != null && voucher == null) {
      throw ArgumentError('Mã ưu đãi không tồn tại.');
    }
    if (voucher != null && subtotal < voucher!.minimumSpend) {
      throw ArgumentError('Đơn hàng chưa đạt giá trị tối thiểu của mã ưu đãi.');
    }
  }

  final int subtotal;
  final DeliveryOption delivery;
  final DemoVoucher? voucher;
  int get shippingFee => delivery.fee;
  int get discount => voucher?.discountFor(subtotal) ?? 0;
  int get total => subtotal + shippingFee - discount;
}

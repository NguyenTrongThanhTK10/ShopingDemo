import 'package:flutter/material.dart';

enum PaymentMethod {
  cod(
    id: 'cod',
    title: 'Thanh toán khi nhận hàng (COD)',
    subtitle: 'Thanh toán tiền mặt cho shipper khi nhận được hàng',
    icon: Icons.payments_outlined,
  ),
  vietQr(
    id: 'vietqr',
    title: 'Chuyển khoản VietQR (Napas 247)',
    subtitle: 'Quét mã QR tự động điền số tiền và nội dung qua app ngân hàng',
    icon: Icons.qr_code_2_rounded,
  ),
  vnpay(
    id: 'vnpay',
    title: 'Cổng thanh toán VNPAY',
    subtitle: 'Thanh toán qua VNPAY-QR, Thẻ ATM nội địa hoặc Visa/Mastercard',
    icon: Icons.account_balance_wallet_outlined,
  );

  const PaymentMethod({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}

enum PaymentStatus {
  pending(label: 'Chờ thanh toán', color: Color(0xFFF59E0B)),
  paid(label: 'Đã thanh toán', color: Color(0xFF10B981)),
  failed(label: 'Thanh toán thất bại', color: Color(0xFFEF4444));

  const PaymentStatus({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;
}


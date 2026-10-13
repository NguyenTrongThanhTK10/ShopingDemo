import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopingdemo/core/utils/money_formatter.dart';
import 'package:shopingdemo/features/orders/domain/demo_order.dart';
import 'package:shopingdemo/features/orders/presentation/order_success_screen.dart';
import 'package:shopingdemo/features/orders/presentation/orders_screen.dart';
import 'package:shopingdemo/features/orders/presentation/providers/orders_provider.dart';

import '../domain/payment_types.dart';
import '../domain/vietqr_config.dart';

class VietQrPaymentScreen extends ConsumerStatefulWidget {
  const VietQrPaymentScreen({
    super.key,
    required this.order,
    this.config = const VietQrConfig(),
  });

  final DemoOrder order;
  final VietQrConfig config;

  @override
  ConsumerState<VietQrPaymentScreen> createState() =>
      _VietQrPaymentScreenState();
}

class _VietQrPaymentScreenState extends ConsumerState<VietQrPaymentScreen> {
  late Timer _timer;
  int _remainingSeconds = 15 * 60; // 15 phút
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label: $text'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmPayment() async {
    setState(() => _isConfirming = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    ref
        .read(ordersProvider.notifier)
        .updateOrderPaymentStatus(
          orderId: widget.order.id,
          paymentStatus: PaymentStatus.paid,
          orderStatus: 'Đã thanh toán',
        );

    final updatedOrder = widget.order.copyWith(
      paymentStatus: PaymentStatus.paid,
      status: 'Đã thanh toán',
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => OrderSuccessScreen(order: updatedOrder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final qrUrl = widget.config.generateQrUrl(
      amount: widget.order.total,
      orderId: widget.order.id,
    );
    final transferNote = widget.config.transferContent(widget.order.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán VietQR'), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // Thanh đếm ngược thời gian
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.primaryContainer),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_outlined, color: colors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Đơn hàng hết hạn sau: ',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatTimer(_remainingSeconds),
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Thẻ hiển thị mã QR
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: colors.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF005BAA)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NAPAS 247',
                            style: TextStyle(
                              color: Color(0xFF005BAA),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFED1C24)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'VIETQR CHUẨN',
                            style: TextStyle(
                              color: Color(0xFFED1C24),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Quét mã QR để chuyển khoản',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Mở app ngân hàng bất kỳ để quét mã',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.onSurface),
                    ),
                    const SizedBox(height: 16),

                    // Ảnh QR tự động tạo qua VietQR API
                    Container(
                      width: 260,
                      height: 260,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          qrUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                        : null,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('Đang tạo mã QR...'),
                                ],
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.qr_code_2_rounded,
                                    size: 90,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Chuyển theo thông tin bên dưới',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      formatVnd(widget.order.total),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Thông tin chuyển khoản chi tiết
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: colors.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin chuyển khoản',
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      label: 'Ngân hàng',
                      value: widget.config.bankName,
                      onCopy: () => _copyToClipboard(
                        widget.config.bankCode,
                        'Mã ngân hàng',
                      ),
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      label: 'Chủ tài khoản',
                      value: widget.config.accountHolder,
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      label: 'Số tài khoản',
                      value: widget.config.accountNumber,
                      isBold: true,
                      onCopy: () => _copyToClipboard(
                        widget.config.accountNumber,
                        'Số tài khoản',
                      ),
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      label: 'Số tiền',
                      value: formatVnd(widget.order.total),
                      isBold: true,
                      valueColor: colors.primary,
                      onCopy: () => _copyToClipboard(
                        widget.order.total.toString(),
                        'Số tiền',
                      ),
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      label: 'Nội dung CK',
                      value: transferNote,
                      isBold: true,
                      valueColor: Colors.deepOrange,
                      onCopy: () => _copyToClipboard(
                        transferNote,
                        'Nội dung chuyển khoản',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lưu ý
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vui lòng điền chính xác nội dung chuyển khoản để hệ thống kiểm tra và xác nhận đơn hàng tự động.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.brown.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nút bấm xác nhận thanh toán
            FilledButton.icon(
              onPressed: _isConfirming ? null : _confirmPayment,
              icon: _isConfirming
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                _isConfirming
                    ? 'Đang kiểm tra giao dịch...'
                    : 'Tôi đã chuyển khoản thành công',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(builder: (_) => const OrdersScreen()),
                );
              },
              child: const Text('Thanh toán sau (Lưu đơn hàng)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
    this.onCopy,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ),
        if (onCopy != null)
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.copy_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}

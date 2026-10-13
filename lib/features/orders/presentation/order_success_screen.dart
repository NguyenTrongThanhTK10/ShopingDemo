import 'package:flutter/material.dart';
import 'package:shopingdemo/core/utils/money_formatter.dart';
import 'package:shopingdemo/features/orders/domain/demo_order.dart';
import 'package:shopingdemo/features/orders/presentation/orders_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final DemoOrder order;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt hàng thành công')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          children: [
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 56,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Đã tạo đơn hàng mẫu!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Mã đơn ${order.id}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Đây là bản demo. Đơn chỉ lưu trong phiên này; không có thanh toán hoặc giao hàng thực tế.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _DetailRow(label: 'Trạng thái', value: order.status),
                  const SizedBox(height: 12),
                  const _DetailRow(label: 'Thanh toán', value: 'COD mô phỏng'),
                  const Divider(height: 28),
                  _DetailRow(
                    label: 'Tổng đơn',
                    value: formatVnd(order.total),
                    emphasized: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const OrdersScreen()),
              ),
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Xem đơn hàng'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Về giỏ hàng'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value,
          style: emphasized
              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                )
              : Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

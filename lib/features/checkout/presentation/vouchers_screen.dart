import 'package:flutter/material.dart';

import '../../../core/utils/money_formatter.dart';
import '../../catalog/presentation/product_list_screen.dart';
import '../domain/checkout_quote.dart';

class VouchersScreen extends StatefulWidget {
  const VouchersScreen({super.key, this.subtotal});

  /// A subtotal enables selection for checkout; otherwise browse the offers.
  final int? subtotal;

  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> {
  final _code = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _apply(String code) {
    final voucher = DemoVoucher.find(code);
    if (voucher == null) {
      setState(() => _error = 'Mã ưu đãi không tồn tại.');
      return;
    }
    if (widget.subtotal! < voucher.minimumSpend) {
      setState(
        () => _error = 'Áp dụng cho đơn từ ${formatVnd(voucher.minimumSpend)}.',
      );
      return;
    }
    Navigator.of(context).pop(voucher.code);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Ưu đãi của bạn')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 32,
                  color: colors.onSecondaryContainer,
                ),
                const SizedBox(height: 16),
                Text(
                  'Mua vui hơn,\ntiết kiệm nhiều hơn.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colors.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ưu đãi trải nghiệm Lumi · Mỗi đơn áp dụng một mã.',
                  style: TextStyle(color: colors.onSecondaryContainer),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (widget.subtotal != null) ...[
            TextField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              onSubmitted: _apply,
              decoration: InputDecoration(
                labelText: 'Nhập mã ưu đãi',
                errorText: _error,
                suffixIcon: IconButton(
                  tooltip: 'Áp dụng mã',
                  onPressed: () => _apply(_code.text),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          for (final voucher in DemoVoucher.available) ...[
            Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number_outlined,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          voucher.code,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      voucher.description,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đơn từ ${formatVnd(voucher.minimumSpend)} · Không gồm phí giao hàng',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: widget.subtotal == null
                            ? () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const ProductListScreen(),
                                ),
                              )
                            : widget.subtotal! >= voucher.minimumSpend
                            ? () => _apply(voucher.code)
                            : null,
                        child: Text(
                          widget.subtotal == null
                              ? 'Mua sắm ngay'
                              : widget.subtotal! >= voucher.minimumSpend
                              ? 'Dùng mã này'
                              : 'Chưa đủ điều kiện',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            'Các mã và điều kiện trên là dữ liệu mẫu trong ứng dụng.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

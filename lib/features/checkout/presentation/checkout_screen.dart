// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopingdemo/core/utils/money_formatter.dart';
import 'package:shopingdemo/features/cart/domain/cart_line.dart';
import 'package:shopingdemo/features/cart/presentation/providers/cart_provider.dart';
import 'package:shopingdemo/features/catalog/presentation/widgets/product_image.dart';
import 'package:shopingdemo/features/orders/presentation/order_success_screen.dart';
import 'package:shopingdemo/features/orders/presentation/providers/orders_provider.dart';
import 'package:shopingdemo/features/payment/domain/payment_types.dart';
import 'package:shopingdemo/features/payment/presentation/providers/payment_preferences_provider.dart';
import 'package:shopingdemo/features/payment/presentation/vietqr_payment_screen.dart';
import 'package:shopingdemo/features/payment/presentation/vnpay_payment_screen.dart';
import 'package:shopingdemo/features/profile/presentation/providers/delivery_details_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  late PaymentMethod _selectedPaymentMethod;
  bool _placingOrder = false;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = ref.read(preferredPaymentMethodProvider);
    final deliveryDetails = ref.read(deliveryDetailsProvider);
    if (deliveryDetails != null) {
      _recipientController.text = deliveryDetails.recipient;
      _phoneController.text = deliveryDetails.phone;
      _addressController.text = deliveryDetails.address;
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _placeOrder() {
    if (_placingOrder || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final selected = ref.read(cartProvider).selectedLines;
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hãy chọn ít nhất một sản phẩm.')),
      );
      return;
    }

    setState(() => _placingOrder = true);
    try {
      final order = ref
          .read(ordersProvider.notifier)
          .placeOrder(
            items: selected,
            recipient: _recipientController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            paymentMethod: _selectedPaymentMethod,
            paymentStatus: _selectedPaymentMethod == PaymentMethod.cod
                ? PaymentStatus.pending
                : PaymentStatus.pending,
          );
      ref.read(cartProvider.notifier).clearSelected();

      if (_selectedPaymentMethod == PaymentMethod.vietQr) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => VietQrPaymentScreen(order: order),
          ),
        );
      } else if (_selectedPaymentMethod == PaymentMethod.vnpay) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => VnpayPaymentScreen(order: order),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => OrderSuccessScreen(order: order),
          ),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tạo đơn mẫu. Vui lòng thử lại.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _placingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final lines = cart.selectedLines;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận đơn hàng')),
      body: lines.isEmpty
          ? _NoSelectedItems(onBack: () => Navigator.of(context).pop())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colors.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Đây là đơn hàng mô phỏng. Không phát sinh giao dịch hoặc giao hàng thực tế.',
                            style: TextStyle(color: colors.onPrimaryContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(
                    icon: Icons.location_on_outlined,
                    title: 'Thông tin nhận hàng',
                  ),
                  const SizedBox(height: 10),
                  _SurfaceCard(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _recipientController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Họ và tên',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => (value?.trim().length ?? 0) < 2
                              ? 'Nhập tên người nhận.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Số điện thoại',
                            prefixIcon: Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final phone = value?.trim() ?? '';
                            return RegExp(r'^(0\d{9}|\+84\d{9})$')
                                    .hasMatch(phone)
                                ? null
                                : 'Nhập số điện thoại Việt Nam hợp lệ.';
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressController,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Địa chỉ nhận hàng',
                            hintText:
                                'Số nhà, đường, phường/xã, tỉnh/thành phố',
                            alignLabelWithHint: true,
                            prefixIcon: Icon(Icons.home_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => (value?.trim().length ?? 0) < 10
                              ? 'Nhập địa chỉ nhận hàng đầy đủ.'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Sản phẩm (${lines.length})',
                  ),
                  const SizedBox(height: 10),
                  _SurfaceCard(
                    child: Column(
                      children: [
                        for (var i = 0; i < lines.length; i++) ...[
                          if (i > 0) const Divider(height: 20),
                          _CheckoutLine(line: lines[i]),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(
                    icon: Icons.payments_outlined,
                    title: 'Phương thức thanh toán',
                  ),
                  const SizedBox(height: 10),
                  _SurfaceCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: PaymentMethod.values.map((method) {
                        final isSelected = _selectedPaymentMethod == method;
                        return InkWell(
                          onTap: () =>
                              setState(() => _selectedPaymentMethod = method),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colors.primaryContainer
                                        : colors.surfaceContainerHighest
                                              .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    method.icon,
                                    color: isSelected
                                        ? colors.primary
                                        : colors.onSurfaceVariant,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            method.title,
                                            style: TextStyle(
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                              fontSize: 13.5,
                                            ),
                                          ),
                                          if (method ==
                                              PaymentMethod.vietQr) ...[
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Khuyên dùng',
                                                style: TextStyle(
                                                  color: Colors.green.shade800,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ] else if (method ==
                                              PaymentMethod.vnpay) ...[
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Cổng VNPAY',
                                                style: TextStyle(
                                                  color: Colors.blue.shade800,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        method.subtitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontSize: 13,
                                              height: 1.4,
                                              color: colors.onSurface,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Radio<PaymentMethod>(
                                  value: method,
                                  groupValue: _selectedPaymentMethod,
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(
                                        () => _selectedPaymentMethod = val,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(
                    icon: Icons.receipt_long_outlined,
                    title: 'Chi tiết thanh toán',
                  ),
                  const SizedBox(height: 10),
                  _SurfaceCard(
                    child: Column(
                      children: [
                        _AmountRow(
                          label: 'Tạm tính',
                          value: formatVnd(cart.selectedSubtotal),
                        ),
                        const SizedBox(height: 10),
                        const _AmountRow(
                          label: 'Phí vận chuyển',
                          value: 'Miễn phí (demo)',
                        ),
                        const Divider(height: 24),
                        _AmountRow(
                          label: 'Tổng cộng',
                          value: formatVnd(cart.selectedSubtotal),
                          prominent: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: lines.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(top: BorderSide(color: colors.outlineVariant)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tổng thanh toán',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            formatVnd(cart.selectedSubtotal),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: _placingOrder ? null : _placeOrder,
                        child: Text(
                          _placingOrder
                              ? 'Đang xử lý...'
                              : _selectedPaymentMethod == PaymentMethod.vietQr
                              ? 'Tiếp tục thanh toán VietQR'
                              : _selectedPaymentMethod == PaymentMethod.vnpay
                              ? 'Thanh toán qua VNPAY'
                              : 'Đặt hàng (COD)',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 21, color: colors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
      ],
    );
  }
}

class _CheckoutLine extends StatelessWidget {
  const _CheckoutLine({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 52,
            height: 52,
            child: ProductImage(
              product: line.product,
              imageIndex: line.variant.imageIndex ?? 0,
              compact: true,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                '${line.variant.label} · x${line.quantity}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 3),
              Text(
                line.product.shopName,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatVnd(line.variant.price * line.quantity),
          style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.prominent = false,
  });

  final String label;
  final String value;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = prominent
        ? Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: colors.primary, fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

class _NoSelectedItems extends StatelessWidget {
  const _NoSelectedItems({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.remove_shopping_cart_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có sản phẩm được chọn',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Quay lại giỏ hàng để chọn sản phẩm.'),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onBack, child: const Text('Về giỏ hàng')),
          ],
        ),
      ),
    );
  }
}

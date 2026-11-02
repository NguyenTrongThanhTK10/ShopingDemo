import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cart/presentation/cart_screen.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../domain/demo_order.dart';
import '../providers/orders_provider.dart';

class OrderActions extends ConsumerStatefulWidget {
  const OrderActions({super.key, required this.order});
  final DemoOrder order;

  @override
  ConsumerState<OrderActions> createState() => _OrderActionsState();
}

class _OrderActionsState extends ConsumerState<OrderActions> {
  bool _reordering = false;

  Future<void> _cancel() async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const _CancelOrderSheet(),
    );
    if (!mounted || reason == null) return;
    try {
      ref
          .read(ordersProvider.notifier)
          .cancelOrder(widget.order.id, reason: reason);
    } on StateError catch (error) {
      _message(error.message);
    }
  }

  Future<void> _reorder() async {
    setState(() => _reordering = true);
    try {
      final repository = ref.read(catalogRepositoryProvider);
      final products = await Future.wait([
        for (final line in widget.order.items)
          repository.getProductById(line.product.id),
      ]);
      if (!mounted) return;
      var added = 0;
      var adjusted = false;
      for (var i = 0; i < widget.order.items.length; i++) {
        final line = widget.order.items[i];
        final product = products[i];
        final variants = product?.variants.where(
          (v) => v.id == line.variant.id && v.stock > 0,
        );
        if (product == null || variants == null || variants.isEmpty) {
          adjusted = true;
          continue;
        }
        final variant = variants.first;
        final cart = ref.read(cartProvider);
        final existing = cart.items.where((item) => item.id == variant.id);
        final alreadyInCart = existing.isEmpty ? 0 : existing.first.quantity;
        final remaining = (variant.stock - alreadyInCart).clamp(
          0,
          variant.stock,
        );
        final quantity = line.quantity.clamp(0, remaining);
        if (quantity != line.quantity || variant.price != line.variant.price) {
          adjusted = true;
        }
        if (quantity == 0) continue;
        ref
            .read(cartProvider.notifier)
            .add(product, variant, quantity: quantity);
        ref.read(cartProvider.notifier).toggleSelected(variant.id, true);
        added += quantity;
      }
      if (added == 0) {
        _message('Sản phẩm đã hết hàng hoặc giỏ hàng đã đạt số lượng tối đa.');
        return;
      }
      _message(
        adjusted
            ? 'Đã cập nhật giỏ theo giá và tồn kho hiện tại. Vui lòng kiểm tra trước khi thanh toán.'
            : 'Đã thêm $added sản phẩm vào giỏ hàng.',
      );
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const CartScreen()));
    } catch (_) {
      if (mounted) _message('Không tải được sản phẩm. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _reordering = false);
    }
  }

  void _message(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        if (order.canCancel)
          OutlinedButton(onPressed: _cancel, child: const Text('Hủy đơn')),
        if (order.stage == OrderStage.awaitingConfirmation ||
            order.stage == OrderStage.awaitingPickup)
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(ordersProvider.notifier).advanceDemoOrder(order.id),
            icon: const Icon(Icons.local_shipping_outlined, size: 18),
            label: Text(
              order.stage == OrderStage.awaitingConfirmation
                  ? 'Mô phỏng chuẩn bị hàng'
                  : 'Mô phỏng giao hàng',
            ),
          ),
        if (order.stage == OrderStage.completed ||
            order.stage == OrderStage.canceled)
          FilledButton.icon(
            onPressed: _reordering ? null : _reorder,
            icon: const Icon(Icons.shopping_bag_outlined, size: 18),
            label: Text(_reordering ? 'Đang kiểm tra...' : 'Mua lại'),
          ),
      ],
    );
  }
}

class _CancelOrderSheet extends StatefulWidget {
  const _CancelOrderSheet();
  @override
  State<_CancelOrderSheet> createState() => _CancelOrderSheetState();
}

class _CancelOrderSheetState extends State<_CancelOrderSheet> {
  static const _reasons = [
    'Muốn thay đổi sản phẩm',
    'Muốn đổi địa chỉ nhận hàng',
    'Tìm được giá tốt hơn',
    'Không còn nhu cầu',
  ];
  String? _reason;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Lý do hủy đơn', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Chọn lý do để xác nhận hủy đơn hàng này.'),
          const SizedBox(height: 12),
          for (final reason in _reasons)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                _reason == reason
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(reason),
              onTap: () => setState(() => _reason = reason),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _reason == null
                ? null
                : () => Navigator.of(context).pop(_reason),
            child: const Text('Xác nhận hủy đơn'),
          ),
        ],
      ),
    ),
  );
}

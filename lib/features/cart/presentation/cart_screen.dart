import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopingdemo/core/utils/money_formatter.dart';
import 'package:shopingdemo/features/cart/domain/cart_line.dart';
import 'package:shopingdemo/features/cart/presentation/providers/cart_provider.dart';
import 'package:shopingdemo/features/catalog/presentation/product_list_screen.dart';
import 'package:shopingdemo/features/catalog/presentation/widgets/product_image.dart';
import 'package:shopingdemo/features/catalog/presentation/widgets/quantity_stepper.dart';
import 'package:shopingdemo/features/chat/presentation/chat_screen.dart';
import 'package:shopingdemo/features/checkout/presentation/checkout_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Giỏ hàng (${cart.totalQuantity})')),
      body: cart.isEmpty
          ? const _EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      _InfoBanner(colors: colors),
                      const SizedBox(height: 16),
                      for (final shop in _groupByShop(cart.items).entries) ...[
                        _ShopCartCard(
                          shopId: shop.key,
                          shopName: shop.value.first.product.shopName,
                          lines: shop.value,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
                _CartCheckoutBar(
                  selectedCount: cart.selectedCount,
                  subtotal: cart.selectedSubtotal,
                ),
              ],
            ),
    );
  }
}

Map<String, List<CartLine>> _groupByShop(List<CartLine> lines) {
  final grouped = <String, List<CartLine>>{};
  for (final line in lines) {
    grouped.putIfAbsent(line.product.shopId, () => []).add(line);
  }
  return grouped;
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.local_shipping_outlined, color: colors.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Kiểm tra sản phẩm và số lượng trước khi thanh toán.',
              style: TextStyle(color: colors.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopCartCard extends StatelessWidget {
  const _ShopCartCard({
    required this.shopId,
    required this.shopName,
    required this.lines,
  });

  final String shopId;
  final String shopName;
  final List<CartLine> lines;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 20,
                  color: colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    shopName,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Chat với $shopName',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ChatScreen(
                        shopId: shopId,
                        shopName: shopName,
                        product: lines.first.product,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.forum_rounded),
                ),
                Text(
                  '${lines.length} sản phẩm',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          for (var index = 0; index < lines.length; index++) ...[
            if (index > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            _CartLineTile(line: lines[index]),
          ],
        ],
      ),
    );
  }
}

class _CartLineTile extends ConsumerWidget {
  const _CartLineTile({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final notifier = ref.read(cartProvider.notifier);
    final stock = line.variant.stock;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 12, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: line.selected,
            onChanged: (value) =>
                notifier.toggleSelected(line.variant.id, value ?? false),
            semanticLabel: 'Chọn ${line.product.name}',
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 68,
              height: 68,
              child: ProductImage(
                product: line.product,
                imageIndex: line.variant.imageIndex ?? 0,
                compact: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        line.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Xóa ${line.product.name}',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => notifier.remove(line.variant.id),
                      icon: const Icon(Icons.delete_outline, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  line.variant.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  formatVnd(line.variant.price),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                QuantityStepper(
                  quantity: line.quantity,
                  stock: stock,
                  onChanged: (quantity) =>
                      notifier.updateQuantity(line.variant.id, quantity),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartCheckoutBar extends StatelessWidget {
  const _CartCheckoutBar({required this.selectedCount, required this.subtotal});

  final int selectedCount;
  final int subtotal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Đã chọn $selectedCount',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    formatVnd(subtotal),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: selectedCount == 0
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CheckoutScreen(),
                      ),
                    ),
              child: const Text('Thanh toán'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 72, color: colors.primary),
            const SizedBox(height: 16),
            Text(
              'Giỏ hàng đang trống',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Khám phá sản phẩm và thêm món bạn thích vào giỏ hàng.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => const ProductListScreen(),
                ),
              ),
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Mua sắm ngay'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/money_formatter.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import '../domain/product.dart';
import 'providers/catalog_providers.dart';
import 'widgets/product_artwork.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({required this.productId, super.key});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String? _selectedVariantId;
  int _quantity = 1;

  ProductVariant? _selectedVariant(Product product) {
    if (product.variants.isEmpty) return null;
    for (final variant in product.variants) {
      if (variant.id == _selectedVariantId) return variant;
    }
    return product.variants.first;
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(productByIdProvider(widget.productId));
    final colors = Theme.of(context).colorScheme;

    return result.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
        body: _StatusView(
          icon: Icons.cloud_off_rounded,
          title: 'Không tải được sản phẩm',
          message: 'Vui lòng thử lại sau ít phút.',
          onRetry: () => ref.invalidate(productByIdProvider(widget.productId)),
        ),
      ),
      data: (product) {
        if (product == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
            body: const _StatusView(
              icon: Icons.inventory_2_outlined,
              title: 'Không tìm thấy sản phẩm',
              message: 'Sản phẩm này hiện không còn trong danh mục.',
            ),
          );
        }

        final variant = _selectedVariant(product);
        final stock = variant?.stock ?? 0;
        final quantity = stock > 0 ? _quantity.clamp(1, stock) : 1;
        final price = variant?.price ?? product.price;
        final oldPrice = product.oldPrice;
        final showOldPrice =
            oldPrice != null && oldPrice > price && price == product.price;

        return Scaffold(
          backgroundColor: colors.surface,
          appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  AspectRatio(
                    aspectRatio: 1.22,
                    child: ProductArtwork(
                      emoji: product.emoji,
                      label: product.name,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _ProductHeadline(
                    product: product,
                    price: price,
                    oldPrice: showOldPrice ? oldPrice : null,
                  ),
                  const SizedBox(height: 24),
                  _DetailSection(
                    title: 'Chọn phân loại',
                    child: product.variants.isEmpty
                        ? Text(
                            'Sản phẩm chưa có phân loại để đặt mua.',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final item in product.variants)
                                ChoiceChip(
                                  label: Text(item.label),
                                  selected: variant?.id == item.id,
                                  onSelected: item.stock < 1
                                      ? null
                                      : (_) => setState(() {
                                          _selectedVariantId = item.id;
                                          _quantity = 1;
                                        }),
                                  avatar: item.stock < 1
                                      ? const Icon(
                                          Icons.close_rounded,
                                          size: 15,
                                        )
                                      : null,
                                ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 20),
                  _DetailSection(
                    title: 'Số lượng',
                    child: Row(
                      children: [
                        _QuantityButton(
                          icon: Icons.remove_rounded,
                          tooltip: 'Giảm số lượng',
                          onPressed: quantity <= 1 || stock < 1
                              ? null
                              : () => setState(() => _quantity = quantity - 1),
                        ),
                        SizedBox(
                          width: 48,
                          child: Text(
                            '$quantity',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        _QuantityButton(
                          icon: Icons.add_rounded,
                          tooltip: 'Tăng số lượng',
                          onPressed: quantity >= stock || stock < 1
                              ? null
                              : () => setState(() => _quantity = quantity + 1),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            stock < 1 ? 'Hết hàng' : 'Còn $stock sản phẩm',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DetailSection(
                    title: 'Thông tin sản phẩm',
                    child: Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(height: 1.55),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DetailSection(
                    title: 'Gian hàng',
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: colors.secondaryContainer,
                          foregroundColor: colors.secondary,
                          child: const Icon(Icons.storefront_rounded),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            product.shopName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Icon(
                          Icons.verified_rounded,
                          size: 19,
                          color: colors.secondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _ProductBottomBar(
            total: price * quantity,
            outOfStock: stock < 1,
            onAdd: variant == null || stock < 1
                ? null
                : () {
                    ref
                        .read(cartProvider.notifier)
                        .add(product, variant, quantity: quantity);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đã thêm $quantity sản phẩm vào giỏ hàng',
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
          ),
        );
      },
    );
  }
}

class _ProductBottomBar extends StatelessWidget {
  const _ProductBottomBar({
    required this.total,
    required this.outOfStock,
    required this.onAdd,
  });

  final int total;
  final bool outOfStock;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final priceInfo = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tạm tính', style: Theme.of(context).textTheme.bodySmall),
        Text(
          formatVnd(total),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: colors.primary, fontWeight: FontWeight.w600),
        ),
      ],
    );
    final addButton = FilledButton.icon(
      onPressed: onAdd,
      icon: const Icon(Icons.add_shopping_cart_rounded),
      label: Text(outOfStock ? 'Hết hàng' : 'Thêm vào giỏ'),
    );
    final compact = MediaQuery.sizeOf(context).width < 360;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: compact
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [priceInfo, const SizedBox(height: 8), addButton],
                )
              : Row(
                  children: [
                    Expanded(child: priceInfo),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: addButton),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ProductHeadline extends StatelessWidget {
  const _ProductHeadline({
    required this.product,
    required this.price,
    required this.oldPrice,
  });

  final Product product;
  final int price;
  final int? oldPrice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              formatVnd(price),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (oldPrice != null) ...[
              Text(
                formatVnd(oldPrice!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.star_rounded, color: colors.tertiary, size: 19),
            const SizedBox(width: 4),
            Text(
              product.rating.toStringAsFixed(1),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Đã bán ${product.soldCount}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton.outlined(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: Icon(icon),
  );
}

class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 14),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              FilledButton.tonal(
                onPressed: onRetry,
                child: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

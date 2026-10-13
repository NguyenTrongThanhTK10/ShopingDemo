import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/money_formatter.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import '../domain/product.dart';
import 'providers/catalog_providers.dart';
import 'widgets/product_image.dart';

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
  int _currentImageIndex = 0;
  final PageController _imageController = PageController();

  ProductVariant? _selectedVariant(Product product) {
    if (product.variants.isEmpty) return null;
    for (final variant in product.variants) {
      if (variant.id == _selectedVariantId && variant.stock > 0) return variant;
    }
    for (final variant in product.variants) {
      if (variant.stock > 0) return variant;
    }
    return product.variants.first;
  }

  void _selectVariant(Product product, ProductVariant variant) {
    setState(() {
      _selectedVariantId = variant.id;
      _quantity = 1;
    });
    final imageIndex = variant.imageIndex;
    if (imageIndex != null &&
        imageIndex >= 0 &&
        imageIndex < product.imagePaths.length &&
        _imageController.hasClients) {
      _imageController.animateToPage(
        imageIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onImageChanged(Product product, int index) {
    ProductVariant? matchingVariant;
    for (final variant in product.variants) {
      if (variant.imageIndex == index && variant.stock > 0) {
        matchingVariant = variant;
        break;
      }
    }
    setState(() {
      _currentImageIndex = index;
      if (matchingVariant != null && matchingVariant.id != _selectedVariantId) {
        _selectedVariantId = matchingVariant.id;
        _quantity = 1;
      }
    });
  }

  void _showImage(Product product, int imageIndex) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: ProductImage(
                    product: product,
                    imageIndex: imageIndex,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filledTonal(
                  tooltip: 'Đóng ảnh',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: Text(
                  'Chụm để phóng to • ${imageIndex + 1}/${product.imagePaths.isEmpty ? 1 : product.imagePaths.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
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
          appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: _ProductGallery(
                        product: product,
                        controller: _imageController,
                        currentIndex: _currentImageIndex,
                        onPageChanged: (index) =>
                            _onImageChanged(product, index),
                        onOpen: (index) => _showImage(product, index),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Đã chọn: ${variant?.label ?? ''}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 9,
                                        runSpacing: 9,
                                        children: [
                                          for (final item in product.variants)
                                            _VariantOption(
                                              variant: item,
                                              selected: variant?.id == item.id,
                                              showPrice:
                                                  item.price != product.price,
                                              onTap: item.stock < 1
                                                  ? null
                                                  : () => _selectVariant(
                                                      product,
                                                      item,
                                                    ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 14),
                          _DetailSection(
                            title: 'Số lượng',
                            child: _QuantitySelector(
                              quantity: quantity,
                              stock: stock,
                              onDecrease: quantity <= 1 || stock < 1
                                  ? null
                                  : () => setState(
                                      () => _quantity = quantity - 1,
                                    ),
                              onIncrease: quantity >= stock || stock < 1
                                  ? null
                                  : () => setState(
                                      () => _quantity = quantity + 1,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _DetailSection(
                            title: 'Thông tin sản phẩm',
                            child: Text(
                              product.description,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(height: 1.55),
                            ),
                          ),
                          const SizedBox(height: 14),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
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
                  ],
                ),
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
            onBuy: variant == null || stock < 1
                ? null
                : () {
                    final cart = ref.read(cartProvider.notifier);
                    cart.add(product, variant, quantity: quantity);
                    cart.toggleSelected(variant.id, true);
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CartScreen(),
                      ),
                    );
                  },
          ),
        );
      },
    );
  }
}

class _ProductGallery extends StatelessWidget {
  const _ProductGallery({
    required this.product,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
    required this.onOpen,
  });

  final Product product;
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final count = product.imagePaths.isEmpty ? 1 : product.imagePaths.length;
    final selectedIndex = currentIndex.clamp(0, count - 1);

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.08,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: controller,
                  itemCount: count,
                  onPageChanged: onPageChanged,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () => onOpen(index),
                    child: ProductImage(product: product, imageIndex: index),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton.filledTonal(
                    tooltip: 'Phóng to ảnh sản phẩm',
                    onPressed: () => onOpen(selectedIndex),
                    icon: const Icon(Icons.zoom_in_rounded),
                  ),
                ),
                if (product.imagePaths.isNotEmpty)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: .92),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        child: Text(
                          '${selectedIndex + 1}/$count',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (count > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: count,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) => Tooltip(
                message: 'Xem ảnh ${index + 1}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => controller.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                  ),
                  child: Container(
                    width: 68,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedIndex == index
                            ? colors.primary
                            : colors.outlineVariant,
                        width: selectedIndex == index ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ProductImage(
                        product: product,
                        imageIndex: index,
                        compact: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _VariantOption extends StatelessWidget {
  const _VariantOption({
    required this.variant,
    required this.selected,
    required this.showPrice,
    required this.onTap,
  });

  final ProductVariant variant;
  final bool selected;
  final bool showPrice;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: Material(
        color: selected ? colors.primaryContainer : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minWidth: 118, maxWidth: 245),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? colors.primary : colors.outlineVariant,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selected) ...[
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        variant.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: enabled
                              ? (selected
                                    ? colors.onPrimaryContainer
                                    : colors.onSurface)
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  enabled
                      ? (showPrice
                            ? formatVnd(variant.price)
                            : 'Còn ${variant.stock} sản phẩm')
                      : 'Hết hàng',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: selected
                        ? colors.onPrimaryContainer
                        : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.stock,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final int stock;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Giảm số lượng',
                onPressed: onDecrease,
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'Tăng số lượng',
                onPressed: onIncrease,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            stock < 1 ? 'Hết hàng' : 'Còn $stock sản phẩm',
            textAlign: TextAlign.end,
            maxLines: 2,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _ProductBottomBar extends StatelessWidget {
  const _ProductBottomBar({
    required this.total,
    required this.outOfStock,
    required this.onAdd,
    required this.onBuy,
  });

  final int total;
  final bool outOfStock;
  final VoidCallback? onAdd;
  final VoidCallback? onBuy;

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
    final addButton = OutlinedButton(
      onPressed: onAdd,
      child: const Text('Thêm vào giỏ', maxLines: 1),
    );
    final buyButton = FilledButton(
      onPressed: onBuy,
      child: Text(outOfStock ? 'Hết hàng' : 'Mua ngay', maxLines: 1),
    );
    final actionButtons = Row(
      children: [
        Expanded(child: addButton),
        const SizedBox(width: 8),
        Expanded(child: buyButton),
      ],
    );
    final compact = MediaQuery.sizeOf(context).width < 600;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Align(
          alignment: Alignment.center,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: compact
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Tạm tính',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              formatVnd(total),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      actionButtons,
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: priceInfo),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: actionButtons),
                    ],
                  ),
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
    final previousPrice = oldPrice;
    final discount = previousPrice == null
        ? null
        : ((previousPrice - price) * 100 / previousPrice).round();
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
            if (previousPrice != null) ...[
              Text(
                formatVnd(previousPrice),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    '-$discount%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
        color: colors.surface,
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

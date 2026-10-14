import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/money_formatter.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../reviews/presentation/providers/review_providers.dart';
import '../../reviews/presentation/widgets/product_reviews_section.dart';
import '../domain/product.dart';
import 'product_list_screen.dart';
import 'providers/catalog_providers.dart';
import 'widgets/product_image.dart';
import 'widgets/product_selection_sheet.dart';

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
  bool _favorite = false;
  final PageController _imageController = PageController();
  final GlobalKey _shopKey = GlobalKey();
  final GlobalKey _reviewsKey = GlobalKey();

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

  void _openCart() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const CartScreen()));
  }

  Future<void> _openSelection(
    Product product,
    ProductPurchaseAction action,
  ) async {
    final selection = await showProductSelectionSheet(
      context,
      product: product,
      initialVariant: _selectedVariant(product),
      initialQuantity: _quantity,
      action: action,
    );
    if (!mounted || selection == null) return;

    setState(() {
      _selectedVariantId = selection.variant.id;
      _quantity = selection.quantity;
    });
    final imageIndex = selection.variant.imageIndex;
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

    if (action == ProductPurchaseAction.configure) return;
    final cart = ref.read(cartProvider.notifier);
    cart.add(product, selection.variant, quantity: selection.quantity);
    if (action == ProductPurchaseAction.buyNow) {
      cart.toggleSelected(selection.variant.id, true);
      _openCart();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${selection.quantity} sản phẩm vào giỏ hàng'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
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

  void _scrollToSection(GlobalKey key) {
    final sectionContext = key.currentContext;
    if (sectionContext == null) return;
    Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: .15,
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
    final cartCount = ref.watch(cartProvider).totalQuantity;

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
        final price = variant?.price ?? product.price;
        final oldPrice = product.oldPrice;
        final showOldPrice =
            oldPrice != null && oldPrice > price && price == product.price;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chi tiết sản phẩm'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text(cartCount > 99 ? '99+' : '$cartCount'),
                  child: IconButton(
                    tooltip: 'Mở giỏ hàng',
                    onPressed: _openCart,
                    icon: const Icon(Icons.shopping_cart_outlined),
                  ),
                ),
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProductGallery(
                      product: product,
                      controller: _imageController,
                      currentIndex: _currentImageIndex,
                      onPageChanged: (index) => _onImageChanged(product, index),
                      onOpen: (index) => _showImage(product, index),
                    ),
                    _DetailSection(
                      child: _ProductHeadline(
                        product: product,
                        price: price,
                        oldPrice: showOldPrice ? oldPrice : null,
                        favorite: _favorite,
                        onOpenReviews: () => _scrollToSection(_reviewsKey),
                        onToggleFavorite: () =>
                            setState(() => _favorite = !_favorite),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _DetailSection(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            color: colors.secondary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thông tin nhận hàng',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Thêm địa chỉ nhận hàng ở bước thanh toán.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Material(
                      color: colors.surface,
                      child: InkWell(
                        key: const ValueKey('open-product-selection'),
                        onTap: () => _openSelection(
                          product,
                          ProductPurchaseAction.configure,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Chọn phân loại',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      variant == null
                                          ? 'Chưa có phân loại'
                                          : '${variant.label} · Số lượng: $_quantity',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: colors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _DetailSection(
                      key: _shopKey,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: colors.primaryContainer,
                            child: Icon(
                              Icons.storefront_outlined,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.shopName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Gian hàng',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            key: const ValueKey('chat-with-shop'),
                            tooltip: 'Chat với shop',
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ChatScreen(
                                  shopId: product.shopId,
                                  shopName: product.shopName,
                                  product: product,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.forum_rounded),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              minimumSize: const Size(0, 36),
                              foregroundColor: colors.primary,
                              side: BorderSide(color: colors.primary),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ProductListScreen(
                                  title: product.shopName,
                                  initialQuery: product.shopName,
                                ),
                              ),
                            ),
                            child: const Text('Xem shop'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _DetailSection(
                      title: 'Chi tiết sản phẩm',
                      child: Text(
                        product.description,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ProductReviewsSection(key: _reviewsKey, product: product),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: _ProductBottomBar(
            onShop: () => _scrollToSection(_shopKey),
            onAdd: stock < 1
                ? null
                : () =>
                      _openSelection(product, ProductPurchaseAction.addToCart),
            onBuy: stock < 1
                ? null
                : () => _openSelection(product, ProductPurchaseAction.buyNow),
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

    return ColoredBox(
      color: colors.surface,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
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
                    style: IconButton.styleFrom(
                      backgroundColor: colors.surface.withValues(alpha: .9),
                    ),
                    onPressed: () => onOpen(selectedIndex),
                    icon: const Icon(Icons.zoom_in_rounded),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .5),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${selectedIndex + 1}/$count',
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (count > 1)
            SizedBox(
              height: 64,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                scrollDirection: Axis.horizontal,
                itemCount: count,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) => Tooltip(
                  message: 'Xem ảnh ${index + 1}',
                  child: InkWell(
                    onTap: () => controller.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                    ),
                    child: Container(
                      width: 48,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: selectedIndex == index
                              ? colors.primary
                              : colors.outlineVariant,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
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
      ),
    );
  }
}

class _ProductBottomBar extends StatelessWidget {
  const _ProductBottomBar({
    required this.onShop,
    required this.onAdd,
    required this.onBuy,
  });

  final VoidCallback onShop;
  final VoidCallback? onAdd;
  final VoidCallback? onBuy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    final buttonTextStyle = theme.textTheme.labelLarge?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w700,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Align(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 44,
                      child: Tooltip(
                        message: 'Xem thông tin gian hàng',
                        child: Material(
                          color: colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: onShop,
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.storefront_outlined,
                                  size: 20,
                                  color: colors.onSurfaceVariant,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Shop',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: OutlinedButton.icon(
                        onPressed: onAdd,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          backgroundColor: colors.primaryContainer,
                          foregroundColor: colors.onPrimaryContainer,
                          side: BorderSide(
                            color: onAdd == null
                                ? colors.outlineVariant
                                : colors.primary.withValues(alpha: .25),
                          ),
                          shape: buttonShape,
                          textStyle: buttonTextStyle,
                          iconSize: 18,
                        ),
                        icon: const Icon(Icons.add_shopping_cart_rounded),
                        label: const Text(
                          'Thêm vào giỏ',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: onBuy,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          shape: buttonShape,
                          textStyle: buttonTextStyle,
                        ),
                        child: Text(
                          onBuy == null ? 'Hết hàng' : 'Mua ngay',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductHeadline extends ConsumerWidget {
  const _ProductHeadline({
    required this.product,
    required this.price,
    required this.oldPrice,
    required this.favorite,
    required this.onToggleFavorite,
    required this.onOpenReviews,
  });

  final Product product;
  final int price;
  final int? oldPrice;
  final bool favorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onOpenReviews;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final summary = ref.watch(productReviewSummaryProvider(product.id));
    final ratingLabel = summary == null
        ? product.rating.toStringAsFixed(1)
        : summary.count == 0
        ? 'Chưa đánh giá'
        : '${summary.average.toStringAsFixed(1)} (${summary.count})';
    final previousPrice = oldPrice;
    final discount = previousPrice == null
        ? null
        : ((previousPrice - price) * 100 / previousPrice).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              formatVnd(price),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (previousPrice != null) ...[
              Text(
                formatVnd(previousPrice),
                style: theme.textTheme.bodySmall?.copyWith(
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '-$discount%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Text(
          product.name,
          style: theme.textTheme.titleMedium?.copyWith(height: 1.4),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            InkWell(
              onTap: onOpenReviews,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: colors.tertiary, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      ratingLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('|', style: theme.textTheme.bodySmall),
            ),
            Expanded(
              child: Text(
                'Đã bán ${product.soldCount}',
                style: theme.textTheme.bodySmall,
              ),
            ),
            IconButton(
              tooltip: favorite ? 'Bỏ yêu thích' : 'Yêu thích sản phẩm',
              onPressed: onToggleFavorite,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                favorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: favorite ? colors.primary : colors.onSurfaceVariant,
                size: 21,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({super.key, this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
          ],
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
              style: theme.textTheme.titleLarge,
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

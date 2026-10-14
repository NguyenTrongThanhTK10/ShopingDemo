import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/money_formatter.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import '../../catalog/domain/product.dart';
import '../../catalog/presentation/product_detail_screen.dart';
import '../../catalog/presentation/widgets/product_image.dart';
import '../../catalog/presentation/widgets/product_selection_sheet.dart';
import '../domain/demo_live_session.dart';

/// A local product showcase that simulates a live room with catalog photos.
class DemoLiveRoomScreen extends ConsumerStatefulWidget {
  const DemoLiveRoomScreen({
    required this.session,
    required this.products,
    super.key,
  }) : assert(products.length > 0);

  final DemoLiveSession session;
  final List<Product> products;

  @override
  ConsumerState<DemoLiveRoomScreen> createState() => _DemoLiveRoomScreenState();
}

class _DemoLiveRoomScreenState extends ConsumerState<DemoLiveRoomScreen> {
  final _commentController = TextEditingController();
  final _comments = <String>[];
  Timer? _rotationTimer;
  int _productIndex = 0;

  Product get _product => widget.products[_productIndex];

  @override
  void initState() {
    super.initState();
    if (widget.products.length > 1) {
      _rotationTimer = Timer.periodic(const Duration(seconds: 12), (_) {
        if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
          _nextProduct();
        }
      });
    }
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _commentController.dispose();
    super.dispose();
  }

  void _nextProduct() {
    setState(() {
      _productIndex = (_productIndex + 1) % widget.products.length;
    });
  }

  void _sendComment() {
    final message = _commentController.text.trim();
    if (message.isEmpty) return;
    setState(() => _comments.add('Bạn: $message'));
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  void _openProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(productId: product.id),
      ),
    );
  }

  Future<void> _addToCart(Product product) async {
    ProductVariant? availableVariant;
    for (final variant in product.variants) {
      if (variant.stock > 0) {
        availableVariant = variant;
        break;
      }
    }
    if (availableVariant == null) return;
    final selection = await showProductSelectionSheet(
      context,
      product: product,
      initialVariant: availableVariant,
      initialQuantity: 1,
      action: ProductPurchaseAction.addToCart,
    );
    if (!mounted || selection == null) return;
    ref
        .read(cartProvider.notifier)
        .add(product, selection.variant, quantity: selection.quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm ${selection.quantity} sản phẩm vào giỏ'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showProducts() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SizedBox(
        height: (MediaQuery.sizeOf(sheetContext).height * .6).clamp(0, 520),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Sản phẩm trong live mẫu',
                      style: Theme.of(sheetContext).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Đóng danh sách',
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.products.length,
                itemBuilder: (context, index) {
                  final product = widget.products[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: ProductImage(product: product),
                      ),
                    ),
                    title: Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(formatVnd(product.price)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _openProduct(product);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final product = _product;
    final cartCount = ref.watch(cartProvider).totalQuantity;
    final allComments = [...widget.session.talkingPoints, ..._comments];
    final visibleComments = allComments.skip(
      allComments.length > 3 ? allComments.length - 3 : 0,
    );

    return Scaffold(
      key: const ValueKey('demo-live-room'),
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.session.shopName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            const Text(
              'Phiên quảng bá sản phẩm mô phỏng',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey(product.id),
                      tween: Tween(begin: 1, end: 1.08),
                      duration: const Duration(seconds: 4),
                      builder: (context, zoom, child) =>
                          Transform.scale(scale: zoom, child: child),
                      child: ProductImage(product: product),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black26,
                          Colors.transparent,
                          Colors.black87,
                        ],
                        stops: [0, .42, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC3B28),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'LIVE MẪU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 12,
                    child: IconButton(
                      key: const ValueKey('live-next-product'),
                      tooltip: 'Sản phẩm tiếp theo',
                      onPressed: widget.products.length > 1
                          ? _nextProduct
                          : null,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.skip_next_rounded),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.session.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final comment in visibleComments)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                comment,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: colors.surface,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        key: const ValueKey('live-featured-product'),
                        onTap: () => _openProduct(product),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 54,
                                height: 54,
                                child: ProductImage(product: product),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelMedium,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    formatVnd(product.price),
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filledTonal(
                      key: const ValueKey('live-add-to-cart'),
                      tooltip: 'Thêm sản phẩm live vào giỏ',
                      onPressed: () => _addToCart(product),
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                    ),
                  ],
                ),
              ),
            ),
            Material(
              color: colors.surface,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 2, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const ValueKey('live-comment-field'),
                        controller: _commentController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendComment(),
                        decoration: InputDecoration(
                          hintText: 'Bình luận trong live mẫu',
                          isDense: true,
                          suffixIcon: IconButton(
                            key: const ValueKey('live-comment-send'),
                            tooltip: 'Gửi bình luận mẫu',
                            onPressed: _sendComment,
                            icon: const Icon(Icons.send_rounded),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('live-products-button'),
                      tooltip: 'Sản phẩm trong live',
                      onPressed: _showProducts,
                      icon: const Icon(Icons.shopping_bag_outlined),
                    ),
                    IconButton(
                      key: const ValueKey('live-cart-button'),
                      tooltip: 'Mở giỏ hàng',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CartScreen(),
                        ),
                      ),
                      icon: Badge(
                        isLabelVisible: cartCount > 0,
                        label: Text('$cartCount'),
                        child: const Icon(Icons.shopping_cart_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

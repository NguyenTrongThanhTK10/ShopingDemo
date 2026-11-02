import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/design_tokens.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import '../../catalog/domain/category.dart';
import '../../catalog/domain/product.dart';
import '../../catalog/presentation/product_detail_screen.dart';
import '../../catalog/presentation/product_list_screen.dart';
import '../../catalog/presentation/providers/catalog_providers.dart';
import '../../catalog/presentation/widgets/category_icon.dart';
import '../../catalog/presentation/widgets/product_card.dart';
import '../../chat/presentation/chat_inbox_screen.dart';
import '../../voice_search/presentation/widgets/voice_search_button.dart';
import '../../checkout/presentation/vouchers_screen.dart';
import '../../orders/presentation/orders_screen.dart';
import '../../wishlist/presentation/wishlist_screen.dart';
import '../../profile/presentation/providers/delivery_details_provider.dart';
import '../../profile/presentation/delivery_details_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.onOpenCart});

  final VoidCallback onOpenCart;

  void _openListing(
    BuildContext context, {
    String? title,
    String? categoryId,
    bool search = false,
    String initialQuery = '',
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductListScreen(
          title: title,
          categoryId: categoryId,
          autofocusSearch: search,
          initialQuery: initialQuery,
        ),
      ),
    );
  }

  void _openProduct(BuildContext context, Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(productId: product.id),
      ),
    );
  }

  void _openChatInbox(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const ChatInboxScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider);
    final products = ref.watch(productsProvider);
    final cartCount = ref.watch(cartProvider).totalQuantity;

    return SafeArea(
      child: ColoredBox(
        color: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            _HomeSearchHeader(
              cartCount: cartCount,
              onSearch: () => _openListing(context, search: true),
              onOpenChat: () => _openChatInbox(context),
              onOpenCart: onOpenCart,
              onVoiceSearch: (query) =>
                  _openListing(context, initialQuery: query),
            ),
            Expanded(
              child: ListView(
                key: const ValueKey('home-feed'),
                padding: const EdgeInsets.only(bottom: 28),
                children: [
                  Material(
                    color: theme.colorScheme.surface,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const DeliveryDetailsScreen(),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                ref.watch(deliveryDetailsProvider)?.address ??
                                    'Chọn địa chỉ nhận hàng',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _HeroBanner(
                      onTap: () =>
                          _openListing(context, title: 'Khám phá hôm nay'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _QuickAction(
                          icon: Icons.confirmation_number_outlined,
                          label: 'Ưu đãi',
                          color: const Color(0xFFFFEEE8),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const VouchersScreen(),
                            ),
                          ),
                        ),
                        _QuickAction(
                          icon: Icons.receipt_long_outlined,
                          label: 'Đơn mua',
                          color: const Color(0xFFFFF3DD),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const OrdersScreen(),
                            ),
                          ),
                        ),
                        _QuickAction(
                          icon: Icons.favorite_border_rounded,
                          label: 'Yêu thích',
                          color: const Color(0xFFE9F5F1),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const WishlistScreen(),
                            ),
                          ),
                        ),
                        _QuickAction(
                          icon: Icons.grid_view_rounded,
                          label: 'Danh mục',
                          color: const Color(0xFFEDF0FF),
                          onTap: () => _openListing(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SectionHeading(
                    title: 'Danh mục nổi bật',
                    action: 'Xem tất cả',
                    onAction: () => _openListing(context),
                  ),
                  const SizedBox(height: 12),
                  categories.when(
                    data: (items) => items.isEmpty
                        ? const _InlineMessage(message: 'Chưa có danh mục nào.')
                        : SizedBox(
                            height: 86,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount: items.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) =>
                                  _CategoryShortcut(
                                    category: items[index],
                                    onTap: () => _openListing(
                                      context,
                                      title: items[index].name,
                                      categoryId: items[index].id,
                                    ),
                                  ),
                            ),
                          ),
                    loading: () => const _LoadingStrip(),
                    error: (_, _) => _InlineMessage(
                      message: 'Không tải được danh mục.',
                      onRetry: () => ref.invalidate(categoriesProvider),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SectionHeading(
                    title: 'Được yêu thích',
                    subtitle: 'Khám phá những lựa chọn nổi bật',
                    action: 'Xem thêm',
                    onAction: () =>
                        _openListing(context, title: 'Được yêu thích'),
                  ),
                  const SizedBox(height: 12),
                  products.when(
                    data: (items) => items.isEmpty
                        ? const _InlineMessage(
                            message: 'Sản phẩm sẽ sớm xuất hiện.',
                          )
                        : SizedBox(
                            key: const ValueKey('home-featured-products'),
                            height: 258,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount: items.length > 6 ? 6 : items.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) => SizedBox(
                                width: 152,
                                child: ProductCard(
                                  product: items[index],
                                  compact: true,
                                  onTap: () =>
                                      _openProduct(context, items[index]),
                                ),
                              ),
                            ),
                          ),
                    loading: () => const _LoadingStrip(height: 266),
                    error: (_, _) => _InlineMessage(
                      message: 'Không tải được sản phẩm.',
                      onRetry: () => ref.invalidate(productsProvider),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeading(
                    title: 'GỢI Ý HÔM NAY',
                    action: 'Khám phá',
                    onAction: () => _openListing(context),
                  ),
                  const SizedBox(height: 12),
                  products.when(
                    data: (items) => items.isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final columns = constraints.maxWidth >= 720
                                    ? 4
                                    : 2;
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: items.length > 8
                                      ? 8
                                      : items.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: columns,
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 10,
                                        childAspectRatio: .60,
                                      ),
                                  itemBuilder: (context, index) => ProductCard(
                                    product: items[index],
                                    compact: true,
                                    onTap: () =>
                                        _openProduct(context, items[index]),
                                  ),
                                );
                              },
                            ),
                          ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSearchHeader extends StatelessWidget {
  const _HomeSearchHeader({
    required this.cartCount,
    required this.onSearch,
    required this.onOpenChat,
    required this.onOpenCart,
    required this.onVoiceSearch,
  });

  final int cartCount;
  final VoidCallback onSearch;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenCart;
  final ValueChanged<String> onVoiceSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final headerColor = theme.brightness == Brightness.dark
        ? AppColors.profileHeaderDark
        : AppColors.profileHeaderLight;
    return Material(
      key: const ValueKey('home-search-header'),
      color: headerColor,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Tooltip(
                message: 'Tìm kiếm sản phẩm',
                child: Material(
                  key: const ValueKey('home-search'),
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(4),
                  child: InkWell(
                    onTap: onSearch,
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 44,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              size: 21,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tìm sản phẩm, thương hiệu...',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            VoiceSearchButton(
                              onSearch: onVoiceSearch,
                              compact: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Mở giỏ hàng',
              onPressed: onOpenCart,
              color: Colors.white,
              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text(cartCount > 99 ? '99+' : '$cartCount'),
                backgroundColor: colors.surface,
                textColor: colors.primary,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Mở lịch sử chat',
              onPressed: onOpenChat,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: .14),
                foregroundColor: Colors.white,
                fixedSize: const Size(44, 44),
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.forum_rounded, size: 23),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: const Color(0xFFFFE9DE),
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFE9DE), Color(0xFFFFCFB6)],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'LUMI MARKET',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF9B351D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mở app,\nmở niềm vui!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF982C19),
                        height: 1.12,
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Deal xinh cho ngày mới',
                      style: TextStyle(color: Color(0xFF963E27), fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.coralDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'Khám phá ngay',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Transform.rotate(
                  angle: -.07,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x229B351D),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/products/earbuds.jpg',
                        height: 138,
                        fit: BoxFit.cover,
                      ),
                    ),
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 27),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryShortcut extends StatelessWidget {
  const _CategoryShortcut({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              height: 52,
              width: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(16),
              ),
              child: CategoryIcon(categoryId: category.id, size: 25),
            ),
            const SizedBox(height: 7),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.action,
    required this.onAction,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton(onPressed: onAction, child: Text(action)),
        ],
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    child: Row(
      children: [
        Expanded(child: Text(message)),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
      ],
    ),
  );
}

class _LoadingStrip extends StatelessWidget {
  const _LoadingStrip({this.height = 108});

  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: const Center(child: CircularProgressIndicator()),
  );
}

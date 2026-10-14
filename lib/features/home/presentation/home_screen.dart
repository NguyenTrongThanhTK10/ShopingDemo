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
import '../../voice_search/presentation/widgets/voice_search_button.dart';

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
              onOpenCart: onOpenCart,
              onVoiceSearch: (query) =>
                  _openListing(context, initialQuery: query),
            ),
            Expanded(
              child: ListView(
                key: const ValueKey('home-feed'),
                padding: const EdgeInsets.only(bottom: 28),
                children: [
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _HeroBanner(
                      onTap: () =>
                          _openListing(context, title: 'Khám phá hôm nay'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _QuickAction(
                          icon: Icons.bolt_rounded,
                          label: 'Flash Sale',
                          color: const Color(0xFFFFEEE8),
                          onTap: () =>
                              _openListing(context, title: 'Flash Sale'),
                        ),
                        _QuickAction(
                          icon: Icons.workspace_premium_outlined,
                          label: 'Hàng chọn',
                          color: const Color(0xFFFFF3DD),
                          onTap: () =>
                              _openListing(context, title: 'Hàng chọn'),
                        ),
                        _QuickAction(
                          icon: Icons.sell_outlined,
                          label: 'Giá tốt',
                          color: const Color(0xFFE9F5F1),
                          onTap: () => _openListing(context, title: 'Giá tốt'),
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
                  const SizedBox(height: 22),
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
                            height: 98,
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
                  const SizedBox(height: 22),
                  _SectionHeading(
                    title: 'Được yêu thích',
                    subtitle:
                        'Flash Sale · Giá tốt cho những món đang được săn đón',
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
                            height: 288,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount: items.length > 6 ? 6 : items.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) => SizedBox(
                                width: 176,
                                child: ProductCard(
                                  product: items[index],
                                  onTap: () =>
                                      _openProduct(context, items[index]),
                                ),
                              ),
                            ),
                          ),
                    loading: () => const _LoadingStrip(height: 288),
                    error: (_, _) => _InlineMessage(
                      message: 'Không tải được sản phẩm.',
                      onRetry: () => ref.invalidate(productsProvider),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeading(
                    title: 'Dành riêng cho bạn',
                    subtitle: 'Cảm hứng mua sắm mỗi ngày',
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
                                        childAspectRatio: .57,
                                      ),
                                  itemBuilder: (context, index) => ProductCard(
                                    product: items[index],
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
    required this.onOpenCart,
    required this.onVoiceSearch,
  });

  final int cartCount;
  final VoidCallback onSearch;
  final VoidCallback onOpenCart;
  final ValueChanged<String> onVoiceSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      key: const ValueKey('home-search-header'),
      color: AppColors.coralDark,
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
                  borderRadius: BorderRadius.circular(8),
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
            Badge(
              isLabelVisible: cartCount > 0,
              label: Text(cartCount > 99 ? '99+' : '$cartCount'),
              backgroundColor: colors.surface,
              textColor: colors.primary,
              child: IconButton(
                tooltip: 'Mở giỏ hàng',
                onPressed: onOpenCart,
                color: Colors.white,
                constraints: const BoxConstraints.tightFor(
                  width: 48,
                  height: 48,
                ),
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 178,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF351E20), Color(0xFF9D3832), Color(0xFFF57742)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -35,
              bottom: -92,
              child: CircleAvatar(
                radius: 125,
                backgroundColor: Colors.white.withValues(alpha: .11),
              ),
            ),
            Positioned(
              right: 3,
              top: 13,
              child: Transform.rotate(
                angle: .11,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/products/earbuds.jpg',
                    width: 134,
                    height: 155,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LUMI DEALS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFFFD28C),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 175,
                      child: Text(
                        'Món hay\ngiá mê ly',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.08,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Khám phá ngay',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.coralDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 17,
                            color: AppColors.coralDark,
                          ),
                        ],
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
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
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
              height: 60,
              width: 60,
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
                  style: theme.textTheme.titleLarge?.copyWith(
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

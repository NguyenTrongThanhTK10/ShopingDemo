import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/presentation/providers/cart_provider.dart';
import '../../catalog/domain/category.dart';
import '../../catalog/domain/product.dart';
import '../../catalog/presentation/product_detail_screen.dart';
import '../../catalog/presentation/product_list_screen.dart';
import '../../catalog/presentation/providers/catalog_providers.dart';
import '../../catalog/presentation/widgets/category_icon.dart';
import '../../catalog/presentation/widgets/product_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.onOpenCart});

  final VoidCallback onOpenCart;

  void _openListing(
    BuildContext context, {
    String? title,
    String? categoryId,
    bool search = false,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductListScreen(
          title: title,
          categoryId: categoryId,
          autofocusSearch: search,
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
    final colors = theme.colorScheme;
    final categories = ref.watch(categoriesProvider);
    final products = ref.watch(productsProvider);
    final cartCount = ref.watch(cartProvider).totalQuantity;

    return SafeArea(
      child: ColoredBox(
        color: theme.scaffoldBackgroundColor,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_mall_outlined,
                      color: colors.primary,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lumi Market',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -.2,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Mua sắm nhẹ nhàng',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Tìm kiếm sản phẩm',
                    onPressed: () => _openListing(context, search: true),
                    icon: const Icon(Icons.search_rounded),
                  ),
                  const SizedBox(width: 8),
                  Badge(
                    isLabelVisible: cartCount > 0,
                    label: Text(cartCount > 99 ? '99+' : '$cartCount'),
                    child: IconButton.filledTonal(
                      tooltip: 'Mở giỏ hàng',
                      style: IconButton.styleFrom(
                        backgroundColor: colors.primaryContainer,
                        foregroundColor: colors.primary,
                      ),
                      onPressed: onOpenCart,
                      icon: const Icon(Icons.shopping_cart_outlined),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _openListing(context, search: true),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.outlineVariant),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: colors.onSurfaceVariant,
                        size: 21,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Bạn đang tìm gì hôm nay?',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _HeroBanner(
                onTap: () => _openListing(context, title: 'Khám phá hôm nay'),
              ),
            ),
            const SizedBox(height: 26),
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
                      height: 96,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) => _CategoryShortcut(
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
            const SizedBox(height: 24),
            _SectionHeading(
              title: 'Được yêu thích',
              subtitle: 'Những món nhỏ làm ngày thêm vui',
              action: 'Xem thêm',
              onAction: () => _openListing(context, title: 'Được yêu thích'),
            ),
            const SizedBox(height: 12),
            products.when(
              data: (items) => items.isEmpty
                  ? const _InlineMessage(message: 'Sản phẩm sẽ sớm xuất hiện.')
                  : SizedBox(
                      height: 274,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length > 6 ? 6 : items.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) => SizedBox(
                          width: 184,
                          child: ProductCard(
                            product: items[index],
                            onTap: () => _openProduct(context, items[index]),
                          ),
                        ),
                      ),
                    ),
              loading: () => const _LoadingStrip(height: 274),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 720 ? 4 : 2;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length > 8 ? 8 : items.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: .67,
                                ),
                            itemBuilder: (context, index) => ProductCard(
                              product: items[index],
                              onTap: () => _openProduct(context, items[index]),
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
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 174,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.primaryContainer, colors.tertiaryContainer],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -48,
              bottom: -76,
              child: CircleAvatar(
                radius: 126,
                backgroundColor: colors.surface.withValues(alpha: .42),
              ),
            ),
            Positioned(
              right: 21,
              bottom: 30,
              child: Transform.rotate(
                angle: -.13,
                child: Container(
                  width: 86,
                  height: 86,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: .52),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 45,
                    color: colors.primary.withValues(alpha: .64),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LUMI EDIT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 190,
                    child: Text(
                      'Chọn món bạn yêu',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Khám phá',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 17,
                        color: colors.primary,
                      ),
                    ],
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
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(17),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    fontWeight: FontWeight.w600,
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

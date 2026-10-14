import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/design_tokens.dart';
import '../domain/category.dart';
import 'product_list_screen.dart';
import 'providers/catalog_providers.dart';
import 'widgets/category_icon.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final headerColor = theme.brightness == Brightness.dark
        ? AppColors.profileHeaderDark
        : AppColors.profileHeaderLight;
    final categories = ref.watch(categoriesProvider);

    return SafeArea(
      child: ColoredBox(
        color: theme.scaffoldBackgroundColor,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                key: const ValueKey('categories-header'),
                width: double.infinity,
                color: headerColor,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Khám phá danh mục',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tìm nhanh món bạn cần, chọn đúng gu bạn thích',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: .94),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              sliver: SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE5D8), Color(0xFFFFF3E7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 28,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mỗi ngày một điều mới',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: const Color(0xFFB63E22),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Từ công nghệ đến góc nhà xinh',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF51423D),
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
            categories.when(
              data: (items) => items.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _StatusView(
                        icon: Icons.category_outlined,
                        message: 'Chưa có danh mục nào.',
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                      sliver: SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.crossAxisExtent >= 720
                              ? 4
                              : 2;
                          return SliverGrid.builder(
                            itemCount: items.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: .94,
                                ),
                            itemBuilder: (context, index) =>
                                _CategoryTile(category: items[index]),
                          );
                        },
                      ),
                    ),
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: _StatusView(
                  icon: Icons.cloud_off_outlined,
                  message: 'Không tải được danh mục.',
                  onRetry: () => ref.invalidate(categoriesProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(13),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ProductListScreen(
              title: category.name,
              categoryId: category.id,
            ),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(_categoryImage(category.id), fit: BoxFit.cover),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: .94),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: CategoryIcon(categoryId: category.id, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: colors.primary,
                    size: 17,
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

String _categoryImage(String id) => switch (id) {
  'tech' => 'assets/products/earbuds.jpg',
  'fashion' => 'assets/products/linen-shirt.jpg',
  'beauty' => 'assets/products/serum.jpg',
  'home' => 'assets/products/lamp.jpg',
  'lifestyle' => 'assets/products/tumbler.jpg',
  _ => 'assets/products/coffee.jpg',
};

class _StatusView extends StatelessWidget {
  const _StatusView({required this.icon, required this.message, this.onRetry});

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: colors.primary),
          const SizedBox(height: 12),
          Text(message),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ],
      ),
    );
  }
}

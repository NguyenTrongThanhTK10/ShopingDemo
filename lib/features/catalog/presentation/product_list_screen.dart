import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../reviews/presentation/providers/review_providers.dart';
import '../domain/filter_products.dart';
import 'product_detail_screen.dart';
import 'providers/catalog_providers.dart';
import 'widgets/catalog_search_field.dart';
import 'widgets/catalog_filter_sheet.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import 'widgets/product_card.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({
    super.key,
    this.title,
    this.categoryId,
    this.autofocusSearch = false,
    this.initialQuery = '',
  });

  final String? title;
  final String? categoryId;
  final bool autofocusSearch;
  final String initialQuery;

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  late final TextEditingController _searchController;
  String? _categoryId;
  ProductSort _sortOrder = ProductSort.popular;
  CatalogFilters _filters = const CatalogFilters();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _categoryId = widget.categoryId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final products = ref.watch(productsProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.title ?? 'Khám phá sản phẩm'),
        backgroundColor: colors.surface,
        actions: [
          IconButton(
            tooltip: 'Bộ lọc tìm kiếm',
            icon: Badge.count(
              count: _filters.count,
              isLabelVisible: _filters.count > 0,
              child: const Icon(Icons.filter_alt_outlined),
            ),
            onPressed: () async {
              final filters = await showCatalogFilterSheet(context, _filters);
              if (mounted && filters != null) {
                setState(() => _filters = filters);
              }
            },
          ),
          IconButton(
            tooltip: 'Mở giỏ hàng',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const CartScreen())),
            icon: Badge.count(
              count: ref.watch(cartProvider).totalQuantity,
              isLabelVisible: ref.watch(cartProvider).totalQuantity > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: colors.surface,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: CatalogSearchField(
                controller: _searchController,
                autofocus: widget.autofocusSearch,
                categoryId: _categoryId,
                onChanged: (_) => setState(() {}),
              ),
            ),
            if (categories.asData case final data?)
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: data.value.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = index == 0 ? null : data.value[index - 1];
                    return _CatalogFilterChip(
                      label: category?.name ?? 'Tất cả',
                      selected: _categoryId == category?.id,
                      onTap: () => setState(() => _categoryId = category?.id),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _SortChip(
                    label: 'Phổ biến',
                    selected: _sortOrder == ProductSort.popular,
                    onTap: () =>
                        setState(() => _sortOrder = ProductSort.popular),
                  ),
                  _SortChip(
                    label: 'Giá thấp',
                    selected: _sortOrder == ProductSort.priceAsc,
                    onTap: () =>
                        setState(() => _sortOrder = ProductSort.priceAsc),
                  ),
                  _SortChip(
                    label: 'Giá cao',
                    selected: _sortOrder == ProductSort.priceDesc,
                    onTap: () =>
                        setState(() => _sortOrder = ProductSort.priceDesc),
                  ),
                  _SortChip(
                    label: 'Đánh giá tốt',
                    selected: _sortOrder == ProductSort.topRated,
                    onTap: () =>
                        setState(() => _sortOrder = ProductSort.topRated),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: products.when(
                data: (allProducts) {
                  final items = filterProducts(
                    allProducts,
                    ratingOverrides:
                        _sortOrder == ProductSort.topRated ||
                            _filters.minimumRating > 0
                        ? {
                            for (final product in allProducts)
                              if (ref.watch(
                                    productReviewSummaryProvider(product.id),
                                  )
                                  case final summary?)
                                product.id: summary.average,
                          }
                        : const {},
                    query: _searchController.text,
                    categoryId: _categoryId,
                    sortOrder: _sortOrder,
                    minimumPrice: _filters.minimumPrice,
                    maximumPrice: _filters.maximumPrice,
                    minimumRating: _filters.minimumRating,
                    inStockOnly: _filters.inStockOnly,
                  );
                  if (items.isEmpty) {
                    return _ListingStatus(
                      icon: Icons.search_off_rounded,
                      title: 'Chưa tìm thấy sản phẩm',
                      detail: 'Thử từ khóa hoặc danh mục khác nhé.',
                      action:
                          _searchController.text.isNotEmpty ||
                              _categoryId != null ||
                              _filters.count > 0
                          ? () {
                              _searchController.clear();
                              setState(() {
                                _categoryId = null;
                                _filters = const CatalogFilters();
                              });
                            }
                          : null,
                      actionLabel: 'Xem tất cả',
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                        child: Text(
                          '${items.length} sản phẩm dành cho bạn',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = constraints.maxWidth >= 720 ? 4 : 2;
                            return GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              itemCount: items.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: .57,
                                  ),
                              itemBuilder: (context, index) {
                                final hasVariantFilter =
                                    _filters.minimumPrice != null ||
                                    _filters.maximumPrice != null ||
                                    _filters.inStockOnly;
                                final variant = hasVariantFilter
                                    ? matchingProductVariant(
                                        items[index],
                                        minimumPrice: _filters.minimumPrice,
                                        maximumPrice: _filters.maximumPrice,
                                        inStockOnly: _filters.inStockOnly,
                                      )
                                    : null;
                                return ProductCard(
                                  product: items[index],
                                  displayPrice: variant?.price,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => ProductDetailScreen(
                                        productId: items[index].id,
                                        initialVariantId: variant?.id,
                                        initialImageIndex:
                                            variant?.imageIndex ?? 0,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => _ListingStatus(
                  icon: Icons.cloud_off_rounded,
                  title: 'Không tải được sản phẩm',
                  detail: 'Kiểm tra kết nối rồi thử lại.',
                  action: () => ref.invalidate(productsProvider),
                  actionLabel: 'Thử lại',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: _CatalogFilterChip(label: label, selected: selected, onTap: onTap),
  );
}

class _CatalogFilterChip extends StatelessWidget {
  const _CatalogFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: colors.surface,
      selectedColor: colors.primaryContainer,
      surfaceTintColor: Colors.transparent,
      checkmarkColor: colors.primary,
      side: BorderSide(
        color: selected ? colors.primary : colors.outlineVariant,
      ),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: selected ? colors.primary : colors.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}

class _ListingStatus extends StatelessWidget {
  const _ListingStatus({
    required this.icon,
    required this.title,
    required this.detail,
    required this.actionLabel,
    this.action,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback? action;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(detail, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 12),
              FilledButton.tonal(onPressed: action, child: Text(actionLabel)),
            ],
          ],
        ),
      ),
    );
  }
}

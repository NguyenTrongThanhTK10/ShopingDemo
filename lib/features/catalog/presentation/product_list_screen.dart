import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/filter_products.dart';
import 'product_detail_screen.dart';
import 'providers/catalog_providers.dart';
import 'widgets/product_card.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({
    super.key,
    this.title,
    this.categoryId,
    this.autofocusSearch = false,
  });

  final String? title;
  final String? categoryId;
  final bool autofocusSearch;

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  late final TextEditingController _searchController;
  String? _categoryId;
  ProductSort _sortOrder = ProductSort.popular;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
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
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _searchController,
                autofocus: widget.autofocusSearch,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Tìm sản phẩm hoặc cửa hàng',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Xóa tìm kiếm',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: colors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
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
                    return ChoiceChip(
                      label: Text(category?.name ?? 'Tất cả'),
                      selected: _categoryId == category?.id,
                      onSelected: (_) =>
                          setState(() => _categoryId = category?.id),
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
                    query: _searchController.text,
                    categoryId: _categoryId,
                    sortOrder: _sortOrder,
                  );
                  if (items.isEmpty) {
                    return _ListingStatus(
                      icon: Icons.search_off_rounded,
                      title: 'Chưa tìm thấy sản phẩm',
                      detail: 'Thử từ khóa hoặc danh mục khác nhé.',
                      action:
                          _searchController.text.isNotEmpty ||
                              _categoryId != null
                          ? () {
                              _searchController.clear();
                              setState(() => _categoryId = null);
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
                          '${items.length} sản phẩm',
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
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: .64,
                                  ),
                              itemBuilder: (context, index) => ProductCard(
                                product: items[index],
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ProductDetailScreen(
                                      productId: items[index].id,
                                    ),
                                  ),
                                ),
                              ),
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
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    ),
  );
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

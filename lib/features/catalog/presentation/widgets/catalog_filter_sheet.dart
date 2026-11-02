import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CatalogFilters {
  const CatalogFilters({
    this.minimumPrice,
    this.maximumPrice,
    this.minimumRating = 0,
    this.inStockOnly = false,
  });

  final int? minimumPrice;
  final int? maximumPrice;
  final double minimumRating;
  final bool inStockOnly;

  int get count =>
      (minimumPrice != null || maximumPrice != null ? 1 : 0) +
      (minimumRating > 0 ? 1 : 0) +
      (inStockOnly ? 1 : 0);
}

Future<CatalogFilters?> showCatalogFilterSheet(
  BuildContext context,
  CatalogFilters filters,
) => showModalBottomSheet<CatalogFilters>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _CatalogFilterSheet(filters: filters),
);

class _CatalogFilterSheet extends StatefulWidget {
  const _CatalogFilterSheet({required this.filters});
  final CatalogFilters filters;

  @override
  State<_CatalogFilterSheet> createState() => _CatalogFilterSheetState();
}

class _CatalogFilterSheetState extends State<_CatalogFilterSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _minimum;
  late final TextEditingController _maximum;
  late double _rating;
  late bool _inStock;

  @override
  void initState() {
    super.initState();
    _minimum = TextEditingController(
      text: widget.filters.minimumPrice?.toString() ?? '',
    );
    _maximum = TextEditingController(
      text: widget.filters.maximumPrice?.toString() ?? '',
    );
    _rating = widget.filters.minimumRating;
    _inStock = widget.filters.inStockOnly;
  }

  @override
  void dispose() {
    _minimum.dispose();
    _maximum.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .9,
        ),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    'Bộ lọc tìm kiếm',
                    style: theme.textTheme.titleMedium,
                  ),
                  trailing: IconButton(
                    tooltip: 'Đóng bộ lọc',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Khoảng giá (₫)',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                key: const ValueKey('filter-min-price'),
                                controller: _minimum,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Từ',
                                  hintText: '0',
                                ),
                                validator: (value) =>
                                    value!.isNotEmpty &&
                                        int.tryParse(value) == null
                                    ? 'Giá không hợp lệ'
                                    : null,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text('–'),
                            ),
                            Expanded(
                              child: TextFormField(
                                key: const ValueKey('filter-max-price'),
                                controller: _maximum,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Đến',
                                  hintText: 'Không giới hạn',
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) return null;
                                  final maximum = int.tryParse(value);
                                  if (maximum == null) {
                                    return 'Giá không hợp lệ';
                                  }
                                  return maximum <
                                          (int.tryParse(_minimum.text) ?? 0)
                                      ? 'Thấp hơn giá tối thiểu'
                                      : null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('Đánh giá', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            for (final rating in [0.0, 4.0, 4.5, 5.0])
                              ChoiceChip(
                                label: Text(
                                  rating == 0
                                      ? 'Tất cả'
                                      : '★ ${rating.toStringAsFixed(1)} trở lên',
                                ),
                                selected: _rating == rating,
                                onSelected: (_) =>
                                    setState(() => _rating = rating),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text('Chỉ hiện sản phẩm còn hàng'),
                          value: _inStock,
                          onChanged: (value) =>
                              setState(() => _inStock = value ?? false),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _formKey.currentState?.reset();
                            _minimum.clear();
                            _maximum.clear();
                            setState(() {
                              _rating = 0;
                              _inStock = false;
                            });
                          },
                          child: const Text('Thiết lập lại'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            Navigator.of(context).pop(
                              CatalogFilters(
                                minimumPrice: int.tryParse(_minimum.text),
                                maximumPrice: int.tryParse(_maximum.text),
                                minimumRating: _rating,
                                inStockOnly: _inStock,
                              ),
                            );
                          },
                          child: const Text('Áp dụng'),
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
    );
  }
}

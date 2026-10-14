import 'package:flutter/material.dart';

import '../../../../core/utils/money_formatter.dart';
import '../../domain/product.dart';
import 'product_image.dart';
import 'quantity_stepper.dart';

enum ProductPurchaseAction { configure, addToCart, buyNow }

class ProductSelection {
  const ProductSelection({required this.variant, required this.quantity});

  final ProductVariant variant;
  final int quantity;
}

Future<ProductSelection?> showProductSelectionSheet(
  BuildContext context, {
  required Product product,
  required ProductVariant? initialVariant,
  required int initialQuantity,
  required ProductPurchaseAction action,
}) {
  return showModalBottomSheet<ProductSelection>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (_) => _ProductSelectionSheet(
      product: product,
      initialVariant: initialVariant,
      initialQuantity: initialQuantity,
      action: action,
    ),
  );
}

class _ProductSelectionSheet extends StatefulWidget {
  const _ProductSelectionSheet({
    required this.product,
    required this.initialVariant,
    required this.initialQuantity,
    required this.action,
  });

  final Product product;
  final ProductVariant? initialVariant;
  final int initialQuantity;
  final ProductPurchaseAction action;

  @override
  State<_ProductSelectionSheet> createState() => _ProductSelectionSheetState();
}

class _ProductSelectionSheetState extends State<_ProductSelectionSheet> {
  ProductVariant? _variant;
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _variant = widget.initialVariant;
    _quantity = (_variant?.stock ?? 0) > 0
        ? widget.initialQuantity.clamp(1, _variant!.stock)
        : 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final variant = _variant;
    final stock = variant?.stock ?? 0;
    final price = variant?.price ?? widget.product.price;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final actionLabel = switch (widget.action) {
      ProductPurchaseAction.configure => 'Xác nhận',
      ProductPurchaseAction.addToCart => 'Thêm vào giỏ hàng',
      ProductPurchaseAction.buyNow => 'Mua ngay',
    };

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: (MediaQuery.sizeOf(context).height - keyboardInset) * .9,
          maxWidth: 640,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 88,
                        height: 88,
                        child: ProductImage(
                          product: widget.product,
                          imageIndex: variant?.imageIndex ?? 0,
                          compact: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              formatVnd(price),
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            stock > 0 ? 'Kho: $stock' : 'Hết hàng',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            variant == null
                                ? 'Chưa có phân loại'
                                : 'Đã chọn: ${variant.label}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Đóng lựa chọn',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 22),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phân loại', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      if (widget.product.variants.isEmpty)
                        const Text('Sản phẩm chưa có phân loại để đặt mua.')
                      else
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final item in widget.product.variants)
                              _VariantChoice(
                                variant: item,
                                selected: item.id == variant?.id,
                                onTap: item.stock < 1
                                    ? null
                                    : () => setState(() {
                                        _variant = item;
                                        _quantity = 1;
                                      }),
                              ),
                          ],
                        ),
                      const Divider(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Số lượng',
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  stock > 0
                                      ? 'Tối đa $stock sản phẩm'
                                      : 'Hết hàng',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          QuantityStepper(
                            quantity: _quantity,
                            stock: stock,
                            onChanged: (value) =>
                                setState(() => _quantity = value),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Tạm tính',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          formatVnd(price * _quantity),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const ValueKey('confirm-product-selection'),
                        onPressed: variant == null || stock < 1
                            ? null
                            : () => Navigator.of(context).pop(
                                ProductSelection(
                                  variant: variant,
                                  quantity: _quantity,
                                ),
                              ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          backgroundColor:
                              widget.action == ProductPurchaseAction.addToCart
                              ? colors.primaryContainer
                              : null,
                          foregroundColor:
                              widget.action == ProductPurchaseAction.addToCart
                              ? colors.onPrimaryContainer
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          iconSize: 20,
                        ),
                        icon: Icon(switch (widget.action) {
                          ProductPurchaseAction.configure =>
                            Icons.check_rounded,
                          ProductPurchaseAction.addToCart =>
                            Icons.add_shopping_cart_rounded,
                          ProductPurchaseAction.buyNow =>
                            Icons.shopping_bag_outlined,
                        }),
                        label: Text(stock < 1 ? 'Hết hàng' : actionLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VariantChoice extends StatelessWidget {
  const _VariantChoice({
    required this.variant,
    required this.selected,
    required this.onTap,
  });

  final ProductVariant variant;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      child: Material(
        color: selected ? colors.primaryContainer : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 42),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? colors.primary : colors.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    variant.stock < 1
                        ? '${variant.label} · Hết hàng'
                        : variant.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: onTap == null
                          ? colors.onSurfaceVariant
                          : selected
                          ? colors.primary
                          : colors.onSurface,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check_rounded, size: 16, color: colors.primary),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

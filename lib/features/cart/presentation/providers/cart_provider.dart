import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalog/domain/product.dart';
import '../../domain/cart_line.dart';

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);

/// In-memory demo cart. A production cart must be validated by the server.
class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => const CartState([]);

  void add(Product product, ProductVariant variant, {int quantity = 1}) {
    if (!product.variants.any((item) => item.id == variant.id)) {
      throw ArgumentError.value(
        variant.id,
        'variant',
        'Variant is not in product',
      );
    }
    if (quantity < 1 || variant.stock < 1) return;

    final current = state.items;
    final existingIndex = current.indexWhere((line) => line.id == variant.id);
    if (existingIndex == -1) {
      state = CartState([
        ...current,
        CartLine(
          product: product,
          variant: variant,
          quantity: quantity.clamp(1, variant.stock),
        ),
      ]);
      return;
    }

    state = CartState([
      for (final line in current)
        if (line.id == variant.id)
          line.copyWith(
            quantity: (line.quantity + quantity).clamp(1, variant.stock),
          )
        else
          line,
    ]);
  }

  void updateQuantity(String variantId, int quantity) {
    state = CartState([
      for (final line in state.items)
        if (line.id == variantId)
          line.copyWith(quantity: quantity.clamp(1, line.variant.stock))
        else
          line,
    ]);
  }

  void toggleSelected(String variantId, bool selected) {
    state = CartState([
      for (final line in state.items)
        if (line.id == variantId) line.copyWith(selected: selected) else line,
    ]);
  }

  void remove(String variantId) {
    state = CartState(
      state.items.where((line) => line.id != variantId).toList(),
    );
  }

  void clearSelected() {
    state = CartState(state.items.where((line) => !line.selected).toList());
  }
}

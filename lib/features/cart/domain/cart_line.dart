import '../../catalog/domain/product.dart';

class CartLine {
  const CartLine({
    required this.product,
    required this.variant,
    required this.quantity,
    this.selected = true,
  });

  final Product product;
  final ProductVariant variant;
  final int quantity;
  final bool selected;

  String get id => variant.id;
  int get subtotal => variant.price * quantity;

  CartLine copyWith({int? quantity, bool? selected}) => CartLine(
    product: product,
    variant: variant,
    quantity: quantity ?? this.quantity,
    selected: selected ?? this.selected,
  );
}

class CartState {
  const CartState(this.items);

  final List<CartLine> items;

  bool get isEmpty => items.isEmpty;
  int get totalQuantity => items.fold(0, (sum, line) => sum + line.quantity);
  List<CartLine> get selectedLines =>
      items.where((line) => line.selected).toList(growable: false);
  int get selectedCount => selectedLines.length;
  int get selectedSubtotal =>
      selectedLines.fold(0, (sum, line) => sum + line.subtotal);
}

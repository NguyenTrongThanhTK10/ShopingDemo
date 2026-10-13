import '../../cart/domain/cart_line.dart';

class DemoOrder {
  const DemoOrder({
    required this.id,
    required this.items,
    required this.total,
    required this.recipient,
    required this.phone,
    required this.address,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final List<CartLine> items;
  final int total;
  final String recipient;
  final String phone;
  final String address;
  final DateTime createdAt;
  final String status;
}

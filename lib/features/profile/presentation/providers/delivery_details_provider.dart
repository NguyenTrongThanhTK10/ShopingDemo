import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/delivery_details.dart';

final deliveryDetailsProvider =
    NotifierProvider<DeliveryDetailsNotifier, DeliveryDetails?>(
      DeliveryDetailsNotifier.new,
    );

/// Stores one default delivery address during the current app session.
class DeliveryDetailsNotifier extends Notifier<DeliveryDetails?> {
  @override
  DeliveryDetails? build() => null;

  void save(DeliveryDetails details) => state = details;

  void clear() => state = null;
}

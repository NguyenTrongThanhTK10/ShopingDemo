import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/payment_types.dart';

final preferredPaymentMethodProvider =
    NotifierProvider<PreferredPaymentMethodNotifier, PaymentMethod>(
      PreferredPaymentMethodNotifier.new,
    );

/// The demo preference lasts for the current app session.
class PreferredPaymentMethodNotifier extends Notifier<PaymentMethod> {
  @override
  PaymentMethod build() => PaymentMethod.vietQr;

  void select(PaymentMethod method) => state = method;
}

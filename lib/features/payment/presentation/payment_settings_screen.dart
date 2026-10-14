import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/payment_types.dart';
import 'providers/payment_preferences_provider.dart';

class PaymentSettingsScreen extends ConsumerWidget {
  const PaymentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferred = ref.watch(preferredPaymentMethodProvider);
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt thanh toán')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            children: [
              Text('Phương thức ưu tiên', style: theme.textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                'Phương thức bạn chọn sẽ được điền sẵn khi thanh toán. Bạn vẫn có thể đổi ở từng đơn hàng.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < PaymentMethod.values.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          indent: 68,
                          color: colors.outlineVariant,
                        ),
                      _PaymentMethodTile(
                        method: PaymentMethod.values[i],
                        selected: preferred == PaymentMethod.values[i],
                        onTap: () => ref
                            .read(preferredPaymentMethodProvider.notifier)
                            .select(PaymentMethod.values[i]),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bản demo chỉ nhớ lựa chọn trong phiên này; không lưu thẻ hay tài khoản ngân hàng.',
                        style: theme.textTheme.bodySmall,
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

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      key: ValueKey('preferred-payment-${method.id}'),
      contentPadding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
      selected: selected,
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: selected
            ? colors.primaryContainer
            : colors.surfaceContainerLow,
        child: Icon(
          method.icon,
          color: selected ? colors.primary : colors.onSurfaceVariant,
        ),
      ),
      title: Text(method.title, style: const TextStyle(fontSize: 14)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(method.subtitle),
      ),
      trailing: Icon(
        selected
            ? Icons.check_circle_rounded
            : Icons.radio_button_unchecked_rounded,
        color: selected ? colors.primary : colors.onSurfaceVariant,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../domain/demo_order.dart';

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.order});
  final DemoOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final steps = [
      OrderStage.awaitingConfirmation,
      OrderStage.awaitingPickup,
      OrderStage.shipping,
      OrderStage.completed,
    ];
    final current = steps.indexOf(order.stage);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hành trình đơn hàng', style: theme.textTheme.titleSmall),
          const SizedBox(height: 16),
          if (order.stage != OrderStage.canceled) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < steps.length; i++)
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          i <= current
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 22,
                          color: i <= current
                              ? colors.secondary
                              : colors.outline,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          steps[i].label,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: i <= current
                                ? colors.secondary
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
          ],
          for (final event in order.events.reversed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Icon(Icons.circle, size: 7, color: colors.secondary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(event.label, style: theme.textTheme.bodySmall),
                  ),
                  const SizedBox(width: 8),
                  Text(_date(event.at), style: theme.textTheme.labelSmall),
                ],
              ),
            ),
          if (order.cancellationReason != null)
            Text(
              'Lý do: ${order.cancellationReason}',
              style: theme.textTheme.bodySmall,
            ),
          if (order.stage != OrderStage.canceled &&
              order.stage != OrderStage.completed)
            Text(
              '${order.delivery.label} · ${order.delivery.estimate} (mô phỏng)',
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  String _date(DateTime date) {
    final local = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)} ${two(local.hour)}:${two(local.minute)}';
  }
}

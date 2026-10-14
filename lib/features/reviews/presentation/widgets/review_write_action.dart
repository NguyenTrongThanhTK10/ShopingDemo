import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/review_providers.dart';
import 'review_form_sheet.dart';

class ReviewWriteAction extends ConsumerWidget {
  const ReviewWriteAction({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targets = ref.watch(productReviewTargetsProvider(productId));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          key: const ValueKey('write-product-review'),
          onPressed: targets.isEmpty
              ? null
              : () async {
                  final sent = await showReviewFormSheet(
                    context,
                    targets: targets,
                  );
                  if (context.mounted && sent == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã gửi đánh giá của bạn'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
          icon: const Icon(Icons.rate_review_outlined, size: 18),
          label: const Text('Viết đánh giá'),
        ),
        if (targets.isEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'Hoàn thành đơn mua để đánh giá. Mỗi sản phẩm trong đơn được đánh giá một lần.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

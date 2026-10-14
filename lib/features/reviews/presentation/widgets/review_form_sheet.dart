import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalog/presentation/widgets/product_image.dart';
import '../../domain/product_review.dart';
import '../providers/review_providers.dart';

Future<bool?> showReviewFormSheet(
  BuildContext context, {
  required List<ProductReviewTarget> targets,
}) {
  if (targets.isEmpty) return Future.value(false);
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (_) => _ReviewFormSheet(targets: targets),
  );
}

class _ReviewFormSheet extends ConsumerStatefulWidget {
  const _ReviewFormSheet({required this.targets});

  final List<ProductReviewTarget> targets;

  @override
  ConsumerState<_ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends ConsumerState<_ReviewFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 0;
  int _selectedTarget = 0;
  String? _ratingError;
  String? _submissionError;

  Future<void> _submit() async {
    if (ref.read(reviewSubmissionProvider).isLoading) return;
    final validComment = _formKey.currentState?.validate() ?? false;
    setState(() {
      _ratingError = _rating == 0 ? 'Vui lòng chọn số sao.' : null;
      _submissionError = null;
    });
    if (!validComment || _rating == 0) return;
    FocusScope.of(context).unfocus();
    final target = widget.targets[_selectedTarget];
    try {
      await ref
          .read(reviewSubmissionProvider.notifier)
          .submit(
            orderId: target.orderId,
            variantId: target.variant.id,
            rating: _rating,
            comment: _commentController.text,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _submissionError = error is ReviewException
            ? error.message
            : 'Chưa gửi được đánh giá. Vui lòng thử lại.',
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final saving = ref.watch(reviewSubmissionProvider).isLoading;
    final target = widget.targets[_selectedTarget];
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final labels = [
      'Chạm để chọn số sao',
      'Rất không hài lòng',
      'Chưa hài lòng',
      'Bình thường',
      'Hài lòng',
      'Rất hài lòng',
    ];

    return PopScope(
      canPop: !saving,
      child: Padding(
        padding: EdgeInsets.only(bottom: inset),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: (MediaQuery.sizeOf(context).height - inset) * .92,
            maxWidth: 640,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Viết đánh giá',
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Đóng đánh giá',
                        onPressed: saving
                            ? null
                            : () => Navigator.of(context).pop(false),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: AbsorbPointer(
                      absorbing: saving,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: ProductImage(
                                      product: target.product,
                                      imageIndex:
                                          target.variant.imageIndex ?? 0,
                                      compact: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        target.product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        target.variant.label,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (widget.targets.length > 1)
                              DropdownButtonFormField<int>(
                                initialValue: _selectedTarget,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Sản phẩm trong đơn',
                                ),
                                items: [
                                  for (
                                    var index = 0;
                                    index < widget.targets.length;
                                    index++
                                  )
                                    DropdownMenuItem(
                                      value: index,
                                      child: Text(
                                        '${widget.targets[index].orderId} · ${widget.targets[index].variant.label}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedTarget = value);
                                  }
                                },
                              )
                            else
                              Text(
                                'Đơn ${target.orderId} · Đã nhận hàng',
                                style: theme.textTheme.bodySmall,
                              ),
                            const SizedBox(height: 20),
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (var stars = 1; stars <= 5; stars++)
                                    IconButton(
                                      tooltip: 'Đánh giá $stars sao',
                                      isSelected: _rating == stars,
                                      onPressed: () => setState(() {
                                        _rating = stars;
                                        _ratingError = null;
                                      }),
                                      icon: Icon(
                                        _rating >= stars
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        color: colors.tertiary,
                                        size: 34,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Center(
                              child: Text(
                                labels[_rating],
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: _rating == 0
                                      ? colors.onSurfaceVariant
                                      : colors.primary,
                                ),
                              ),
                            ),
                            if (_ratingError != null) ...[
                              const SizedBox(height: 6),
                              Center(
                                child: Text(
                                  _ratingError!,
                                  style: TextStyle(color: colors.error),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            TextFormField(
                              key: const ValueKey('review-comment-input'),
                              controller: _commentController,
                              minLines: 4,
                              maxLines: 6,
                              maxLength: 1000,
                              textCapitalization: TextCapitalization.sentences,
                              keyboardType: TextInputType.multiline,
                              decoration: const InputDecoration(
                                labelText: 'Nhận xét của bạn',
                                alignLabelWithHint: true,
                                hintText: 'Chia sẻ trải nghiệm về chất lượng, thiết kế và cách sử dụng...',
                              ),
                              validator: (value) =>
                                  (value?.trim().length ?? 0) < 10
                                  ? 'Vui lòng viết ít nhất 10 ký tự.'
                                  : null,
                            ),
                            Text(
                              'Đánh giá của bạn được lưu trong phiên trải nghiệm này.',
                              style: theme.textTheme.bodySmall,
                            ),
                            if (_submissionError != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _submissionError!,
                                style: TextStyle(color: colors.error),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const ValueKey('submit-product-review'),
                      onPressed: saving ? null : _submit,
                      child: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Gửi đánh giá'),
                    ),
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

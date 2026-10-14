import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/features/cart/domain/cart_line.dart';
import 'package:shopingdemo/features/catalog/domain/product.dart';
import 'package:shopingdemo/features/orders/domain/demo_order.dart';
import 'package:shopingdemo/features/orders/presentation/providers/orders_provider.dart';
import 'package:shopingdemo/features/payment/domain/payment_types.dart';
import 'package:shopingdemo/features/reviews/data/datasources/mock_review_data_source.dart';
import 'package:shopingdemo/features/reviews/data/repositories/mock_review_repository.dart';
import 'package:shopingdemo/features/reviews/domain/product_review.dart';
import 'package:shopingdemo/features/reviews/presentation/providers/review_providers.dart';

void main() {
  const variant = ProductVariant(
    id: 'review-sku',
    label: 'Kem sữa',
    price: 99000,
    stock: 10,
  );
  const product = Product(
    id: 'review-product',
    name: 'Sản phẩm mẫu',
    description: 'Mô tả',
    shopId: 'shop',
    shopName: 'Shop',
    categoryId: 'tech',
    price: 99000,
    rating: 4.9,
    soldCount: 10,
    emoji: '🎧',
    variants: [variant],
  );
  const items = [CartLine(product: product, variant: variant, quantity: 1)];

  test('review summary counts every score and handles no reviews', () {
    final reviews = [
      for (final rating in [5, 5, 4, 1])
        ProductReview(
          id: '$rating',
          productId: 'p',
          author: 'Lan',
          rating: rating,
          comment: 'Nhận xét mẫu',
          createdAt: DateTime.utc(2026, 10, 14),
        ),
    ];
    final summary = ProductReviewSummary.fromReviews(reviews);
    expect(summary.count, 4);
    expect(summary.average, 3.75);
    expect(summary.countForStars(5), 2);
    expect(summary.countForStars(1), 1);
    expect(summary.countForStars(3), 0);
    final empty = ProductReviewSummary.fromReviews([]);
    expect(empty.count, 0);
    expect(empty.average, 0);
    expect(empty.starCounts, [0, 0, 0, 0, 0]);
  });

  test('repository validates scores and comments and prevents concurrent duplicates', () async {
    final repository = MockReviewRepository(MockReviewDataSource());
    Future<ProductReview> submit({
      int rating = 4,
      String comment = '  Sản phẩm dùng tốt, đúng mô tả.  ',
    }) => repository.addReview(
      productId: product.id,
      orderId: 'order',
      variantId: variant.id,
      variantLabel: variant.label,
      author: '  Lan  ',
      rating: rating,
      comment: comment,
    );

    for (final rating in [0, 6]) {
      await expectLater(
        submit(rating: rating),
        throwsA(isA<ReviewException>()),
      );
    }
    await expectLater(submit(comment: '    '), throwsA(isA<ReviewException>()));
    await expectLater(
      submit(comment: List.filled(1001, 'a').join()),
      throwsA(isA<ReviewException>()),
    );
    final first = submit(rating: 1);
    final duplicate = submit();
    await expectLater(duplicate, throwsA(isA<ReviewException>()));
    final review = await first;
    expect(review.rating, 1);
    expect(review.author, 'Lan');
    expect(review.comment, 'Sản phẩm dùng tốt, đúng mô tả.');
    expect(review.createdAt.isUtc, isTrue);
    expect(await repository.getReviews(product.id), hasLength(1));
    expect(await repository.getReviews('another-product'), isEmpty);
  });

  test('only completed order items can be reviewed and eligibility updates after submission', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final orders = container.read(ordersProvider.notifier);
    final order = orders.placeOrder(
      items: items,
      recipient: 'Nguyễn Lan',
      phone: '0900000000',
      address: 'Hà Nội',
    );
    await container.read(productReviewsProvider(product.id).future);
    expect(container.read(productReviewTargetsProvider(product.id)), isEmpty);
    final submitter = container.read(reviewSubmissionProvider.notifier);
    await expectLater(
      submitter.submit(
        orderId: order.id,
        variantId: variant.id,
        rating: 4,
        comment: 'Nhận xét đủ dài cho sản phẩm.',
      ),
      throwsA(isA<ReviewException>()),
    );

    orders.completeDemoOrder(order.id);
    expect(container.read(ordersProvider).single.stage, OrderStage.completed);
    expect(
      container.read(ordersProvider).single.paymentStatus,
      PaymentStatus.paid,
    );
    expect(
      container.read(productReviewTargetsProvider(product.id)),
      hasLength(1),
    );
    await expectLater(
      submitter.submit(
        orderId: order.id,
        variantId: 'another-sku',
        rating: 4,
        comment: 'Nhận xét đủ dài cho sản phẩm.',
      ),
      throwsA(isA<ReviewException>()),
    );

    final review = await submitter.submit(
      orderId: order.id,
      variantId: variant.id,
      rating: 2,
      comment: 'Sản phẩm chưa phù hợp nhu cầu của mình.',
    );
    expect(review.author, order.recipient);
    expect(review.productId, product.id);
    expect(review.orderId, order.id);
    expect(review.variantLabel, variant.label);
    await container.read(productReviewsProvider(product.id).future);
    expect(container.read(productReviewTargetsProvider(product.id)), isEmpty);
    expect(
      container.read(productReviewSummaryProvider(product.id))!.average,
      2,
    );
    await expectLater(
      submitter.submit(
        orderId: order.id,
        variantId: variant.id,
        rating: 5,
        comment: 'Muốn gửi thêm một đánh giá nữa.',
      ),
      throwsA(isA<ReviewException>()),
    );
    expect(
      await container.read(productReviewsProvider(product.id).future),
      hasLength(1),
    );
  });

  test('unpaid online and canceled orders cannot be marked as received', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final orders = container.read(ordersProvider.notifier);
    final unpaid = orders.placeOrder(
      items: items,
      recipient: 'Lan',
      phone: '0900000000',
      address: 'Hà Nội',
      paymentMethod: PaymentMethod.vnpay,
    );
    final canceled = orders.placeOrder(
      items: items,
      recipient: 'Lan',
      phone: '0900000000',
      address: 'Hà Nội',
      status: 'Đã hủy',
    );
    expect(() => orders.completeDemoOrder(unpaid.id), throwsStateError);
    expect(() => orders.completeDemoOrder(canceled.id), throwsStateError);
    orders.updateOrderPaymentStatus(
      orderId: unpaid.id,
      paymentStatus: PaymentStatus.paid,
    );
    orders.completeDemoOrder(unpaid.id);
    expect(
      container
          .read(ordersProvider)
          .firstWhere((order) => order.id == unpaid.id)
          .stage,
      OrderStage.completed,
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/app/theme/app_theme.dart';
import 'package:shopingdemo/features/cart/domain/cart_line.dart';
import 'package:shopingdemo/features/catalog/presentation/product_detail_screen.dart';
import 'package:shopingdemo/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:shopingdemo/features/catalog/presentation/widgets/product_card.dart';
import 'package:shopingdemo/features/orders/presentation/orders_screen.dart';
import 'package:shopingdemo/features/orders/presentation/providers/orders_provider.dart';
import 'package:shopingdemo/features/reviews/data/datasources/mock_review_data_source.dart';
import 'package:shopingdemo/features/reviews/data/repositories/mock_review_repository.dart';
import 'package:shopingdemo/features/reviews/domain/product_review.dart';
import 'package:shopingdemo/features/reviews/domain/review_repository.dart';
import 'package:shopingdemo/features/reviews/presentation/product_reviews_screen.dart';
import 'package:shopingdemo/features/reviews/presentation/providers/review_providers.dart';

Future<void> settleReviews(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pumpAndSettle();
}

Future<void> pumpReviewPage(
  WidgetTester tester,
  ProviderContainer container,
  Widget page, {
  bool dark = false,
}) async {
  await tester.binding.setSurfaceSize(const Size(320, 720));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: page,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 600));
  await settleReviews(tester);
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'review preview, star filters, and Vietnamese search work on a narrow phone',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await pumpReviewPage(
        tester,
        container,
        const ProductDetailScreen(productId: 'earbuds'),
      );
      await tester.ensureVisible(find.text('Đánh giá sản phẩm'));
      await tester.pumpAndSettle();
      expect(find.text('3 đánh giá'), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(
              find.byKey(const ValueKey('write-product-review')),
            )
            .onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);

      await tapVisible(tester, find.text('Xem tất cả'));
      await settleReviews(tester);
      expect(find.byType(ProductReviewsScreen), findsOneWidget);
      expect(find.text('3 nhận xét'), findsOneWidget);
      final filterScroll = find.descendant(
        of: find.byKey(const ValueKey('review-star-filters')),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        find.text('4 sao (1)'),
        100,
        scrollable: filterScroll,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('4 sao (1)'));
      await tester.pumpAndSettle();
      expect(find.text('1 nhận xét'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'ket noi');
      await tester.pumpAndSettle();
      expect(find.text('Không có nhận xét phù hợp'), findsOneWidget);
      await tapVisible(tester, find.text('Xóa bộ lọc'));
      await tester.enterText(find.byType(TextField), 'KET NOI');
      await tester.pumpAndSettle();
      expect(find.text('1 nhận xét'), findsOneWidget);
      await tester.tap(find.byTooltip('Xóa tìm kiếm nhận xét'));
      await tester.pumpAndSettle();
      expect(find.text('3 nhận xét'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'completed purchase can submit a review and updates detail and card ratings',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final product = (await tester.runAsync(
        () => container.read(productByIdProvider('earbuds').future),
      ))!;
      final order = container
          .read(ordersProvider.notifier)
          .placeOrder(
            items: [
              CartLine(
                product: product,
                variant: product.variants.first,
                quantity: 1,
              ),
            ],
            recipient: 'Nguyễn Lan',
            phone: '0900000000',
            address: '12 Đường Mẫu, Hà Nội',
            status: 'Hoàn thành',
          );
      await pumpReviewPage(
        tester,
        container,
        const ProductDetailScreen(productId: 'earbuds'),
      );
      await tapVisible(
        tester,
        find.byKey(const ValueKey('write-product-review')),
      );
      final submit = find.byKey(const ValueKey('submit-product-review'));
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('Vui lòng chọn số sao.'), findsOneWidget);
      expect(find.text('Vui lòng viết ít nhất 10 ký tự.'), findsOneWidget);
      await tester.tap(find.byTooltip('Đánh giá 2 sao'));
      await tester.enterText(
        find.byKey(const ValueKey('review-comment-input')),
        'Âm thanh ổn nhưng chưa thật sự hợp nhu cầu của mình.',
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'review form with keyboard',
      );
      tester.view.resetViewInsets();
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await tester.pump();
      expect(
        tester.widget<FilledButton>(submit).onPressed,
        isNull,
        reason: 'disable duplicate sends',
      );
      await settleReviews(tester);
      expect(find.byKey(const ValueKey('submit-product-review')), findsNothing);
      expect(find.text('Đã gửi đánh giá của bạn'), findsOneWidget);
      expect(find.text('4 đánh giá'), findsOneWidget);
      expect(
        find.text('Âm thanh ổn nhưng chưa thật sự hợp nhu cầu của mình.'),
        findsOneWidget,
      );
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('review-average'))).data,
        '4.0',
      );
      expect(
        tester
            .widget<OutlinedButton>(
              find.byKey(const ValueKey('write-product-review')),
            )
            .onPressed,
        isNull,
      );
      final reviews = await container.read(
        productReviewsProvider(product.id).future,
      );
      expect(reviews.first.author, 'Nguyễn Lan');
      expect(reviews.first.orderId, order.id);
      expect(reviews.first.rating, 2);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SizedBox(
                width: 180,
                height: 300,
                child: ProductCard(product: product, onTap: () {}),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('4.0'),
        findsOneWidget,
        reason: 'card uses submitted reviews',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'load and submit failures can be retried without losing the comment',
    (tester) async {
      final repository = _FlakyReviewRepository();
      final container = ProviderContainer(
        overrides: [reviewRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final product = (await tester.runAsync(
        () => container.read(productByIdProvider('earbuds').future),
      ))!;
      container
          .read(ordersProvider.notifier)
          .placeOrder(
            items: [
              CartLine(
                product: product,
                variant: product.variants.first,
                quantity: 1,
              ),
            ],
            recipient: 'Lan',
            phone: '0900000000',
            address: 'Hà Nội',
            status: 'Hoàn thành',
          );
      await pumpReviewPage(
        tester,
        container,
        ProductReviewsScreen(product: product),
        dark: true,
      );
      expect(
        find.text('Không tải được đánh giá. Thử lại nhé.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Thử lại'));
      await settleReviews(tester);
      expect(find.text('Chưa có đánh giá nào'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('write-product-review')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Đánh giá 4 sao'));
      const comment = 'Dùng khá tiện, thiết kế nhỏ gọn và đẹp.';
      await tester.enterText(
        find.byKey(const ValueKey('review-comment-input')),
        comment,
      );
      await tester.tap(find.byKey(const ValueKey('submit-product-review')));
      await settleReviews(tester);
      expect(
        find.text('Chưa gửi được đánh giá. Vui lòng thử lại.'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const ValueKey('review-comment-input')),
            )
            .controller!
            .text,
        comment,
      );
      await tester.tap(find.byKey(const ValueKey('submit-product-review')));
      await settleReviews(tester);
      expect(find.text('1 nhận xét'), findsOneWidget);
      expect(
        (await container.read(productReviewsProvider(product.id).future))
            .single
            .comment,
        comment,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('demo received action enables reviewing directly from orders', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final product = (await tester.runAsync(
      () => container.read(productByIdProvider('earbuds').future),
    ))!;
    final order = container
        .read(ordersProvider.notifier)
        .placeOrder(
          items: [
            CartLine(
              product: product,
              variant: product.variants.first,
              quantity: 1,
            ),
          ],
          recipient: 'Minh',
          phone: '0900000000',
          address: 'Hà Nội',
        );
    await pumpReviewPage(tester, container, const OrdersScreen(), dark: true);
    await tester.tap(find.text(order.id));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Mô phỏng nhận hàng'));
    await settleReviews(tester);
    await tapVisible(tester, find.text('Đánh giá'));
    await tester.tap(find.byTooltip('Đánh giá 5 sao'));
    await tester.enterText(
      find.byKey(const ValueKey('review-comment-input')),
      'Thiết kế đẹp, dùng thuận tiện và phù hợp nhu cầu.',
    );
    await tester.tap(find.byKey(const ValueKey('submit-product-review')));
    await settleReviews(tester);
    expect(find.text('Đã đánh giá'), findsOneWidget);
    expect(
      (await container.read(productReviewsProvider(product.id).future))
          .first
          .orderId,
      order.id,
    );
    expect(tester.takeException(), isNull);
  });
}

class _FlakyReviewRepository implements ReviewRepository {
  final _repository = MockReviewRepository(MockReviewDataSource());
  bool _failLoad = true;
  bool _failSubmit = true;
  final List<ProductReview> _saved = [];

  @override
  Future<List<ProductReview>> getReviews(String productId) async {
    if (_failLoad) {
      _failLoad = false;
      throw Exception('Simulated loading failure');
    }
    return _saved.where((review) => review.productId == productId).toList();
  }

  @override
  Future<ProductReview> addReview({
    required String productId,
    required String orderId,
    required String variantId,
    required String variantLabel,
    required String author,
    required int rating,
    required String comment,
  }) async {
    if (_failSubmit) {
      _failSubmit = false;
      throw Exception('Simulated submission failure');
    }
    final review = await _repository.addReview(
      productId: productId,
      orderId: orderId,
      variantId: variantId,
      variantLabel: variantLabel,
      author: author,
      rating: rating,
      comment: comment,
    );
    _saved.insert(0, review);
    return review;
  }
}

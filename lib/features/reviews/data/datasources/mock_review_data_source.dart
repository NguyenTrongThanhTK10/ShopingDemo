import '../../domain/product_review.dart';
import '../dto/product_review_dto.dart';

/// Local sample reviews and session-only submissions, matching the demo orders.
class MockReviewDataSource {
  final Map<String, List<ProductReviewDto>> _reviews = {
    for (final entry in _sampleComments.entries)
      entry.key: [
        for (var index = 0; index < entry.value.length; index++)
          ProductReviewDto(
            id: 'SAMPLE-${entry.key}-$index',
            productId: entry.key,
            author: ['L***n', 'M***h', 'T***o'][index],
            rating: index == 2 ? 4 : 5,
            comment: entry.value[index],
            createdAt: DateTime.utc(2026, 10, 12 - index),
            isSample: true,
          ),
      ],
  };
  int _nextId = 1;

  Future<List<ProductReviewDto>> getReviews(String productId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List<ProductReviewDto>.unmodifiable(_reviews[productId] ?? []);
  }

  Future<ProductReviewDto> addReview({
    required String productId,
    required String orderId,
    required String variantId,
    required String variantLabel,
    required String author,
    required int rating,
    required String comment,
  }) async {
    if (rating < 1 || rating > 5) {
      throw const ReviewException('Vui lòng chọn từ 1 đến 5 sao.');
    }
    final text = comment.trim();
    if (text.length < 10 || text.length > 1000) {
      throw const ReviewException('Nhận xét cần từ 10 đến 1.000 ký tự.');
    }
    if (productId.isEmpty ||
        orderId.isEmpty ||
        variantId.isEmpty ||
        author.trim().isEmpty) {
      throw const ReviewException('Thông tin đơn hàng không hợp lệ.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final reviews = _reviews.putIfAbsent(productId, () => []);
    if (reviews.any(
      (review) => review.orderId == orderId && review.variantId == variantId,
    )) {
      throw const ReviewException(
        'Bạn đã đánh giá sản phẩm này trong đơn hàng.',
      );
    }
    final review = ProductReviewDto(
      id: 'REVIEW-${_nextId++}',
      productId: productId,
      orderId: orderId,
      variantId: variantId,
      variantLabel: variantLabel,
      author: author.trim(),
      rating: rating,
      comment: text,
      createdAt: DateTime.now().toUtc(),
    );
    reviews.insert(0, review);
    return review;
  }

  static const _sampleComments = <String, List<String>>{
    'earbuds': [
      'Tai nghe nhẹ, đeo thoải mái. Hộp sạc nhỏ gọn và kết nối khá nhanh.',
      'Màu kem đẹp, âm thanh rõ. Dùng nghe nhạc và gọi điện hằng ngày rất tiện.',
      'Thiết kế đẹp, dễ mang theo. Mình muốn có thêm vài cỡ nút tai để lựa chọn.',
    ],
    'linen-shirt': [
      'Vải nhẹ và thoáng, mặc thoải mái. Dáng áo rộng đúng kiểu mình thích.',
      'Màu trắng ngà dễ phối đồ, đường may gọn gàng.',
      'Áo đẹp, chất vải hơi nhăn nên cần là nhẹ trước khi mặc.',
    ],
    'serum': [
      'Kết cấu nhẹ và thấm khá nhanh. Chai nhỏ gọn, dễ sử dụng.',
      'Bao bì đẹp, đầu lấy serum tiện. Mình sẽ tiếp tục dùng để theo dõi thêm.',
      'Chai được đóng gói cẩn thận. Mình thích có thêm hướng dẫn sử dụng chi tiết.',
    ],
    'lamp': [
      'Ánh sáng ấm, đặt ở góc bàn rất xinh. Bật tắt tiện lợi.',
      'Kiểu dáng dễ thương, màu trắng kem hợp với phòng ngủ.',
      'Đèn đẹp và gọn, mình muốn dây điện dài hơn một chút.',
    ],
    'tumbler': [
      'Bình cầm vừa tay, nắp kín và dễ mang đi làm.',
      'Màu xanh đẹp, kích thước đủ dùng. Vệ sinh cũng thuận tiện.',
      'Bình chắc chắn, hơi nặng khi đổ đầy nhưng dùng vẫn tiện.',
    ],
    'sneakers': [
      'Giày đi khá êm, màu trắng dễ phối. Chọn đúng cỡ thường đi là vừa.',
      'Kiểu dáng gọn, đường may đẹp và đế chắc chắn.',
      'Giày đẹp, cần đi vài lần để chất vải mềm hơn.',
    ],
    'coffee': [
      'Hương thơm dễ chịu, pha phin hợp khẩu vị của mình.',
      'Túi có khóa kéo tiện bảo quản, hạt đều và thơm.',
      'Cà phê thơm, mình thích vị đậm hơn nên điều chỉnh lượng khi pha.',
    ],
    'backpack': [
      'Balo nhẹ, nhiều ngăn nhỏ tiện sắp xếp đồ khi đi làm.',
      'Màu be đẹp, quai đeo thoải mái. Kích thước đúng nhu cầu.',
      'Balo gọn và dễ dùng, ngăn chính sẽ hơi nhỏ nếu mang nhiều đồ.',
    ],
    'keyboard': [
      'Bàn phím gọn, gõ thoải mái. Phối màu đẹp trên bàn làm việc.',
      'Các phím chắc chắn và kết nối dễ, dùng hằng ngày rất tiện.',
      'Thiết kế đẹp, cần làm quen một chút với bố cục nhỏ gọn.',
    ],
    'plant': [
      'Chậu cây nhỏ xinh, đặt trên bàn giúp góc làm việc dễ chịu hơn.',
      'Màu chậu đẹp, đóng gói cẩn thận và dễ sắp xếp.',
      'Chậu gọn, mình muốn có thêm hướng dẫn chăm sóc cây.',
    ],
    'lip-tint': [
      'Màu hồng trà dễ dùng, chất son nhẹ và dễ dặm lại.',
      'Màu lên tự nhiên, đầu cọ nhỏ dễ thao tác.',
      'Màu đẹp, sau khi ăn uống mình cần dặm lại một chút.',
    ],
    'camera': [
      'Máy nhỏ gọn, chụp và in ảnh dễ dùng. Mang đi chơi khá tiện.',
      'Màu kem xinh, thao tác đơn giản và ảnh lưu kỷ niệm rất vui.',
      'Máy đẹp, cần thử vài lần để làm quen với ánh sáng khi chụp.',
    ],
  };
}

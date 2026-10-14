class DemoLiveSession {
  const DemoLiveSession({
    required this.id,
    required this.shopName,
    required this.title,
    required this.productIds,
    required this.talkingPoints,
  });

  final String id;
  final String shopName;
  final String title;
  final List<String> productIds;
  final List<String> talkingPoints;
}

const demoLiveSessions = <DemoLiveSession>[
  DemoLiveSession(
    id: 'melo-studio',
    shopName: 'Melo Studio',
    title: 'Góc công nghệ: nghe nhạc và làm việc',
    productIds: ['earbuds', 'keyboard', 'camera'],
    talkingPoints: [
      'Melo Studio: Cùng xem các món công nghệ nổi bật hôm nay.',
      'Melo Studio: Chạm sản phẩm để chọn màu và xem chi tiết nhé.',
    ],
  ),
  DemoLiveSession(
    id: 'mori-beauty',
    shopName: 'Mori Beauty',
    title: 'Chăm da và chọn màu son mỗi ngày',
    productIds: ['serum', 'lip-tint'],
    talkingPoints: [
      'Mori Beauty: Bắt đầu với serum cấp ẩm dịu nhẹ.',
      'Mori Beauty: Mở giỏ sản phẩm để xem thêm màu son.',
    ],
  ),
  DemoLiveSession(
    id: 'serein-wear',
    shopName: 'Serein Wear',
    title: 'Phối đồ đơn giản cho cuối tuần',
    productIds: ['linen-shirt', 'sneakers'],
    talkingPoints: [
      'Serein Wear: Thử phối áo linen cùng đôi giày yêu thích.',
      'Serein Wear: Chọn phân loại phù hợp trước khi thêm giỏ.',
    ],
  ),
];

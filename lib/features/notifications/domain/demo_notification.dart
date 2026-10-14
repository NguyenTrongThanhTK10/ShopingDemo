enum NotificationKind { order, offer, live, account }

enum NotificationTarget { orders, product, live, none }

class DemoNotification {
  const DemoNotification(
    this.id,
    this.kind,
    this.title,
    this.body,
    this.time,
    this.target, {
    this.productId,
    this.recent = false,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final String time;
  final NotificationTarget target;
  final String? productId;
  final bool recent;
}

const demoNotifications = <DemoNotification>[
  DemoNotification(
    'melo-live',
    NotificationKind.live,
    'Melo Studio đang live',
    'Xem shop giới thiệu tai nghe, bàn phím và máy ảnh trong phiên live mẫu.',
    'Vừa xong',
    NotificationTarget.live,
    recent: true,
  ),
  DemoNotification(
    'orders',
    NotificationKind.order,
    'Theo dõi đơn mua của bạn',
    'Xem trạng thái các đơn hàng mẫu và hành trình giao hàng.',
    '2 giờ trước',
    NotificationTarget.orders,
    recent: true,
  ),
  DemoNotification(
    'earbuds',
    NotificationKind.offer,
    'Gợi ý hôm nay: Melo Air',
    'Khám phá tai nghe không dây đang được nhiều người quan tâm.',
    '5 giờ trước',
    NotificationTarget.product,
    productId: 'earbuds',
    recent: true,
  ),
  DemoNotification(
    'mori-live',
    NotificationKind.live,
    'Góc làm đẹp cùng Mori Beauty',
    'Xem phiên live mẫu về serum cấp ẩm và cách chọn màu son.',
    'Hôm qua',
    NotificationTarget.live,
  ),
  DemoNotification(
    'serum',
    NotificationKind.offer,
    'Sản phẩm dành cho bạn',
    'Thử xem serum cấp ẩm dịu nhẹ từ gian hàng Mori Beauty.',
    '2 ngày trước',
    NotificationTarget.product,
    productId: 'serum',
  ),
  DemoNotification(
    'welcome',
    NotificationKind.account,
    'Chào mừng đến Lumi Market',
    'Khám phá sản phẩm, trò chuyện với shop và thử mua sắm trong ứng dụng.',
    '3 ngày trước',
    NotificationTarget.none,
  ),
];

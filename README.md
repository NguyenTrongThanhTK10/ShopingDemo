# TÀI LIỆU ĐẶC TẢ XÂY DỰNG ỨNG DỤNG THƯƠNG MẠI ĐIỆN TỬ

## Bản Flutter demo hiện có

Ứng dụng người mua **Lumi Market** hiện dùng dữ liệu mẫu trong bộ nhớ để trình diễn luồng: Trang chủ → Danh mục/Tìm kiếm → Chi tiết sản phẩm → Giỏ hàng → Đặt hàng mô phỏng → Đơn mua → Đánh giá. Có năm tab chính; tab **Live & Video** dành cho nội dung của shop, còn Đơn mua mở từ trang **Tôi**. Giỏ hàng mở từ icon ở đầu trang chủ. Ứng dụng hỗ trợ giao diện sáng/tối và quản lý trạng thái bằng Riverpod. Dữ liệu giỏ hàng, đơn hàng và đánh giá mới sẽ được đặt lại khi đóng ứng dụng.

**Icon ứng dụng:** nền cam Lumi Market với túi mua sắm trắng và chữ L. Bộ icon Android (gồm adaptive icon), iOS, macOS, web và Windows được tạo bằng `swift tool/generate_app_icons.swift` từ cùng một bản vẽ để giữ kích thước nhất quán.

**Live & Video:** mục Live có ba phiên quảng bá sản phẩm mô phỏng theo shop. Ảnh sản phẩm tự chuyển, có bình luận cục bộ, danh sách sản phẩm gắn trong phiên và luồng thêm vào giỏ bằng màn chọn phân loại hiện có. Mục Video vẫn hiển thị trạng thái chờ cùng gợi ý sản phẩm. Đây là bản mô phỏng bằng ảnh, chưa có luồng phát trực tiếp hoặc tệp video; cần nguồn nội dung và trình phát khi kết nối backend.

**Thông báo:** tab Thông báo hiển thị sáu tin mẫu về đơn mua, gợi ý sản phẩm, live và tài khoản. Badge trên thanh điều hướng hiển thị số tin chưa đọc và biến mất khi đọc hết. Có thể lọc theo loại, mở màn liên quan và đánh dấu đã đọc; trạng thái chỉ giữ trong phiên sử dụng. Các mốc thời gian là nhãn minh họa, chưa có thông báo đẩy hoặc dữ liệu từ máy chủ.

**Thẻ sản phẩm Trang chủ:** thẻ nhỏ hiển thị tối đa hai dòng tên, nơi gửi hàng và khoảng thời gian giao dự kiến. Địa điểm và thời gian là dữ liệu mẫu, chưa tính theo địa chỉ nhận hàng.

**Chat với shop:** icon chat cạnh giỏ hàng ở Trang chủ mở trang **Lịch sử chat**, liệt kê các shop đã có tin nhắn theo thứ tự mới nhất. Có thể mở cùng trang từ **Tôi → Chat với shop**; mở hội thoại trực tiếp từ thông tin shop ở chi tiết sản phẩm hoặc giỏ hàng. Người mua có thể soạn và xem tin nhắn của mình cùng sản phẩm đang hỏi. Đây là chat mẫu trong bộ nhớ: tin nhắn chưa gửi tới người bán và sẽ mất khi đóng ứng dụng. Cần dịch vụ nhắn tin, xác thực người dùng và kênh dành cho người bán để chat hoạt động thật.

**Tài khoản và cài đặt mua hàng:** trang **Tôi** có lối tắt theo trạng thái đơn, đánh giá, chat và thông báo. Trong **Địa chỉ nhận hàng**, người mua có thể lưu một bộ thông tin giao hàng mặc định; trong **Cài đặt thanh toán**, có thể chọn COD, VietQR hoặc VNPAY làm phương thức ưu tiên. Cả hai được điền sẵn ở Checkout và vẫn có thể sửa cho từng đơn. Đây là dữ liệu mẫu chỉ giữ trong phiên, không lưu thẻ hay tài khoản ngân hàng.

**Chi tiết tài khoản:** chạm avatar hoặc tên ở header trang **Tôi** để xem tài khoản. Khách chưa có tài khoản có thể điền tên và số điện thoại để đăng ký tài khoản mẫu; sau đó có thể sửa thông tin hoặc trở về trạng thái khách. Dữ liệu chỉ giữ trong phiên, chưa xác thực số điện thoại và chưa tạo tài khoản trên máy chủ.

**Đánh giá sản phẩm:** trang chi tiết hiển thị điểm trung bình, phân bố sao và nhận xét; màn hình xem tất cả hỗ trợ lọc 1–5 sao và tìm nội dung không dấu. Các nhận xét minh họa có nhãn “Mẫu”. Để thử viết đánh giá: đặt đơn COD (hoặc hoàn tất thanh toán mô phỏng), mở chi tiết đơn trong Đơn mua → **Mô phỏng nhận hàng** → **Đánh giá**. Mỗi phân loại trong một đơn đã hoàn thành được đánh giá một lần; nội dung cần 10–1.000 ký tự và 1–5 sao. Điểm sao trên thẻ sản phẩm, trang chi tiết và sắp xếp “Đánh giá tốt” được cập nhật theo các đánh giá hiện có. `filterProducts` có thêm tham số tùy chọn `ratingOverrides` để dùng điểm hiện tại; lời gọi cũ giữ cách sắp xếp theo `Product.rating`.

Tính năng dùng `ReviewRepository` và dữ liệu trong phiên; khi kết nối backend cần xác thực tài khoản, quyền đánh giá theo order item, chống gửi trùng và kiểm duyệt ở server. Ảnh đánh giá và báo cáo vi phạm chưa có trong bản demo.

**Gợi ý tìm kiếm:** khi gõ trong Khám phá sản phẩm, danh sách gợi ý hiện bên dưới ô tìm kiếm theo tên sản phẩm/cửa hàng trong danh mục đang chọn. Hỗ trợ từ khóa không dấu, ưu tiên tên bắt đầu bằng từ khóa, tối đa 6 gợi ý và loại bỏ tên trùng. Chạm gợi ý để điền từ khóa và xem kết quả; bấm Tìm kiếm trên bàn phím giữ nguyên từ khóa đang gõ. Gợi ý dùng dữ liệu catalog mẫu hiện có.

**Tìm kiếm bằng giọng nói:** icon micro nằm bên phải bên trong ô tìm kiếm ở Trang chủ và Khám phá sản phẩm. Bấm micro, nói tên sản phẩm bằng tiếng Việt, kiểm tra câu nhận được rồi bấm **Tìm kiếm**. Có thể Dừng nghe/Nói lại; hủy bảng nghe giữ nguyên từ khóa trước đó. Phiên nghe kết thúc khi đóng bảng hoặc đưa ứng dụng xuống nền. Quyền micro/nhận dạng chỉ được yêu cầu khi bấm micro; lỗi quyền, không nghe rõ, mạng hoặc ngôn ngữ không được hỗ trợ có thông báo và cho thử lại.

Tính năng dùng [speech_to_text 7.5.0](https://pub.dev/packages/speech_to_text), tương thích với Flutter từ 3.44.0; không thay đổi phiên bản các dependency hiện có. Android có quyền `RECORD_AUDIO`, `INTERNET` và khai báo truy vấn `RecognitionService`; iOS/macOS có mô tả quyền micro và nhận dạng, macOS thêm sandbox audio input/network client. Cần chạy lại `flutter run` sau khi thêm plugin native và cấp quyền khi được hỏi. Khả năng nhận tiếng Việt và yêu cầu kết nối mạng phụ thuộc dịch vụ nhận dạng trên thiết bị; widget test dùng dịch vụ giả lập, cần thử nói trên thiết bị thật để kiểm tra chất lượng nhận dạng.

```bash
flutter pub get
flutter run
dart format lib test
flutter analyze
flutter test
```

**Giới hạn hiện tại:** chưa kết nối API, đăng nhập, địa chỉ lưu trữ, tồn kho thực, phí vận chuyển, voucher hoặc thanh toán thật. Nút đặt hàng chỉ tạo đơn thử nghiệm trên thiết bị; không gửi đơn tới người bán. Khi có backend, thay `MockCatalogDataSource`/repository và trạng thái giỏ hàng, đơn hàng cục bộ bằng các API theo mục 7; giá và tồn kho phải được server xác thực ở checkout. Quy tắc kinh doanh còn chưa chốt ở mục 15 là TODO trước khi chạy production.

> Phiên bản: 1.0 | Ngày: 2026-10-13  
> Nền tảng: Flutter (Android/iOS), Riverpod, ASP.NET Core Web API, SQL Server, Vue 3 + PrimeVue  
> Mục tiêu: Xây dựng marketplace đa người bán với trải nghiệm mua sắm tương đương các sàn thương mại điện tử lớn. Không sao chép logo, thương hiệu, hình ảnh hoặc mã nguồn độc quyền của Shopee.

## 1. Mục tiêu và phạm vi

Xây dựng hệ thống gồm **ứng dụng khách mua hàng**, **kênh người bán**, **trang quản trị**, **backend API** và các dịch vụ thanh toán, vận chuyển, thông báo. Giai đoạn đầu tập trung vào MVP có thể vận hành: đăng ký/đăng nhập, duyệt/tìm sản phẩm, giỏ hàng, checkout, COD, quản lý đơn, quản lý shop/sản phẩm.

### 1.1 Vai trò
- **Khách vãng lai:** xem, tìm, lọc sản phẩm; cần đăng nhập khi đặt hàng.
- **Người mua:** hồ sơ, địa chỉ, giỏ hàng, đặt hàng, thanh toán, theo dõi, đánh giá, khiếu nại.
- **Người bán:** tạo shop, quản lý SKU/tồn kho, xử lý đơn, voucher, chat, báo cáo.
- **Quản trị viên:** kiểm duyệt, phân quyền, cấu hình, xử lý tranh chấp, đối soát.
- **Hệ thống/đối tác:** cổng thanh toán, vận chuyển, push, lưu trữ.

### 1.2 MVP và các giai đoạn
| Giai đoạn | Phạm vi | Tiêu chí hoàn thành |
|---|---|---|
| M1 - Nền tảng | Auth, UI kit, home, category, listing, detail, search | Điều hướng, tải API, trạng thái loading/error/empty ổn định |
| M2 - Mua hàng | Cart, địa chỉ, phí ship ước tính, voucher cơ bản, COD, orders | Đặt hàng thành công, chống đặt trùng, tồn kho nhất quán |
| M3 - Người bán | Shop, catalog, biến thể, tồn kho, xử lý đơn, admin moderation | Seller xử lý được đơn đầu-cuối |
| M4 - Tích hợp | VNPay/MoMo, chat SignalR, FCM, đơn vị vận chuyển | Callback xác thực, trạng thái đồng bộ, retry an toàn |
| M5 - Mở rộng | Flash sale, recommendation, livestream (tùy chọn), ví/đối soát | Đo lường, tải cao, vận hành và kiểm soát rủi ro |

**Ngoài MVP:** livestream, ví nội bộ, trả góp, gợi ý ML, affiliate, quốc tế hóa đa tiền tệ; chỉ triển khai khi có yêu cầu nghiệp vụ và pháp lý rõ ràng.

## 2. Quy chuẩn UX/UI

### 2.1 Điều hướng chính
Bottom navigation: **Trang chủ / Danh mục / Live & Video / Thông báo / Tôi**. Giỏ hàng mở từ icon ở đầu trang chủ; Đơn mua mở từ trang Tôi. Đơn mua có các tab Tất cả, Chờ thanh toán, Chờ xác nhận, Chờ lấy hàng, Đang giao, Hoàn thành, Đã hủy. Có thể đặt tab Chat riêng nếu nghiên cứu UX xác nhận. Luồng chính: Trang chủ → Danh sách/Tìm kiếm → Chi tiết sản phẩm → Chọn biến thể → Giỏ hàng hoặc Mua ngay → Checkout → Xác nhận đơn → Theo dõi.

### 2.2 Danh sách màn hình
| Module | Màn hình |
|---|---|
| Auth | Splash, onboarding tùy chọn, login, register, OTP, quên mật khẩu |
| Home | Home, banner, flash sale, đề xuất, danh mục |
| Catalog | Category, search, search suggestion/history, filter, sort, listing |
| Product | Detail, gallery, variants, reviews, shop profile, wishlist |
| Cart | Cart, select items, voucher, quantity, out-of-stock handling |
| Checkout | Addresses, shipping option, payment method, order review, success/failure |
| Order | Order tabs, detail, tracking, cancel, return/refund request |
| Chat | Conversation list, conversation, attachment, product card |
| Account | Profile, addresses, saved products, notifications, settings, support |
| Seller/Admin | Dashboard, products, inventory, orders, promotions, moderation, reports |

### 2.3 Thiết kế giao diện
- Thiết kế **riêng** với hệ màu thương hiệu tùy biến; dùng `ColorScheme` và design tokens thay vì hardcode màu.
- Khoảng cách theo hệ 4/8; typography có cấp bậc; bo góc, elevation nhất quán.
- Responsive cho nhiều kích thước; hỗ trợ safe area, bàn phím, text scaling, dark mode (nếu có).
- Ảnh sản phẩm theo tỷ lệ nhất quán, lazy load, cache, placeholder; tránh tải ảnh gốc quá lớn.
- Mọi màn hình dữ liệu phải có loading/skeleton, empty, error/retry, offline và pagination khi phù hợp.
- Accessibility: semantic labels, contrast, kích thước vùng chạm, hỗ trợ screen reader.
- Hiển thị tiền VND theo locale `vi_VN`; server lưu giá trị chính xác bằng `decimal`, không dùng `double` để tính tiền.

## 3. Kiến trúc tổng thể

```text
Flutter Buyer App ─┐
Flutter Seller App ├── HTTPS ── ASP.NET Core API ── SQL Server
Vue Admin Web ─────┘                 │
                                    ├── Redis (cache/rate-limit, khi cần)
                                    ├── Object Storage + CDN
                                    ├── SignalR (chat/event realtime)
                                    ├── Queue/Background Jobs
                                    ├── Payment Gateways (VNPay/MoMo)
                                    ├── Shipping Providers
                                    └── Firebase Cloud Messaging
```

**Khuyến nghị:** bắt đầu bằng **modular monolith** ASP.NET Core; tách dịch vụ chỉ khi tải, ranh giới dữ liệu và vận hành chứng minh nhu cầu. Không để ứng dụng Flutter truy cập SQL Server trực tiếp.

### 3.1 Backend modules
Identity, Users, Shops, Catalog, Inventory, Pricing, Promotions, Cart, Checkout, Orders, Payments, Shipping, Reviews, Chat, Notifications, Returns, Admin, Reporting, Audit.

### 3.2 Nguyên tắc kỹ thuật
- API versioning (`/api/v1`), DTO rõ ràng, validation ở server, mã lỗi chuẩn hóa.
- JWT access token ngắn hạn + refresh token rotation/revocation; RBAC/permission theo tài nguyên shop.
- Ghi log có correlation ID, không ghi token/OTP/thông tin thẻ.
- Transaction cho tạo đơn và giữ tồn kho; idempotency key cho checkout và webhook.
- Background jobs xử lý retry/outbox; webhook có xác thực chữ ký và chống replay.
- Tất cả thời điểm lưu UTC; hiển thị theo múi giờ người dùng.

## 4. Kiến trúc Flutter + Riverpod

### 4.1 Cấu trúc thư mục
```text
lib/
├── main.dart
├── bootstrap.dart
├── app/
│   ├── app.dart
│   ├── router/app_router.dart
│   └── theme/{app_theme.dart,design_tokens.dart}
├── core/
│   ├── config/{env.dart,app_config.dart}
│   ├── network/{dio_provider.dart,auth_interceptor.dart,api_error.dart}
│   ├── storage/{secure_storage.dart,local_database.dart}
│   ├── auth/session_provider.dart
│   ├── widgets/{app_scaffold.dart,async_state_view.dart,product_card.dart}
│   ├── utils/{money_formatter.dart,debouncer.dart}
│   └── errors/{app_exception.dart,failure.dart}
├── features/
│   ├── auth/
│   ├── home/
│   ├── categories/
│   ├── search/
│   ├── products/
│   ├── shops/
│   ├── cart/
│   ├── checkout/
│   ├── orders/
│   ├── payments/
│   ├── vouchers/
│   ├── reviews/
│   ├── wishlist/
│   ├── chat/
│   ├── notifications/
│   └── profile/
└── l10n/
```

Mỗi feature:
```text
features/products/
├── domain/
│   ├── entities/product.dart
│   ├── repositories/product_repository.dart
│   └── usecases/get_product_detail.dart
├── data/
│   ├── dto/product_dto.dart
│   ├── datasources/product_remote_data_source.dart
│   └── repositories/product_repository_impl.dart
└── presentation/
    ├── providers/{product_detail_provider.dart,product_list_provider.dart}
    ├── screens/{product_detail_screen.dart,product_list_screen.dart}
    └── widgets/{product_gallery.dart,variant_selector.dart}
```

### 4.2 Riverpod conventions
- Dùng `Provider` cho dependency bất biến, `FutureProvider` cho read-only fetch, `AsyncNotifier`/`Notifier` cho trạng thái có thao tác.
- Dùng `family` cho product ID, filter, pagination key; `autoDispose` cho state theo màn hình khi phù hợp.
- Không gọi HTTP trong Widget; Widget chỉ `watch` state và `read` notifier để phát lệnh.
- Mutation phải xử lý loading, lỗi, refresh/invalidate đúng phạm vi; không cập nhật giá cuối cùng chỉ ở client.
- Tránh `ref.watch` trong callback; phân biệt `watch`, `read`, `listen`.
- Tách domain entity và DTO; không để JSON mapping trong UI.
- Generated providers dùng `riverpod_generator` nếu dự án thống nhất codegen; kiểm soát version tương thích.

### 4.3 Dependency khuyến nghị
`flutter_riverpod`, `riverpod_annotation` (tùy chọn), `go_router`, `dio`, `freezed_annotation`, `json_annotation`, `flutter_secure_storage`, `cached_network_image`, `intl`, `connectivity_plus`, `firebase_core`, `firebase_messaging`; dev: `flutter_lints`, `build_runner`, `freezed`, `json_serializable`, `riverpod_generator` nếu dùng codegen, `mocktail`.

**Không khóa số phiên bản trong tài liệu:** chọn các bản tương thích với Flutter/Dart/AGP/Kotlin của dự án và kiểm tra `flutter pub outdated` trước khi chốt. Đặc biệt không nâng đồng loạt plugin Android/iOS khi chưa xác nhận tương thích build.

### 4.4 Router và session
- Routes typed/named: `/`, `/search`, `/product/:id`, `/cart`, `/checkout`, `/orders`, `/orders/:id`, `/chat/:id`, `/account`, `/login`.
- Redirect auth chỉ cho thao tác cần đăng nhập; giữ `returnTo` an toàn sau login.
- Refresh token được lưu trong secure storage; không lưu mật khẩu hoặc payment secrets trong app.
- Dùng một cơ chế refresh token tuần tự để tránh nhiều request đồng thời cùng refresh.

## 5. Đặc tả nghiệp vụ chi tiết

### 5.1 Sản phẩm và SKU
Product có `id`, `shopId`, `name`, `slug`, `description`, `categoryId`, `status`, `images`, `attributes`, `createdAt`. SKU có `id`, `productId`, `skuCode`, `options` (màu/size), `price`, `stockAvailable`, `stockReserved`, `weight`, `status`. Một sản phẩm có nhiều SKU; mọi cart/order item phải tham chiếu SKU cụ thể. Lưu snapshot tên, giá, biến thể và shop trong order item để lịch sử không bị thay đổi khi người bán sửa sản phẩm.

### 5.2 Giỏ hàng
- Giỏ theo user, nhóm theo shop; chọn/bỏ chọn item và shop.
- Quantity hợp lệ từ 1 đến hạn mức cho phép; backend kiểm tra SKU, giá, khuyến mãi và tồn kho khi checkout.
- Nếu sản phẩm ngừng bán/hết hàng, thông báo và cho sửa giỏ.
- Giỏ khách chưa đăng nhập có thể lưu cục bộ; merge sau đăng nhập có quy tắc rõ ràng.

### 5.3 Checkout đa shop
1. Client gửi SKU/quantity được chọn, address ID, voucher, shipping selection.
2. Server xác minh quyền mua, trạng thái sản phẩm, địa chỉ, tồn kho và khuyến mãi.
3. Server tính lại subtotal, discount, shipping, total; trả checkout preview có thời hạn.
4. Client xác nhận; gửi `Idempotency-Key`.
5. Server tạo **parent order** và **sub-order theo shop** trong transaction, giữ tồn kho, lưu giá snapshot.
6. COD: chuyển sang chờ shop xác nhận. Online: tạo payment intent/order; chờ callback xác thực.
7. Khi thanh toán thành công, cập nhật đơn theo state machine; thất bại/hết hạn thì giải phóng giữ tồn kho theo chính sách.

Không tin tổng tiền do client gửi. Quy tắc phân bổ voucher, phí ship, thuế và hoàn tiền phải được thống nhất theo từng sub-order.

### 5.4 Trạng thái đơn hàng
```text
PendingPayment -> Paid -> Confirmed -> Packing -> Shipped -> Delivered -> Completed
       |            |          |
       v            v          v
    Cancelled    Cancelled   CancelRequested

Delivered -> ReturnRequested -> ReturnApproved/ReturnRejected -> Refunded (nếu duyệt)
```

COD có thể đi từ `PendingConfirmation` tới `Confirmed` mà không qua `Paid`; việc thu tiền khi giao phải được đối soát. Các chuyển trạng thái do server kiểm tra role, thời hạn và trạng thái hiện tại. Không tự động hoàn tiền chỉ bằng cách đổi enum.

### 5.5 Thanh toán
- COD cho MVP; thanh toán online triển khai qua API nhà cung cấp chính thức.
- Tạo giao dịch với `paymentReference`, amount, currency, expiry, trạng thái.
- Xác thực webhook signature, amount, merchant/order ID; xử lý lặp idempotent.
- Chỉ backend xác nhận thành công, không tin redirect success trên mobile.
- Hỗ trợ đối soát, refund toàn phần/một phần, xử lý giao dịch pending.
- Không tự lưu PAN/CVV/thông tin thẻ; rà soát yêu cầu pháp lý và hợp đồng tích hợp.

### 5.6 Chat và notification
- Chat buyer ↔ seller theo conversation; SignalR để nhận/gửi realtime, REST để tải lịch sử.
- Message có ID, sender, type, body/attachment, sentAt, delivered/read state.
- Xác thực quyền vào conversation; rate limit, chặn spam và upload độc hại.
- FCM dùng cho thông báo khi offline; app phải lấy dữ liệu chuẩn từ API khi mở.
- Notification types: đơn hàng, thanh toán, vận chuyển, chat, khuyến mãi (opt-in phù hợp).

### 5.7 Đánh giá, hoàn trả và khiếu nại
- Chỉ buyer đã mua và đủ điều kiện mới được đánh giá.
- Review gắn order item; có rating, nội dung, ảnh; kiểm duyệt báo cáo vi phạm.
- Return/refund có lý do, bằng chứng, deadline, xử lý của shop/admin và lịch sử trạng thái.
- Thiết kế ledger/transaction records để truy vết hoàn tiền và đối soát.

## 6. Mô hình dữ liệu đề xuất

### 6.1 Bảng lõi
| Nhóm | Bảng |
|---|---|
| Identity | Users, Roles, UserRoles, RefreshTokens, UserAddresses |
| Seller | Shops, ShopMembers, ShopPolicies |
| Catalog | Categories, Products, ProductImages, ProductAttributes, ProductVariants, SKUs |
| Inventory | StockBalances, StockReservations, InventoryMovements |
| Shopping | Carts, CartItems, Wishlists |
| Promotions | Vouchers, VoucherRedemptions, Campaigns |
| Orders | Orders, ShopOrders, OrderItems, OrderStatusHistories |
| Payment | Payments, PaymentEvents, Refunds, ReconciliationRecords |
| Logistics | Shipments, ShipmentTrackingEvents |
| Social | Reviews, ReviewImages, Conversations, Messages |
| Ops | Notifications, Returns, Disputes, AuditLogs, OutboxEvents |

### 6.2 Ràng buộc quan trọng
- `Users.email/phone` unique theo chính sách chuẩn hóa; không giả định phone luôn có.
- `SKUs.skuCode` unique trong shop hoặc toàn hệ thống tùy quy tắc.
- `CartItems(cartId, skuId)` unique.
- `Payments.providerTransactionId` unique khi tồn tại; webhook event ID chống xử lý lặp.
- `StockBalances` có optimistic concurrency (`rowversion` trong SQL Server) hoặc locking hợp lệ.
- Giá/tiền: `decimal(18,2)` hoặc mô hình minor units nhất quán; với VND thường không có phần lẻ trong hiển thị.
- Soft delete ở các thực thể cần lịch sử; không xóa vật lý order/payment/audit.
- Chỉ mục cho product category/status, shop/status, search, order user/date, SKU, message conversation/date.

## 7. API REST đề xuất

Response thành công:
```json
{"data": {}, "meta": {"requestId": "..."}}
```
Response lỗi:
```json
{"error": {"code": "OUT_OF_STOCK", "message": "Sản phẩm không đủ tồn kho", "details": []}, "requestId": "..."}
```

| Method | Endpoint | Mục đích |
|---|---|---|
| POST | `/api/v1/auth/register` | Đăng ký |
| POST | `/api/v1/auth/login` | Đăng nhập |
| POST | `/api/v1/auth/refresh` | Refresh token |
| GET | `/api/v1/home` | Dữ liệu trang chủ |
| GET | `/api/v1/categories` | Danh mục |
| GET | `/api/v1/products` | Tìm kiếm/lọc/phân trang |
| GET | `/api/v1/products/{id}` | Chi tiết sản phẩm |
| GET | `/api/v1/shops/{id}` | Shop profile |
| GET | `/api/v1/cart` | Giỏ hàng |
| POST | `/api/v1/cart/items` | Thêm SKU |
| PATCH | `/api/v1/cart/items/{id}` | Sửa số lượng/chọn |
| DELETE | `/api/v1/cart/items/{id}` | Xóa item |
| POST | `/api/v1/checkout/preview` | Tính tiền và xác thực |
| POST | `/api/v1/orders` | Tạo đơn idempotent |
| GET | `/api/v1/orders` | Danh sách đơn |
| GET | `/api/v1/orders/{id}` | Chi tiết đơn |
| POST | `/api/v1/orders/{id}/cancel` | Yêu cầu hủy |
| POST | `/api/v1/payments/intents` | Khởi tạo thanh toán |
| POST | `/api/v1/payments/webhooks/{provider}` | Callback từ provider |
| GET | `/api/v1/conversations` | Danh sách chat |
| GET | `/api/v1/conversations/{id}/messages` | Lịch sử chat |
| POST | `/api/v1/reviews` | Tạo đánh giá |
| POST | `/api/v1/seller/products` | Seller tạo sản phẩm |
| PATCH | `/api/v1/seller/orders/{id}/status` | Seller xử lý đơn |

**Phân trang:** ưu tiên cursor cho feed/search lớn; quy định `limit`, `nextCursor`, thứ tự ổn định. Search cần chuẩn hóa tiếng Việt không dấu, gợi ý và chống lạm dụng.

### 7.1 Ví dụ checkout preview
```json
{
  "addressId": "addr_123",
  "items": [{"skuId": "sku_456", "quantity": 2}],
  "voucherCodes": ["WELCOME10"],
  "shippingSelections": [{"shopId": "shop_1", "serviceCode": "standard"}]
}
```

Server trả giá chi tiết theo shop và tổng đơn, kèm `previewToken` hoặc quote ID có thời hạn; client không được sửa giá trị này.

## 8. Bảo mật và tuân thủ
- HTTPS bắt buộc; không tắt kiểm tra TLS/certificate trong bản production.
- Chống IDOR: kiểm tra ownership của order, address, cart, chat và shop ở server.
- Chống brute force và abuse: rate limiting, lockout hợp lý, OTP expiry, CAPTCHA theo rủi ro.
- Upload: kiểm tra MIME thực, kích thước, scan malware, signed URL, private bucket.
- Secrets chỉ ở backend/secret manager; `.env` mobile không phải nơi lưu bí mật.
- Mã hóa dữ liệu nhạy cảm, backup có kiểm tra khôi phục, retention/deletion policy.
- Tuân thủ quy định thương mại điện tử, dữ liệu cá nhân, thuế, bảo vệ người tiêu dùng và chính sách App Store/Google Play áp dụng tại thị trường triển khai; cần rà soát pháp lý riêng.
- Không tự động đưa thông tin người mua sang shop khác hoặc analytics bên thứ ba ngoài mục đích được phép.

## 9. Hiệu năng, độ tin cậy và quan sát
- Product feed pagination, debounce search, CDN ảnh, thumbnail, lazy loading.
- Cache có TTL và invalidation; tồn kho/giá tại checkout luôn kiểm tra từ nguồn chuẩn.
- Timeout, retry có backoff cho GET/idempotent operations; không retry POST đặt hàng nếu không có idempotency key.
- Sử dụng tracing, metrics, structured logging, crash reporting; dashboard theo p95 latency, error rate, conversion, payment success, oversell.
- Thiết kế circuit breaker cho đối tác thanh toán/vận chuyển; queue + outbox cho sự kiện sau transaction.
- Định nghĩa SLO sau khi đo baseline thực tế, không cam kết con số tùy ý.

## 10. Kiểm thử và nghiệm thu

### 10.1 Test layers
- **Unit:** tính tổng tiền, voucher, state transitions, Riverpod notifier.
- **Widget:** product card, variant picker, cart, checkout, error/loading/empty.
- **Integration:** login → browse → cart → checkout → order; seller confirm → ship.
- **Backend:** concurrency tồn kho, webhook lặp/sai chữ ký, idempotency, phân quyền, rollback.
- **E2E:** Android/iOS thiết bị thật, mạng chậm/mất mạng, deep link, push, background/foreground.
- **Security:** OWASP API Top 10, dependency scan, secrets scan, upload abuse.

### 10.2 Acceptance criteria mẫu
1. Người mua chọn SKU hợp lệ, thêm vào giỏ, chỉnh số lượng, dữ liệu đồng bộ sau đăng nhập.
2. Checkout luôn tính lại giá/khuyến mãi/tồn kho trên server.
3. Hai request đặt hàng cùng `Idempotency-Key` không tạo hai đơn.
4. Hai người cùng mua SKU còn một sản phẩm không được bán vượt tồn kho.
5. Callback thanh toán trùng lặp không tạo nhiều lần ghi nhận tiền.
6. Người bán không truy cập hoặc chỉnh sửa đơn của shop khác.
7. UI hiển thị trạng thái loading/empty/error và cho retry an toàn.
8. Đơn hàng giữ lịch sử snapshot giá, biến thể, phí ship và discount.

## 11. CI/CD và môi trường
- Environments: local, dev, staging, production; base URL và feature flags tách biệt.
- CI: format, analyze, unit/widget tests, backend tests, dependency/security scan, build artifacts.
- Android: ký release bằng keystore được bảo vệ; iOS: signing/provisioning qua quy trình an toàn.
- Migration DB có version, backup và kế hoạch rollback; không chạy thay đổi phá dữ liệu tùy tiện.
- Theo dõi tương thích Flutter SDK, Dart, Android Gradle Plugin, Gradle, Kotlin và iOS/Xcode theo phiên bản dự án.

## 12. Quy tắc bắt buộc cho AI coding agent / Codex

1. **Đọc tài liệu này trước khi thay đổi kiến trúc.** Tuân thủ cấu trúc feature-first + Clean Architecture.
2. Không tạo `god class`, không đặt HTTP request trực tiếp trong widget, không nhét nghiệp vụ vào `build()`.
3. Không thay đổi public API, DB schema, dependency version hay naming conventions mà không mô tả ảnh hưởng.
4. Riverpod là state management chính; không trộn GetX/Bloc/Provider nếu không được yêu cầu.
5. Widget nhỏ, tái sử dụng được; design tokens và theme dùng thống nhất.
6. Mỗi tính năng phải có loading, error, empty, success; xử lý hủy request/dispose hợp lý.
7. Phân tách DTO, domain entity, repository interface, repository implementation, provider và screen.
8. Ưu tiên null safety, immutable state, typed models, không dùng `dynamic` bừa bãi.
9. Không lưu JWT/refresh token trong SharedPreferences dạng plaintext; dùng secure storage.
10. Không hardcode credentials, khóa thanh toán, private key hoặc URL production vào source.
11. Không bỏ qua TLS verification và không dùng `badCertificateCallback = true` ở production.
12. Không tin giá, tồn kho, quyền truy cập hoặc trạng thái thanh toán từ client.
13. Khi sinh code phải chỉ rõ file tạo/sửa, lệnh chạy và kiểm thử tương ứng.
14. Chỉ nâng package khi kiểm tra tương thích SDK, Gradle/AGP/Kotlin, iOS; tránh nâng hàng loạt vô kiểm soát.
15. Viết test cho nghiệp vụ tiền, tồn kho, checkout, auth, permission và webhook.
16. Không sao chép giao diện, logo, ảnh và tài sản sở hữu trí tuệ của Shopee; chỉ học hỏi pattern UX chung.
17. Khi yêu cầu chưa rõ, nêu giả định và đánh dấu `TODO` thay vì bịa API hoặc quy tắc nghiệp vụ.
18. Mọi thay đổi phải chạy tối thiểu `dart format`, `flutter analyze` và test liên quan (khi môi trường hỗ trợ).

## 13. Backlog theo epic

| Epic | User stories ưu tiên |
|---|---|
| E01 Identity | Đăng ký, login, refresh, logout, profile, addresses |
| E02 Discovery | Home, categories, search, filters, sort, pagination |
| E03 Catalog | Product detail, SKU selection, images, reviews, shop |
| E04 Cart | Add/update/remove, grouped shops, merge guest cart |
| E05 Checkout | Quote, voucher, shipping selection, COD, order placement |
| E06 Order | Order history, detail, tracking, cancellation |
| E07 Seller | Shop setup, catalog CRUD, stock, order fulfillment |
| E08 Admin | Moderation, roles, dispute, audit |
| E09 Payments | Provider integrations, webhook, refunds, reconciliation |
| E10 Messaging | SignalR chat, unread, attachments, push |
| E11 Logistics | Shipping provider, label/tracking, delivery status |
| E12 Quality | Accessibility, performance, CI/CD, monitoring, security |

## 14. Thứ tự thực hiện được khuyến nghị

**Sprint 0:** chốt business rules, sơ đồ dữ liệu, wireframe, thiết kế theme, tạo repo và CI.  
**Sprint 1:** Flutter shell, navigation, home/category/product listing với mock API.  
**Sprint 2:** Auth, product detail, search/filter, backend catalog.  
**Sprint 3:** Cart, addresses, checkout preview, COD, tạo đơn an toàn.  
**Sprint 4:** Seller quản lý sản phẩm/tồn kho/đơn; admin tối thiểu.  
**Sprint 5+:** payment online, logistics, chat, notification, return/refund, hardening.

Thời gian thực tế phụ thuộc quy mô nhóm, mức độ hoàn thiện UI, tích hợp bên thứ ba và kiểm thử; không coi sprint ở đây là cam kết thời lượng.

## 15. Các quyết định cần chốt trước khi code production

- Một app Flutter chỉ dành cho buyer hay seller cũng dùng chung app?
- Cho phép một tài khoản sở hữu nhiều shop không?
- Chính sách giữ tồn kho bao lâu trong lúc chờ thanh toán?
- Phân bổ voucher toàn sàn/voucher shop, phí ship, thuế và hoàn tiền ra sao?
- Đơn vị vận chuyển và đối tác thanh toán nào được ký hợp đồng?
- Quy trình xác minh người bán, hoa hồng sàn, đối soát và xuất hóa đơn?
- Có cho phép thanh toán đa shop trong một giao dịch không?
- SLA xử lý tranh chấp, đổi trả và kiểm duyệt nội dung?

---

**Definition of Done:** Code tuân thủ kiến trúc; có test liên quan; `flutter analyze` sạch lỗi; API có validation/authorization; logging và xử lý lỗi; UI đầy đủ các trạng thái; tài liệu cập nhật; đã kiểm thử ít nhất một luồng end-to-end trên staging.

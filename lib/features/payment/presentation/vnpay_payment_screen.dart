import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopingdemo/core/utils/money_formatter.dart';
import 'package:shopingdemo/features/orders/domain/demo_order.dart';
import 'package:shopingdemo/features/orders/presentation/order_success_screen.dart';
import 'package:shopingdemo/features/orders/presentation/providers/orders_provider.dart';

import '../domain/payment_types.dart';

class VnpayPaymentScreen extends ConsumerStatefulWidget {
  const VnpayPaymentScreen({super.key, required this.order});

  final DemoOrder order;

  @override
  ConsumerState<VnpayPaymentScreen> createState() => _VnpayPaymentScreenState();
}

class _VnpayPaymentScreenState extends ConsumerState<VnpayPaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form ATM
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _cardDateController = TextEditingController();
  String _selectedAtmBank = 'NCB';

  // State OTP
  bool _showOtpStep = false;
  final _otpController = TextEditingController(text: '123456');

  // Trạng thái xử lý
  bool _isProcessing = false;

  final List<Map<String, String>> _atmBanks = [
    {'code': 'NCB', 'name': 'NCB Bank (Test Sandbox)'},
    {'code': 'VCB', 'name': 'Vietcombank'},
    {'code': 'CTG', 'name': 'VietinBank'},
    {'code': 'BIDV', 'name': 'BIDV'},
    {'code': 'MB', 'name': 'MB Bank'},
    {'code': 'TCB', 'name': 'Techcombank'},
    {'code': 'VPB', 'name': 'VPBank'},
    {'code': 'ACB', 'name': 'ACB'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _cardDateController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _fillVnpayTestCard() {
    setState(() {
      _selectedAtmBank = 'NCB';
      _cardNumberController.text = '9704198526191432198';
      _cardHolderController.text = 'NGUYEN VAN A';
      _cardDateController.text = '07/15';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã điền thẻ test VNPAY Sandbox (Ngân hàng NCB)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _processSuccessPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Cập nhật trạng thái đơn hàng
    ref
        .read(ordersProvider.notifier)
        .updateOrderPaymentStatus(
          orderId: widget.order.id,
          paymentStatus: PaymentStatus.paid,
          orderStatus: 'Đã thanh toán qua VNPAY',
        );

    final updatedOrder = widget.order.copyWith(
      paymentStatus: PaymentStatus.paid,
      status: 'Đã thanh toán qua VNPAY',
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => OrderSuccessScreen(order: updatedOrder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const vnpayBlue = Color(0xFF005BAA);
    const vnpayRed = Color(0xFFED1C24);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: vnpayBlue,
        foregroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'VNPAY',
                style: TextStyle(
                  color: vnpayBlue,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Cổng thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(vnpayBlue),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Đang kết nối cổng VNPAY...',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vui lòng không tắt hoặc rời khỏi ứng dụng',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Banner thông tin đơn thanh toán
                Container(
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đơn hàng: ${widget.order.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Merchant: LUMI MARKET DEMO',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Số tiền',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            formatVnd(widget.order.total),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: vnpayRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tab Bar các phương thức VNPAY
                TabBar(
                  controller: _tabController,
                  labelColor: vnpayBlue,
                  unselectedLabelColor: Colors.black54,
                  indicatorColor: vnpayBlue,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(icon: Icon(Icons.qr_code_scanner), text: 'VNPAY-QR'),
                    Tab(icon: Icon(Icons.credit_card), text: 'Thẻ ATM'),
                    Tab(icon: Icon(Icons.credit_score), text: 'Quốc tế'),
                  ],
                ),

                // Nội dung các Tabs
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildQrTab(vnpayBlue),
                      _buildAtmTab(vnpayBlue),
                      _buildInternationalTab(vnpayBlue),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // TAB 1: VNPAY-QR
  Widget _buildQrTab(Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Image.network(
                  'https://img.vietqr.io/image/970422-0988889999-compact.png?amount=${widget.order.total}&addInfo=VNPAY%20${widget.order.id}',
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    width: 220,
                    height: 220,
                    child: Center(
                      child: Icon(Icons.qr_code_2_rounded, size: 100),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Quét mã với Ví VNPAY hoặc 30+ App Ngân hàng',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF005BAA)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mở ứng dụng Mobile Banking (Vietcombank, MB, BIDV, Agribank...) chọn tính năng QR Pay để quét.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF005BAA)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: _processSuccessPayment,
          style: FilledButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Mô phỏng: Đã quét & thanh toán thành công'),
        ),
      ],
    );
  }

  // TAB 2: Thẻ ATM & Tài khoản nội địa (Sandbox)
  Widget _buildAtmTab(Color primaryColor) {
    if (_showOtpStep) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, color: Colors.green),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Mã OTP giả lập sandbox đã được gửi tới số điện thoại đăng ký.',
                    style: TextStyle(fontSize: 13, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              letterSpacing: 8,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              labelText: 'Mã xác thực OTP (Mặc định: 123456)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _processSuccessPayment,
            style: FilledButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Xác nhận thanh toán'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => setState(() => _showOtpStep = false),
            child: const Text('Quay lại sửa thẻ'),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Nút điền nhanh thẻ test
        OutlinedButton.icon(
          onPressed: _fillVnpayTestCard,
          icon: const Icon(Icons.flash_on, color: Colors.amber),
          label: const Text('Điền nhanh thẻ test VNPAY Sandbox'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: _selectedAtmBank,
          decoration: const InputDecoration(
            labelText: 'Ngân hàng phát hành thẻ',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.account_balance),
          ),
          items: _atmBanks.map((bank) {
            return DropdownMenuItem<String>(
              value: bank['code'],
              child: Text('${bank['code']} - ${bank['name']}'),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedAtmBank = val);
          },
        ),
        const SizedBox(height: 14),

        TextField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Số thẻ ngân hàng',
            hintText: '9704...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.credit_card),
          ),
        ),
        const SizedBox(height: 14),

        TextField(
          controller: _cardHolderController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Tên in trên thẻ (không dấu)',
            hintText: 'NGUYEN VAN A',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 14),

        TextField(
          controller: _cardDateController,
          decoration: const InputDecoration(
            labelText: 'Ngày phát hành (MM/YY)',
            hintText: '07/15',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.calendar_today),
          ),
        ),
        const SizedBox(height: 24),

        FilledButton(
          onPressed: () {
            if (_cardNumberController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng nhập số thẻ.')),
              );
              return;
            }
            setState(() => _showOtpStep = true);
          },
          style: FilledButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Tiếp tục xác thực OTP'),
        ),
      ],
    );
  }

  // TAB 3: Thẻ quốc tế
  Widget _buildInternationalTab(Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card, size: 32, color: Colors.blue),
            SizedBox(width: 12),
            Text(
              'Visa · Mastercard · JCB · UnionPay',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Số thẻ tín dụng / ghi nợ',
            hintText: '4000 0000 0000 0000',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.credit_card),
          ),
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Hết hạn (MM/YY)',
                  hintText: '12/28',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'CVV / CVC',
                  hintText: '•••',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Tên chủ thẻ',
            hintText: 'NGUYEN VAN A',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _processSuccessPayment,
          style: FilledButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Thanh toán ngay'),
        ),
      ],
    );
  }
}

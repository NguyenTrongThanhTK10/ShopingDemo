class BankInfo {
  const BankInfo({
    required this.code,
    required this.name,
    required this.shortName,
    required this.bin,
  });

  final String code;
  final String name;
  final String shortName;
  final String bin;
}

class VietQrConfig {
  const VietQrConfig({
    this.bankCode = 'MB',
    this.bankName = 'MBBank (Ngân hàng Quân Đội)',
    this.accountNumber = '0988889999',
    this.accountHolder = 'LUMI MARKET SHOP',
    this.template = 'compact2',
  });

  final String bankCode;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final String template;

  /// Tạo đường dẫn ảnh mã QR theo chuẩn VietQR API công khai của Napas & VietQR
  String generateQrUrl({required int amount, required String orderId}) {
    final cleanOrderId = orderId.replaceAll('-', '');
    final description = Uri.encodeComponent('LUMI $cleanOrderId');
    final encodedHolder = Uri.encodeComponent(accountHolder);
    return 'https://img.vietqr.io/image/$bankCode-$accountNumber-$template.png'
        '?amount=$amount&addInfo=$description&accountName=$encodedHolder';
  }

  /// Cú pháp nội dung chuyển khoản chuẩn cho đơn hàng
  String transferContent(String orderId) {
    final cleanOrderId = orderId.replaceAll('-', '');
    return 'LUMI $cleanOrderId';
  }

  /// Danh sách các ngân hàng phổ biến tại Việt Nam
  static const List<BankInfo> popularBanks = [
    BankInfo(code: 'MB', shortName: 'MB Bank', name: 'Ngân hàng TMCP Quân Đội', bin: '970422'),
    BankInfo(code: 'VCB', shortName: 'Vietcombank', name: 'Ngân hàng Ngoại Thương Việt Nam', bin: '970436'),
    BankInfo(code: 'TCB', shortName: 'Techcombank', name: 'Ngân hàng Kỹ Thương Việt Nam', bin: '970407'),
    BankInfo(code: 'ICB', shortName: 'VietinBank', name: 'Ngân hàng Công Thương Việt Nam', bin: '970415'),
    BankInfo(code: 'BIDV', shortName: 'BIDV', name: 'Ngân hàng Đầu tư và Phát triển VN', bin: '970418'),
    BankInfo(code: 'ACB', shortName: 'ACB', name: 'Ngân hàng Á Châu', bin: '970416'),
    BankInfo(code: 'VPB', shortName: 'VPBank', name: 'Ngân hàng Việt Nam Thịnh Vượng', bin: '970432'),
    BankInfo(code: 'TPB', shortName: 'TPBank', name: 'Ngân hàng Tiên Phong', bin: '970423'),
  ];
}


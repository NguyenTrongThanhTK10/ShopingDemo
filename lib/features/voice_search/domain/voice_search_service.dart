enum VoiceSearchStatus { listening, stopped, done }

enum VoiceSearchFailure {
  unavailable(
    'Chưa dùng được tìm kiếm giọng nói. Kiểm tra quyền micro và nhận dạng giọng nói trong cài đặt thiết bị.',
  ),
  unsupported('Thiết bị này chưa hỗ trợ tìm kiếm bằng giọng nói.'),
  permissionDenied(
    'Cần cho phép micro và nhận dạng giọng nói trong cài đặt để dùng tính năng này.',
  ),
  noSpeech('Chưa nghe rõ. Bạn hãy nói lại tên sản phẩm.'),
  network('Không kết nối được dịch vụ giọng nói. Kiểm tra mạng rồi thử lại.'),
  language(
    'Thiết bị chưa hỗ trợ nhận giọng nói tiếng Việt. Bạn có thể nhập từ khóa.',
  ),
  busy('Micro đang bận. Bạn hãy thử lại sau ít giây.'),
  unknown('Không nhận được giọng nói. Bạn hãy thử lại hoặc nhập từ khóa.');

  const VoiceSearchFailure(this.message);

  final String message;
}

class VoiceSearchException implements Exception {
  const VoiceSearchException(this.failure);

  final VoiceSearchFailure failure;
}

abstract interface class VoiceSearchService {
  Future<void> start({
    required void Function(String words) onResult,
    required void Function(VoiceSearchStatus status) onStatus,
    required void Function(VoiceSearchFailure failure) onError,
  });

  Future<void> stop();

  Future<void> cancel();
}

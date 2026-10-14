import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/device_voice_search_service.dart';
import '../../domain/voice_search_service.dart';

final voiceSearchServiceProvider = Provider<VoiceSearchService>((ref) {
  final service = DeviceVoiceSearchService();
  ref.onDispose(() => unawaited(service.cancel()));
  return service;
});

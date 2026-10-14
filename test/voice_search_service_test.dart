import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:shopingdemo/features/voice_search/data/device_voice_search_service.dart';
import 'package:shopingdemo/features/voice_search/domain/voice_search_service.dart';

void main() {
  setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  Future<void> listen(
    DeviceVoiceSearchService service, {
    void Function(String)? result,
    void Function(VoiceSearchStatus)? status,
    void Function(VoiceSearchFailure)? error,
  }) => service.start(
    onResult: result ?? (_) {},
    onStatus: status ?? (_) {},
    onError: error ?? (_) {},
  );

  test(
    'Vietnamese locale is preferred even when the device defaults to English',
    () {
      expect(vietnameseSpeechLocale(['en_US', 'vi', 'vi_VN']), 'vi_VN');
      expect(vietnameseSpeechLocale(['en-US', 'vi-VN']), 'vi-VN');
      expect(vietnameseSpeechLocale(['vi']), 'vi');
      expect(vietnameseSpeechLocale(['en_US']), 'vi-VN');
    },
  );

  test(
    'recognizer initializes once and rebinds callbacks when reopening',
    () async {
      final speech = _FakeSpeech();
      final service = DeviceVoiceSearchService(speech: speech);
      addTearDown(service.cancel);
      final first = <String>[];
      final second = <String>[];
      await listen(service, result: first.add);
      final oldCallback = speech.resultListener!;
      speech.emit('tai nghe');
      await service.cancel();
      await listen(service, result: second.add);
      oldCallback(_result('late result'));
      speech.emit('cà phê');
      expect(first, ['tai nghe']);
      expect(second, ['cà phê']);
      expect(speech.initializations, 1);
      expect(speech.options!.localeId, 'vi_VN');
      expect(speech.options!.listenMode, ListenMode.search);
      expect(speech.options!.listenFor, const Duration(seconds: 30));
      expect(speech.config, contains(SpeechToText.androidNoBluetooth));
    },
  );

  test(
    'canceling pending initialization never starts the microphone later',
    () async {
      final gate = Completer<bool>();
      final speech = _FakeSpeech()..initializationGate = gate;
      final service = DeviceVoiceSearchService(speech: speech);
      final starting = listen(service);
      await Future<void>.delayed(Duration.zero);
      final canceling = service.cancel();
      gate.complete(true);
      await Future.wait([starting, canceling]);
      expect(speech.listenCalls, 0);
      expect(speech.isListening, isFalse);
      expect(speech.cancelCalls, greaterThan(0));
    },
  );

  test('a canceled startup cannot cancel the next requested session', () async {
    final gate = Completer<bool>();
    final speech = _FakeSpeech()..initializationGate = gate;
    final service = DeviceVoiceSearchService(speech: speech);
    addTearDown(service.cancel);
    final first = listen(service);
    await Future<void>.delayed(Duration.zero);
    final canceling = service.cancel();
    final second = listen(service);
    gate.complete(true);
    await Future.wait([first, canceling, second]);
    expect(speech.listenCalls, 1);
    expect(speech.isListening, isTrue);
  });

  test(
    'unavailable permission setup can be retried without listening first',
    () async {
      final speech = _FakeSpeech()..initializeAvailable = false;
      final service = DeviceVoiceSearchService(speech: speech);
      addTearDown(service.cancel);
      await expectLater(listen(service), throwsA(isA<VoiceSearchException>()));
      expect(speech.listenCalls, 0);
      speech.initializeAvailable = true;
      await listen(service);
      expect(speech.initializations, 2);
      expect(speech.listenCalls, 1);
    },
  );

  test(
    'recognition errors are mapped and end the microphone session',
    () async {
      final speech = _FakeSpeech();
      final service = DeviceVoiceSearchService(speech: speech);
      addTearDown(service.cancel);
      final failures = <VoiceSearchFailure>[];
      for (final entry in {
        'error_permission': VoiceSearchFailure.permissionDenied,
        'error_no_match': VoiceSearchFailure.noSpeech,
        'error_network': VoiceSearchFailure.network,
        'error_language_unavailable': VoiceSearchFailure.language,
        'error_busy': VoiceSearchFailure.busy,
      }.entries) {
        await listen(service, error: failures.add);
        speech.errorListener!(SpeechRecognitionError(entry.key, true));
        await Future<void>.delayed(Duration.zero);
        expect(failures.last, entry.value);
        expect(speech.isListening, isFalse);
      }
    },
  );

  test(
    'stop keeps final results available and done releases the native session',
    () async {
      final speech = _FakeSpeech();
      final service = DeviceVoiceSearchService(speech: speech);
      final words = <String>[];
      final statuses = <VoiceSearchStatus>[];
      await listen(service, result: words.add, status: statuses.add);
      await service.stop();
      speech.emit('cà phê');
      speech.statusListener!(SpeechToText.doneStatus);
      await Future<void>.delayed(Duration.zero);
      expect(words, ['cà phê']);
      expect(statuses, contains(VoiceSearchStatus.done));
      expect(speech.cancelCalls, greaterThan(0));
      expect(speech.isListening, isFalse);
    },
  );
}

SpeechRecognitionResult _result(String words) => SpeechRecognitionResult([
  SpeechRecognitionWords(words, null, .9),
], ResultType.finalResult.value);

class _FakeSpeech extends SpeechToText {
  _FakeSpeech() : super.withMethodChannel();
  Completer<bool>? initializationGate;
  bool initializeAvailable = true;
  bool _available = false;
  bool _listening = false;
  int initializations = 0;
  int listenCalls = 0;
  int cancelCalls = 0;
  SpeechResultListener? resultListener;
  SpeechListenOptions? options;
  List<SpeechConfigOption>? config;

  @override
  bool get isAvailable => _available;
  @override
  bool get isListening => _listening;

  @override
  Future<bool> initialize({
    SpeechErrorListener? onError,
    SpeechStatusListener? onStatus,
    debugLogging = false,
    Duration finalTimeout = SpeechToText.defaultFinalTimeout,
    List<SpeechConfigOption>? options,
  }) async {
    initializations++;
    errorListener = onError;
    statusListener = onStatus;
    config = options;
    _available = initializationGate == null
        ? initializeAvailable
        : await initializationGate!.future;
    return _available;
  }

  @override
  Future<List<LocaleName>> locales() async => [
    LocaleName('en_US', 'English'),
    LocaleName('vi_VN', 'Tiếng Việt'),
  ];

  @override
  Future<void> listen({
    SpeechResultListener? onResult,
    Duration? listenFor,
    Duration? pauseFor,
    String? localeId,
    SpeechSoundLevelChange? onSoundLevelChange,
    cancelOnError = false,
    partialResults = true,
    onDevice = false,
    ListenMode listenMode = ListenMode.confirmation,
    sampleRate = 0,
    SpeechListenOptions? listenOptions,
  }) async {
    listenCalls++;
    resultListener = onResult;
    options = listenOptions;
    _listening = true;
    statusListener?.call(SpeechToText.listeningStatus);
  }

  void emit(String words) => resultListener?.call(_result(words));

  @override
  Future<void> stop() async {
    _listening = false;
    statusListener?.call(SpeechToText.notListeningStatus);
  }

  @override
  Future<void> cancel() async {
    cancelCalls++;
    _listening = false;
    statusListener?.call(SpeechToText.notListeningStatus);
  }
}

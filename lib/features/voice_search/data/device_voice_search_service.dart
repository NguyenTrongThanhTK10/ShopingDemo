import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../domain/voice_search_service.dart';

/// Owns the single speech recognizer and guards canceled startup operations.
class DeviceVoiceSearchService implements VoiceSearchService {
  DeviceVoiceSearchService({SpeechToText? speech})
    : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  Future<bool>? _initialization;
  Future<void> _operationQueue = Future.value();
  int _generation = 0;
  void Function(String)? _onResult;
  void Function(VoiceSearchStatus)? _onStatus;
  void Function(VoiceSearchFailure)? _onError;
  VoiceSearchFailure? _lastFailure;

  @override
  Future<void> start({
    required void Function(String words) onResult,
    required void Function(VoiceSearchStatus status) onStatus,
    required void Function(VoiceSearchFailure failure) onError,
  }) {
    final generation = ++_generation;
    final operation = _operationQueue.then(
      (_) => _start(
        generation: generation,
        onResult: onResult,
        onStatus: onStatus,
        onError: onError,
      ),
    );
    _operationQueue = operation.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return operation;
  }

  Future<void> _start({
    required int generation,
    required void Function(String) onResult,
    required void Function(VoiceSearchStatus) onStatus,
    required void Function(VoiceSearchFailure) onError,
  }) async {
    if (generation != _generation) return;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
      throw const VoiceSearchException(VoiceSearchFailure.unsupported);
    }
    await _cancelPlatform();
    if (generation != _generation) return;
    _onResult = onResult;
    _onStatus = onStatus;
    _onError = onError;
    _lastFailure = null;
    try {
      final available = await (_initialization ??= _speech.initialize(
        onStatus: _handleStatus,
        onError: (error) {
          final failure = _mapError(error.errorMsg);
          _lastFailure = failure;
          _onError?.call(failure);
          unawaited(cancel());
        },
        options: [SpeechToText.androidNoBluetooth],
      ));
      if (!available) _initialization = null;
      if (generation != _generation) return;
      if (!available) {
        throw VoiceSearchException(
          _lastFailure ?? VoiceSearchFailure.unavailable,
        );
      }
      final locales = await _speech.locales();
      if (generation != _generation) return;
      if (_lastFailure != null) throw VoiceSearchException(_lastFailure!);
      await _speech.listen(
        onResult: (result) {
          if (generation == _generation) {
            _onResult?.call(result.recognizedWords);
          }
        },
        listenOptions: SpeechListenOptions(
          localeId: vietnameseSpeechLocale(
            locales.map((locale) => locale.localeId),
          ),
          listenMode: ListenMode.search,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: true,
        ),
      );
      if (generation != _generation) {
        await _cancelPlatform();
      } else if (!_speech.isListening && _lastFailure == null) {
        _onStatus?.call(VoiceSearchStatus.stopped);
      }
    } on VoiceSearchException {
      rethrow;
    } on MissingPluginException {
      _initialization = null;
      throw const VoiceSearchException(VoiceSearchFailure.unsupported);
    } on PlatformException catch (error) {
      _initialization = null;
      throw VoiceSearchException(_mapError(error.code));
    } catch (_) {
      _initialization = null;
      throw const VoiceSearchException(VoiceSearchFailure.unknown);
    }
  }

  void _handleStatus(String status) {
    switch (status) {
      case SpeechToText.listeningStatus:
        _onStatus?.call(VoiceSearchStatus.listening);
      case SpeechToText.notListeningStatus:
        _onStatus?.call(VoiceSearchStatus.stopped);
      case SpeechToText.doneStatus:
        _onStatus?.call(VoiceSearchStatus.done);
        unawaited(cancel());
    }
  }

  @override
  Future<void> stop() {
    final generation = _generation;
    final operation = _operationQueue.then((_) async {
      if (generation == _generation && _speech.isAvailable) {
        await _speech.stop();
      }
    });
    _operationQueue = operation.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return operation;
  }

  @override
  Future<void> cancel() async {
    final generation = ++_generation;
    final pendingStart = _operationQueue;
    _onResult = null;
    _onStatus = null;
    _onError = null;
    await _cancelPlatform();
    await pendingStart;
    if (generation == _generation) await _cancelPlatform();
  }

  Future<void> _cancelPlatform() async {
    if (!_speech.isAvailable) return;
    try {
      await _speech.cancel();
    } catch (_) {
      // A canceled or already ended native session has no results to deliver.
    }
  }

  VoiceSearchFailure _mapError(String code) {
    final value = code.toLowerCase();
    if (value.contains('permission') ||
        value.contains('denied') ||
        value.contains('not_allowed')) {
      return VoiceSearchFailure.permissionDenied;
    }
    if (value.contains('no_match') || value.contains('speech_timeout')) {
      return VoiceSearchFailure.noSpeech;
    }
    if (value.contains('network') || value.contains('server')) {
      return VoiceSearchFailure.network;
    }
    if (value.contains('language') || value.contains('locale')) {
      return VoiceSearchFailure.language;
    }
    if (value.contains('busy')) return VoiceSearchFailure.busy;
    return VoiceSearchFailure.unknown;
  }
}

String vietnameseSpeechLocale(Iterable<String> locales) {
  final available = locales.toList();
  for (final locale in available) {
    if (locale.toLowerCase().replaceAll('_', '-') == 'vi-vn') return locale;
  }
  for (final locale in available) {
    final language = locale.toLowerCase().replaceAll('_', '-');
    if (language == 'vi' || language.startsWith('vi-')) return locale;
  }
  return 'vi-VN';
}

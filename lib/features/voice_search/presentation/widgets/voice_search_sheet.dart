import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/voice_search_service.dart';
import '../providers/voice_search_provider.dart';

Future<String?> showVoiceSearchSheet(BuildContext context) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => const _VoiceSearchSheet(),
    );

class _VoiceSearchSheet extends ConsumerStatefulWidget {
  const _VoiceSearchSheet();

  @override
  ConsumerState<_VoiceSearchSheet> createState() => _VoiceSearchSheetState();
}

class _VoiceSearchSheetState extends ConsumerState<_VoiceSearchSheet>
    with WidgetsBindingObserver {
  late final VoiceSearchService _service;
  bool _starting = true;
  bool _listening = false;
  bool _closing = false;
  int _generation = 0;
  String _words = '';
  VoiceSearchFailure? _error;

  @override
  void initState() {
    super.initState();
    _service = ref.read(voiceSearchServiceProvider);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_start());
    });
  }

  Future<void> _start() async {
    if (_closing) return;
    final generation = ++_generation;
    setState(() {
      _starting = true;
      _listening = false;
      _words = '';
      _error = null;
    });
    try {
      await _service.start(
        onResult: (words) {
          if (!mounted || _closing || generation != _generation) return;
          setState(() => _words = words.trim());
        },
        onStatus: (status) {
          if (!mounted || _closing || generation != _generation) return;
          setState(() {
            _starting = false;
            _listening = status == VoiceSearchStatus.listening;
            if (status == VoiceSearchStatus.done &&
                _words.isEmpty &&
                _error == null) {
              _error = VoiceSearchFailure.noSpeech;
            }
          });
        },
        onError: (failure) {
          if (!mounted || _closing || generation != _generation) return;
          ++_generation;
          unawaited(_service.cancel());
          setState(() {
            _starting = false;
            _listening = false;
            _error = failure;
          });
        },
      );
      if (mounted && !_closing && generation == _generation) {
        setState(() => _starting = false);
      }
    } catch (error) {
      if (!mounted || _closing || generation != _generation) return;
      setState(() {
        _starting = false;
        _listening = false;
        _error = error is VoiceSearchException
            ? error.failure
            : VoiceSearchFailure.unknown;
      });
    }
  }

  Future<void> _stop() async {
    try {
      await _service.stop();
      if (mounted && !_closing) setState(() => _listening = false);
    } catch (_) {
      ++_generation;
      unawaited(_service.cancel());
      if (mounted && !_closing) {
        setState(() {
          _listening = false;
          _error = VoiceSearchFailure.unknown;
        });
      }
    }
  }

  Future<void> _search() async {
    final query = _words.trim();
    if (_closing || query.isEmpty) return;
    setState(() => _closing = true);
    ++_generation;
    await _service.cancel();
    if (mounted) Navigator.of(context).pop(query);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      ++_generation;
      unawaited(_service.cancel());
      if (mounted && !_closing) {
        setState(() {
          _starting = false;
          _listening = false;
        });
      }
    }
  }

  @override
  void dispose() {
    ++_generation;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_service.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return PopScope<String>(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) return;
        _closing = true;
        ++_generation;
        unawaited(_service.cancel());
      },
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .8,
            maxWidth: 640,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tìm bằng giọng nói',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Đóng tìm kiếm giọng nói',
                      onPressed: _closing
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      shape: BoxShape.circle,
                    ),
                    child: _starting
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _listening
                                ? Icons.mic_rounded
                                : Icons.mic_none_rounded,
                            size: 38,
                            color: _listening
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _starting
                      ? 'Đang chuẩn bị micro...'
                      : _listening
                      ? 'Đang nghe...'
                      : 'Nói tên sản phẩm bạn muốn tìm',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Ví dụ: “tai nghe” hoặc “cà phê”',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                if (_words.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        _words,
                        key: const ValueKey('voice-search-transcript'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
                if (_error != null) ...[
                  Text(
                    _error!.message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _starting || _closing
                            ? null
                            : _listening
                            ? _stop
                            : _start,
                        icon: Icon(
                          _listening
                              ? Icons.stop_rounded
                              : Icons.refresh_rounded,
                          size: 18,
                        ),
                        label: Text(_listening ? 'Dừng nghe' : 'Nói lại'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('confirm-voice-search'),
                        onPressed: _words.isEmpty || _closing ? null : _search,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text('Tìm kiếm'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

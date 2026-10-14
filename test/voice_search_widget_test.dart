import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/app/theme/app_theme.dart';
import 'package:shopingdemo/features/catalog/presentation/product_list_screen.dart';
import 'package:shopingdemo/features/catalog/presentation/widgets/product_card.dart';
import 'package:shopingdemo/features/voice_search/domain/voice_search_service.dart';
import 'package:shopingdemo/features/voice_search/presentation/providers/voice_search_provider.dart';
import 'package:shopingdemo/main.dart';

Future<void> _pumpVoiceApp(
  WidgetTester tester,
  _FakeVoiceService service, {
  Widget? page,
  bool dark = false,
}) async {
  await tester.binding.setSurfaceSize(const Size(320, 720));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [voiceSearchServiceProvider.overrideWithValue(service)],
      child: page == null
          ? const LumiMarketApp()
          : MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
              home: page,
            ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'home microphone is inside the right of pinned search and searches recognized Vietnamese',
    (tester) async {
      final service = _FakeVoiceService();
      await _pumpVoiceApp(tester, service);
      final mic = find.byTooltip('Tìm kiếm bằng giọng nói');
      final search = tester.getRect(find.byKey(const ValueKey('home-search')));
      final microphone = tester.getRect(mic);
      expect(search.contains(microphone.center), isTrue);
      expect(microphone.center.dx, greaterThan(search.center.dx));
      await tester.drag(
        find.byKey(const ValueKey('home-feed')),
        const Offset(0, -650),
      );
      await tester.pumpAndSettle();
      expect(mic.hitTestable(), findsOneWidget);
      await tester.tap(mic);
      await tester.pumpAndSettle();
      expect(find.text('Đang nghe...'), findsOneWidget);
      expect(service.startCalls, 1);
      service.result!('  Cà phê  ');
      service.status!(VoiceSearchStatus.done);
      await tester.pumpAndSettle();
      expect(find.text('Cà phê'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('confirm-voice-search')));
      await tester.pumpAndSettle();
      expect(find.byType(ProductListScreen), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Cà phê',
      );
      expect(find.text('Cà phê hạt rang mộc 250g'), findsOneWidget);
      expect(find.byType(ProductCard), findsOneWidget);
      expect(service.cancelCalls, greaterThan(0));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'listing voice search preserves a typed query on cancel and replaces it on confirmation',
    (tester) async {
      final service = _FakeVoiceService();
      await _pumpVoiceApp(
        tester,
        service,
        page: const ProductListScreen(initialQuery: 'tai nghe'),
      );
      await tester.tap(find.byTooltip('Tìm kiếm bằng giọng nói'));
      await tester.pumpAndSettle();
      final lateResult = service.result!;
      service.result!('serum');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Đóng tìm kiếm giọng nói'));
      await tester.pumpAndSettle();
      lateResult('late result');
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'tai nghe',
      );
      await tester.tap(find.byTooltip('Tìm kiếm bằng giọng nói'));
      await tester.pumpAndSettle();
      service.result!('serum');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirm-voice-search')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'serum',
      );
      expect(find.text('Serum cấp ẩm Dew Drop'), findsOneWidget);
      expect(find.byType(ProductCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('failed stop cancels recognition before retrying', (
    tester,
  ) async {
    final service = _FakeVoiceService()..failStop = true;
    await _pumpVoiceApp(tester, service, page: const ProductListScreen());
    await tester.tap(find.byTooltip('Tìm kiếm bằng giọng nói'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dừng nghe'));
    await tester.pumpAndSettle();
    expect(service.cancelCalls, greaterThan(0));
    expect(find.text(VoiceSearchFailure.unknown.message), findsOneWidget);
    expect(find.text('Đang nghe...'), findsNothing);
    service.failStop = false;
    await tester.tap(find.text('Nói lại'));
    await tester.pumpAndSettle();
    expect(find.text('Đang nghe...'), findsOneWidget);
    await tester.tap(find.byTooltip('Đóng tìm kiếm giọng nói'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final failure in [
    VoiceSearchFailure.permissionDenied,
    VoiceSearchFailure.unavailable,
    VoiceSearchFailure.network,
  ]) {
    testWidgets(
      'voice ${failure.name} error can be retried without changing the search',
      (tester) async {
        final service = _FakeVoiceService()..failure = failure;
        await _pumpVoiceApp(
          tester,
          service,
          page: const ProductListScreen(initialQuery: 'cà phê'),
          dark: true,
        );
        await tester.tap(find.byTooltip('Tìm kiếm bằng giọng nói'));
        await tester.pumpAndSettle();
        expect(find.text(failure.message), findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const ValueKey('confirm-voice-search')),
              )
              .onPressed,
          isNull,
        );
        service.failure = null;
        await tester.tap(find.text('Nói lại'));
        await tester.pumpAndSettle();
        service.status!(VoiceSearchStatus.done);
        await tester.pumpAndSettle();
        expect(find.text(VoiceSearchFailure.noSpeech.message), findsOneWidget);
        await tester.tap(find.text('Nói lại'));
        await tester.pumpAndSettle();
        service.result!('tai nghe');
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('confirm-voice-search')));
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'tai nghe',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'closing pending initialization and pausing the app cancel voice listening',
    (tester) async {
      final service = _FakeVoiceService()..startGate = Completer<void>();
      await _pumpVoiceApp(tester, service, page: const ProductListScreen());
      await tester.tap(find.byTooltip('Tìm kiếm bằng giọng nói'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Đang chuẩn bị micro...'), findsOneWidget);
      await tester.tap(find.byTooltip('Đóng tìm kiếm giọng nói'));
      await tester.pumpAndSettle();
      final lateStatus = service.status!;
      service.startGate!.complete();
      await tester.pumpAndSettle();
      lateStatus(VoiceSearchStatus.listening);
      await tester.pumpAndSettle();
      expect(service.cancelCalls, greaterThan(0));
      service.startGate = null;
      await tester.tap(find.byTooltip('Tìm kiếm bằng giọng nói'));
      await tester.pumpAndSettle();
      final cancellations = service.cancelCalls;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      expect(service.cancelCalls, greaterThan(cancellations));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('Đang nghe...'), findsNothing);
      await tester.tap(find.byTooltip('Đóng tìm kiếm giọng nói'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}

class _FakeVoiceService implements VoiceSearchService {
  int startCalls = 0;
  int cancelCalls = 0;
  VoiceSearchFailure? failure;
  bool failStop = false;
  Completer<void>? startGate;
  void Function(String)? result;
  void Function(VoiceSearchStatus)? status;
  void Function(VoiceSearchFailure)? error;

  @override
  Future<void> start({
    required void Function(String) onResult,
    required void Function(VoiceSearchStatus) onStatus,
    required void Function(VoiceSearchFailure) onError,
  }) async {
    startCalls++;
    result = onResult;
    status = onStatus;
    error = onError;
    if (failure != null) throw VoiceSearchException(failure!);
    if (startGate != null) await startGate!.future;
    onStatus(VoiceSearchStatus.listening);
  }

  @override
  Future<void> stop() async {
    if (failStop) throw Exception('Simulated stop failure');
    status?.call(VoiceSearchStatus.stopped);
  }

  @override
  Future<void> cancel() async {
    cancelCalls++;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/demo_account.dart';

final demoAccountProvider = NotifierProvider<DemoAccountNotifier, DemoAccount?>(
  DemoAccountNotifier.new,
);

class DemoAccountNotifier extends Notifier<DemoAccount?> {
  @override
  DemoAccount? build() => null;

  void save(DemoAccount account) => state = account;

  void signOut() => state = null;
}

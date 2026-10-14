import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationReadProvider =
    NotifierProvider<NotificationReadNotifier, Set<String>>(
      NotificationReadNotifier.new,
    );

class NotificationReadNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {'mori-live', 'serum', 'welcome'};

  void markRead(String id) => state = {...state, id};

  void markAllRead(Iterable<String> ids) => state = {...state, ...ids};
}

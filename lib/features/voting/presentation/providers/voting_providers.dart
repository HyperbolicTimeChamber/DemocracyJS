import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/web_socket_event.dart';

final webSocketEventsProvider = StreamProvider<WebSocketEvent>((ref) {
  // Will be overridden when server starts
  return const Stream.empty();
});

final liveResultsProvider =
    StateNotifierProvider<LiveResultsNotifier, Poll?>((ref) {
  return LiveResultsNotifier();
});

class LiveResultsNotifier extends StateNotifier<Poll?> {
  LiveResultsNotifier() : super(null);

  void update(Poll poll) {
    state = poll;
  }

  void clear() {
    state = null;
  }
}

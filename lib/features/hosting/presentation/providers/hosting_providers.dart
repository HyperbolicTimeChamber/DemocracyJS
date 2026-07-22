import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_poll/core/constants/app_constants.dart';
import 'package:local_poll/core/enums/event_type.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/server_status.dart';
import 'package:local_poll/features/hosting/data/server/local_server_impl.dart';
import 'package:local_poll/features/poll/domain/entities/web_socket_event.dart';
import 'package:local_poll/features/poll/presentation/providers/poll_providers.dart';
import 'package:local_poll/features/poll/domain/usecases/submit_vote.dart';
import 'package:local_poll/features/voting/domain/usecases/process_vote.dart';
import 'package:local_poll/shared/services/mdns_service.dart';
import 'package:local_poll/shared/services/network_service.dart';

final localServerProvider = Provider<ShelfLocalServer>((ref) {
  final processVote = ProcessVote();
  final submitVoteUseCase = SubmitVote();

  // Local reference used by callbacks to broadcast without re-reading the
  // provider recursively. Nulled on dispose to prevent stale references.
  ShelfLocalServer? serverRef;

  final server = ShelfLocalServer(
    getPoll: () => ref.read(currentPollProvider)!,
    onVote: (optionIds, ip) async {
      final repo = ref.read(pollRepositoryProvider);
      final poll = ref.read(currentPollProvider);
      if (poll == null) return false;

      // Block votes when the poll is not actively hosting (e.g. paused).
      if (poll.status != PollStatus.hosting) return false;

      final alreadyVoted = await repo.hasVoted(poll.id, ip);
      if (alreadyVoted) return false;

      final vote = submitVoteUseCase(
        pollId: poll.id,
        optionIds: optionIds,
        voterIp: ip,
      );
      await repo.submitVote(vote);

      final updatedPoll = processVote(poll: poll, vote: vote);
      await repo.updatePoll(updatedPoll);
      ref.read(currentPollProvider.notifier).updatePoll(updatedPoll);

      // Broadcast results update via captured server reference.
      serverRef?.broadcastEvent(WebSocketEvent(
        type: EventType.resultsUpdated,
        data: {
          'options': updatedPoll.options
              .map((o) => {'id': o.id, 'text': o.text, 'voteCount': o.voteCount})
              .toList(),
          'totalVotes': updatedPoll.options.fold<int>(0, (sum, o) => sum + o.voteCount),
        },
      ));
      serverRef?.broadcastEvent(WebSocketEvent(
        type: EventType.voteSubmitted,
        data: {
          'totalVotes': updatedPoll.options.fold<int>(0, (sum, o) => sum + o.voteCount),
        },
      ));

      return true;
    },
    onClientCountChanged: (count) {
      ref.read(connectedClientsProvider.notifier).update(count);
    },
  );

  serverRef = server;

  ref.onDispose(() {
    serverRef = null;
  });

  return server;
});

final mdnsServiceProvider = Provider<MdnsService>((ref) {
  return MdnsService();
});

final serverStatusProvider =
    StateNotifierProvider<ServerStatusNotifier, ServerStatus>((ref) {
  return ServerStatusNotifier();
});

class ServerStatusNotifier extends StateNotifier<ServerStatus> {
  ServerStatusNotifier() : super(ServerStatus.stopped);

  void update(ServerStatus status) {
    state = status;
  }
}

final networkInfoProvider = FutureProvider<String?>((ref) async {
  final service = NetworkService();
  return await service.getLocalIp();
});

final serverPortProvider =
    StateNotifierProvider<ServerPortNotifier, int>((ref) {
  return ServerPortNotifier();
});

class ServerPortNotifier extends StateNotifier<int> {
  ServerPortNotifier() : super(AppConstants.defaultServerPort);

  void update(int port) {
    state = port;
  }
}

final connectedClientsProvider =
    StateNotifierProvider<ConnectedClientsNotifier, int>((ref) {
  return ConnectedClientsNotifier();
});

class ConnectedClientsNotifier extends StateNotifier<int> {
  ConnectedClientsNotifier() : super(0);

  void update(int count) {
    state = count;
  }

  void increment() {
    state = state + 1;
  }

  void decrement() {
    if (state > 0) state = state - 1;
  }

  void reset() {
    state = 0;
  }
}

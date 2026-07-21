import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/features/poll/data/repositories/poll_repository_impl.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/repositories/poll_repository.dart';
import 'package:local_poll/features/poll/domain/usecases/create_poll.dart';
import 'package:local_poll/features/poll/domain/usecases/add_option.dart';
import 'package:local_poll/features/poll/domain/usecases/remove_option.dart';
import 'package:local_poll/shared/services/hive_storage_service.dart';

final hiveStorageServiceProvider = Provider<HiveStorageService>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final pollRepositoryProvider = Provider<PollRepository>((ref) {
  final storage = ref.watch(hiveStorageServiceProvider);
  return PollRepositoryImpl(
    pollsBox: storage.pollsBox,
    votesBox: storage.votesBox,
  );
});

final pollListProvider =
    StateNotifierProvider<PollListNotifier, AsyncValue<List<Poll>>>((ref) {
  final repository = ref.watch(pollRepositoryProvider);
  return PollListNotifier(repository);
});

class PollListNotifier extends StateNotifier<AsyncValue<List<Poll>>> {
  PollListNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final PollRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final polls = await _repository.getAllPolls();
      state = AsyncValue.data(polls);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addPoll(Poll poll) async {
    await _repository.createPoll(poll);
    await load();
  }

  Future<void> removePoll(String id) async {
    await _repository.deletePoll(id);
    await load();
  }
}

final currentPollProvider =
    StateNotifierProvider<CurrentPollNotifier, Poll?>((ref) {
  return CurrentPollNotifier();
});

class CurrentPollNotifier extends StateNotifier<Poll?> {
  CurrentPollNotifier() : super(null);

  final _createPoll = CreatePoll();
  final _addOption = AddOption();
  final _removeOption = RemoveOption();

  void create({
    required String question,
    required VoteMode voteMode,
    required ResultsVisibility resultsVisibility,
  }) {
    state = _createPoll(
      question: question,
      voteMode: voteMode,
      resultsVisibility: resultsVisibility,
    );
  }

  void addOption(String text) {
    if (state == null) return;
    state = _addOption(poll: state!, text: text);
  }

  void removeOption(String optionId) {
    if (state == null) return;
    state = _removeOption(poll: state!, optionId: optionId);
  }

  void updateStatus(PollStatus status) {
    if (state == null) return;
    state = state!.copyWith(status: status, updatedAt: DateTime.now());
  }

  void updatePoll(Poll poll) {
    state = poll;
  }

  void clear() {
    state = null;
  }
}

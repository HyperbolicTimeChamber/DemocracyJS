import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:local_poll/features/poll/data/models/poll_model.dart';
import 'package:local_poll/features/poll/data/models/vote_model.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/vote.dart';
import 'package:local_poll/features/poll/domain/repositories/poll_repository.dart';

class PollRepositoryImpl implements PollRepository {
  PollRepositoryImpl({required this.pollsBox, required this.votesBox});

  final Box pollsBox;
  final Box votesBox;

  @override
  Future<Poll> createPoll(Poll poll) async {
    final model = PollModel.fromEntity(poll);
    await pollsBox.put(poll.id, jsonEncode(model.toJson()));
    return poll;
  }

  @override
  Future<Poll?> getPoll(String id) async {
    final raw = pollsBox.get(id);
    if (raw == null) return null;
    final model = PollModel.fromJson(jsonDecode(raw as String) as Map<String, dynamic>);
    return model.toEntity();
  }

  @override
  Future<List<Poll>> getAllPolls() async {
    return pollsBox.values.map((raw) {
      final model = PollModel.fromJson(jsonDecode(raw as String) as Map<String, dynamic>);
      return model.toEntity();
    }).toList();
  }

  @override
  Future<Poll> updatePoll(Poll poll) async {
    final model = PollModel.fromEntity(poll);
    await pollsBox.put(poll.id, jsonEncode(model.toJson()));
    return poll;
  }

  @override
  Future<void> deletePoll(String id) async {
    await pollsBox.delete(id);
    final voteKeys = votesBox.keys.where((key) => (key as String).startsWith('$id:')).toList();
    for (final key in voteKeys) {
      await votesBox.delete(key);
    }
  }

  @override
  Future<Vote> submitVote(Vote vote) async {
    final model = VoteModel.fromEntity(vote);
    final key = '${vote.pollId}:${vote.voterIp}';
    await votesBox.put(key, jsonEncode(model.toJson()));
    return vote;
  }

  @override
  Future<List<Vote>> getVotesForPoll(String id) async {
    final votes = <Vote>[];
    for (final key in votesBox.keys) {
      if ((key as String).startsWith('$id:')) {
        final raw = votesBox.get(key);
        final model = VoteModel.fromJson(jsonDecode(raw as String) as Map<String, dynamic>);
        votes.add(model.toEntity());
      }
    }
    return votes;
  }

  @override
  Future<bool> hasVoted(String pollId, String voterIp) async {
    final key = '$pollId:$voterIp';
    return votesBox.containsKey(key);
  }
}

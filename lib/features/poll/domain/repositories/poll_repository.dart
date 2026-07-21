import '../entities/poll.dart';
import '../entities/vote.dart';

abstract class PollRepository {
  Future<Poll> createPoll(Poll poll);
  Future<Poll?> getPoll(String id);
  Future<List<Poll>> getAllPolls();
  Future<Poll> updatePoll(Poll poll);
  Future<void> deletePoll(String id);
  Future<Vote> submitVote(Vote vote);
  Future<List<Vote>> getVotesForPoll(String id);
  Future<bool> hasVoted(String pollId, String voterIp);
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:democracy_js/app.dart';
import 'package:democracy_js/features/poll/domain/entities/poll.dart';
import 'package:democracy_js/features/poll/domain/entities/vote.dart';
import 'package:democracy_js/features/poll/domain/repositories/poll_repository.dart';
import 'package:democracy_js/features/poll/presentation/providers/poll_providers.dart';

void main() {
  testWidgets('App smoke test - renders DemocracyJS text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pollListProvider.overrideWith((ref) {
            final notifier = PollListNotifier(_FakeRepo());
            notifier.state = const AsyncValue.data([]);
            return notifier;
          }),
        ],
        child: const DemocracyJSApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('DemocracyJS'), findsOneWidget);
  });
}

class _FakeRepo implements PollRepository {
  @override
  Future<Poll> createPoll(Poll poll) async => poll;
  @override
  Future<void> deletePoll(String id) async {}
  @override
  Future<List<Poll>> getAllPolls() async => [];
  @override
  Future<Poll?> getPoll(String id) async => null;
  @override
  Future<List<Vote>> getVotesForPoll(String id) async => [];
  @override
  Future<bool> hasVoted(String pollId, String voterIp) async => false;
  @override
  Future<Vote> submitVote(Vote vote) async => vote;
  @override
  Future<Poll> updatePoll(Poll poll) async => poll;
}

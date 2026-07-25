import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:democracy_js/features/poll/presentation/providers/poll_providers.dart';
import 'package:democracy_js/features/poll/presentation/screens/home_screen.dart';
import 'package:democracy_js/features/poll/domain/entities/poll.dart';
import 'package:democracy_js/features/poll/domain/repositories/poll_repository.dart';
import 'package:democracy_js/features/poll/domain/entities/vote.dart';
import 'package:democracy_js/core/enums/poll_status.dart';
import 'package:democracy_js/core/enums/vote_mode.dart';
import 'package:democracy_js/core/enums/results_visibility.dart';

void main() {
  Widget wrap(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );
  }

  group('HomeScreen', () {
    testWidgets('shows empty state when no polls', (tester) async {
      await tester.pumpWidget(wrap(
        const HomeScreen(),
        overrides: [
          pollListProvider.overrideWith((ref) {
            return PollListNotifierStub([]);
          }),
        ],
      ));
      await tester.pumpAndSettle();
      expect(find.text('No polls yet'), findsOneWidget);
    });

    testWidgets('shows FAB to create poll', (tester) async {
      await tester.pumpWidget(wrap(
        const HomeScreen(),
        overrides: [
          pollListProvider.overrideWith((ref) {
            return PollListNotifierStub([]);
          }),
        ],
      ));
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}

class PollListNotifierStub extends PollListNotifier {
  PollListNotifierStub(List<Poll> polls) : super(_FakeRepo()) {
    state = AsyncValue.data(polls);
  }
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

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:democracy_js/core/enums/poll_status.dart';
import 'package:democracy_js/core/enums/vote_mode.dart';
import 'package:democracy_js/core/enums/results_visibility.dart';
import 'package:democracy_js/features/hosting/data/server/api_handler.dart';
import 'package:democracy_js/features/poll/domain/entities/poll.dart';
import 'package:democracy_js/features/poll/domain/entities/poll_option.dart';
import 'package:shelf/shelf.dart';

void main() {
  late ApiHandler handler;
  late Poll testPoll;

  setUp(() {
    final now = DateTime.now();
    testPoll = Poll(
      id: 'p1',
      question: 'Best?',
      options: const [
        PollOption(id: 'o1', text: 'A', voteCount: 0),
        PollOption(id: 'o2', text: 'B', voteCount: 0),
      ],
      status: PollStatus.hosting,
      voteMode: VoteMode.singleChoice,
      resultsVisibility: ResultsVisibility.afterVote,
      createdAt: now,
      updatedAt: now,
    );
    handler = ApiHandler(
      getPoll: () => testPoll,
      onVote: (optionIds, ip) async => true,
      getClientCount: () => 2,
    );
  });

  group('ApiHandler', () {
    test('GET /api/poll returns poll JSON', () async {
      final request = Request('GET', Uri.parse('http://localhost/api/poll'));
      final response = await handler.router.call(request);

      expect(response.statusCode, 200);
      final body =
          jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['question'], 'Best?');
      expect(body['options'], hasLength(2));
    });

    test('GET /api/status returns server status', () async {
      final request = Request('GET', Uri.parse('http://localhost/api/status'));
      final response = await handler.router.call(request);

      expect(response.statusCode, 200);
      final body =
          jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['status'], 'running');
      expect(body['connectedClients'], 2);
    });

    test('POST /api/vote accepts valid vote', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/api/vote'),
        body: jsonEncode({'optionIds': ['o1']}),
        headers: {'content-type': 'application/json'},
      );
      final response = await handler.router.call(request);

      expect(response.statusCode, 200);
      final body =
          jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['success'], true);
    });
  });
}
